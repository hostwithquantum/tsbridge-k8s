package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#Deployment: appsv1.#Deployment & {
	#config:     #Config
	#cmName:     string
	#secretName: string

	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   #config.metadata
	spec: appsv1.#DeploymentSpec & {
		// One instance per tailnet node set; the state volume is RWO.
		replicas: 1
		strategy: type:        "Recreate"
		selector: matchLabels: #config.selector.labels
		template: {
			metadata: labels: #config.selector.labels
			spec: corev1.#PodSpec & {
				automountServiceAccountToken: false
				securityContext: {
					runAsNonRoot: true
					runAsUser:    65532
					runAsGroup:   65532
					fsGroup:      65532
				}
				containers: [{
					name:            "tsbridge"
					image:           #config.image.reference
					imagePullPolicy: #config.image.pullPolicy
					args: ["-config", "/etc/tsbridge/tsbridge.toml"]
					env: [{name: "HOME", value: "/tmp"}]
					envFrom: [{secretRef: name: #secretName}]
					volumeMounts: [
						{name: "config", mountPath: "/etc/tsbridge", readOnly: true},
						{name: "state", mountPath: #config.config.tailscale.state_dir},
						{name: "tmp", mountPath: "/tmp"},
					]
					resources: #config.resources
					securityContext: {
						allowPrivilegeEscalation: false
						readOnlyRootFilesystem:   true
						capabilities: drop: ["ALL"]
					}
				}]
				volumes: [
					{name: "config", configMap: name: #cmName},
					{name: "state", persistentVolumeClaim: claimName: #config.metadata.name},
					{name: "tmp", emptyDir: {}},
				]
			}
		}
	}
}
