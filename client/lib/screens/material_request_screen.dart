import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/service/service_bloc.dart';
import '../models/user.dart';
import '../bloc/user/user_bloc.dart';
import '../utils/api_provider.dart';

class materialRequestScreen extends StatefulWidget {
  const materialRequestScreen({Key? key}) : super(key: key);

  @override
  State<materialRequestScreen> createState() => _MaterialRequestScreenState();
}

class _MaterialRequestScreenState extends State<materialRequestScreen> {
  final ApiProvider apiProvider = ApiProvider();
  final List<String> list = <String>['Sign out'];
  bool isDropdownVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchMaterialRequest();
  }

  Future<void> _fetchMaterialRequest() async {
    final response = await apiProvider.allMaterialRequest();
    if (response != null && response.containsKey("material")) {
      context
          .read<ServiceBloc>()
          .add(SetServices(services: response["material"]));
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
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
              return const Text("Error getting username");
            }
          },
        ),
        const SizedBox(height: 10),
        BlocListener<ServiceBloc, ServiceState>(
          listener: (context, state) {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isDropdownVisible = !isDropdownVisible;
                      });
                    },
                    icon: const Icon(Icons.account_circle_outlined),
                    tooltip: "Material Request",
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  if (isDropdownVisible)
                    DropdownButton<String>(
                      value: list.first,
                      onChanged: (newValue) async {
                        if (newValue == 'Sign out') {
                          final response = await apiProvider.logout();
                          if (response != null) {
                            context
                                .read<UserBloc>()
                                .add(SetUser(name: '', cookies: ''));
                            GoRouter.of(context).push('/login');
                          }
                        }
                      },
                      items: list.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
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
              final filteredService = service.where((item) =>
                  item['picking_type_id'] != null &&
                  item['picking_type_id'][0] == 15 &&
                  item['picking_type_id'][1] == "My Company: Testing");

              return SizedBox(
                height: MediaQuery.of(context).size.height - 180,
                child: ListView.builder(
                  itemCount: filteredService.length,
                  itemBuilder: (v, i) => Card(
                    key: UniqueKey(),
                    child: InkWell(
                      onTap: () {
                        return GoRouter.of(context).push(
                          "/request/${service[i]['id'].toString()}",
                        );
                      },
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
                                Text(
                                    "state: ${service[i]['state'].toString()}"),
                                Text(
                                    "ID: ${service[i]['picking_type_id'][0].toString()}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const Text("testing2");
            }
          },
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Contact'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Product'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Unit of Measure'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
