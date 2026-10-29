package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	kubeVersion!: string
	clusterVersion: timoniv1.#SemVer & {#Version: kubeVersion, #Minimum: "1.20.0"}
	moduleVersion!: string

	metadata: timoniv1.#Metadata & {#Version: moduleVersion}
	metadata: labels:       timoniv1.#Labels
	metadata: annotations?: timoniv1.#Annotations
	selector: timoniv1.#Selector & {#Name: metadata.name}

	// Defaults are set in images.cue.
	image!: timoniv1.#Image

	// Tailscale credentials: an OAuth client or an auth key.
	// Rendered into a Secret and loaded as env.
	auth!: close({
		oauthClientId!:     string
		oauthClientSecret!: string
	}) | close({
		authKey!: string
	})

	// tsbridge.toml, see https://github.com/jtdowney/tsbridge/blob/main/docs/configuration-reference.md
	config: {
		tailscale: {
			state_dir: "/var/lib/tsbridge"
			default_tags!: [...string]
			...
		}
		services!: [...{
			name!:         string
			backend_addr!: string
			...
		}]
		...
	}

	// Size of the volume for the tailscale state.
	storage: *"1Gi" | string

	// Storage class for the state volume, cluster default if unset.
	storageClassName?: string

	resources: timoniv1.#ResourceRequirements & {
		requests: {
			cpu:    *"10m" | timoniv1.#CPUQuantity
			memory: *"64Mi" | timoniv1.#MemoryQuantity
		}
	}
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		cm: #ConfigMap & {#config: config}
		secret: #Secret & {#config: config}
		pvc: #PVC & {#config: config}
		deploy: #Deployment & {
			#config:     config
			#cmName:     objects.cm.metadata.name
			#secretName: objects.secret.metadata.name
		}
	}
}
