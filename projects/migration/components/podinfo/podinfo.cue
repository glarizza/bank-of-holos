package holos

import ks "sigs.k8s.io/kustomize/api/types"

// Produce a helm chart build plan.
(#Helm & Chart).BuildPlan

let Chart = {
  Name:    "podinfo"
  Namespace: #Migration.Namespace

  Chart: {
      version: "6.6.2"
      repository: {
        name: "podinfo"
        url: "https://stefanprodan.github.io/podinfo"
      }
  }

  // Necessary to ensure the resources go to the correct namespace.
  EnableKustomizePostProcessor: true
  KustomizeFiles: "kustomization.yaml": ks.#Kustomization & {
    namespace: Namespace
  }

  // Allow the platform team to route traffic into our namespace.
  Resources: ReferenceGrant: grant: #ReferenceGrant & {
    metadata: namespace: Namespace
  }
}
