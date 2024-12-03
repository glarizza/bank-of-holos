package holos

// Produce a kubernetes objects build plan.
holos: Component.BuildPlan

let BankName = BankOfHolos.Name
let BackendNamespace = BankOfHolos.configuration.environments[EnvironmentName].backend.namespace

let CommonLabels = {
	application: BankName
	environment: EnvironmentName
	team:        "ledger"
	tier:        "backend"
}

Component: #Kubernetes & {
	Namespace: BackendNamespace

	// Ensure resources go in the correct namespace
	Resources: [_]: [_]: metadata: namespace: Namespace
	Resources: [_]: [_]: metadata: labels:    CommonLabels

	// https://github.com/GoogleCloudPlatform/bank-of-anthos/blob/release/v0.6.5/kubernetes-manifests
	Resources: {
		Service: balancereader: {
			apiVersion: "v1"
			kind:       "Service"
			metadata: {
				name:   "balancereader"
				labels: CommonLabels
			}
			spec: {
				ports: [{
					name:       "http"
					port:       8080
					targetPort: 8080
				}]
				selector: {
					app: "balancereader"
					CommonLabels
				}
				type: "ClusterIP"
			}
		}

		Deployment: balancereader: {
			apiVersion: "apps/v1"
			kind:       "Deployment"
			metadata: {
				name:   "balancereader"
				labels: CommonLabels
			}
			spec: {
				selector: matchLabels: {
					app: "balancereader"
					CommonLabels
				}
				template: {
					metadata: labels: {
						app: "balancereader"
						CommonLabels
					}
					spec: {
						containers: [{
							env: [{
								name:  "VERSION"
								value: "v0.6.5"
							}, {
								name:  "PORT"
								value: "8080"
							}, {
								name:  "ENABLE_TRACING"
								value: "false"
							}, {
								name:  "ENABLE_METRICS"
								value: "false"
							}, {
								name:  "POLL_MS"
								value: "100"
							}, {
								name:  "CACHE_SIZE"
								value: "1000000"
							}, {
								name:  "JVM_OPTS"
								value: "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -Xms256m -Xmx512m"
							}, {
								name:  "LOG_LEVEL"
								value: "info"
							}, {
								name: "NAMESPACE"
								valueFrom: fieldRef: fieldPath: "metadata.namespace"
							}]
							envFrom: [{
								configMapRef: name: "environment-config"
							}, {
								configMapRef: name: "ledger-db-config"
							}]
							image: "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/balancereader:v0.6.5@sha256:de01f16554ae2d0b49ac85116e6307da8c0f8a35f50a0cf25e1e4a4fe18dca83"
							livenessProbe: {
								httpGet: {
									path: "/healthy"
									port: 8080
								}
								initialDelaySeconds: 120
								periodSeconds:       5
								timeoutSeconds:      10
							}
							name: "balancereader"
							readinessProbe: {
								httpGet: {
									path: "/ready"
									port: 8080
								}
								initialDelaySeconds: 60
								periodSeconds:       5
								timeoutSeconds:      10
							}
							resources: {
								limits: {
									cpu:                 "500m"
									"ephemeral-storage": "0.5Gi"
									memory:              "512Mi"
								}
								requests: {
									cpu:                 "100m"
									"ephemeral-storage": "0.5Gi"
									memory:              "256Mi"
								}
							}
							securityContext: {
								allowPrivilegeEscalation: false
								capabilities: drop: ["all"]
								privileged:             false
								readOnlyRootFilesystem: true
							}
							startupProbe: {
								failureThreshold: 30
								httpGet: {
									path: "/healthy"
									port: 8080
								}
								periodSeconds: 10
							}
							volumeMounts: [{
								mountPath: "/tmp"
								name:      "tmp"
							}, {
								mountPath: "/tmp/.ssh"
								name:      "publickey"
								readOnly:  true
							}]
						}]
						securityContext: {
							fsGroup:      1000
							runAsGroup:   1000
							runAsNonRoot: true
							runAsUser:    1000
						}
						serviceAccountName:            BankName
						terminationGracePeriodSeconds: 5
						volumes: [{
							emptyDir: {}
							name: "tmp"
						}, {
							name: "publickey"
							secret: {
								items: [{
									key:  "jwtRS256.key.pub"
									path: "publickey"
								}]
								secretName: "jwt-key"
							}
						}]
					}
				}
			}
		}
	}
}
