import 'package:pesa_lending/features/auth/providers/auth_provider.dart';
import 'package:pesa_lending/features/kyc/providers/kyc_provider.dart';
import 'package:pesa_lending/features/loans/providers/loan_provider.dart';
import 'package:pesa_lending/features/onboarding/providers/preferences_provider.dart';
import 'package:pesa_lending/features/profile/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => AuthProvider()),
  ChangeNotifierProvider(create: (_) => LoanProvider()),
  ChangeNotifierProvider(create: (_) => KycProvider()),
  ChangeNotifierProvider(create: (_) => UserProvider()),
  ChangeNotifierProvider(create: (_) => PreferencesProvider()),
];
