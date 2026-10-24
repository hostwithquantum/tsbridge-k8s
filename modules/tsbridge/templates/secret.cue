package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

#Secret: timoniv1.#ImmutableConfig & {
	#config: #Config
	#Kind:   timoniv1.#SecretKind
	#Meta:   #config.metadata
	#Suffix: "-auth"
	#Data: {
		if #config.auth.authKey != _|_ {
			TS_AUTHKEY: #config.auth.authKey
		}
		if #config.auth.oauthClientId != _|_ {
			TS_OAUTH_CLIENT_ID:     #config.auth.oauthClientId
			TS_OAUTH_CLIENT_SECRET: #config.auth.oauthClientSecret
		}
	}
}
