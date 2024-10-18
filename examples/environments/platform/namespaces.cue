package holos

// Manage the Component on every Cluster in the Platform
for Fleet in #Fleets {
	for Cluster in Fleet.clusters {
		#Platform: Components: "\(Cluster.name):namespaces": {
			name:      "namespaces"
			component: "projects/platform/components/namespaces"
			cluster:   Cluster.name
		}
	}
}