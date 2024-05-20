import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../models/distance_matrix_response_model.dart';
import '../services/routeApiService.dart';
import '../widgets/route_response_list_widget.dart';
import 'maps_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? name;
  bool isLoading = true;
  List<DistanceMatrixResponseModel>? model;

  @override
  void initState() {
    _getRoute();
    _loadName();
    super.initState();
  }

  Future<void> _getRoute() async {
    print("get route");
    List<DistanceMatrixResponseModel>? result =
        await RouteApiService.getRoutes();
    setState(() {
      model = result;
      isLoading = false;
      print(model?.length);
    });
  }

  // SharedPreferences'ten name değerini yükleyen fonksiyon
  void _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(children: [
              Container(
                color: Theme.of(context).canvasColor,
                height: 150,
                padding: const EdgeInsets.only(left: 36, top: 12),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tekrar Hoşgeldin,',
                        style: Theme.of(context).textTheme.headline2),
                    Text("$name!",
                        style: Theme.of(context).textTheme.headline1),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 30,
                right: 30,
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapsScreen(null, false),
                      ),
                    );

                    await _getRoute();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                        color: AppColors.secondaryAccent,
                        borderRadius: BorderRadius.circular(32)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ücretini Hesapla',
                          style: TextStyle(
                              color: AppColors.primaryWhiteColor, fontSize: 16),
                        ),
                        SizedBox(width: 32),
                        Icon(Icons.route, color: Colors.white, size: 32),
                      ],
                    ),
                  ),
                ),
              )
            ]),
          ),
          Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : model!.isNotEmpty
                      ? buildRefreshIndicator()
                      : const Center(
                          child: Text("Daha önce bir rota belirlemediniz"))),
        ],
      ),
    );
  }

  RefreshIndicator buildRefreshIndicator() {
    return RefreshIndicator.adaptive(
      color: Colors.white,
      onRefresh: () async {
        await _getRoute();
      },
      child: SingleChildScrollView(
        child: Column(
            children: model!.map((e) {
          return RouteResponseListWidget(
            model: e,
          );
        }).toList()),
      ),
    );
  }
}
