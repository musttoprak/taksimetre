import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../models/spending_category_model.dart';
import '../widgets/spending_category.dart';
import 'maps_screen.dart';

class HomeScreen extends StatefulWidget {
  static const categoryModels = [
    SpendingCategoryModel(
      'Kağıthane',
      'assets/image1.png',
      28,
      AppColors.categoryColor1,
    ),
    SpendingCategoryModel(
      'Umuttepe',
      'assets/image2.png',
      28,
      AppColors.categoryColor2,
    ),
    SpendingCategoryModel(
      'Şişli',
      'assets/image3.png',
      28,
      AppColors.categoryColor3,
    ),
  ];

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? name;

  @override
  void initState() {
    super.initState();
    _loadName();
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
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MapsScreen()));
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
          //const Padding(
          //  padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 24),
          //  child: SearchBar(),
          //),
          Expanded(
            child: ListView(children: [
              for (var model in HomeScreen.categoryModels)
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36.0, vertical: 16),
                    child: SpendingCategory(model))
            ]),
          ),
        ],
      ),
    );
  }
}
