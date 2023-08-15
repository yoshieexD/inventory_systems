import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/service/service_bloc.dart';
import '../models/user.dart';
import '../bloc/user/user_bloc.dart';
import '../utils/api_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiProvider apiProvider = ApiProvider();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoggedOut) {
            context.go('/login');
          }
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserLoaded) {
            User user = state.user;
            return Text("Hello, ${user.name}!");
          } else {
            return const Text("tsting1");
          }
        },
      ),
      const SizedBox(height: 10),
      BlocListener<ServiceBloc, ServiceState>(
        listener: (context, state) {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 200,
                            child: Center(
                                child:
                                    const Text('Your Modal Content Goes here')),
                          );
                        });
                  },
                  icon: const Icon(Icons.add),
                  tooltip: "Material Request",
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            )
          ],
        ),
      ),
      const SizedBox(height: 10),
      BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          if (state is ServiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ServiceLoaded) {
            List<dynamic> service = state.service;

            return SizedBox(
              height: MediaQuery.of(context).size.height - 180,
              child: ListView.builder(
                itemCount: service.length,
                itemBuilder: (v, i) => Card(
                  key: UniqueKey(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 230,
                                child: Text(
                                  "Reference: ${service[i]['name'].toString()}",
                                  softWrap: true,
                                  maxLines: 2,
                                ),
                              ),
                              SizedBox(
                                width: 230,
                                child: Text(
                                  "Contact: ${service[i]['partner_id'] == false ? 'None' : service[i]['partner_id'][1].toString()}",
                                  softWrap: true,
                                  maxLines: 2,
                                ),
                              ),
                              Text("state: ${service[i]['state'].toString()}"),
                            ],
                          ),
                        ]),
                  ),
                ),
              ),
            );
          } else {
            return const Text("testing2");
          }
        },
      )
    ]);
  }
}
