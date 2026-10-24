bundle: {
	apiVersion: "v1alpha1"
	name:       "tsbridge"
	instances: {
		"tsbridge": {
			module: url: "file://../modules/tsbridge"
			namespace: "tsbridge"
			values: {
				auth: {
					oauthClientId:     string @timoni(runtime:string:TS_OAUTH_CLIENT_ID)
					oauthClientSecret: string @timoni(runtime:string:TS_OAUTH_CLIENT_SECRET)
				}
				config: {
					tailscale: default_tags: ["tag:server"]
					services: [{
						name:         "whoami"
						backend_addr: "whoami.default.svc.cluster.local:80"
					}]
				}
			}
		}
	}
}
