import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;

import '../../contract/contract.dart';
import '../../core/crypto/index.dart' as core;
import '../../core/index.dart';
import '../signer/stark_account_signer.dart';
import 'account_derivation.dart';

class ArgentXAccountDerivation extends AccountDerivation {
  final Felt classHash;
  final Felt implementationClassHash;

  static const String masterPrefix = "m/44'/60'/0'/0/0";
  static const String pathPrefix = "m/44'/9004'/0'/0";

  ArgentXAccountDerivation({
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
    final seed = bip39.mnemonicToSeed(mnemonic.join(' '));
    final hdNodeSingleSeed = bip32.BIP32.fromSeed(seed);
    final hdNodeDoubleSeed = bip32.BIP32.fromSeed(hdNodeSingleSeed.derivePath(masterPrefix).privateKey!);
    final child = hdNodeDoubleSeed.derivePath('$pathPrefix/$index');
    var key = child.privateKey!;
    key = core.grindKey(key);
    final privateKey = Felt(bytesToUnsignedInt(key));
    return privateKey;
  }

  @override
  List<Felt> constructorCalldata({required Felt publicKey}) {
    return [implementationClassHash, core.getSelectorByName('initialize'), Felt.two, publicKey, Felt.zero];
  }

  @override
  Felt computeAddress({required Felt publicKey}) {
    final calldata = constructorCalldata(publicKey: publicKey);
    final salt = publicKey;
    final accountAddress = Contract.computeAddress(classHash: classHash, calldata: calldata, salt: salt);
    return accountAddress;
  }
}
