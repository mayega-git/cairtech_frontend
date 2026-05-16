import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/bar_progress.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/tag.dart';
import '../data/finance_repository.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  late final FinanceRepository _repo = FinanceRepository(sl());
  Future<List<ContributionDto>>? _future;

  String? get _bibleClubId {
    final s = sl<AuthBloc>().state;
    if (s is AuthAuthenticated) return s.user.bibleClubId;
    return null;
  }

  bool get _canCreate {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:financial:contribution-create');
  }

  bool get _canRecord {
    final s = sl<AuthBloc>().state;
    if (s is! AuthAuthenticated) return false;
    return s.user.hasPermission('bbcms:financial:contribution-record');
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final id = _bibleClubId;
    if (id == null) {
      _future = Future.value([]);
    } else {
      _future = _repo.listByBibleClub(id);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RoundIconButton(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go('/home'),
                    child: const Icon(Icons.arrow_back, size: 16),
                  ),
                  Row(
                    children: [
                      RoundIconButton(
                        onTap: _reload,
                        child: const Icon(Icons.refresh, size: 15),
                      ),
                      const SizedBox(width: 6),
                      if (_canCreate)
                        RoundIconButton(
                          onTap: () async {
                            final ok = await _showCreateDialog();
                            if (ok == true) _reload();
                          },
                          child: const Icon(Icons.add, size: 16),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const ScreenHeader(
              eyebrow: 'BBC · FINANCE',
              title: 'Contributions',
              subtitle: 'Suivi des collectes et versements',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _reload(),
                child: FutureBuilder<List<ContributionDto>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text('Erreur: ${snap.error}',
                                style: AppTypography.sans(
                                    size: 12, color: AppColors.danger)),
                          ),
                        ],
                      );
                    }
                    final list = snap.data ?? const [];
                    return _content(list);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(List<ContributionDto> all) {
    final open = all.where((c) => c.isOpen).toList()
      ..sort((a, b) => b.dateOpen.compareTo(a.dateOpen));
    final closed = all.where((c) => !c.isOpen).toList()
      ..sort((a, b) => b.dateOpen.compareTo(a.dateOpen));

    if (all.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 32, color: AppColors.muted),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune contribution active.',
                    style: AppTypography.sans(
                        size: 13, color: AppColors.muted),
                  ),
                  if (_canCreate) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await _showCreateDialog();
                        if (ok == true) _reload();
                      },
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Démarrer une collecte'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        _summaryHero(open),
        const SizedBox(height: 16),
        if (open.isNotEmpty) ...[
          _sectionTitle('CONTRIBUTIONS OUVERTES (${open.length})'),
          for (final c in open) _contributionCard(c, true),
        ],
        if (closed.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionTitle('CLÔTURÉES (${closed.length})'),
          for (final c in closed) _contributionCard(c, false),
        ],
      ],
    );
  }

  Widget _summaryHero(List<ContributionDto> open) {
    final totalObjective =
        open.fold<double>(0, (s, c) => s + c.objectiveAmount);
    final totalContributed =
        open.fold<double>(0, (s, c) => s + c.totalContributed);
    final ratio = totalObjective == 0
        ? 0.0
        : (totalContributed / totalObjective).clamp(0.0, 1.0);
    final currency = open.isEmpty ? 'USD' : open.first.currency;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL CONTRIBUÉ · ${DateTime.now().year}',
              style:
                  AppTypography.eyebrow(color: Colors.white.withOpacity(0.55))),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatAmount(totalContributed),
                style: AppTypography.serif(
                    size: 48,
                    color: Colors.white,
                    height: 0.95,
                    letterSpacing: -1.3),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(currency,
                    style: AppTypography.mono(
                        size: 13,
                        color: Colors.white.withOpacity(0.55))),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (totalObjective > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Objectif ${_formatAmount(totalObjective)} $currency',
                  style: AppTypography.mono(
                      size: 11,
                      color: Colors.white.withOpacity(0.55),
                      letterSpacing: 0.8),
                ),
                Text(
                  '${(ratio * 100).toStringAsFixed(0)}%',
                  style: AppTypography.serif(
                      size: 16, color: Colors.white, letterSpacing: -0.2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BarProgress(
              value: ratio,
              color: Colors.white,
              track: Colors.white.withOpacity(0.14),
              height: 3,
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '${open.length} collecte${open.length > 1 ? "s" : ""} ouverte${open.length > 1 ? "s" : ""}',
            style: AppTypography.mono(
                size: 10,
                color: Colors.white.withOpacity(0.55),
                letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String s) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
        child: Text(s, style: AppTypography.eyebrow()),
      );

  Widget _contributionCard(ContributionDto c, bool canPay) {
    final ratio = c.ratio;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () async {
        await context.push('${AppRoutes.financeBase}/${c.id}');
        _reload();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(c.title,
                      style: AppTypography.sans(
                          size: 14.5, weight: FontWeight.w500)),
                ),
                _statusBadge(c.status),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${_formatAmount(c.totalContributed)} ${c.currency}',
                    style: AppTypography.serif(
                        size: 20, letterSpacing: -0.3)),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '/ ${_formatAmount(c.objectiveAmount)}',
                    style: AppTypography.mono(
                        size: 11, color: AppColors.muted),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(ratio * 100).toStringAsFixed(0)} %',
                  style: AppTypography.serif(
                      size: 16,
                      letterSpacing: -0.2,
                      color: ratio >= 1.0
                          ? AppColors.positive
                          : AppColors.ink),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BarProgress(
              value: ratio,
              color: ratio >= 1.0 ? AppColors.positive : AppColors.ink,
            ),
            if (canPay && _canRecord) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final ok = await _showPaymentDialog(c);
                      if (ok == true) _reload();
                    },
                    icon: const Icon(Icons.add, size: 12),
                    label: Text('VERSER',
                        style: AppTypography.mono(
                            size: 10,
                            weight: FontWeight.w600,
                            letterSpacing: 1.4,
                            color: AppColors.ink)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String s) => switch (s) {
        'OPEN' => const TagX('OUVERTE', kind: TagKind.success),
        'CLOSED' => const TagX('CLÔTURÉE'),
        _ => TagX(s),
      };

  Future<bool?> _showCreateDialog() async {
    final title = TextEditingController();
    final description = TextEditingController();
    final objective = TextEditingController(text: '500');
    String? err;

    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
            title:
                Text('Nouvelle collecte', style: AppTypography.serif(size: 22)),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TITRE', style: AppTypography.eyebrow()),
                  const SizedBox(height: 4),
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(
                        hintText: 'Édifice Gospel — Construction salle'),
                  ),
                  const SizedBox(height: 10),
                  Text('OBJECTIF (USD)', style: AppTypography.eyebrow()),
                  const SizedBox(height: 4),
                  TextField(
                    controller: objective,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '500'),
                  ),
                  const SizedBox(height: 10),
                  Text('DESCRIPTION (OPTIONNEL)',
                      style: AppTypography.eyebrow()),
                  const SizedBox(height: 4),
                  TextField(
                    controller: description,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        hintText: 'Objectif et utilisation des fonds…'),
                  ),
                  if (err != null) ...[
                    const SizedBox(height: 10),
                    Text(err!,
                        style: AppTypography.sans(
                            size: 12, color: AppColors.danger)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Annuler')),
              ElevatedButton(
                onPressed: () async {
                  if (title.text.trim().isEmpty) {
                    setS(() => err = 'Titre requis');
                    return;
                  }
                  final obj = double.tryParse(objective.text) ?? 0;
                  if (obj <= 0) {
                    setS(() => err = 'Objectif doit être > 0');
                    return;
                  }
                  try {
                    final today = DateTime.now();
                    final dateOpen =
                        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                    await _repo.openContribution(
                      bibleClubId: _bibleClubId!,
                      title: title.text.trim(),
                      description: description.text.trim().isEmpty
                          ? null
                          : description.text.trim(),
                      objective: obj,
                      dateOpen: dateOpen,
                    );
                    Navigator.pop(ctx, true);
                  } catch (e) {
                    setS(() => err = '$e');
                  }
                },
                child: const Text('Démarrer'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<bool?> _showPaymentDialog(ContributionDto c) async {
    final amount = TextEditingController(text: '10');
    final contributorName = TextEditingController();
    final reference = TextEditingController();
    PaymentChannel channel = PaymentChannel.cash;
    bool isMember = true;
    String? err;

    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
            title: Text('Enregistrer un versement',
                style: AppTypography.serif(size: 22)),
            content: SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title,
                        style: AppTypography.sans(
                            size: 13.5, weight: FontWeight.w500)),
                    Text('Objectif ${_formatAmount(c.objectiveAmount)} ${c.currency}',
                        style: AppTypography.sans(
                            size: 11.5, color: AppColors.muted)),
                    const SizedBox(height: 14),
                    Text('MONTANT (${c.currency})',
                        style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    TextField(
                      controller: amount,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '10'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final v in [5, 10, 25, 50]) ...[
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  setS(() => amount.text = v.toString()),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surface2,
                                  border: Border.all(color: AppColors.hair),
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.sm),
                                ),
                                alignment: Alignment.center,
                                child: Text('$v',
                                    style: AppTypography.serif(
                                        size: 14, letterSpacing: -0.2)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('CONTRIBUTEUR', style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: _toggleBtn(
                            label: 'Moi (membre)',
                            selected: isMember,
                            onTap: () => setS(() => isMember = true),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _toggleBtn(
                            label: 'Non-membre',
                            selected: !isMember,
                            onTap: () => setS(() => isMember = false),
                          ),
                        ),
                      ],
                    ),
                    if (!isMember) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: contributorName,
                        decoration: const InputDecoration(
                            hintText: 'Nom du contributeur'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text('CANAL DE PAIEMENT',
                        style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: PaymentChannel.values
                          .map((pc) => _channelChip(
                                label: pc.label,
                                selected: channel == pc,
                                onTap: () => setS(() => channel = pc),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    Text('RÉFÉRENCE (OPTIONNEL)',
                        style: AppTypography.eyebrow()),
                    const SizedBox(height: 4),
                    TextField(
                      controller: reference,
                      decoration: const InputDecoration(
                          hintText: 'N° transaction, reçu…'),
                    ),
                    if (err != null) ...[
                      const SizedBox(height: 10),
                      Text(err!,
                          style: AppTypography.sans(
                              size: 12, color: AppColors.danger)),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Annuler')),
              ElevatedButton(
                onPressed: () async {
                  final v = double.tryParse(amount.text) ?? 0;
                  if (v <= 0) {
                    setS(() => err = 'Montant > 0 requis');
                    return;
                  }
                  if (!isMember && contributorName.text.trim().isEmpty) {
                    setS(() => err = 'Nom du contributeur requis');
                    return;
                  }
                  try {
                    final me = sl<AuthBloc>().state;
                    String? myMemberId;
                    if (isMember && me is AuthAuthenticated) {
                      // Fetch member/me to get memberId — keep simple here:
                      // backend accepts memberId=null + contributorName, but
                      // pour un membre on doit fournir le memberId réel.
                      // On laisse l'utilisateur saisir le nom si non-membre,
                      // et on omet le memberId pour la simplicité de la V1.
                    }
                    await _repo.recordPayment(
                      contributionId: c.id,
                      memberId: myMemberId,
                      contributorName: isMember
                          ? me is AuthAuthenticated
                              ? me.user.displayName
                              : null
                          : contributorName.text.trim(),
                      amount: v,
                      channel: channel,
                      reference: reference.text.trim().isEmpty
                          ? null
                          : reference.text.trim(),
                      paymentDate:
                          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                    );
                    Navigator.pop(ctx, true);
                  } catch (e) {
                    setS(() => err = '$e');
                  }
                },
                child: const Text('Confirmer'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _toggleBtn({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          border: Border.all(
              color: selected ? AppColors.ink : AppColors.hair),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(label,
            style: AppTypography.sans(
                size: 12.5,
                weight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.ink)),
      ),
    );
  }

  Widget _channelChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          border: Border.all(
              color: selected ? AppColors.ink : AppColors.hair),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: AppTypography.sans(
                size: 12,
                weight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.ink)),
      ),
    );
  }

  String _formatAmount(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 10000) return '${(v / 1000).toStringAsFixed(1)}K';
    // Affichage entier ou avec 2 décimales selon valeur
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }
}
