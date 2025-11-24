part of 'verify_otp_cubit.dart';

abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpLoading extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {
  final dynamic data;
  VerifyOtpSuccess(this.data);
}

class VerifyOtpFailure extends VerifyOtpState {
  final String message;
  VerifyOtpFailure(this.message);
}
