# tsbridge-k8s

[Timoni](https://timoni.sh) module for [tsbridge](https://github.com/jtdowney/tsbridge).

Renders a ConfigMap (`tsbridge.toml`), a Secret (credentials), a PVC
(tailscale state) and a Deployment.

## Usage

Keep credentials out of values files. Inject them at runtime from env
with a bundle:

```cue
// bundle.cue
bundle: {
	apiVersion: "v1alpha1"
	name:       "tsbridge"
	instances: tsbridge: {
		module: url: "oci://ghcr.io/<owner>/modules/tsbridge"
		namespace: "tsbridge"
		values: {
			auth: {
				oauthClientId:     string @timoni(runtime:string:TS_OAUTH_CLIENT_ID)
				oauthClientSecret: string @timoni(runtime:string:TS_OAUTH_CLIENT_SECRET)
			}
			// or, with an auth key:
			// auth: authKey: string @timoni(runtime:string:TS_AUTHKEY)
			config: {
				tailscale: default_tags: ["tag:server"]
				services: [{
					name:         "api"
					backend_addr: "api.default.svc.cluster.local:80"
				}]
			}
		}
	}
}
```

```sh
export TS_OAUTH_CLIENT_ID=... TS_OAUTH_CLIENT_SECRET=...
timoni bundle apply -f bundle.cue --runtime-from-env
```

Instead of env, `--runtime` also takes a Runtime file that reads
values from a Kubernetes Secret, see
[timoni runtime docs](https://timoni.sh/bundle-runtime/).

`config` is rendered as-is to TOML, so any option from the
[configuration reference](https://github.com/jtdowney/tsbridge/blob/main/docs/configuration-reference.md)
works. Optional: `storage` (default `1Gi`), `resources`, `image`.

## Development

```sh
make lint test   # cue fmt, timoni vet, kubeconform
make setup       # kind cluster
make run-dev     # apply setup/bundle.cue, creds from TS_OAUTH_CLIENT_ID/SECRET env
```

Release: push a tag like `0.1.0`.

## License

MPL-2.0, see [LICENSE](LICENSE).
