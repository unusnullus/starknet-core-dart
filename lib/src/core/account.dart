// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:starknet_core/src/provider/starknet_provider.dart';

import 'account/derivation/account_derivation.dart';
import 'account/signer/base_account_signer.dart';
import 'contract/index.dart';
import 'core/crypto/index.dart' as core;
import 'core/types/index.dart';
import 'crypto/index.dart' as c;
import 'fee/estimated_transaction_fee.dart';
import 'presets/udc.g.dart';
import 'static_config.dart';

/// Account abstraction class
class Account {
  /// Provider use by this account
  final Provider provider;

  /// Signer use by this account
  final BaseAccountSigner signer;

  /// Address of this account
  final Felt accountAddress;

  final Felt chainId;

  Account({
    required this.provider,
    required this.signer,
    required this.accountAddress,
    required this.chainId,
  });

  /// Retrieves an account from given [mnemonic], [provider] and [chainId]
  ///
  /// Default [accountDerivation] is [BraavosAccountDerivation]
  factory Account.fromMnemonic({
    required List<String> mnemonic,
    required Provider provider,
    required Felt chainId,
    required AccountDerivation accountDerivation,
    int index = 0,
  }) {
    final accountSigner = accountDerivation.deriveSigner(mnemonic: mnemonic, index: index);

    return Account(
      accountAddress: accountDerivation.computeAddress(publicKey: accountSigner.publicKey),
      provider: provider,
      signer: accountSigner,
      chainId: chainId,
    );
  }

  /// Get Nonce for account at given [blockId]
  Future<Felt> getNonce([BlockId blockId = BlockId.latest]) async {
    final response = await provider.getNonce(
      blockId: blockId,
      contractAddress: accountAddress,
    );
    return response.when(
      error: (error) => throw Exception('Error retrieving nonce (${error.code}): ${error.message}'),
      result: (result) => result,
    );
  }

  Future<EstimatedTransactionFee> estimateFeeForInvokeTx({
    required List<FunctionCall> functionCalls,
    Felt? nonce,
    Felt? tip,
    BlockId blockId = BlockId.latest,
    double feeMultiplier = 1.2,
  }) async {
    // These values are for future use (until then they are empty or zero)
    const List<Felt> accountDeploymentData = <Felt>[];
    const List<Felt> paymasterData = <Felt>[];
    const String feeDataAvailabilityMode = 'L1';
    const String nonceDataAvailabilityMode = 'L1';

    nonce = nonce ?? await getNonce();
    tip = tip ?? Felt.zero;
    final Map<String, ResourceBounds> resourceBounds = _buildResourceBounds();

    final signature = await signer.signInvokeTransactionsV3(
      transactions: functionCalls,
      senderAddress: accountAddress,
      chainId: chainId,
      nonce: nonce,
      resourceBounds: resourceBounds,
      accountDeploymentData: accountDeploymentData,
      paymasterData: paymasterData,
      tip: tip,
      feeDataAvailabilityMode: feeDataAvailabilityMode,
      nonceDataAvailabilityMode: nonceDataAvailabilityMode,
    );

    return estimateFeeForBroadcastedTx(
      transaction: BroadcastedInvokeTxnV3(
        type: 'INVOKE',
        version: '0x3',
        signature: signature,
        nonce: nonce,
        accountDeploymentData: accountDeploymentData,
        calldata: c.functionCallsToCalldata(functionCalls: functionCalls, useLegacyCalldata: false),
        feeDataAvailabilityMode: feeDataAvailabilityMode,
        nonceDataAvailabilityMode: nonceDataAvailabilityMode,
        paymasterData: paymasterData,
        resourceBounds: resourceBounds,
        senderAddress: accountAddress,
        tip: tip.toHexString(),
      ),
      blockId: blockId,
      feeMultiplier: feeMultiplier,
    );
  }

