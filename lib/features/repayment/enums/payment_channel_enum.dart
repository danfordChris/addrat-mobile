import 'package:flutter/material.dart';

enum PaymentChannel {
  mpesa('MPESA', 'M-Pesa', Color(0xFF00A650)),
  airtel('AIRTEL', 'Airtel', Color(0xFFFF0000)),
  bank('BANK', 'Benki', Color(0xFF1141A8));

  const PaymentChannel(this.code, this.label, this.color);
  final String code;
  final String label;
  final Color color;
}
