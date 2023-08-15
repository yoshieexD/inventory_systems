import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/models/user.dart';
import 'package:client/bloc/user/user_bloc.dart';
import 'package:client/utils/api_provider.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiProvider apiProvider = ApiProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        // Wrap with Center widget
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoaded) {
                    User user = state.user;
                    return Text(
                      "Hello, ${user.name}!",
                      style: const TextStyle(fontSize: 16),
                    );
                  } else {
                    return const Text("Error");
                  }
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'john.doe@example.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final response = await apiProvider.logout();
                  if (response != null) {
                    context
                        .read<UserBloc>()
                        .add(SetUser(name: '', cookies: ''));

                    // Navigate to /login route after logging out
                    GoRouter.of(context).go('/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
