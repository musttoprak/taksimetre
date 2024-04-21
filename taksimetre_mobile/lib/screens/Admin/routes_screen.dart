import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/distance_matrix_response_model.dart';
import '../../models/fee_table_response_model.dart';
import '../../services/adminApiService.dart';
import '../../widgets/route_response_list_widget.dart';

class RoutesScreen extends StatefulWidget {
  List<DistanceMatrixResponseModel> routes;

  RoutesScreen({required this.routes, super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  late List<DistanceMatrixResponseModel> routes;

  @override
  void initState() {
    routes = widget.routes;
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
                    "Rotalar",
                    style:
                    TextStyle(color: AppColors.headerTextColor, fontSize: 24,fontWeight: FontWeight.bold),
                  ),
                  Text("Toplam: ${routes.length}")
                ],
              ),
              const SizedBox(height: 24),
              Column(
                children: routes.map((e) {
                  return RouteResponseListWidget(e);
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
