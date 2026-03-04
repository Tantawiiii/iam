import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_service.dart';
import '../models/public_setting_response_model.dart';
import 'public_setting_state.dart';

class PublicSettingCubit extends Cubit<PublicSettingState> {
  final ApiService _apiService;

  PublicSettingCubit(this._apiService) : super(PublicSettingInitial());

  Future<void> getPublicSettings() async {
    emit(PublicSettingLoading());
    try {
      final response = await _apiService.get(ApiConstants.publicSetting);
      if (response.statusCode == 200) {
        final model = PublicSettingResponseModel.fromJson(response.data);
        if (model.data.isNotEmpty) {
          emit(PublicSettingSuccess(model.data.first));
        } else {
          emit(PublicSettingError("No settings found"));
        }
      } else {
        emit(PublicSettingError("Failed to fetch settings"));
      }
    } catch (e) {
      emit(PublicSettingError(e.toString()));
    }
  }
}