  Future<EstimatedTransactionFee> estimateFeeForDeclareTx({
    required ICompiledContract compiledContract,
    required BigInt compiledClassHash,
    CASMCompiledContract? casmCompiledContract,
    Felt? nonce,
    Felt? tip,
    BlockId blockId = BlockId.latest,
    double feeMultiplier = 1.2,
  }) async {
    // These values are for future use (until then they are empty or zero)
    const List<Felt> accountDeploymentData = <Felt>[];
    const List<Felt> paymasterData = <Felt>[];
    const String feeDataAvailabilityMode = 'L1';
    const String nonceDataAvailabilityMode = 'L1';

    nonce = nonce ?? await getNonce();
    tip ??= Felt.zero;
    final Map<String, ResourceBounds> resourceBounds = _buildResourceBounds();

    final signature = await signer.signDeclareTransactionV3(
      compiledContract: compiledContract as CompiledContract,
      senderAddress: accountAddress,
      chainId: chainId,
      nonce: nonce,
      compiledClassHash: Felt(compiledClassHash),
      casmCompiledContract: casmCompiledContract,
      resourceBounds: resourceBounds,
      accountDeploymentData: accountDeploymentData,
      paymasterData: paymasterData,
      tip: tip,
      feeDataAvailabilityMode: feeDataAvailabilityMode,
      nonceDataAvailabilityMode: nonceDataAvailabilityMode,
    );

    return estimateFeeForBroadcastedTx(
      transaction: BroadcastedDeclareTxnV3(
        type: 'DECLARE',
        version: '0x3',
        signature: signature,
        nonce: nonce,
        accountDeploymentData: accountDeploymentData,
        compiledClassHash: Felt(compiledClassHash),
        contractClass: compiledContract.flatten(),
        feeDataAvailabilityMode: feeDataAvailabilityMode,
        nonceDataAvailabilityMode: nonceDataAvailabilityMode,
        paymasterData: paymasterData,
        resourceBounds: resourceBounds,
        senderAddress: accountAddress,
        tip: tip.toHexString(),
      ),
      blockId: blockId,
      feeMultiplier: feeMultiplier,
    );
  }

  Future<EstimatedTransactionFee> estimateFeeForDeployAccountTx({
    required Felt classHash,
    required List<Felt> constructorCalldata,
    required Felt contractAddressSalt,
    Felt? nonce,
    Felt? tip,
    BlockId blockId = BlockId.latest,
    double feeMultiplier = 1.2,
  }) async {
    // These values are for future use (until then they are empty or zero)
    const List<Felt> paymasterData = <Felt>[];
    const String feeDataAvailabilityMode = 'L1';
    const String nonceDataAvailabilityMode = 'L1';

    nonce ??= Felt.zero;
    tip ??= Felt.zero;
    final Map<String, ResourceBounds> resourceBounds = _buildResourceBounds();

    final signature = await signer.signDeployAccountTransactionV3(
      contractAddress: accountAddress,
      resourceBounds: resourceBounds,
      tip: tip,
      paymasterData: paymasterData,
      chainId: chainId,
      nonce: nonce,
      feeDataAvailabilityMode: feeDataAvailabilityMode,
      nonceDataAvailabilityMode: nonceDataAvailabilityMode,
      constructorCalldata: constructorCalldata,
      classHash: classHash,
      contractAddressSalt: contractAddressSalt,
    );

    return estimateFeeForBroadcastedTx(
      transaction: BroadcastedDeployAccountTxnV3(
        type: 'DEPLOY_ACCOUNT',
        version: '0x3',
        signature: signature,
        nonce: nonce,
        classHash: classHash,
        constructorCalldata: constructorCalldata,
        contractAddressSalt: contractAddressSalt,
        feeDataAvailabilityMode: feeDataAvailabilityMode,
        nonceDataAvailabilityMode: nonceDataAvailabilityMode,
        paymasterData: paymasterData,
        resourceBounds: resourceBounds,
        tip: tip.toHexString(),
      ),
      blockId: blockId,
      feeMultiplier: feeMultiplier,
    );
  }

  Future<EstimatedTransactionFee> estimateFeeForDeployTx({
    required Felt classHash,
    Felt? salt,
    Felt? unique,
    List<Felt>? calldata,
    Felt? tip,
  }) async {
    salt ??= _generateSalt();
    unique ??= Felt.zero;
    calldata ??= [];
    final params = [classHash, salt, unique, Felt.fromInt(calldata.length), ...calldata];

    final maxFee = await estimateFeeForInvokeTx(
      functionCalls: [
        FunctionCall(
          //verify the udcAddress before use this logic
          contractAddress: udcAddress,
          entryPointSelector: core.getSelectorByName('deployContract'),
          calldata: params,
        ),
      ],
      tip: tip,
    );

    return maxFee;
  }

  Future<EstimatedTransactionFee> estimateFeeForBroadcastedTx({
    required BroadcastedTxn transaction,
    required BlockId blockId,
    required double feeMultiplier,
  }) async {
    final estimateFeeResponse = await provider.estimateFee(
      EstimateFeeRequest(
        request: [transaction],
        blockId: blockId,
        simulation_flags: [],
      ),
    );

    final fee = estimateFeeResponse.when(
      result: (result) => result[0],
      error: (error) => throw Exception(error.message),
    );

    return EstimatedTransactionFee(
      l1GasConsumed: fee.l1GasConsumed * Felt.fromDouble(feeMultiplier),
      l1GasPrice: fee.l1GasPrice * Felt.fromDouble(feeMultiplier),
      l1DataGasConsumed: fee.l1DataGasConsumed * Felt.fromDouble(feeMultiplier),
      l1DataGasPrice: fee.l1DataGasPrice * Felt.fromDouble(feeMultiplier),
      l2GasConsumed: fee.l2GasConsumed * Felt.fromDouble(feeMultiplier),
      l2GasPrice: fee.l2GasPrice * Felt.fromDouble(feeMultiplier),
      overallFee: fee.overallFee * Felt.fromDouble(feeMultiplier),
      unit: fee.unit,
    );
  }

