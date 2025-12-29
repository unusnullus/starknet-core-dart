import '../../contract/contract.dart';
import '../../core/crypto/index.dart' as core;
import '../../core/index.dart';
import '../signer/stark_account_signer.dart';
import 'account_derivation.dart';

class OpenzeppelinAccountDerivation implements AccountDerivation {
  final Felt classHash;
  final Felt implementationClassHash;

  OpenzeppelinAccountDerivation({
    required this.classHash,
    required this.implementationClassHash,
  });

  @override
  StarkAccountSigner deriveSigner({required List<String> mnemonic, int index = 0}) {
    final privateKey = derivePrivateKey(mnemonic: mnemonic, index: index);
    return StarkAccountSigner(signer: StarkSigner(privateKey: privateKey));
  }

  @override
  Felt derivePrivateKey({required List<String> mnemonic, int index = 0}) {
    return core.derivePrivateKey(mnemonic: mnemonic.join(' '), index: index);
  }

  @override
  Felt computeAddress({required Felt publicKey}) {
    final calldata = constructorCalldata(publicKey: publicKey);
    final salt = publicKey;
    final accountAddress = Contract.computeAddress(classHash: classHash, calldata: calldata, salt: salt);
    return accountAddress;
  }

  @override
  List<Felt> constructorCalldata({required Felt publicKey}) {
    return [implementationClassHash, core.getSelectorByName('initializer'), Felt.one, publicKey];
  }
}
