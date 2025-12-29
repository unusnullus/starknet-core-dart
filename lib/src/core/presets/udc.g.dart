// Generated code, do not modify. Run `build_runner build` to re-generate!
// ignore_for_file: unused_element

import 'package:starknet_core/src/core/fee/estimated_transaction_fee.dart';
import 'package:starknet_core/src/provider/model/function_call.dart';

import '../contract/index.dart';
import '../core/index.dart';

class Udc extends Contract {
  Udc({
    required super.account,
    required super.address,
  });

  Future<String> deployContract({
    required Felt classHash,
    required Felt salt,
    required Felt unique,
    required List<Felt> calldata,
    required Felt? tip,
    required EstimatedTransactionFee? estimatedFee,
  }) async {
    final trx = await execute(
      functionCalls: [
        FunctionCall(
          contractAddress: address,
          entryPointSelector: getSelectorByName("deployContract"),
          calldata: [
            classHash,
            salt,
            unique,
            ...calldata.toCallData(),
          ],
        ),
      ],
      tip: tip,
      estimatedFee: estimatedFee,
    );
    return trx.when(
      result: (result) => result.transaction_hash,
      error: (error) => throw Exception,
    );
  }
}

extension on List<Felt> {
  List<Felt> toCallData() {
    return [
      Felt.fromInt(length),
      ...this,
    ];
  }

  List<Felt> fromCallData() {
    return sublist(1);
  }
}
