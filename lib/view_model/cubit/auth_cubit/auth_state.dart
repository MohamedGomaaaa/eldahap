part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

enum Status {loading, success, error}

final class LoginLoadingState extends AuthState {}

final class LoginSuccessState extends AuthState {
  final User user;
  LoginSuccessState(this.user);
}
final class LoginErrorState extends AuthState {
  final String? msg;
  LoginErrorState({this.msg});
}

final class RegisterLoadingState extends AuthState {}

final class RegisterSuccessState extends AuthState {
  final User user;
  RegisterSuccessState(this.user);
}
final class RegisterErrorState extends AuthState {
  final String? msg;
  RegisterErrorState({this.msg});
}

final class LogoutLoadingState extends AuthState {}

final class LogoutSuccessState extends AuthState {}

final class LogoutErrorState extends AuthState {
  final String? msg;
  LogoutErrorState({this.msg});
}
