import 'package:starknet_core/src/core/fee/estimated_transaction_fee.dart';

import '../../provider/starknet_provider.dart';
import '../account.dart';
import '../core/index.dart';

class Contract {
  final Account account;
  final Felt address;

  Contract({
    required this.account,
    required this.address,
  });

  /// Compute contract address for given [classHash], [calldata], [salt]
  ///
  /// https://docs.starknet.io/documentation/architecture_and_concepts/Contracts/contract-address/
  static Felt computeAddress({
    required Felt classHash,
    required List<Felt> calldata,
    required Felt salt,
  }) {
    final deployerAddress = BigInt.from(0); // always zero
    final elements = <BigInt>[];
    elements.add(Felt.fromString('STARKNET_CONTRACT_ADDRESS').toBigInt());
    // caller address is always zero
    elements.add(deployerAddress);
    elements.add(salt.toBigInt());
    elements.add(classHash.toBigInt());
    elements.add(computeHashOnElements(calldata.map((e) => e.toBigInt()).toList()));
    final address = computeHashOnElements(elements);
    return Felt(address);
  }

  /// Call contract given [selector] with [calldata]
  Future<List<Felt>> call(String selector, List<Felt> calldata) async {
    final response = await account.provider.call(
      request: FunctionCall(
        contractAddress: address,
        entryPointSelector: getSelectorByName(selector),
        calldata: calldata,
      ),
      blockId: BlockId.latest,
    );
    return response.when(
      result: (result) => result,
      error: (error) => throw Exception(error),
    );
  }

  /// Execute contract given [selector] with [calldata]
  Future<InvokeTransactionResponse> execute({
    required List<FunctionCall> functionCalls,
    Felt? tip,
    EstimatedTransactionFee? estimatedFee,
  }) {
    return account.execute(
      functionCalls: functionCalls,
      tip: tip,
      estimatedFee: estimatedFee,
    );
  }
}
