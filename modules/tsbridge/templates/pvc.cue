package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#PVC: corev1.#PersistentVolumeClaim & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata:   #config.metadata
	spec: {
		accessModes: ["ReadWriteOnce"]
		resources: requests: storage: #config.storage
		if #config.storageClassName != _|_ {
			storageClassName: #config.storageClassName
		}
	}
}
