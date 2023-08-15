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
  State<materialRequestScreen> createState() => _materialRequestScreenState();
}

class _materialRequestScreenState extends State<materialRequestScreen> {
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
            return const Text("Error");
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
                                "Reference: ${filteredService.elementAt(i)['name'].toString()}",
                                softWrap: true,
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(
                              width: 230,
                              child: Text(
                                "Contact: ${filteredService.elementAt(i)['partner_id'] == false ? 'None' : filteredService.elementAt(i)['partner_id'][1].toString()}",
                                softWrap: true,
                                maxLines: 2,
                              ),
                            ),
                            Text(
                                "state: ${filteredService.elementAt(i)['state'].toString()}"),
                            Text(
                                "ID: ${filteredService.elementAt(i)['picking_type_id'][0].toString()}"),
                          ],
                        ),
                      ],
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
    ]);
  }
}
