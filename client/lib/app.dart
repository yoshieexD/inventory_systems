import 'package:client/bloc/service/service_bloc.dart';
import 'package:client/routes/routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user/user_bloc.dart';

import 'models/user.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserBloc()
            ..add(
              const GetName(),
            ),
        ),
        BlocProvider(
          create: (context) => ServiceBloc()
            ..add(
              const GetServices(),
            ),
        )
      ],
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          // if (state is UserLoading) {
          //   return const Center(child: CircularProgressIndicator());
          // }

          if (state is UserLoaded) {
            User user = state.user;
            return MaterialApp.router(
              title: 'AWB inventory',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xff333267),
                ),
                useMaterial3: true,
              ),
              routeInformationParser:
                  AppRouter.returnRouter(user.name.isNotEmpty)
                      .routeInformationParser,
              routerDelegate:
                  AppRouter.returnRouter(user.name.isNotEmpty).routerDelegate,
            );
          } else {
            return const MaterialApp(
              home: Text("went wrong"),
            );
          }
        },
      ),
    );
  }
}