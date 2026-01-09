import '../../../provider/model/function_call.dart';
import '../../core/index.dart';

abstract class Erc20CallSelectors {
  static const String transferName = 'transfer';
  static const String transferFromName = 'transferFrom';
  static const String approveName = 'approve';

  static Felt get transfer => _getSelectorByName(transferName);

  static Felt get transferFrom => _getSelectorByName(transferFromName);

  static Felt get approve => _getSelectorByName(approveName);

  static Felt _getSelectorByName(String name) => getSelectorByName(name);
}

typedef CreateErc20CallByFunctionCall = Erc20Call Function(FunctionCall);

abstract class Erc20CallFactory {
  static final Map<Felt, CreateErc20CallByFunctionCall> _selectorToCreateCallByFunctionCall =
      <Felt, CreateErc20CallByFunctionCall>{
        Erc20CallSelectors.transfer: Erc20TransferCall.fromFunctionCall,
        Erc20CallSelectors.transferFrom: Erc20TransferFromCall.fromFunctionCall,
        Erc20CallSelectors.approve: Erc20ApproveCall.fromFunctionCall,
      };

  static Erc20Call? createByFunctionCall(FunctionCall functionCall) {
    return _selectorToCreateCallByFunctionCall[functionCall.entryPointSelector]?.call(functionCall);
  }
}

sealed class Erc20Call {
  final Felt contractAddress;
  final String selectorName;

  Erc20Call({
    required this.contractAddress,
    required this.selectorName,
  });

  List<Felt> get calldata;

  Felt get selector => getSelectorByName(selectorName);

  FunctionCall toFunctionCall() {
    return FunctionCall(
      contractAddress: contractAddress,
      entryPointSelector: selector,
      calldata: calldata,
    );
  }
}

class Erc20TransferCall extends Erc20Call {
  final Felt recipientAddress;
  final Uint256 amount;

  Erc20TransferCall({
    required super.contractAddress,
    required this.recipientAddress,
    required this.amount,
  }) : super(selectorName: Erc20CallSelectors.transferName);

  factory Erc20TransferCall.fromFunctionCall(FunctionCall functionCall) {
    return Erc20TransferCall(
      contractAddress: functionCall.contractAddress,
      recipientAddress: functionCall.calldata[0],
      amount: Uint256(
        low: functionCall.calldata[1],
        high: functionCall.calldata[2],
      ),
    );
  }

  @override
  List<Felt> get calldata => <Felt>[recipientAddress, amount.low, amount.high];
}

class Erc20TransferFromCall extends Erc20Call {
  final Felt fromAddress;
  final Felt toAddress;
  final Uint256 amount;

  Erc20TransferFromCall({
    required super.contractAddress,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
  }) : super(selectorName: Erc20CallSelectors.transferFromName);

  factory Erc20TransferFromCall.fromFunctionCall(FunctionCall functionCall) {
    return Erc20TransferFromCall(
      contractAddress: functionCall.contractAddress,
      fromAddress: functionCall.calldata[0],
      toAddress: functionCall.calldata[1],
      amount: Uint256(
        low: functionCall.calldata[2],
        high: functionCall.calldata[3],
      ),
    );
  }

  @override
  List<Felt> get calldata => <Felt>[fromAddress, toAddress, amount.low, amount.high];
}

class Erc20ApproveCall extends Erc20Call {
  final Felt spenderAddress;
  final Uint256 amount;

  Erc20ApproveCall({
    required super.contractAddress,
    required this.spenderAddress,
    required this.amount,
  }) : super(selectorName: Erc20CallSelectors.approveName);

  factory Erc20ApproveCall.fromFunctionCall(FunctionCall functionCall) {
    return Erc20ApproveCall(
      contractAddress: functionCall.contractAddress,
      spenderAddress: functionCall.calldata[0],
      amount: Uint256(
        low: functionCall.calldata[1],
        high: functionCall.calldata[2],
      ),
    );
  }

  @override
  List<Felt> get calldata => <Felt>[spenderAddress, amount.low, amount.high];
}
