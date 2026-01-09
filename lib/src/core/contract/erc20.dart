import 'package:starknet_core/src/core/contract/index.dart';
import 'package:starknet_core/src/core/fee/estimated_transaction_fee.dart';

import '../../provider/starknet_provider.dart';
import '../core/types/index.dart';

class ERC20 extends Contract {
  ERC20({required super.account, required super.address});

  /// Returns the name of the token.
  Future<String> name() async {
    final res = await call(
      functionCall: Erc20NameCall(contractAddress: address).toFunctionCall(),
    );
    final Felt name = res[0];
    return name.toSymbol();
  }

  /// Returns the symbol of the token, usually a shorter version of the name.
  Future<String> symbol() async {
    final res = await call(
      functionCall: Erc20SymbolCall(contractAddress: address).toFunctionCall(),
    );
    final Felt symbol = res[0];
    return symbol.toSymbol();
  }

  /// Returns the number of decimals used to get its user representation.
  ///
  /// For example, if decimals equals 2, a balance of 505 tokens
  /// should be displayed to a user as 5,05 (505 / 10 ** 2).
  Future<Felt> decimals() async {
    final res = await call(
      functionCall: Erc20DecimalsCall(contractAddress: address).toFunctionCall(),
    );
    return res[0];
  }

  /// Returns the amount of tokens in existence.
  Future<Uint256> totalSupply() async {
    final res = await call(
      functionCall: Erc20TotalSupplyCall(contractAddress: address).toFunctionCall(),
    );
    return Uint256(low: res[0], high: res[1]);
  }

  /// Returns the amount of tokens owned by `accountAddress`.
  Future<Uint256> balanceOf({required Felt accountAddress}) async {
    final res = await call(
      functionCall: Erc20BalanceOfCall(
        contractAddress: address,
        accountAddress: accountAddress,
      ).toFunctionCall(),
    );
    return Uint256(low: res[0], high: res[1]);
  }

  /// Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner through transferFrom.
  ///
  /// This is zero by default.
  ///
  /// This value changes when approve or transferFrom are called.
  Future<Uint256> allowance({
    required Felt ownerAddress,
    required Felt spenderAddress,
  }) async {
    final res = await call(
      functionCall: Erc20AllowanceCall(
        contractAddress: address,
        ownerAddress: ownerAddress,
        spenderAddress: spenderAddress,
      ).toFunctionCall(),
    );
    return Uint256(low: res[0], high: res[1]);
  }

  /// Moves `amount` tokens from the caller’s account to `recipientAddress`.
  ///
  /// Returns transaction hash.
  Future<String> transfer({
    required Felt recipientAddress,
    required Uint256 amount,
    Felt? tip,
    EstimatedTransactionFee? estimatedFee,
  }) async {
    final List<FunctionCall> functionCalls = <FunctionCall>[
      Erc20TransferCall(
        contractAddress: address,
        recipientAddress: recipientAddress,
        amount: amount,
      ).toFunctionCall(),
    ];

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

  /// Moves `amount` tokens from `fromAddress` to `toAddress` using the allowance mechanism.
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
    final List<FunctionCall> functionCalls = <FunctionCall>[
      Erc20TransferFromCall(
        contractAddress: address,
        fromAddress: fromAddress,
        toAddress: toAddress,
        amount: amount,
      ).toFunctionCall(),
    ];

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

  /// Sets `amount` as the allowance of `spenderAddress` over the caller’s tokens.
  ///
  /// Returns transaction hash.
  Future<String> approve({
    required Felt spenderAddress,
    required Uint256 amount,
    Felt? tip,
    EstimatedTransactionFee? estimatedFee,
  }) async {
    final List<FunctionCall> functionCalls = [
      Erc20ApproveCall(
        contractAddress: address,
        spenderAddress: spenderAddress,
        amount: amount,
      ).toFunctionCall(),
    ];

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
}
