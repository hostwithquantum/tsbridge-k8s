SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

MODULE_DIR   := ./modules/tsbridge
BUNDLE_FILE  := ./setup/bundle.cue
NAMESPACE    := tsbridge
DIST_DIR     := ./dist
MANIFESTS    := $(DIST_DIR)/manifests.yaml
KIND_CLUSTER := tsbridge-dev
KUBE_VERSION := 1.33.0

.PHONY: help lint build test run-dev setup teardown clean
.DEFAULT_GOAL := help

help: ## show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

lint: ## cue fmt check
	cd $(MODULE_DIR) && cue fmt --check ./...
	cue fmt --check $(BUNDLE_FILE)

# Dummy credentials, only used to render/vet locally and in CI.
TEST_ENV := TS_OAUTH_CLIENT_ID=test TS_OAUTH_CLIENT_SECRET=test

build: ## render manifests to dist/
	mkdir -p $(DIST_DIR)
	$(TEST_ENV) TIMONI_KUBE_VERSION=$(KUBE_VERSION) timoni bundle build -f $(BUNDLE_FILE) --runtime-from-env > $(MANIFESTS)

test: build ## mod vet + bundle vet + kubeconform
	TIMONI_KUBE_VERSION=$(KUBE_VERSION) timoni mod vet $(MODULE_DIR) --debug
	$(TEST_ENV) timoni bundle vet -f $(BUNDLE_FILE) --runtime-from-env
	kubeconform -kubernetes-version $(KUBE_VERSION) -strict -summary $(MANIFESTS)

run-dev: ## apply bundle to current context, creds from env (TS_OAUTH_CLIENT_ID, TS_OAUTH_CLIENT_SECRET)
	kubectl get namespace $(NAMESPACE) >/dev/null 2>&1 || kubectl create namespace $(NAMESPACE)
	timoni bundle apply -f $(BUNDLE_FILE) --runtime-from-env

setup: ## create kind cluster
	kind get clusters 2>/dev/null | grep -qx $(KIND_CLUSTER) || kind create cluster --name $(KIND_CLUSTER)
	kubectl config use-context kind-$(KIND_CLUSTER)

teardown: ## delete kind cluster
	kind delete cluster --name $(KIND_CLUSTER)

clean: ## delete dist/
	rm -rf $(DIST_DIR)
