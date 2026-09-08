import 'package:bloc/bloc.dart';
import 'package:official_gold/view_model/cubit/static_page_cubit/static_page_states.dart';

import '../../../services/app_service/app_service.dart';
import '../../../view/screen/static_pages/old_static_page_screen.dart';

class PageCubit extends Cubit<PageState> {
  final ApiService _apiService;

  PageCubit(this._apiService) : super(PageInitial());

  Future<void> loadPage(int id) async {
    emit(PageLoading());

    try {
      final response = await _apiService.getSinglePage(id);

      if (response.success && response.result != null) {
        emit(PageLoaded(response.result!));
      } else {
        emit(PageError(response.message));
      }
    } catch (e) {
      emit(PageError('Failed to load page data'));
    }
  }
}