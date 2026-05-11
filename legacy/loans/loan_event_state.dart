part of 'loan_bloc.dart';

// Events
abstract class LoanEvent extends Equatable {
  @override List<Object?> get props => [];
}
class LoadLoanProducts extends LoanEvent {}
class CalculateLoan extends LoanEvent {
  final Map<String, dynamic> params;
  CalculateLoan(this.params);
  @override List<Object?> get props => [params];
}
class ApplyForLoan extends LoanEvent {
  final Map<String, dynamic> params;
  ApplyForLoan(this.params);
  @override List<Object?> get props => [params];
}
class AcceptLoan extends LoanEvent {
  final String loanId, pin;
  AcceptLoan({required this.loanId, required this.pin});
  @override List<Object?> get props => [loanId, pin];
}
class LoadMyLoans extends LoanEvent {}
class LoadLoanDetail extends LoanEvent {
  final String loanId;
  LoadLoanDetail(this.loanId);
  @override List<Object?> get props => [loanId];
}

// States
abstract class LoanState extends Equatable {
  @override List<Object?> get props => [];
}
class LoanInitial extends LoanState {}
class LoanLoading extends LoanState {}
class LoanCalculating extends LoanState {}
class LoanSubmitting extends LoanState {}

class LoanProductsLoaded extends LoanState {
  final List<Map<String, dynamic>> products;
  LoanProductsLoaded({required this.products});
  @override List<Object?> get props => [products];
}
class LoanCalculated extends LoanState {
  final Map<String, dynamic> result;
  LoanCalculated({required this.result});
  @override List<Object?> get props => [result];
}
class LoanApplied extends LoanState {
  final Map<String, dynamic> loan;
  LoanApplied({required this.loan});
  @override List<Object?> get props => [loan];
}
class LoanAccepted extends LoanState {
  final Map<String, dynamic> loan;
  LoanAccepted({required this.loan});
  @override List<Object?> get props => [loan];
}
class MyLoansLoaded extends LoanState {
  final List<Map<String, dynamic>> loans;
  MyLoansLoaded({required this.loans});
  @override List<Object?> get props => [loans];
}
class LoanDetailLoaded extends LoanState {
  final Map<String, dynamic> loan;
  LoanDetailLoaded({required this.loan});
  @override List<Object?> get props => [loan];
}
class LoanError extends LoanState {
  final String message;
  LoanError(this.message);
  @override List<Object?> get props => [message];
}

