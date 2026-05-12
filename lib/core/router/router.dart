import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pesa_lending/core/router/app_transitions.dart';
import 'package:pesa_lending/core/router/navigation_keys.dart';
import 'package:pesa_lending/features/auth/screens/login_screen.dart';
import 'package:pesa_lending/features/auth/screens/otp_screen.dart';
import 'package:pesa_lending/features/auth/screens/phone_entry_screen.dart';
import 'package:pesa_lending/features/auth/screens/register_screen.dart';
import 'package:pesa_lending/features/auth/screens/set_pin_screen.dart';
import 'package:pesa_lending/features/auth/screens/splash_screen.dart';
import 'package:pesa_lending/features/auth/screens/welcome_screen.dart';
import 'package:pesa_lending/features/dashboard/screens/main_nav_screen.dart';
import 'package:pesa_lending/features/dashboard/widgets/loan_calculator_screen.dart';
import 'package:pesa_lending/features/kyc/screens/employment_info_step.dart';
import 'package:pesa_lending/features/kyc/screens/financial_details_step.dart';
import 'package:pesa_lending/features/kyc/screens/kyc_review_step.dart';
import 'package:pesa_lending/features/kyc/screens/kyc_screen.dart';
import 'package:pesa_lending/features/kyc/screens/personal_info_step.dart';
import 'package:pesa_lending/features/loans/screens/loan_apply_screen.dart';
import 'package:pesa_lending/features/loans/screens/loan_products_screen.dart';
import 'package:pesa_lending/features/onboarding/language_selection_screen.dart';
import 'package:pesa_lending/features/repayment/screens/repayment_screen.dart';
import 'package:pesa_lending/services/storage_service.dart';

// ── Route Enum ────────────────────────────────────────────────

enum AppRoute {
  splash('/splash'),
  onboardingLanguage('/onboarding/language'),
  authWelcome('/auth/welcome'),
  authPhone('/auth/phone'),
  authLogin('/auth/login'),
  authRegister('/auth/register'),
  authOtp('/auth/otp'),
  authSetPin('/auth/set-pin'),
  home('/home'),
  kyc('/kyc'),
  kycPersonal('/kyc/personal'),
  kycEmployment('/kyc/employment'),
  kycFinancial('/kyc/financial'),
  kycReview('/kyc/review'),
  loansProducts('/loans/products'),
  loansCalculator('/loans/calculator'),
  loansApply('/loans/apply'),
  loanDetail('/loans/:id'),
  repayment('/loans/:loanId/repay'),
  devComponents('/dev/components'),
  ;

  const AppRoute(this.path);
 
  final String path;

  String replaceParam(String param, String value) => path.replaceFirst(':$param', value);
}

// ── Router ────────────────────────────────────────────────────

final _publicPaths = {
  AppRoute.splash.path,
  AppRoute.authWelcome.path,
  AppRoute.authPhone.path,
  AppRoute.authLogin.path,
  AppRoute.authRegister.path,
  AppRoute.authOtp.path,
  AppRoute.authSetPin.path,
  AppRoute.onboardingLanguage.path,
};

Widget _placeholder(String name) => Scaffold(body: Center(child: Text(name)));

