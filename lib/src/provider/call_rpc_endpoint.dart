import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/contract/index.dart';
import 'exception/index.dart';

Future<Map<String, dynamic>> callRpcEndpoint({
  required Uri nodeUri,
  required Map<String, String>? headers,
  required String method,
  Object? params,
}) async {
  final body = {
    'jsonrpc': '2.0',
    'method': method,
    'params': params ?? [],
    'id': 0,
  };

  final response = await http.post(
    nodeUri,
    headers: headers,
    body: PythonicJsonEncoder(sortSymbol: false).convert(body),
  );

  Map<String, dynamic>? decodedResponseBody;
  try {
    final json = jsonDecode(response.body);
    if (json is Map<String, dynamic>) decodedResponseBody = json;
  } catch (_) {}

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw RpcHttpException(
      statusCode: response.statusCode,
      message: 'HTTP request failed.',
      body: response.body,
    );
  }

  final hasJsonRpc = decodedResponseBody?['jsonrpc'] == '2.0';
  final hasError = decodedResponseBody?.containsKey('error') ?? false;
  final hasResult = decodedResponseBody?.containsKey('result') ?? false;
  if (decodedResponseBody == null || !hasJsonRpc || (!hasError && !hasResult)) {
    throw RpcHttpException(
      statusCode: response.statusCode,
      message: 'Invalid JSON response.',
      body: response.body,
    );
  }

  return decodedResponseBody;
}
