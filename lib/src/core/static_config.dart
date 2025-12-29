import 'core/types/index.dart';

class StarknetChainId {
  static final mainnet = Felt.fromString('SN_MAIN');
  static final testNet = Felt.fromString('SN_SEPOLIA');
}

class TransactionHashPrefix {
  static final declare = Felt.fromString('declare');
  static final deploy = Felt.fromString('deploy');
  static final deployAccount = Felt.fromString('deploy_account');
  static final invoke = Felt.fromString('invoke');
  static final l1Handler = Felt.fromString('l1_handler');
}

final udcAddress = Felt.fromHexString(
  '0x041a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf',
);