class AppRouter {
  static final router = GoRouter(
    navigatorKey: NavigationKeys.root,
    initialLocation: AppRoute.splash.path,
    redirect: (context, state) async {
      final path = state.matchedLocation;
      final isPublic = _publicPaths.any((p) => path.startsWith(p));
      if (isPublic) return null;

      final loggedIn = await StorageService.isLoggedIn();
      if (!loggedIn) return AppRoute.authPhone.path;

      if (path == AppRoute.loansApply.path) {
        final kycStatus = await StorageService.getKycStatus();
        if (kycStatus != 'APPROVED') {
          return AppRoute.kyc.path;
        }
      }

      return null;
    },
    routes: [
      // ── Splash & Onboarding ───────────────────────────────
      GoRoute(
        path: AppRoute.splash.path,
        pageBuilder: (_, state) => AppTransitions.fadeCurveTransition(state, const SplashScreen()),
      ),
      GoRoute(
        path: AppRoute.onboardingLanguage.path,
        pageBuilder: (_, state) => AppTransitions.slideTransition(state, const LanguageSelectionScreen()),
      ),

      // ── Auth ──────────────────────────────────────────────
      GoRoute(
        path: AppRoute.authWelcome.path,
        pageBuilder: (_, state) => AppTransitions.fadeCurveTransition(state, const WelcomeScreen()),
      ),
      GoRoute(
        path: AppRoute.authPhone.path,
        pageBuilder: (_, state) => AppTransitions.fadeAndSlideTransition(state, const PhoneEntryScreen()),
      ),
      GoRoute(
        path: AppRoute.authLogin.path,
        pageBuilder: (_, state) => AppTransitions.fadeAndSlideTransition(state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoute.authRegister.path,
        pageBuilder: (_, state) => AppTransitions.slideTransition(state, const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoute.authOtp.path,
        pageBuilder: (_, state) {
          final e = state.extra as Map<String, dynamic>? ?? {};
          return AppTransitions.slideTransition(
            state,
            OtpScreen(
              phoneNumber: e['phone'] as String? ?? '',
              purpose: e['purpose'] as String? ?? 'LOGIN',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoute.authSetPin.path,
        pageBuilder: (_, state) => AppTransitions.slideTransition(state, const SetPinScreen()),
      ),

      // ── Main App ──────────────────────────────────────────
      GoRoute(
        path: AppRoute.home.path,
        pageBuilder: (_, state) => AppTransitions.fadeCurveTransition(state, const MainNavScreen()),
      ),

      // ── KYC ───────────────────────────────────────────────
      GoRoute(
        path: AppRoute.kyc.path,
        pageBuilder: (_, state) => AppTransitions.slideTransition(state, const KycScreen()),
      ),
      GoRoute(
        path: AppRoute.kycPersonal.path,
        pageBuilder: (_, state) => AppTransitions.slideTransition(state, const PersonalInfoStep()),
      ),
      GoRoute(
        path: AppRoute.kycEmployment.path,
        pageBuilder: (_, state) => AppTransitions.slideTransition(state, const EmploymentInfoStep()),
      ),
      GoRoute(
        path: AppRoute.kycFinancial.path,
        pageBuilder: (_, state) => AppTransitions.slideTransition(state, const FinancialDetailsStep()),
      ),
      GoRoute(
        path: AppRoute.kycReview.path,
        pageBuilder: (_, state) => AppTransitions.slideTransition(state, const KycReviewStep()),
      ),

      // ── Loans ─────────────────────────────────────────────
      GoRoute(
        path: AppRoute.loansProducts.path,
        pageBuilder: (_, state) => AppTransitions.slideTransition(state, const LoanProductsScreen()),
      ),
      GoRoute(
        path: AppRoute.loansCalculator.path,
        pageBuilder: (_, state) => AppTransitions.slideTransition(
          state,
          LoanCalculatorScreen(
            product: state.extra as Map<String, dynamic>?,
          ),
        ),
      ),
      GoRoute(
        path: AppRoute.loansApply.path,
        pageBuilder: (_, state) => AppTransitions.slideTransition(
          state,
          LoanApplyScreen(
            calculation: state.extra as Map<String, dynamic>? ?? {},
          ),
        ),
      ),
      GoRoute(
        path: AppRoute.loanDetail.path,
        pageBuilder: (_, state) => AppTransitions.slideTransition(
          state,
          LoanDetailScreen(loanId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoute.repayment.path,
        pageBuilder: (_, state) {
          final e = state.extra as Map<String, dynamic>? ?? {};
          return AppTransitions.slideTransition(
            state,
            RepaymentScreen(
              loanId: state.pathParameters['loanId']!,
              outstandingAmount: e['outstanding'] as String? ?? '0',
            ),
          );
        },
      ),

      // ── Dev (debug only) ──────────────────────────────────
      if (kDebugMode)
        GoRoute(
          path: AppRoute.devComponents.path,
          pageBuilder: (_, state) => AppTransitions.fadeCurveTransition(state, _placeholder('Component Gallery')),
        ),
    ],
  );
}
