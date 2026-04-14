import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:flutter/foundation.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";

/// eSewa SDK test credentials
final String _testClientId = dotenv.env['TESTCLIENTID'] ?? "";
final String _testSecretKey = dotenv.env['TESTSECRETKEY'] ?? "";

/// Service that wraps the eSewa Flutter SDK for payment operations.
class EsewaPaymentService {
  /// Whether to use live or test environment.
  /// Set to true for production.
  final bool useLiveEnvironment;

  /// Live credentials (provided by eSewa after testing)
  final String? liveClientId;
  final String? liveSecretKey;

  /// Optional test credentials from backend (preferred over local dotenv)
  final String? testClientId;
  final String? testSecretKey;

  EsewaPaymentService({
    this.useLiveEnvironment = false,
    this.liveClientId,
    this.liveSecretKey,
    this.testClientId,
    this.testSecretKey,
  });

  /// Initiate an eSewa payment via the SDK.
  ///
  /// [productId] - Unique product/order identifier
  /// [productName] - Display name for the payment
  /// [amount] - Amount in NPR
  /// [onSuccess] - Callback when payment succeeds
  /// [onFailure] - Callback when payment fails
  /// [onCancellation] - Callback when user cancels
  /// [callbackUrl] - Optional callback URL for live environment
  void initiatePayment({
    required String productId,
    required String productName,
    required String amount,
    required Function(EsewaPaymentSuccessResult) onSuccess,
    required Function(dynamic) onFailure,
    required Function(dynamic) onCancellation,
    String callbackUrl = '',
  }) {
    try {
      final environment = useLiveEnvironment
          ? Environment.live
          : Environment.test;
      final fallbackTestClientId = testClientId ?? _testClientId;
      final fallbackTestSecretKey = testSecretKey ?? _testSecretKey;
      final clientId = useLiveEnvironment
          ? (liveClientId ?? fallbackTestClientId)
          : fallbackTestClientId;
      final secretKey = useLiveEnvironment
          ? (liveSecretKey ?? fallbackTestSecretKey)
          : fallbackTestSecretKey;

      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: environment,
          clientId: clientId,
          secretId: secretKey,
        ),
        esewaPayment: EsewaPayment(
          productId: productId,
          productName: productName,
          productPrice: amount,
          callbackUrl: callbackUrl,
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) {
          debugPrint(
            ":::eSewa SUCCESS::: => productId: ${data.productId}, "
            "refId: ${data.refId}, status: ${data.status}",
          );
          onSuccess(data);
        },
        onPaymentFailure: (data) {
          debugPrint(":::eSewa FAILURE::: => $data");
          onFailure(data);
        },
        onPaymentCancellation: (data) {
          debugPrint(":::eSewa CANCELLATION::: => $data");
          onCancellation(data);
        },
      );
    } on Exception catch (e) {
      debugPrint("eSewa EXCEPTION: ${e.toString()}");
      onFailure(e.toString());
    }
  }
}
