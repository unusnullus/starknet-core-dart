import '../../core/index.dart';
import '../signer/base_account_signer.dart';

/// Account derivation interface
abstract class AccountDerivation {
  /// Derive [BaseAccountSigner] from given [mnemonic] and [index]
  BaseAccountSigner deriveSigner({required List<String> mnemonic, int index = 0});

  Felt derivePrivateKey({required List<String> mnemonic, int index = 0});

  /// Returns expected constructor call data
  List<Felt> constructorCalldata({required Felt publicKey});

  /// Returns account address from given [publicKey]
  Felt computeAddress({required Felt publicKey});
}
