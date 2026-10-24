package templates

import (
	"encoding/toml"

	timoniv1 "timoni.sh/core/v1alpha1"
)

#ConfigMap: timoniv1.#ImmutableConfig & {
	#config: #Config
	#Kind:   timoniv1.#ConfigMapKind
	#Meta:   #config.metadata
	#Data: "tsbridge.toml": toml.Marshal(#config.config)
}
