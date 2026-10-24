@if(debug)

package main

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	auth: {
		oauthClientId:     "debug-id"
		oauthClientSecret: "debug-secret"
	}
	config: {
		tailscale: default_tags: ["tag:server"]
		services: [{
			name:         "whoami"
			backend_addr: "whoami.default.svc.cluster.local:80"
		}]
	}
}
