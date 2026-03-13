import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:khalti_checkout_flutter/khalti_checkout_flutter.dart';

class KhaltiPaymentService {
  String _resolvePublicKey({
    required bool isTestEnvironment,
    String? providedPublicKey,
  }) {
    final envKey = isTestEnvironment
        ? (dotenv.env['KHALTI_TEST_PUBLIC_KEY'] ?? '')
        : (dotenv.env['KHALTI_LIVE_PUBLIC_KEY'] ?? '');

    final resolvedKey = providedPublicKey?.trim().isNotEmpty == true
        ? providedPublicKey!.trim()
        : envKey.trim();

    if (resolvedKey.isEmpty) {
      throw StateError(
        isTestEnvironment
            ? 'Khalti test public key is missing. Add KHALTI_TEST_PUBLIC_KEY to frontend .env.'
            : 'Khalti live public key is missing. Add KHALTI_LIVE_PUBLIC_KEY to frontend .env.',
      );
    }

    return resolvedKey;
  }

  Future<void> initiatePayment({
    required BuildContext context,
    required String pidx,
    required bool isTestEnvironment,
    String? publicKey,
    required void Function(dynamic paymentResult) onPaymentResult,
    required void Function(
      String message, {
      bool needsPaymentConfirmation,
      dynamic khalti,
    })
    onMessage,
    VoidCallback? onReturn,
  }) async {
    final resolvedPublicKey = _resolvePublicKey(
      isTestEnvironment: isTestEnvironment,
      providedPublicKey: publicKey,
    );

    final payConfig = KhaltiPayConfig(
      publicKey: resolvedPublicKey,
      pidx: pidx,
      environment: isTestEnvironment ? Environment.test : Environment.prod,
    );

    final khalti = await Khalti.init(
      enableDebugging: true,
      payConfig: payConfig,
      onPaymentResult: (paymentResult, khaltiInstance) {
        onPaymentResult(paymentResult);
        // Close the in-app Khalti page immediately after success callback.
        khaltiInstance.close(context);
      },
      onMessage:
          (
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
