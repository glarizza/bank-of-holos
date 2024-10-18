package holos

let Podinfo = {
  podinfo: {
    port:      9898
    namespace: #Migration.Namespace
  }
}

// Route migration-podinfo.example.com to port 9898 of Service podinfo in the
// migration namespace.
#HTTPRoutes: "migration-podinfo": _backendRefs: Podinfo
