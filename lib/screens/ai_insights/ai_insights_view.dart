import 'dart:async';

import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/screens/ai_insights/ai_insights_bloc.dart';
import 'package:budgetmanager/screens/components/app_dialog.dart';
import 'package:budgetmanager/screens/components/layout/title_bar.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_ai/flutter_local_ai.dart';

class AiInsightsView extends StatefulWidget {
  const AiInsightsView({super.key});

  @override
  State<AiInsightsView> createState() => _AiInsightsViewState();
}

class _AiInsightsViewState extends State<AiInsightsView> {
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _elapsedTimer?.cancel();
    setState(() => _elapsedSeconds = 0);
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  void _stopTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AiInsightsBloc, AiInsightsState>(
        listener: (context, state) {
          if (state.status == AiInsightsStatus.loading) {
            _startTimer();
          } else {
            _stopTimer();
          }

          if (state.status == AiInsightsStatus.error &&
              state.errorMessage != null) {
            showAppDialog(
              context: context,
              title: 'Analysis failed',
              content: state.errorMessage!,
              cancelLabel: null,
              confirmLabel: 'OK',
            );
          }
        },
        builder: (context, state) {
          final colors = context.appColors;
          final textTheme = Theme.of(context).textTheme;
          final rangeInvalid = state.startMonth != null &&
              state.endMonth != null &&
              state.endMonth!.date.isBefore(state.startMonth!.date);

          final canAnalyze = state.startMonth != null &&
              state.endMonth != null &&
              !rangeInvalid &&
              state.status != AiInsightsStatus.loading;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScreenHeader(title: 'AI Insights'),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.aiBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.aiAccent),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'AI INSIGHTS',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colors.aiAccent,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _MonthDropdown(
                                  label: 'Start Month',
                                  months: state.months,
                                  selected: state.startMonth,
                                  onChanged: (month) => context
                                      .read<AiInsightsBloc>()
                                      .add(
                                        AiInsightsEvent.startMonthChanged(
                                          month: month,
                                        ),
                                      ),
                                ),
                                const SizedBox(height: 12),
                                _MonthDropdown(
                                  label: 'End Month',
                                  months: state.months,
                                  selected: state.endMonth,
                                  onChanged: (month) => context
                                      .read<AiInsightsBloc>()
                                      .add(
                                        AiInsightsEvent.endMonthChanged(
                                          month: month,
                                        ),
                                      ),
                                ),
                                if (rangeInvalid)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'End month must be on or after the start month.',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colors.error,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.aiAccent,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: colors.aiAccent
                                        .withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  onPressed: canAnalyze
                                      ? () => context.read<AiInsightsBloc>().add(
                                            AiInsightsEvent.analyzeRequested(),
                                          )
                                      : null,
                                  child: const Text('Analyse'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (state.status == AiInsightsStatus.loading)
                            Column(
                              children: [
                                CircularProgressIndicator(
                                  color: colors.aiAccent,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Analysing... ${_elapsedSeconds}s',
                                  style: textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          if (state.status == AiInsightsStatus.success &&
                              state.insightText != null)
                            _InsightOutput(text: state.insightText!),
                          if (state.status == AiInsightsStatus.unsupported)
                            const _UnsupportedMessage(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MonthDropdown extends StatelessWidget {
  const _MonthDropdown({
    required this.label,
    required this.months,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<Month> months;
  final Month? selected;
  final ValueChanged<Month?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Month>(
      decoration: InputDecoration(labelText: label),
      value: selected,
      items: months
          .map(
            (m) => DropdownMenuItem<Month>(
              value: m,
              child: Text(m.name),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _InsightOutput extends StatelessWidget {
  const _InsightOutput({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Insights', style: textTheme.titleLarge),
          Divider(height: 24, color: colors.border),
          Text(text, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _UnsupportedMessage extends StatelessWidget {
  const _UnsupportedMessage();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.warningBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.warning),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: colors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'On-device AI not available',
                  style: textTheme.titleLarge?.copyWith(
                    color: colors.warningBackground.readableForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This feature requires Google AICore (Gemini Nano) to be '
            'installed on your device. Your device may not be supported, '
            'or AICore may not yet be installed.',
            style: textTheme.bodyLarge?.copyWith(
              color: colors.warningBackground.readableForeground,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Get AICore on Play Store'),
            onPressed: () async {
              final aiEngine = FlutterLocalAi();
              await aiEngine.openAICorePlayStore();
            },
          ),
        ],
      ),
    );
  }
}
