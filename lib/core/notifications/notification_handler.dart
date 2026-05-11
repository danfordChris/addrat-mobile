import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pesa_lending/core/router/router.dart';

class NotificationHandler {
  NotificationHandler._();

  static void handleTap(String? payload, BuildContext context) {
    if (payload == null) return;
    switch (payload) {
      case 'kyc_update':
        context.push(AppRoute.kyc.path);
      case 'loan_update':
        context.push(AppRoute.home.path);
      case 'repayment_due':
        context.push(AppRoute.home.path);
      default:
        break;
    }
  }
}
