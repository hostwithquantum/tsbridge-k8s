package main

// The container image tracked from the upstream releases.
// Bump tag and digest together.
values: image: {
	repository: *"ghcr.io/jtdowney/tsbridge" | string
	tag:        *"v0.15.1" | string
	digest:     *"sha256:b4a4ceb3fb84be43890ba0cbd51c808f2ddf5a81790b30bcced4a5741ea92121" | string
}
