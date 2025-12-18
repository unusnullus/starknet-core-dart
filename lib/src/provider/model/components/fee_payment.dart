import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/core/index.dart';

part 'fee_payment.freezed.dart';
part 'fee_payment.g.dart';

@freezed
class FeePayment with _$FeePayment {
  const factory FeePayment({
    required Felt amount,
    required String unit,
  }) = _FeePayment;

  factory FeePayment.fromJson(Map<String, Object?> json) =>
      _$FeePaymentFromJson(json);
}
