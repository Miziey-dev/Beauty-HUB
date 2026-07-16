class PaymentResult {
  final bool success;
  final String? reference;
  final String? errorMessage;

  const PaymentResult({required this.success, this.reference, this.errorMessage});
}

/// Screen 5c's "Pay via Paystack sheet" (docs/consumer-flow.md). Kept
/// behind an interface, same pattern as MapPlaceholder for Google Maps --
/// swap [StubPaystackGateway] for a real `flutter_paystack`/checkout
/// integration once a public key exists (see .env.example).
abstract class PaymentGateway {
  Future<PaymentResult> chargeDeposit({
    required int amountCents,
    required String bookingReference,
  });
}

class StubPaystackGateway implements PaymentGateway {
  @override
  Future<PaymentResult> chargeDeposit({
    required int amountCents,
    required String bookingReference,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return PaymentResult(success: true, reference: 'stub_$bookingReference');
  }
}
