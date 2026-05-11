import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/features/auth/providers/auth_provider.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/shared/enums/kyc_status_enum.dart';
import 'package:pesa_lending/shared/widgets/shared_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.stateRead<AuthProvider>().checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    final cs    = context.colorScheme;
    final auth  = context.stateWatch<AuthProvider>();
    final name  = auth.fullName ?? '';
    final phone = auth.phone ?? '';
    final kyc   = auth.kycStatus ?? 'PENDING';
    final limit = auth.creditLimit ?? '0';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('Akaunti Yangu')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          CircleAvatar(
              radius: 32,
              backgroundColor: cs.primary,
              child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: context.headlineSmall.bold.copyWith(color: cs.onPrimary))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: context.titleMedium.bold),
            const SizedBox(height: 3),
            Text(phone, style: context.bodySmall.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 6),
            StatusBadge(status: kyc),
          ])),
        ]))),
        const SizedBox(height: 12),

        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Taarifa za Mkopo', style: context.titleSmall.bold),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: AmountCard(
                  title: 'Kikomo cha Mkopo',
                  amount: (double.tryParse(limit) ?? 0).tzs,
                  icon: Icons.credit_card)),
              const SizedBox(width: 12),
              Expanded(child: AmountCard(
                  title: 'Hali ya KYC',
                  amount: KycStatus.fromString(kyc) == KycStatus.approved ? '✓ Imethibitishwa' : '○ Inasubiri',
                  bgColor: KycStatus.fromString(kyc) == KycStatus.approved
                      ? cs.secondaryContainer
                      : cs.tertiaryContainer,
                  textColor: KycStatus.fromString(kyc) == KycStatus.approved ? cs.secondary : cs.tertiary)),
            ]),
          ],
        ))),
        const SizedBox(height: 12),

        _MenuSection('Akaunti', [
          _MI(Icons.verified_user_outlined, 'Thibitisha KYC',
              sub: KycStatus.fromString(kyc) != KycStatus.approved ? 'Bonyeza kukamilisha' : 'Imekamilika',
              onTap: KycStatus.fromString(kyc) != KycStatus.approved ? () => context.push(AppRoute.kyc.path) : null,
              trailing: KycStatus.fromString(kyc) != KycStatus.approved
                  ? const Icon(Icons.chevron_right)
                  : Icon(Icons.check, color: cs.secondary)),
          _MI(Icons.pin_outlined, 'Badilisha PIN',
              onTap: () => context.push(AppRoute.authSetPin.path)),
        ]),
        const SizedBox(height: 12),

        _MenuSection('Msaada', [
          _MI(Icons.help_outline, 'Msaada & Maswali', onTap: () {}),
          _MI(Icons.phone_outlined, 'Piga Simu: 0800 000 000', onTap: () {}),
        ]),
        const SizedBox(height: 12),

        Card(child: ListTile(
          leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.logout, color: cs.error)),
          title: Text('Toka',
              style: context.titleSmall.semiBold.copyWith(color: cs.error)),
          onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
            title: const Text('Toka'),
            content: const Text('Una uhakika unataka kutoka?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hapana')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: cs.error),
                onPressed: () async {
                  Navigator.pop(context);
                  await context.stateRead<AuthProvider>().logout();
                  if (!context.mounted) return;
                  context.go(AppRoute.authWelcome.path);
                },
                child: const Text('Ndio, Toka')),
            ],
          )),
        )),
        const SizedBox(height: 24),
        Text('Pesa Lending v1.0.0 • Tanzania',
            style: context.labelSmall.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 16),
      ])),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title; final List<Widget> items;
  const _MenuSection(this.title, this.items);
  @override Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(title,
                style: context.labelSmall.bold.copyWith(
                    color: cs.onSurfaceVariant, letterSpacing: 0.5))),
        ...items.map((i) => Column(children: [const Divider(height: 1, indent: 16), i])),
      ]));
  }
}

class _MI extends StatelessWidget {
  final IconData icon; final String title; final String? sub;
  final VoidCallback? onTap; final Widget? trailing;
  const _MI(this.icon, this.title, {this.sub, this.onTap, this.trailing});
  @override Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return ListTile(
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: cs.primary, size: 20)),
      title: Text(title, style: context.bodyMedium),
      subtitle: sub != null
          ? Text(sub!, style: context.bodySmall)
          : null,
      trailing: trailing ?? Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      onTap: onTap);
  }
}
