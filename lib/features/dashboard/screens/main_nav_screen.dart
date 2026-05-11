import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pesa_lending/features/auth/providers/auth_provider.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/features/dashboard/screens/dashboard_screen.dart';
import 'package:pesa_lending/features/loans/screens/loan_products_screen.dart';
import 'package:pesa_lending/features/profile/screens/profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _idx = 0;

  static const _screens = [
    DashboardScreen(),
    LoanProductsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _listenForKycUpdates();
  }

  void _listenForKycUpdates() {
    // Foreground FCM: refresh profile immediately on KYC status change
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final type = message.data['type'] as String?;
      if (type == 'kyc_update' || type == 'KYC_APPROVED' || type == 'KYC_REJECTED') {
        if (mounted) {
          context.stateRead<AuthProvider>().refreshFromServer();
        }
      }
    });

    // User tapped a background notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final type = message.data['type'] as String?;
      if (type == 'kyc_update' || type == 'KYC_APPROVED' || type == 'KYC_REJECTED') {
        if (mounted) {
          context.stateRead<AuthProvider>().refreshFromServer();
          context.push(AppRoute.kyc.path);
        }
      } else if (type == 'loan_update' || type == 'LOAN_APPROVED') {
        if (mounted) setState(() => _idx = 0);
      } else if (type == 'repayment_due') {
        if (mounted) setState(() => _idx = 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          border: Border(
              top: BorderSide(color: cs.outlineVariant, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _idx,
          onDestinationSelected: (i) => setState(() => _idx = i),
          backgroundColor: cs.surfaceContainer,
          surfaceTintColor: Colors.transparent,
          indicatorColor: cs.primary.withValues(alpha: 0.12),
          destinations: [
            NavigationDestination(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedHome01,
                  color: cs.onSurfaceVariant,
                  size: 22),
              selectedIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedHome01,
                  color: cs.primary,
                  size: 22),
              label: 'Nyumbani',
            ),
            NavigationDestination(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCreditCard,
                  color: cs.onSurfaceVariant,
                  size: 22),
              selectedIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCreditCard,
                  color: cs.primary,
                  size: 22),
              label: 'Mkopo',
            ),
            NavigationDestination(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser02,
                  color: cs.onSurfaceVariant,
                  size: 22),
              selectedIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser02,
                  color: cs.primary,
                  size: 22),
              label: 'Akaunti',
            ),
          ],
        ),
      ),
    );
  }
}
