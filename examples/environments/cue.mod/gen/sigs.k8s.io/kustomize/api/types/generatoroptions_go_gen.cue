// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go sigs.k8s.io/kustomize/api/types

package types

// GeneratorOptions modify behavior of all ConfigMap and Secret generators.
#GeneratorOptions: {
	// Labels to add to all generated resources.
	labels?: {[string]: string} @go(Labels,map[string]string)

	// Annotations to add to all generated resources.
	annotations?: {[string]: string} @go(Annotations,map[string]string)

	// DisableNameSuffixHash if true disables the default behavior of adding a
	// suffix to the names of generated resources that is a hash of the
	// resource contents.
	disableNameSuffixHash?: bool @go(DisableNameSuffixHash)

	// Immutable if true add to all generated resources.
	immutable?: bool @go(Immutable)
}
