import 'package:client/bloc/service/service_bloc.dart';
import 'package:client/utils/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user/user_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final ApiProvider apiProvider = ApiProvider();

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {},
      child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Enter Email';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Material(
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Enter Password';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.visiblePassword,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 30), // Increased spacing
              MouseRegion(
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final response = await apiProvider.login(
                        emailController.text,
                        passwordController.text,
                        context,
                      );

                      context.read<UserBloc>().add(SetUser(
                            name: response["name"].toString(),
                            cookies: response["name"].toString(),
                          ));

                      context.read<ServiceBloc>().add(
                            SetServices(services: response["services"]),
                          );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHovered
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
                        : Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 90, // Increased width
                      vertical: 15, // Increased height
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Log In",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.background,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
