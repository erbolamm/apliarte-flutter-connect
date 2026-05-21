/// Role advertised or used by a peer in a local connection session.
enum ConnectRole { host, viewer }

/// Product-level use cases that drive permission and capability checks.
enum ConnectUseCase { discoveryOnly, projectionHost, projectionViewer }