  /// Call account contract `__execute__` with given [functionCalls]
  Future<InvokeTransactionResponse> execute({
    required List<FunctionCall> functionCalls,
    Felt? nonce,
    Felt? tip,
    EstimatedTransactionFee? estimatedFee,
  }) async {
    // These values are for future use (until then they are empty or zero)
    const List<Felt> accountDeploymentData = <Felt>[];
    const List<Felt> paymasterData = <Felt>[];
    const String feeDataAvailabilityMode = 'L1';
    const String nonceDataAvailabilityMode = 'L1';

    nonce = nonce ?? await getNonce();
    tip ??= Felt.zero;
    final Map<String, ResourceBounds> resourceBounds = _buildResourceBounds(estimatedFee: estimatedFee);

    final signature = await signer.signInvokeTransactionsV3(
      transactions: functionCalls,
      senderAddress: accountAddress,
      chainId: chainId,
      nonce: nonce,
      resourceBounds: resourceBounds,
      accountDeploymentData: accountDeploymentData,
      paymasterData: paymasterData,
      tip: tip,
      feeDataAvailabilityMode: feeDataAvailabilityMode,
      nonceDataAvailabilityMode: nonceDataAvailabilityMode,
    );

    final InvokeTransactionResponse response = await provider.addInvokeTransaction(
      InvokeTransactionRequest(
        invokeTransaction: InvokeTransactionV3(
          accountDeploymentData: accountDeploymentData,
          calldata: c.functionCallsToCalldata(functionCalls: functionCalls, useLegacyCalldata: false),
          feeDataAvailabilityMode: feeDataAvailabilityMode,
          nonce: nonce,
          nonceDataAvailabilityMode: nonceDataAvailabilityMode,
          paymasterData: paymasterData,
          resourceBounds: resourceBounds,
          senderAddress: accountAddress,
          signature: signature,
          tip: tip.toHexString(),
        ),
      ),
    );

    return response.when(
      result: (InvokeTransactionResponseResult result) => response,
      error: (JsonRpcApiError error) => throw Exception(error.message),
    );
  }

  /// Declares a [compiledContract]
  Future<DeclareTransactionResponse> declare({
    required ICompiledContract compiledContract,
    required BigInt compiledClassHash,
    CASMCompiledContract? casmCompiledContract,
    Felt? nonce,
    Felt? tip,
    EstimatedTransactionFee? estimatedFee,
  }) async {
    // These values are for future use (until then they are empty or zero)
    const List<Felt> accountDeploymentData = <Felt>[];
    const List<Felt> paymasterData = <Felt>[];
    const String feeDataAvailabilityMode = 'L1';
    const String nonceDataAvailabilityMode = 'L1';

    nonce = nonce ?? await getNonce();
    tip ??= Felt.zero;
    final Map<String, ResourceBounds> resourceBounds = _buildResourceBounds(estimatedFee: estimatedFee);

    final signature = await signer.signDeclareTransactionV3(
      compiledContract: compiledContract as CompiledContract,
      senderAddress: accountAddress,
      chainId: chainId,
      nonce: nonce,
      compiledClassHash: Felt(compiledClassHash),
      casmCompiledContract: casmCompiledContract,
      resourceBounds: resourceBounds,
      accountDeploymentData: accountDeploymentData,
      paymasterData: paymasterData,
      tip: tip,
      feeDataAvailabilityMode: feeDataAvailabilityMode,
      nonceDataAvailabilityMode: nonceDataAvailabilityMode,
    );

    return provider.addDeclareTransaction(
      DeclareTransactionRequest(
        declareTransaction: DeclareTransactionV3(
          accountDeploymentData: accountDeploymentData,
          compiledClassHash: Felt(compiledClassHash),
          contractClass: compiledContract.flatten(),
          feeDataAvailabilityMode: feeDataAvailabilityMode,
          nonce: nonce,
          nonceDataAvailabilityMode: nonceDataAvailabilityMode,
          paymasterData: paymasterData,
          resourceBounds: resourceBounds,
          senderAddress: accountAddress,
          signature: signature,
          tip: tip.toHexString(),
        ),
      ),
    );
  }

