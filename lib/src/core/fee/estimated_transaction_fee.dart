import '../core/index.dart';

/// Estimated fee details for an upcoming transaction
class EstimatedTransactionFee {
  final Felt l1GasConsumed;
  final Felt l1GasPrice;
  final Felt l1DataGasConsumed;
  final Felt l1DataGasPrice;
  final Felt l2GasConsumed;
  final Felt l2GasPrice;
  final Felt overallFee;
  final String unit;

  const EstimatedTransactionFee({
    required this.l1GasConsumed,
    required this.l1GasPrice,
    required this.l1DataGasConsumed,
    required this.l1DataGasPrice,
    required this.l2GasConsumed,
    required this.l2GasPrice,
    required this.overallFee,
    required this.unit,
  });
}
