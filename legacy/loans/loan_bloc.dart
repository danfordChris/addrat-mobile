import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pesa_lending/core/network/api_client.dart';

part 'loan_event_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final ApiClient _api;

  LoanBloc({ApiClient? api}) : _api = api ?? ApiClient(), super(LoanInitial()) {
    on<LoadLoanProducts>(_onLoadProducts);
    on<CalculateLoan>(_onCalculate);
    on<ApplyForLoan>(_onApply);
    on<AcceptLoan>(_onAccept);
    on<LoadMyLoans>(_onLoadMyLoans);
    on<LoadLoanDetail>(_onLoadDetail);
  }

  Future<void> _onLoadProducts(LoadLoanProducts event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    try {
      final res = await _api.getLoanProducts();
      emit(LoanProductsLoaded(products: List<Map<String, dynamic>>.from(res['data'])));
    } catch (e) { emit(LoanError(_msg(e))); }
  }

  Future<void> _onCalculate(CalculateLoan event, Emitter<LoanState> emit) async {
    emit(LoanCalculating());
    try {
      final res = await _api.calculateLoan(event.params);
      emit(LoanCalculated(result: res['data'] as Map<String, dynamic>));
    } catch (e) { emit(LoanError(_msg(e))); }
  }

  Future<void> _onApply(ApplyForLoan event, Emitter<LoanState> emit) async {
    emit(LoanSubmitting());
    try {
      final res = await _api.applyLoan(event.params);
      emit(LoanApplied(loan: res['data'] as Map<String, dynamic>));
    } catch (e) { emit(LoanError(_msg(e))); }
  }

  Future<void> _onAccept(AcceptLoan event, Emitter<LoanState> emit) async {
    emit(LoanSubmitting());
    try {
      final res = await _api.acceptLoan(event.loanId, event.pin);
      emit(LoanAccepted(loan: res['data'] as Map<String, dynamic>));
    } catch (e) { emit(LoanError(_msg(e))); }
  }

  Future<void> _onLoadMyLoans(LoadMyLoans event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    try {
      final res = await _api.getMyLoans();
      final content = res['data']['content'] as List;
      emit(MyLoansLoaded(loans: content.cast<Map<String, dynamic>>()));
    } catch (e) { emit(LoanError(_msg(e))); }
  }

  Future<void> _onLoadDetail(LoadLoanDetail event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    try {
      final res = await _api.getLoan(event.loanId);
      emit(LoanDetailLoaded(loan: res['data'] as Map<String, dynamic>));
    } catch (e) { emit(LoanError(_msg(e))); }
  }

  String _msg(dynamic e) => e is DioException ? (e.message ?? 'Error') : e.toString();
}

