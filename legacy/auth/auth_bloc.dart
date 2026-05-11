import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pesa_lending/core/network/api_client.dart';
import 'package:pesa_lending/core/storage/storage_service.dart';

part 'auth_event_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiClient _api;

  AuthBloc({ApiClient? api}) : _api = api ?? ApiClient(), super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuth);
    on<RegisterRequested>(_onRegister);
    on<LoginRequested>(_onLogin);
    on<OtpRequested>(_onSendOtp);
    on<OtpVerifyRequested>(_onVerifyOtp);
    on<SetPinRequested>(_onSetPin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheckAuth(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final loggedIn = await StorageService.isLoggedIn();
    if (loggedIn) {
      final userId = await StorageService.getUserId() ?? '';
      final fullName = await StorageService.getFullName() ?? '';
      final kycStatus = await StorageService.getKycStatus() ?? 'PENDING';
      final creditLimit = await StorageService.getCreditLimit() ?? '0';
      emit(AuthAuthenticated(userId: userId, fullName: fullName,
          kycStatus: kycStatus, creditLimit: creditLimit));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRegister(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _api.register({
        'phoneNumber': event.phoneNumber,
        'fullName': event.fullName,
        'password': event.password,
      });
      emit(OtpSent(phoneNumber: event.phoneNumber, purpose: 'REGISTRATION'));
    } catch (e) {
      emit(AuthError(_extractError(e)));
    }
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await _api.login({
        'phoneNumber': event.phoneNumber,
        'password': event.password,
      });
      await _saveSession(res['data']);
      final d = res['data'];
      emit(AuthAuthenticated(
        userId: d['user']['id'],
        fullName: d['user']['fullName'],
        kycStatus: d['user']['kycStatus'],
        creditLimit: d['user']['creditLimit'],
      ));
    } catch (e) {
      emit(AuthError(_extractError(e)));
    }
  }

  Future<void> _onSendOtp(OtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _api.sendOtp(event.phoneNumber, event.purpose);
      emit(OtpSent(phoneNumber: event.phoneNumber, purpose: event.purpose));
    } catch (e) {
      emit(AuthError(_extractError(e)));
    }
  }

  Future<void> _onVerifyOtp(OtpVerifyRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await _api.verifyOtp({
        'phoneNumber': event.phoneNumber,
        'otpCode': event.otpCode,
        'purpose': event.purpose,
      });
      await _saveSession(res['data']);
      final d = res['data'];
      emit(AuthAuthenticated(
        userId: d['user']['id'],
        fullName: d['user']['fullName'],
        kycStatus: d['user']['kycStatus'],
        creditLimit: d['user']['creditLimit'],
      ));
    } catch (e) {
      emit(AuthError(_extractError(e)));
    }
  }

  Future<void> _onSetPin(SetPinRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _api.setPin(event.pin);
      emit(PinSet());
    } catch (e) {
      emit(AuthError(_extractError(e)));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await StorageService.clearSession();
    emit(AuthUnauthenticated());
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    await StorageService.saveTokens(data['accessToken'], data['refreshToken']);
    final user = data['user'] as Map<String, dynamic>;
    await StorageService.saveUserInfo(
      userId: user['id'],
      phone: user['phoneNumber'],
      fullName: user['fullName'],
      kycStatus: user['kycStatus'],
      creditLimit: user['creditLimit'],
    );
  }

  String _extractError(dynamic e) {
    if (e is DioException) return e.message ?? 'Network error';
    return e.toString();
  }
}

