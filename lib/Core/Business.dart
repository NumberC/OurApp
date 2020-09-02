import 'dart:convert';
import 'dart:math' as Math;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stripe_payment/stripe_payment.dart';

class Business {
  static const baseURL = "https://ourapp2.herokuapp.com";
  static const String makeAccountURL = "$baseURL/makeUserDriver";
  static const String makeCustomerURL = "$baseURL/makeCustomer";
  static const String addPaymentMethodURL = "$baseURL/addPaymentMethod";
  static const String getPaymentMethodsURL = "$baseURL/paymentMethods";
  static const String getPaymentIntentURL = "$baseURL/paymentIntent";

  static String publishable = DotEnv().env["stripePublishable"].toString();

  static const double pricePerKilometer = 4;
  static const double minimumPrice = 5;

  static void init() {
    StripePayment.setOptions(StripeOptions(
      publishableKey: publishable,
      merchantId: "Test",
      androidPayMode: "test",
    ));
  }

  static double getPrice(double meters) {
    double normalPrice = pricePerKilometer * meters / 1000;
    return Math.max(normalPrice, minimumPrice);
  }

  static Future<Map<String, dynamic>> makeUserDriver(String email) async {
    var res = await http.post(makeAccountURL, body: {
      'email': email,
    });
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> makeCustomer(String email) async {
    var res = await http.post(makeCustomerURL, body: {
      'email': email,
    });
    return jsonDecode(res.body);
  }

  static Future<void> addPaymentMethod(id, card) async {
    var response = await http.post(
      addPaymentMethodURL,
      body: json.encode(
        {
          'CustomerID': id,
          'PaymentMethod': card,
        },
      ),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return;
  }

  static Future<Map<String, dynamic>> getPaymentMethods(id) async {
    print("ALOGA");
    print(id);
    var res = await http.post(
      getPaymentMethodsURL,
      body: {
        'CustomerID': id,
      },
    );
    print(res.body);
    return Map<String, dynamic>.from(jsonDecode(res.body));
  }

  static Future<String> getPaymentIntent(driverID, kilometerDistance) async {
    var res = await http.post(
      getPaymentIntentURL,
      body: {
        'DriverID': driverID,
        'Distance': kilometerDistance,
      },
    );
    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}');
    return jsonDecode(res.body);
  }

  static Future<PaymentIntentResult> confirmPayment(
      clientSecret, paymentMethod) async {
    //paymentMethod or paymentMethodID
    return await StripePayment.confirmPaymentIntent(
      PaymentIntent(
        clientSecret: clientSecret,
        paymentMethod: paymentMethod,
      ),
    );
  }
}
