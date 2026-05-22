import 'package:flutter/material.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/bar_progress.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/tag.dart';
import '../data/finance_repository.dart';

class ContributionDetailPage extends StatefulWidget {
  final String contributionId;
  const ContributionDetailPage({super.key, required this.contributionId});

  @override
  State<ContributionDetailPage> createState() => _ContributionDetailPageState();
}

class _ContributionDetailPageState extends State<ContributionDetailPage> {
  late final FinanceRepository _repo = FinanceRepository(sl());
  Future<_Bundle>? _future;
  bool _changed = false;

  bool get _canClose {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:financial:contribution-create');
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _load();
    setState(() {});
  }

  Future<_Bundle> _load() async {
    final results = await Future.wait([
      _repo.findById(widget.contributionId),
      _repo.listPayments(widget.contributionId),
    ]);
    return _Bundle(
      contribution: results[0] as ContributionDto,
      payments: results[1] as List<ContributionLineDto>,
    );
  }

  Future<void> _close() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Clôturer la collecte ?',
            style: AppTypography.serif(size: 22)),
        content: Text(
          'Aucun nouveau versement ne pourra plus être enregistré sur cette '
          'contribution.',
          style: AppTypography.sans(size: 13, color: AppColors.muted),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clôturer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.close(widget.contributionId);
      _changed = true;
      _reload();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FutureBuilder<_Bundle>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Erreur: ${snap.error}',
                      textAlign: TextAlign.center,
                      style: AppTypography.sans(
                          size: 13, color: AppColors.danger)),
                ),
              );
            }
            return _content(snap.data!);
          },
        ),
      ),
    );
  }

  Widget _content(_Bundle b) {
    final c = b.contribution;
    final payments = b.payments..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    return Column(
      children: [
        _hero(c),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _summaryCard(c),
                const SizedBox(height: 14),
                _channelBreakdown(payments, c.currency),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Text('VERSEMENTS (${payments.length})',
                          style: AppTypography.eyebrow()),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (payments.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.hair),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Text(
                      'Aucun versement enregistré pour cette contribution.',
                      style: AppTypography.sans(
                          size: 12.5, color: AppColors.muted),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.hair),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < payments.length; i++) ...[
                          _paymentRow(payments[i], c.currency),
                          if (i < payments.length - 1)
                            const Divider(
                                height: 1, color: AppColors.hair2),
                        ],
                      ],
                    ),
                  ),
                if (_canClose && c.isOpen) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.hair),
                      ),
                      onPressed: _close,
                      icon: const Icon(Icons.stop_circle, size: 14),
                      label: const Text('Clôturer la collecte'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _hero(ContributionDto c) {
    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RoundIconButton(
                dark: true,
                onTap: () => Navigator.pop(context, _changed),
                child: const Icon(Icons.arrow_back, size: 16),
              ),
              c.isOpen
                  ? const TagX('OUVERTE', kind: TagKind.success)
                  : const TagX('CLÔTURÉE'),
            ],
          ),
          const SizedBox(height: 14),
          Text('COLLECTE FINANCIÈRE',
              style:
                  AppTypography.eyebrow(color: Colors.white.withOpacity(0.55))),
          const SizedBox(height: 4),
          Text(
            c.title,
            style: AppTypography.serif(
                size: 24,
                color: Colors.white,
                letterSpacing: -0.4,
                height: 1.15),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatAmount(c.totalContributed),
                  style: AppTypography.serif(
                      size: 38,
                      color: Colors.white,
                      height: 0.95,
                      letterSpacing: -1.0)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(c.currency,
                    style: AppTypography.mono(
                        size: 12,
                        color: Colors.white.withOpacity(0.55))),
              ),
              const Spacer(),
              Text(Fmt.percent(c.ratio),
                  style: AppTypography.serif(
                      size: 24,
                      color: Colors.white,
                      letterSpacing: -0.3)),
            ],
          ),
          const SizedBox(height: 8),
          BarProgress(
            value: c.ratio,
            color: Colors.white,
            track: Colors.white.withOpacity(0.14),
            height: 3,
          ),
          const SizedBox(height: 6),
          Text(
            'Objectif ${_formatAmount(c.objectiveAmount)} ${c.currency}',
            style: AppTypography.mono(
                size: 10,
                color: Colors.white.withOpacity(0.55),
                letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(ContributionDto c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INFORMATIONS', style: AppTypography.eyebrow()),
          const SizedBox(height: 8),
          _kv('Devise', c.currency),
          _kv('Ouverte le', _formatDate(c.dateOpen)),
          if (c.dateClose != null)
            _kv('Clôturée le', _formatDate(c.dateClose!)),
          _kv('Statut', c.status),
        ],
      ),
    );
  }

  Widget _channelBreakdown(List<ContributionLineDto> payments, String currency) {
    if (payments.isEmpty) return const SizedBox.shrink();
    final byChannel = <PaymentChannel, double>{};
    for (final p in payments) {
      byChannel[p.paymentChannel] =
          (byChannel[p.paymentChannel] ?? 0) + p.amount;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RÉPARTITION PAR CANAL',
              style: AppTypography.eyebrow()),
          const SizedBox(height: 8),
          for (final entry in byChannel.entries) ...[
            Row(
              children: [
                Icon(_iconFor(entry.key), size: 16, color: AppColors.ink),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(entry.key.label,
                      style: AppTypography.sans(size: 13)),
                ),
                Text('${_formatAmount(entry.value)} $currency',
                    style: AppTypography.serif(
                        size: 14, letterSpacing: -0.2)),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  Widget _paymentRow(ContributionLineDto p, String currency) {
    final name = p.contributorName ?? 'Anonyme';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              border: Border.all(color: AppColors.hair),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(_iconFor(p.paymentChannel),
                size: 14, color: AppColors.ink),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTypography.sans(
                        size: 13.5, weight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(p.paymentDate)} · ${p.paymentChannel.label}'
                  '${p.paymentReference == null || p.paymentReference!.isEmpty ? "" : " · ${p.paymentReference}"}',
                  style: AppTypography.sans(
                      size: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            '${_formatAmount(p.amount)} $currency',
            style: AppTypography.serif(size: 16, letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(PaymentChannel c) => switch (c) {
        PaymentChannel.cash => Icons.payments_outlined,
        PaymentChannel.mtnMomo => Icons.smartphone_outlined,
        PaymentChannel.orangeMoney => Icons.smartphone_outlined,
        PaymentChannel.bankTransfer => Icons.account_balance_outlined,
      };

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(k.toUpperCase(),
                  style: AppTypography.mono(
                      size: 10,
                      color: AppColors.muted,
                      letterSpacing: 1.2)),
            ),
            Expanded(
              child: Text(v,
                  style: AppTypography.sans(
                      size: 13, weight: FontWeight.w500)),
            ),
          ],
        ),
      );

  String _formatDate(DateTime d) => Fmt.dateShort(d);

  String _formatAmount(double v) {
    if (v >= 10000) return Fmt.amountCompact(v);
    if (v == v.roundToDouble()) return Fmt.amount(v);
    return Fmt.amount(v, decimals: 2);
  }
}

class _Bundle {
  final ContributionDto contribution;
  final List<ContributionLineDto> payments;
  _Bundle({required this.contribution, required this.payments});
}
