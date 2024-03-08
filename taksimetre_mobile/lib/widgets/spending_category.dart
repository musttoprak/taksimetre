import 'package:flutter/material.dart';
import 'package:taksimetre_mobile/widgets/price_text.dart';

import '../constants/app_colors.dart';
import '../models/spending_category_model.dart';
import 'custom_icon_button.dart';

class SpendingCategory extends StatelessWidget {
  final SpendingCategoryModel data;

  const SpendingCategory(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          Container(
            height: 100,
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      blurRadius: 32, color: Colors.black45, spreadRadius: -8)
                ],
                borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.route, color: AppColors.headerTextColor,size: 64),
                PriceText(price: data.price),
                const Row(children: [
                  CustomIconButton(icon: Icons.file_upload),
                  SizedBox(width: 8),
                  CustomIconButton(icon: Icons.folder)
                ])
              ],
            ),
          ),
          Container(
            width: 132,
            height: 24,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(36),
            ),
            child: Text(
              data.label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
