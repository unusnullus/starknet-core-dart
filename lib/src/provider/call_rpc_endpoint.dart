import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/contract/index.dart';

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

  return jsonDecode(response.body);
}
