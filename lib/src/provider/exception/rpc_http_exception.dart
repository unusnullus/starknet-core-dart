class RpcHttpException implements Exception {
  final int statusCode;
  final String message;
  final String? body;

  RpcHttpException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  @override
  String toString() => 'RpcHttpException.\nStatus code: $statusCode.\nMessage: $message';
}
