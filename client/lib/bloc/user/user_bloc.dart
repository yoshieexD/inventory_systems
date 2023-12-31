import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:client/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserLoading()) {
    on<GetName>((event, emit) async {
      emit(UserLoaded(user: event.user));
    });
    on<SetUser>((event, emit) async {
      emit(UserLoaded(user: User(name: event.name, cookies: event.cookies)));
    });
    on<Logout>((event, emit) async {
      emit(UserLoggedOut());
    });
  }
}