  /// Deploys an instance of [classHash] with given [salt], [unique] and [calldata]
  ///
  /// Contract is deployed with UDC: https://docs.openzeppelin.com/contracts-cairo/0.6.1/udc
  /// Returns deployed contract address
  Future<Felt?> deploy({
    required Felt classHash,
    Felt? salt,
    Felt? unique,
    List<Felt>? calldata,
    Felt? tip,
    EstimatedTransactionFee? estimatedFee,
  }) async {
    salt ??= _generateSalt();
    unique ??= Felt.zero;
    calldata ??= [];

    //verify the udcAddress before use this logic
    final txHash = await Udc(account: this, address: udcAddress).deployContract(
      classHash: classHash,
      salt: salt,
      unique: unique,
      calldata: calldata,
      tip: tip,
      estimatedFee: estimatedFee,
    );

    final txReceipt = await provider.getTransactionReceipt(Felt.fromHexString(txHash));

    return txReceipt.when(
      result: (result) {
        for (final event in result.events) {
          // contract constructor can generate some event also
          //verify the udcAddress before use this logic
          if (event.fromAddress == udcAddress) return event.data?[0];
        }
        throw Exception('UDC deployer event not found');
      },
      error: (error) => throw Exception(error.message),
    );
  }

  /// Deploy a current account
  Future<DeployAccountTransactionResponse> deploySelf({
    required Felt classHash,
    required List<Felt> constructorCalldata,
    required Felt contractAddressSalt,
    Felt? nonce,
    Felt? tip,
    EstimatedTransactionFee? estimatedFee,
  }) async {
    // These values are for future use (until then they are empty or zero)
    const List<Felt> paymasterData = <Felt>[];
    const String feeDataAvailabilityMode = 'L1';
    const String nonceDataAvailabilityMode = 'L1';

    nonce ??= Felt.zero;
    tip ??= Felt.zero;

    estimatedFee ??= await estimateFeeForDeployAccountTx(
      classHash: classHash,
      constructorCalldata: constructorCalldata,
      contractAddressSalt: contractAddressSalt,
      nonce: nonce,
      tip: tip,
    );
    final Map<String, ResourceBounds> resourceBounds = _buildResourceBounds(estimatedFee: estimatedFee);

    final signature = await signer.signDeployAccountTransactionV3(
      contractAddress: accountAddress,
      resourceBounds: resourceBounds,
      tip: tip,
      paymasterData: paymasterData,
      chainId: chainId,
      nonce: nonce,
      feeDataAvailabilityMode: feeDataAvailabilityMode,
      nonceDataAvailabilityMode: nonceDataAvailabilityMode,
      constructorCalldata: constructorCalldata,
      classHash: classHash,
      contractAddressSalt: contractAddressSalt,
    );
    return provider.addDeployAccountTransaction(
      DeployAccountTransactionRequest(
        deployAccountTransaction: DeployAccountTransactionV3(
          classHash: classHash,
          constructorCalldata: constructorCalldata,
          contractAddressSalt: contractAddressSalt,
          feeDataAvailabilityMode: feeDataAvailabilityMode,
          nonce: nonce,
          nonceDataAvailabilityMode: nonceDataAvailabilityMode,
          paymasterData: paymasterData,
          resourceBounds: resourceBounds,
          signature: signature,
          tip: tip.toHexString(),
        ),
      ),
    );
  }

  Map<String, ResourceBounds> _buildResourceBounds({EstimatedTransactionFee? estimatedFee}) {
    const String l1GasKey = 'l1_gas';
    const String l1DataGasKey = 'l1_data_gas';
    const String l2GasKey = 'l2_gas';

    return <String, ResourceBounds>{
      l1GasKey: ResourceBounds(
        maxAmount: estimatedFee?.l1GasConsumed ?? Felt.zero,
        maxPricePerUnit: estimatedFee?.l1GasPrice ?? Felt.zero,
      ),
      l1DataGasKey: ResourceBounds(
        maxAmount: estimatedFee?.l1DataGasConsumed ?? Felt.zero,
        maxPricePerUnit: estimatedFee?.l1DataGasPrice ?? Felt.zero,
      ),
      l2GasKey: ResourceBounds(
        maxAmount: estimatedFee?.l2GasConsumed ?? Felt.zero,
        maxPricePerUnit: estimatedFee?.l2GasPrice ?? Felt.zero,
      ),
    };
  }

  /// Generates a random salt for contract deployment
  /// TODO: Consider using a more secure random number generator if needed
  Felt _generateSalt() {
    // In the secure_random package, the random generation is multiplied many times
    // https://github.com/mingchen/secure_random/blob/master/lib/secure_random.dart
    // It *should* improve randomness, but it is still not 100% bullet proof

    // On the other hand, xrandom seems to be a better implementation:
    // https://pub.dev/packages/xrandom
    final rand = Random.secure();
    final bytes = [for (int i = 0; i < 32; i++) rand.nextInt(256)];
    final randomBigInt = bytes.fold<BigInt>(BigInt.zero, (prev, byte) => (prev << 8) | BigInt.from(byte));
    final salt = Felt(randomBigInt % Felt.prime);
    return salt;
  }
}
