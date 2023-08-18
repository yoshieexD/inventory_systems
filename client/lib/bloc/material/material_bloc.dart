import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'material_event.dart';
part 'material_state.dart';

class MaterialBloc extends Bloc<MaterialEvent, MaterialState> {
  MaterialBloc() : super(MaterialLoading()) {
    on<GetMaterial>((event, emit) {
      emit(
          MaterialLoaded(material: event.material, moveLines: event.moveLines));
    });
  }
}
