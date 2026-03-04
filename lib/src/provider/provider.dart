import 'call_rpc_endpoint.dart';
import 'model/index.dart';
import 'read_provider.dart';

abstract class Provider implements ReadProvider {
  Future<InvokeTransactionResponse> addInvokeTransaction(InvokeTransactionRequest request);

  Future<DeclareTransactionResponse> addDeclareTransaction(DeclareTransactionRequest request);

  Future<DeployAccountTransactionResponse> addDeployAccountTransaction(DeployAccountTransactionRequest request);
}

class JsonRpcProvider extends JsonRpcReadProvider implements Provider {
  JsonRpcProvider({
    required super.nodeUri,
    super.headers,
  });

  @override
  Future<InvokeTransactionResponse> addInvokeTransaction(InvokeTransactionRequest request) async {
    return callRpcEndpoint(
      nodeUri: nodeUri,
      headers: headers,
      method: 'starknet_addInvokeTransaction',
      params: request,
    ).then(InvokeTransactionResponse.fromJson);
  }

  @override
  Future<DeclareTransactionResponse> addDeclareTransaction(DeclareTransactionRequest request) async {
    return callRpcEndpoint(
      nodeUri: nodeUri,
      headers: headers,
      method: 'starknet_addDeclareTransaction',
      params: request,
    ).then(DeclareTransactionResponse.fromJson);
  }

  @override
  Future<DeployAccountTransactionResponse> addDeployAccountTransaction(DeployAccountTransactionRequest request) async {
    return callRpcEndpoint(
      nodeUri: nodeUri,
      headers: headers,
      method: 'starknet_addDeployAccountTransaction',
      params: request,
    ).then(DeployAccountTransactionResponse.fromJson);
  }
}
