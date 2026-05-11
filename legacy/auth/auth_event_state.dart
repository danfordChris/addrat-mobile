part of 'auth_bloc.dart';

// ── Events ────────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  @override List<Object?> get props => [];
}

class RegisterRequested extends AuthEvent {
  final String phoneNumber, fullName, password;
  RegisterRequested({required this.phoneNumber, required this.fullName, required this.password});
  @override List<Object?> get props => [phoneNumber, fullName, password];
}

class LoginRequested extends AuthEvent {
  final String phoneNumber, password;
  LoginRequested({required this.phoneNumber, required this.password});
  @override List<Object?> get props => [phoneNumber, password];
}

class OtpRequested extends AuthEvent {
  final String phoneNumber, purpose;
  OtpRequested({required this.phoneNumber, required this.purpose});
  @override List<Object?> get props => [phoneNumber, purpose];
}

class OtpVerifyRequested extends AuthEvent {
  final String phoneNumber, otpCode, purpose;
  OtpVerifyRequested({required this.phoneNumber, required this.otpCode, required this.purpose});
  @override List<Object?> get props => [phoneNumber, otpCode, purpose];
}

class SetPinRequested extends AuthEvent {
  final String pin;
  SetPinRequested({required this.pin});
  @override List<Object?> get props => [pin];
}

class LogoutRequested extends AuthEvent {}
class CheckAuthStatus extends AuthEvent {}

// ── States ────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  @override List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String userId, fullName, kycStatus, creditLimit;
  AuthAuthenticated({required this.userId, required this.fullName,
    required this.kycStatus, required this.creditLimit});
  @override List<Object?> get props => [userId, fullName, kycStatus, creditLimit];
}
class AuthUnauthenticated extends AuthState {}
class OtpSent extends AuthState {
  final String phoneNumber, purpose;
  OtpSent({required this.phoneNumber, required this.purpose});
  @override List<Object?> get props => [phoneNumber, purpose];
}
class PinSet extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override List<Object?> get props => [message];
}

