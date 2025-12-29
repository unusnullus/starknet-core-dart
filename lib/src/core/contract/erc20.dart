import 'package:starknet_core/src/core/fee/estimated_transaction_fee.dart';

import '../../provider/starknet_provider.dart';
import '../core/types/index.dart';
import 'contract.dart';

class ERC20 extends Contract {
  ERC20({required super.account, required super.address});

  /// Returns the name of the token.
  Future<String> name() async {
    final res = await call("name", []);
    final Felt name = res[0];
    return name.toSymbol();
  }

  /// Returns the symbol of the token, usually a shorter version of the name.
  Future<String> symbol() async {
    final res = await call("symbol", []);
    final Felt symbol = res[0];
    return symbol.toSymbol();
  }

  /// Returns the number of decimals used to get its user representation.
  ///
  /// For example, if decimals equals 2, a balance of 505 tokens
  /// should be displayed to a user as 5,05 (505 / 10 ** 2).
  Future<Felt> decimals() async {
    final res = await call("decimals", []);
    return res[0];
  }

  /// Returns the amount of tokens in existence.
  Future<Uint256> totalSupply() async {
    final res = await call("totalSupply", []);
    return Uint256(low: res[0], high: res[1]);
  }

  /// Returns the amount of tokens owned by `account`.
  Future<Uint256> balanceOf(Felt account) async {
    final res = await call("balanceOf", [account]);
    return Uint256(low: res[0], high: res[1]);
  }

  /// Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner through transferFrom.
  ///
  /// This is zero by default.
  ///
  /// This value changes when approve or transferFrom are called.
  Future<Uint256> allowance(Felt owner, Felt spender) async {
    final res = await call("allowance", [owner, spender]);
    return Uint256(low: res[0], high: res[1]);
  }

  /// Moves `amount` tokens from the caller’s account to `recipient`.
  ///
  /// Returns transaction hash.
  Future<String> transfer({
    required Felt recipient,
    required Uint256 amount,
    Felt? tip,
    EstimatedTransactionFee? estimatedFee,
  }) async {
    final List<FunctionCall> functionCalls = getTransferFunctionCalls(
      recipient: recipient,
      amount: amount,
    );

    estimatedFee ??= await account.estimateFeeForInvokeTx(functionCalls: functionCalls, tip: tip);

    final InvokeTransactionResponse trx = await execute(
      functionCalls: functionCalls,
      tip: tip,
      estimatedFee: estimatedFee,
    );
    return trx.when(
      result: (result) => result.transaction_hash,
      error: (error) => throw Exception(error.message),
    );
  }

  /// Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism.
  /// amount is then deducted from the caller’s allowance.
  ///
  /// Returns transaction hash.
  Future<String> transferFrom({
    required Felt fromAddress,
    required Felt toAddress,
    required Uint256 amount,
    Felt? tip,
    EstimatedTransactionFee? estimatedFee,
  }) async {
    final List<FunctionCall> functionCalls = getTransferFromFunctionCalls(
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
    );

    estimatedFee ??= await account.estimateFeeForInvokeTx(functionCalls: functionCalls, tip: tip);

    final InvokeTransactionResponse trx = await execute(
      functionCalls: functionCalls,
      tip: tip,
      estimatedFee: estimatedFee,
    );
    return trx.when(
      result: (result) => result.transaction_hash,
      error: (error) => throw Exception(error.message),
    );
  }

  /// Sets `amount` as the allowance of `spender` over the caller’s tokens.
  ///
  /// Returns transaction hash.
  Future<String> approve({
    required Felt spenderAddress,
    required Uint256 amount,
    Felt? tip,
    EstimatedTransactionFee? estimatedFee,
  }) async {
    final List<FunctionCall> functionCalls = getApproveFunctionCalls(
      spenderAddress: spenderAddress,
      amount: amount,
    );

    estimatedFee ??= await account.estimateFeeForInvokeTx(functionCalls: functionCalls, tip: tip);

    final InvokeTransactionResponse trx = await execute(
      functionCalls: functionCalls,
      tip: tip,
      estimatedFee: estimatedFee,
    );
    return trx.when(
      result: (result) => result.transaction_hash,
      error: (error) => throw Exception(error.message),
    );
  }

  List<FunctionCall> getTransferFunctionCalls({
    required Felt recipient,
    required Uint256 amount,
  }) {
    return [
      getFunctionCall(selector: 'transfer', calldata: [recipient, amount.low, amount.high]),
    ];
  }

  List<FunctionCall> getTransferFromFunctionCalls({
    required Felt fromAddress,
    required Felt toAddress,
    required Uint256 amount,
  }) {
    return [
      getFunctionCall(selector: 'transferFrom', calldata: [fromAddress, toAddress, amount.low, amount.high]),
    ];
  }

  List<FunctionCall> getApproveFunctionCalls({
    required Felt spenderAddress,
    required Uint256 amount,
  }) {
    return [
      getFunctionCall(selector: 'approve', calldata: [spenderAddress, amount.low, amount.high]),
    ];
  }
}
