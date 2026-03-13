import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:khalti_checkout_flutter/khalti_checkout_flutter.dart';

class KhaltiPaymentService {
  Future<void> initiatePayment({
    required BuildContext context,
    required String publicKey,
    required String pidx,
    required bool isTestEnvironment,
    required void Function(dynamic paymentResult) onPaymentResult,
    required void Function(
      String message, {
      bool needsPaymentConfirmation,
      dynamic khalti,
    }) onMessage,
    VoidCallback? onReturn,
  }) async {
    final payConfig = KhaltiPayConfig(
      publicKey: publicKey,
      pidx: pidx,
      environment: isTestEnvironment ? Environment.test : Environment.prod,
    );

    final khalti = await Khalti.init(
      enableDebugging: true,
      payConfig: payConfig,
      onPaymentResult: (paymentResult, khaltiInstance) {
        onPaymentResult(paymentResult);
      },
      onMessage: (
        khaltiInstance, {
        description,
        statusCode,
        event,
        needsPaymentConfirmation,
      }) async {
        final text =
            'Description: $description, Status Code: $statusCode, Event: $event';
        log(text);
        onMessage(
          text,
          needsPaymentConfirmation: needsPaymentConfirmation ?? false,
          khalti: khaltiInstance,
        );
      },
      onReturn: () {
        if (onReturn != null) {
          onReturn();
        }
      },
    );

    khalti.open(context);
  }
}
