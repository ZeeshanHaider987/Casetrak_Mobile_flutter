/// Decouples the Dio 401 interceptor from [AuthController] so the graph does
/// not cycle. [CaseTrakApp] registers [onUnauthorized] after startup.
class SessionEvents {
  void Function()? onUnauthorized;

  void unauthorized() => onUnauthorized?.call();
}
