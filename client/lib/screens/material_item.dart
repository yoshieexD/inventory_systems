import 'package:client/bloc/material/material_bloc.dart' as custom_material;
import 'package:client/utils/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaterialItemScreen extends StatefulWidget {
  const MaterialItemScreen(this.param, {Key? key}) : super(key: key);
  final Map<String, String> param;

  @override
  State<MaterialItemScreen> createState() => _MaterialItemScreenState();
}

class _MaterialItemScreenState extends State<MaterialItemScreen> {
  ApiProvider apiProvider = ApiProvider();

  @override
  void initState() {
    super.initState();
    _fetchmaterial();
  }

  Future<void> _fetchmaterial() async {
    Map<String, String> id = widget.param;
    final response = await apiProvider.viewRequest(id["id"]!);
    context.read<custom_material.MaterialBloc>().add(
          custom_material.GetMaterial(
            material: response['request'],
            moveLines: response['move_lines'],
          ),
        );
    print(response['request']);
    print(response['move_lines']);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<custom_material.MaterialBloc,
        custom_material.MaterialState>(
      builder: (context, state) {
        if (state is custom_material.MaterialLoading) {
          return const Center(
            child: Text('Loading'),
          );
        }
        if (state is custom_material.MaterialLoaded) {
          List<dynamic> material = state.material;
          List<dynamic> moveLines = state.moveLines;

          return Column(
            children: [
              Center(
                child: Column(
                  children: [
                    for (var materialItem in material)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name: ${materialItem["name"]}"),
                              Text(
                                  "Partner ID: ${materialItem["partner_id"]?.toString() ?? 'N/A'}"),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("State: ${materialItem["state"]}"),
                              Text(
                                  "Picking Type ID: ${materialItem["picking_type_id"]?[1] ?? 'N/A'}"),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Done')),
                  DataColumn(label: Text('Unit of Measure')),
                ],
                rows: moveLines.map<DataRow>((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item["product_id"].toString())),
                      DataCell(Text(item["qty_done"].toString())),
                      DataCell(Text(item["product_uom_id"][1].toString())),
                    ],
                  );
                }).toList(),
              ),
            ],
          );
        } else {
          return const Text('Something went wrong');
        }
      },
    );
  }
}
