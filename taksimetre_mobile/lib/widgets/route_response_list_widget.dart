import 'package:flutter/material.dart';
import 'package:taksimetre_mobile/widgets/price_text.dart';

import '../components/star_rating_widget.dart';
import '../constants/app_colors.dart';
import '../models/distance_matrix_response_model.dart';
import '../screens/maps_screen.dart';

class RouteResponseListWidget extends StatefulWidget {
  final DistanceMatrixResponseModel model;
  const RouteResponseListWidget({required this.model,super.key});

  @override
  State<RouteResponseListWidget> createState() =>
      _RouteResponseListWidgetState();
}

class _RouteResponseListWidgetState extends State<RouteResponseListWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        height: 120,
        child: Stack(
          children: [
            Container(
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
                  Flexible(
                    flex: 3,
                    child: Image.asset("assets/route.png",
                        width: 52, color: AppColors.headerTextColor),
                  ),
                  Flexible(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        PriceText(price: widget.model.price),
                        StarRatingWidget(widget.model.routeId,widget.model.starRating)
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: AppColors.secondaryAccent.withAlpha(80)),
                      child: Material(
                        borderRadius: BorderRadius.circular(24),
                        type: MaterialType.transparency,
                        clipBehavior: Clip.hardEdge,
                        child: IconButton(
                          color: AppColors.primaryWhiteColor,
                          iconSize: 18,
                          icon: const Icon(Icons.golf_course),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapsScreen(widget.model,false),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
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
                color: AppColors.categoryColor1,
                borderRadius: BorderRadius.circular(36),
              ),
              child: Text(
                "${widget.model.duration} dak.",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
