import 'package:bloc/bloc.dart';
import 'package:my_project/blocs/saved_data/saved_data_state.dart';
import 'package:my_project/services/serial_service.dart';

class SavedDataCubit extends Cubit<SavedDataState> {
  SavedDataCubit() : super(SavedDataInitial());

  Future<void> loadSavedData() async {
    emit(SavedDataLoading());
    try {
      final data = await SerialService.instance.readSavedData();
      if (data == null) {
        emit(const SavedDataError('Дані не знайдені або помилка читання'));
      } else {
        emit(SavedDataLoaded(data));
      }
    } catch (e) {
      emit(SavedDataError('Помилка: ${e.toString()}'));
    }
  }
}
