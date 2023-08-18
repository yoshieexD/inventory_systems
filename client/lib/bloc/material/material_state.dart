part of 'material_bloc.dart';

sealed class MaterialState extends Equatable {
  const MaterialState();

  @override
  List<Object> get props => [];
}

final class MaterialInitial extends MaterialState {}

final class MaterialLoading extends MaterialState {}

final class MaterialLoaded extends MaterialState {
  const MaterialLoaded({required this.material, required this.moveLines});

  final List<dynamic> material;
  final List<dynamic> moveLines;

  @override
  List<Object> get props => [material];
}
