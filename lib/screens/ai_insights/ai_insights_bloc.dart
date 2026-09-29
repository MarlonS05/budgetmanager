import 'package:bloc/bloc.dart';
import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/domain/entities/month_income_totals.dart';
import 'package:budgetmanager/domain/repositories/month_repository.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_repository.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_snapshot_repository.dart';
import 'package:budgetmanager/logger/logger.dart';
import 'package:flutter_local_ai/flutter_local_ai.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_insights_event.dart';
part 'ai_insights_state.dart';
part 'ai_insights_bloc.freezed.dart';

class AiInsightsBloc extends Bloc<AiInsightsEvent, AiInsightsState> {
  final MonthRepository repoMonth;
  final RegularPaymentRepository repoRegularPayment;
  final RegularPaymentSnapshotRepository repoRegularPaymentSnapshot;

  AiInsightsBloc(
    this.repoMonth,
    this.repoRegularPayment,
    this.repoRegularPaymentSnapshot,
  ) : super(AiInsightsState.initial()) {
    // Load all months so the user can pick a date range.
    on<_Started>((event, emit) async {
      final months = await repoMonth.getAllMonths();
      emit(state.copyWith(months: months));
    });

    // Update the selected start month and clear previous results.
    on<_StartMonthChanged>((event, emit) {
      emit(
        state.copyWith(
          startMonth: event.month,
          insightText: null,
          errorMessage: null,
          status: AiInsightsStatus.idle,
        ),
      );
    });

    // Update the selected end month and clear previous results.
    on<_EndMonthChanged>((event, emit) {
      emit(
        state.copyWith(
          endMonth: event.month,
          insightText: null,
          errorMessage: null,
          status: AiInsightsStatus.idle,
        ),
      );
    });

    // Run on-device AI inference for the selected month range.
    on<_AnalyzeRequested>((event, emit) async {
      final startMonth = state.startMonth;
      final endMonth = state.endMonth;

      // Guard: both months must be selected and range must be valid.
      if (startMonth == null || endMonth == null) return;
      if (endMonth.date.isBefore(startMonth.date)) return;

      // Filter months to the selected range (inclusive).
      final selectedMonths = state.months
          .where(
            (m) =>
                !m.date.isBefore(startMonth.date) &&
                !m.date.isAfter(endMonth.date),
          )
          .toList();

      emit(
        state.copyWith(
          status: AiInsightsStatus.loading,
          insightText: null,
          errorMessage: null,
        ),
      );

      try {
        final aiEngine = FlutterLocalAi();

        // Check whether on-device AI is supported on this device.
        final isAvailable = await aiEngine.isAvailable();
        if (!isAvailable) {
          emit(state.copyWith(status: AiInsightsStatus.unsupported));
          return;
        }

        // Initialise the model with budget-analysis instructions.
        await aiEngine.initialize(
          instructions:
              'You are a personal finance assistant. Analyse the provided '
              'monthly spending data and give concise, actionable feedback '
              'about spending patterns and trends. Focus only on the data '
              'provided. Do not give general financial advice.',
        );

        final prompt = await _buildPrompt(selectedMonths);
        logger.d('AI Insights prompt:\n$prompt');

        final response = await aiEngine.generateText(
          prompt: prompt,
          config: _getConfig(),
        );

        emit(
          state.copyWith(
            status: AiInsightsStatus.success,
            insightText: response.text,
          ),
        );
      } catch (e, stackTrace) {
        logger.e('AI Insights error', error: e, stackTrace: stackTrace);

        // Distinguish "not supported" errors (AICore error code -101) from
        // generic errors so the view can show the right recovery UI.
        final errorString = e.toString();
        if (errorString.contains('-101') ||
            errorString.contains('AICore') ||
            errorString.contains('not available')) {
          emit(state.copyWith(status: AiInsightsStatus.unsupported));
        } else {
          emit(
            state.copyWith(
              status: AiInsightsStatus.error,
              errorMessage: errorString,
            ),
          );
        }
      }
    });
  }

  /// Build a structured prompt from the list of months to send to the AI.
  Future<String> _buildPrompt(List<Month> months) async {
    final buffer = StringBuffer();
    final closedMonthIds = months
        .where((month) => month.closedOn != null)
        .map((month) => month.id)
        .toList(growable: false);
    final snapshots = await repoRegularPaymentSnapshot.getByMonthIds(
      closedMonthIds,
    );
    buffer.writeln(
      'Below is monthly budget data. Please analyse the spending patterns '
      'and provide specific, actionable feedback and suggestions. '
      'Do NOT give general financial advice — only comment on what the data shows.\n',
    );

    for (final month in months) {
      final regularPaymentsTotal = month.closedOn == null
          ? (await repoRegularPayment.getByMonth(
              month.date.month,
            )).fold<double>(0, (sum, payment) => sum + payment.amount)
          : snapshots[month.id]?.amount ?? 0;
      final totals = MonthIncomeTotals.fromMonth(
        month,
        regularPayments: regularPaymentsTotal,
      );
      buffer.writeln('--- ${month.name} ---');
      buffer.writeln('Income: €${month.income.toStringAsFixed(2)}');
      buffer.writeln('Total spent: €${totals.spent.toStringAsFixed(2)}');
      buffer.writeln('Budgeted income: €${totals.budgeted.toStringAsFixed(2)}');
      buffer.writeln('Budgets:');
      for (final budget in month.budgets) {
        final pct = budget.limit > 0
            ? ((budget.currentUsed / budget.limit) * 100).toStringAsFixed(0)
            : 'N/A';
        buffer.writeln(
          '  • ${budget.name}: '
          '€${budget.currentUsed.toStringAsFixed(2)} / '
          '€${budget.limit.toStringAsFixed(2)} ($pct%)',
        );
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  GenerationConfig _getConfig() {
    return GenerationConfig(maxTokens: 500, temperature: 0.2);
  }
}
