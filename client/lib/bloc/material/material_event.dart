part of 'material_bloc.dart';

sealed class MaterialEvent extends Equatable {
  const MaterialEvent();

  @override
  List<Object> get props => [];
}

class GetMaterial extends MaterialEvent {
  const GetMaterial({this.material = const [], this.moveLines = const []});

  final List<dynamic> material;
  final List<dynamic> moveLines;

  @override
  List<Object> get props => [material, moveLines];
}
