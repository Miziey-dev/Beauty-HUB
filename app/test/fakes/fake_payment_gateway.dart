import 'package:beauty_hub/data/payment_gateway.dart';

class FakePaymentGateway implements PaymentGateway {
  bool shouldSucceed;

  FakePaymentGateway({this.shouldSucceed = true});

  @override
  Future<PaymentResult> chargeDeposit({required int amountCents, required String bookingReference}) async {
    if (shouldSucceed) {
      return PaymentResult(success: true, reference: 'fake_$bookingReference');
    }
    return const PaymentResult(success: false, errorMessage: 'Card declined');
  }
}
