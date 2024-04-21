import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/fee_table_response_model.dart';
import '../../services/adminApiService.dart';

class FeeTableScreen extends StatefulWidget {
  List<FeeTableResponseModel> fees;

  FeeTableScreen({required this.fees, super.key});

  @override
  State<FeeTableScreen> createState() => _FeeTableScreenState();
}

class _FeeTableScreenState extends State<FeeTableScreen> {
  late List<FeeTableResponseModel> fees;

  @override
  void initState() {
    fees = widget.fees;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ücretlendirmeler",
                    style:
                        TextStyle(color: AppColors.headerTextColor, fontSize: 24,fontWeight: FontWeight.bold),
                  ),
                  Text("Toplam: ${fees.length}")
                ],
              ),
              const SizedBox(height: 24),
              Column(
                children: fees.map((e) {
                  TextEditingController _controller = TextEditingController();
                  _controller.text = e.value;
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.price_change),
                        title: Text(e.name),
                        subtitle: TextFormField(
                          controller: _controller,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            hintText: e.value.toString(), // Varsayılan değer
                          ),
                        ),
                        onTap: () async {
                          var newFees = await AdminApiService.feeChangeValue(
                              e.id, double.parse(_controller.text));

                          setState(() {
                            fees = newFees;
                          });
                        },
                        trailing: const Icon(Icons.refresh),
                      ),
                      const Divider(),
                    ],
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
