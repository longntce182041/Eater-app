import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/pro_api_client.dart';
import 'payment_webview_page.dart';
import 'payment_webview_windows_page.dart';
import '../providers/pro_provider.dart';

class ProUpgradePage extends ConsumerWidget {
  const ProUpgradePage({super.key});

  static bool get _supportsEmbeddedWebView {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  static bool get _isWindowsDesktop {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(proNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1E8),
        elevation: 0,
        title: const Text(
          'Upgrade Pro',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final notifier = ref.read(proNotifierProvider.notifier);
          await notifier.loadPlans();
          await notifier.loadStatus();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _heroCard(),
            const SizedBox(height: 16),
            _statusCard(state),
            if (state.status?.isPro == true) ...[
              const SizedBox(height: 12),
              _currentBenefitsCard(state),
            ],
            if (state.status?.isPro != true) ...[
              const SizedBox(height: 16),
              _planSelector(ref, state),
            ],
            if (state.error != null) ...[
              const SizedBox(height: 12),
              _errorCard(state.error!),
            ],
            const SizedBox(height: 20),
            if (state.status?.isPro != true) ...[
              _featureRow(Icons.restaurant_menu, 'Personalized AI meal plans'),
              _featureRow(Icons.insights, 'Advanced nutrition insights'),
              _featureRow(Icons.support_agent, 'Priority nutritionist support'),
              _featureRow(Icons.speed, 'Faster recipe recommendations'),
              const SizedBox(height: 28),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: state.isCreatingCheckout || state.isLoadingPlans
                      ? null
                      : () => _onUpgrade(context, ref),
                  icon: state.isCreatingCheckout
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.rocket_launch),
                  label: Text(
                    state.isCreatingCheckout
                        ? 'Creating payment link...'
                        : 'Upgrade Now',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
            if (state.checkoutUrl != null && state.checkoutUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _copyLink(context, state.checkoutUrl!),
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Copy payment link'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eater Pro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Unlock a stronger meal planning experience with premium features.',
            style: TextStyle(color: Colors.white, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(ProState state) {
    if (state.isLoadingStatus) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final status = state.status;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status?.isPro == true ? Icons.verified : Icons.info_outline,
                color: status?.isPro == true
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF666666),
              ),
              const SizedBox(width: 8),
              Text(
                status == null
                    ? 'Unable to load current plan status'
                    : (status.isPro ? 'Pro is active' : 'You are on Free plan'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          if (status?.isPro == true) ...[
            const SizedBox(height: 10),
            Text(
              'Plan: ${_planLabelFromType(status?.planType)}',
              style: const TextStyle(color: Color(0xFF444444)),
            ),
            if (status?.startDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Start date: ${dateFormat.format(status!.startDate!)}',
                style: const TextStyle(color: Color(0xFF444444)),
              ),
            ],
            if (status?.endDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'End date: ${dateFormat.format(status!.endDate!)}',
                style: const TextStyle(color: Color(0xFF444444)),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _planSelector(WidgetRef ref, ProState state) {
    if (state.isLoadingPlans) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (state.plans.isEmpty) {
      return const SizedBox.shrink();
    }

    final currency = NumberFormat.decimalPattern('vi_VN');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose your plan',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 10),
          ...state.plans.map((plan) {
            final selected = plan.planType == state.selectedPlanType;
            return InkWell(
              onTap: () => ref
                  .read(proNotifierProvider.notifier)
                  .selectPlanType(plan.planType),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFFF9800)
                        : const Color(0xFFE0E0E0),
                    width: selected ? 1.6 : 1,
                  ),
                  color:
                      selected ? const Color(0xFFFFF3E0) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF9E9E9E),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.label ?? _planLabelFromType(plan.planType),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${plan.durationDays} days',
                            style: const TextStyle(
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${currency.format(plan.amount)} VND',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _currentBenefitsCard(ProState state) {
    final status = state.status;
    if (status == null || status.isPro != true) {
      return const SizedBox.shrink();
    }

    final benefits = status.benefits;
    if (benefits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benefits in your current ${_planLabelFromType(status.planType)} plan',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 10),
          ...benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(color: Color(0xFF2D2D2D)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _planLabelFromType(String? planType) {
    switch ((planType ?? '').toLowerCase()) {
      case 'yearly':
        return 'Pro Yearly';
      case 'monthly':
      default:
        return 'Pro Monthly';
    }
  }

  Widget _featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFF9800), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF2D2D2D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFC62828)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Color(0xFFB71C1C)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onUpgrade(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(proNotifierProvider.notifier);
    final url = await notifier.createCheckout();

    if (url == null || url.isEmpty || !context.mounted) {
      return;
    }

    final urls = await ref.read(proApiClientProvider).getPayOSUrls();
    if (!context.mounted) {
      return;
    }

    if (urls.returnUrl.isEmpty || urls.cancelUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Missing return/cancel URL configuration')),
      );
      return;
    }

    PaymentWebViewResult? result;

    if (_isWindowsDesktop) {
      result = await Navigator.of(context).push<PaymentWebViewResult>(
        MaterialPageRoute(
          builder: (_) => PaymentWebViewWindowsPage(
            checkoutUrl: url,
            returnUrl: urls.returnUrl,
            cancelUrl: urls.cancelUrl,
          ),
        ),
      );
    } else if (_supportsEmbeddedWebView) {
      result = await Navigator.of(context).push<PaymentWebViewResult>(
        MaterialPageRoute(
          builder: (_) => PaymentWebViewPage(
            checkoutUrl: url,
            returnUrl: urls.returnUrl,
            cancelUrl: urls.cancelUrl,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Platform hien tai chua ho tro thanh toan in-app'),
        ),
      );
      return;
    }

    if (result == PaymentWebViewResult.success) {
      await _waitForProActivation(ref);
    } else {
      await notifier.loadStatus();
    }
    if (!context.mounted || result == null) {
      return;
    }

    String message;
    switch (result) {
      case PaymentWebViewResult.success:
        message = 'Thanh toan thanh cong. Da quay lai trang Pro.';
        break;
      case PaymentWebViewResult.cancel:
        message = 'Ban da huy thanh toan. Da quay lai trang Pro.';
        break;
      case PaymentWebViewResult.failed:
        message = 'Thanh toan khong thanh cong. Vui long thu lai.';
        break;
      case PaymentWebViewResult.unknown:
        message = 'Da quay lai trang Pro. Trang thai thanh toan chua ro rang.';
        break;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _waitForProActivation(WidgetRef ref) async {
    final notifier = ref.read(proNotifierProvider.notifier);

    for (var i = 0; i < 5; i++) {
      await notifier.loadStatus();
      final latest = ref.read(proNotifierProvider).status;
      if (latest?.isPro == true) {
        return;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> _copyLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment link copied to clipboard')),
      );
    }
  }
}
