part of 'reset_password_cubit.dart';

abstract class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordLoading extends ResetPasswordState {}

class ResetPasswordSuccess extends ResetPasswordState {
  final dynamic response;

  ResetPasswordSuccess(this.response);
}

class ResetPasswordFailure extends ResetPasswordState {
  final String message;

  ResetPasswordFailure(this.message);
}
