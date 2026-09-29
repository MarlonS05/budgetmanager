import 'package:bloc/bloc.dart';
import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/domain/entities/month_income_totals.dart';
import 'package:budgetmanager/domain/repositories/month_repository.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_repository.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AppRouter router;
  final MonthRepository repoMonth;
  final RegularPaymentRepository repoRegularPayment;

  HomeBloc(this.router, this.repoMonth, this.repoRegularPayment)
    : super(HomeState.initial()) {
    on<_Started>((event, emit) async {
      int currentMonthId = await repoMonth.getCurrentMonthId();
      Month currentMonth = (await repoMonth.getMonth(currentMonthId))!;
      final payments = await repoRegularPayment.getByMonth(
        currentMonth.date.month,
      );
      emit(
        state.copyWith(
          currentMonth: currentMonth,
          regularPaymentsTotal: payments.fold(
            0,
            (sum, payment) => sum + payment.amount,
          ),
        ),
      );
    });
    on<_Refresh>((event, emit) async {
      int currentMonthId = await repoMonth.getCurrentMonthId();
      Month currentMonth = (await repoMonth.getMonth(currentMonthId))!;
      final payments = await repoRegularPayment.getByMonth(
        currentMonth.date.month,
      );
      emit(
        state.copyWith(
          currentMonth: currentMonth,
          regularPaymentsTotal: payments.fold(
            0,
            (sum, payment) => sum + payment.amount,
          ),
        ),
      );
    });
    on<_openLive>((event, emit) async {
      int currentMonthId = await repoMonth.getCurrentMonthId();
      router.push("/index/$currentMonthId");
    });
    on<_openHistory>((event, emit) {
      router.push("/history");
    });
    on<_OpenRegularity>((event, emit) {
      router.push('/regularity');
    });
    on<_openSettings>((event, emit) {
      router.push('/settings');
    });
    on<_openAiInsights>((event, emit) {
      router.push('/ai-insights');
    });
  }
}
