package holos

// Manage on every Cluster in the Platform
for Fleet in #Fleets {
	for Cluster in Fleet.clusters {
		#Platform: Components: "\(Cluster.name):gateway-api": {
			name:      "gateway-api"
			component: "projects/platform/components/gateway-api"
			cluster:   Cluster.name
		}
	}
}
