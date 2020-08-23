import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stripe_payment/stripe_payment.dart';

class Business {
  bool isProduction = false;

  String publishable = DotEnv().env["stripePublishable"];
  String secret = DotEnv().env["stripeSecret"];

  double pricePerKilometer = 4;
  double minimumPrice = 5;

  void init() {
    StripePayment.setOptions(StripeOptions(
      publishableKey: publishable,
      androidPayMode: isProduction ? "production" : "test",
    ));
    StripePayment.setStripeAccount("stripeAccount");
  }

  double getPrice(double meters) {
    double normalPrice = pricePerKilometer * meters / 1000;
    return (normalPrice > minimumPrice) ? normalPrice : minimumPrice;
  }

  void createPaymentMethod(card) async {
    StripePayment.createPaymentMethod(
      PaymentMethodRequest(
        card: card,
      ),
    ).then((paymentMethod) {
      print(paymentMethod);
      //_scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${paymentMethod.id}')));
    }).catchError((error) {
      print(error);
    });
  }
}
