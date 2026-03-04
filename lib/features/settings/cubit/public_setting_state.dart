import '../models/public_setting_response_model.dart';

abstract class PublicSettingState {}

class PublicSettingInitial extends PublicSettingState {}

class PublicSettingLoading extends PublicSettingState {}

class PublicSettingSuccess extends PublicSettingState {
  final PublicSettingData data;
  PublicSettingSuccess(this.data);
}

class PublicSettingError extends PublicSettingState {
  final String message;
  PublicSettingError(this.message);
}
