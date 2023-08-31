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

  final productController = TextEditingController();
  final doneController = TextEditingController();
  final unitController = TextEditingController();

  Map<String, dynamic>? apiResponse;

  @override
  void dispose() {
    productController.dispose();
    doneController.dispose();
    unitController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchMaterial();
  }

  Future<void> _fetchMaterial() async {
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

  Future<void> _submitForm() async {
    final id = widget.param["id"];
    final product = productController.text;
    final done = doneController.text;
    final unit = unitController.text;

    if (id == null ||
        id.isEmpty ||
        product.isEmpty ||
        done.isEmpty ||
        unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final response = await apiProvider.createRequest(id, product, done, unit);
    setState(() {
      apiResponse = response;
    });
  }

  List<String> numProduct = [];
  List<String> nameProduct = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Item Screen'),
      ),
      body: BlocBuilder<custom_material.MaterialBloc,
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
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Name: ${materialItem["name"]}"),
                                  Text(
                                      "Partner ID: ${materialItem["partner_id"]?.toString() ?? 'N/A'}"),
                                ],
                              ),
                            ),
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("State: ${materialItem["state"]}"),
                                  Text(
                                      "Picking Type ID: ${materialItem["picking_type_id"]?[1] ?? 'N/A'}"),
                                ],
                              ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: productController,
                        decoration: const InputDecoration(labelText: 'Product'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: doneController,
                        decoration: const InputDecoration(labelText: 'Done'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: unitController,
                        decoration:
                            const InputDecoration(labelText: 'Unit of Measure'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                );
              });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      // Display the API response
      bottomSheet: apiResponse != null
          ? Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue,
              child: Text(
                // Display the response here
                apiResponse.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
}
