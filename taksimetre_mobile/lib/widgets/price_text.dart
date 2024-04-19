import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class PriceText extends StatelessWidget {
  const PriceText({
    Key? key,
    required this.price,
    this.color = AppColors.secondaryAccent,
  }) : super(key: key);

  final double price;
  final Color color;

  @override
  Widget build(BuildContext context) {
    var colorToUse = color;
    String priceText = '${price.toInt()}';
    String decimalPart = (price - price.floor()).toStringAsFixed(2).substring(1);
    return Row(
      children: [
        Text(
          priceText,
          style: Theme.of(context)
              .textTheme
              .headline3!
              .copyWith(color: colorToUse),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 12, left: 0),
          child: Text("$decimalPart TL",
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .copyWith(color: colorToUse, fontSize: 16)),
        ),
      ],
    );
  }
}
