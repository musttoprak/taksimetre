import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/spending_category_model.dart';
import '../widgets/spending_category.dart';
import 'maps_screen.dart';

class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Container(
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
                    Text('Adı Soyadı!',
                        style: Theme.of(context).textTheme.headline1),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const MapsScreen()));
                        },
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                              color: AppColors.secondaryAccent,
                              borderRadius: BorderRadius.circular(32)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ücretini Hesapla',
                                style:
                                TextStyle(color: AppColors.primaryWhiteColor),
                              ),
                              SizedBox(width: 32),
                              Icon(Icons.route,color: Colors.white,size: 32),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: AppColors.secondaryAccent),
                        child: Material(
                          borderRadius: BorderRadius.circular(32),
                          type: MaterialType.transparency,
                          clipBehavior: Clip.hardEdge,
                          child: IconButton(
                            padding: const EdgeInsets.all(16),
                            color: AppColors.primaryWhiteColor,
                            iconSize: 32,
                            icon: const Icon(
                              Icons.history,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ]),
              )
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 24),
            child: SearchBar(),
          ),
          Expanded(
            child: ListView(children: [
              for (var model in categoryModels)
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