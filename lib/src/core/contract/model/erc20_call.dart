import '../../../provider/model/function_call.dart';
import '../../core/index.dart';

abstract class Erc20CallSelectorName {
  static const String transfer = 'transfer';
  static const String transferFrom = 'transferFrom';
  static const String approve = 'approve';
  static const String name = 'name';
  static const String symbol = 'symbol';
  static const String decimals = 'decimals';
  static const String totalSupply = 'totalSupply';
  static const String balanceOf = 'balanceOf';
  static const String allowance = 'allowance';
}

typedef CreateErc20CallByFunctionCall = Erc20Call Function(FunctionCall);

abstract class Erc20CallFactory {
  static final Map<Felt, CreateErc20CallByFunctionCall> _selectorToCreateCallByFunctionCall =
      <Felt, CreateErc20CallByFunctionCall>{
        _getSelectorByName(Erc20CallSelectorName.transfer): Erc20TransferCall.fromFunctionCall,
        _getSelectorByName(Erc20CallSelectorName.transferFrom): Erc20TransferFromCall.fromFunctionCall,
        _getSelectorByName(Erc20CallSelectorName.approve): Erc20ApproveCall.fromFunctionCall,
        _getSelectorByName(Erc20CallSelectorName.name): Erc20NameCall.fromFunctionCall,
        _getSelectorByName(Erc20CallSelectorName.symbol): Erc20SymbolCall.fromFunctionCall,
        _getSelectorByName(Erc20CallSelectorName.decimals): Erc20DecimalsCall.fromFunctionCall,
        _getSelectorByName(Erc20CallSelectorName.totalSupply): Erc20TotalSupplyCall.fromFunctionCall,
        _getSelectorByName(Erc20CallSelectorName.balanceOf): Erc20BalanceOfCall.fromFunctionCall,
        _getSelectorByName(Erc20CallSelectorName.allowance): Erc20AllowanceCall.fromFunctionCall,
      };

  static Felt _getSelectorByName(String name) => getSelectorByName(name);

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

  List<Felt> get calldata => <Felt>[];

  Felt get selector => getSelectorByName(selectorName);

  FunctionCall toFunctionCall() {
    return FunctionCall(
      contractAddress: contractAddress,
      entryPointSelector: selector,
      calldata: calldata,
    );
  }
}

class Erc20NameCall extends Erc20Call {
  Erc20NameCall({required super.contractAddress}) : super(selectorName: Erc20CallSelectorName.name);

  factory Erc20NameCall.fromFunctionCall(FunctionCall functionCall) {
    return Erc20NameCall(contractAddress: functionCall.contractAddress);
  }
}

class Erc20SymbolCall extends Erc20Call {
  Erc20SymbolCall({required super.contractAddress}) : super(selectorName: Erc20CallSelectorName.symbol);

  factory Erc20SymbolCall.fromFunctionCall(FunctionCall functionCall) {
    return Erc20SymbolCall(contractAddress: functionCall.contractAddress);
  }
}

class Erc20DecimalsCall extends Erc20Call {
  Erc20DecimalsCall({required super.contractAddress}) : super(selectorName: Erc20CallSelectorName.decimals);

  factory Erc20DecimalsCall.fromFunctionCall(FunctionCall functionCall) {
    return Erc20DecimalsCall(contractAddress: functionCall.contractAddress);
  }
}

class Erc20TotalSupplyCall extends Erc20Call {
  Erc20TotalSupplyCall({required super.contractAddress}) : super(selectorName: Erc20CallSelectorName.totalSupply);

  factory Erc20TotalSupplyCall.fromFunctionCall(FunctionCall functionCall) {
    return Erc20TotalSupplyCall(contractAddress: functionCall.contractAddress);
  }
}

class Erc20BalanceOfCall extends Erc20Call {
  final Felt accountAddress;

  Erc20BalanceOfCall({
    required super.contractAddress,
    required this.accountAddress,
  }) : super(selectorName: Erc20CallSelectorName.balanceOf);

  factory Erc20BalanceOfCall.fromFunctionCall(FunctionCall functionCall) {
    return Erc20BalanceOfCall(
      contractAddress: functionCall.contractAddress,
      accountAddress: functionCall.calldata[0],
    );
  }

  @override
  List<Felt> get calldata => <Felt>[accountAddress];
}

class Erc20AllowanceCall extends Erc20Call {
  final Felt ownerAddress;
  final Felt spenderAddress;

  Erc20AllowanceCall({
    required super.contractAddress,
    required this.ownerAddress,
    required this.spenderAddress,
  }) : super(selectorName: Erc20CallSelectorName.allowance);

  factory Erc20AllowanceCall.fromFunctionCall(FunctionCall functionCall) {
    return Erc20AllowanceCall(
      contractAddress: functionCall.contractAddress,
      ownerAddress: functionCall.calldata[0],
      spenderAddress: functionCall.calldata[1],
    );
  }

  @override
  List<Felt> get calldata => <Felt>[ownerAddress, spenderAddress];
}

class Erc20TransferCall extends Erc20Call {
  final Felt recipientAddress;
  final Uint256 amount;

  Erc20TransferCall({
    required super.contractAddress,
    required this.recipientAddress,
    required this.amount,
  }) : super(selectorName: Erc20CallSelectorName.transfer);

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
  }) : super(selectorName: Erc20CallSelectorName.transferFrom);

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
  }) : super(selectorName: Erc20CallSelectorName.approve);

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
