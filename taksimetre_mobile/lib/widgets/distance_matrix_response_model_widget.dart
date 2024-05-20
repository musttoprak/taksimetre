import 'package:flutter/material.dart';
import 'package:taksimetre_mobile/constants/app_colors.dart';

import '../components/star_rating_widget.dart';
import '../models/distance_matrix_response_model.dart';

class DistanceMatrixResponseWidget extends StatefulWidget {
  final DistanceMatrixResponseModel? response;

  const DistanceMatrixResponseWidget({Key? key, required this.response})
      : super(key: key);

  @override
  State<DistanceMatrixResponseWidget> createState() =>
      _DistanceMatrixResponseWidgetState();
}

class _DistanceMatrixResponseWidgetState
    extends State<DistanceMatrixResponseWidget>
    with SingleTickerProviderStateMixin {
  bool isMoreVisible = false;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.response != null) {
      return responseWidget();
    }
    return SizedBox.fromSize();
  }

  Widget responseWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.headerTextColor.withOpacity(.3),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
              offset: Offset(4, 0),
              color: Colors.white,
              blurRadius: 10,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                      color: AppColors.primaryWhiteColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      topInfoTextWidget("Tutar"),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                            '${widget.response!.price.toStringAsFixed(2)} TL',
                            style: const TextStyle(
                                fontSize: 26,
                                color: AppColors.headerTextColor,
                                fontWeight: FontWeight.bold),
                            maxLines: 1),
                      ),
                      Visibility(
                        visible: widget.response!.price < 90,
                        child: Text("Minimum tutar 90TL'dir.",
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 11)),
                      ),
                      const SizedBox(height: 12),
                      topInfoTextWidget("Puan"),
                      const SizedBox(height: 12),
                      StarRatingWidget(widget.response!.routeId,0),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 1,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            topInfoTextWidget("Tahmini varış süresi"),
                            const SizedBox(height: 12),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${widget.response!.duration} dakika.',
                                style: const TextStyle(
                                    fontSize: 26,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isMoreVisible = !isMoreVisible;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: AppColors.primaryWhiteColor,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.grey.shade300)),
                            child: Text(
                              isMoreVisible ? "Daha az " : "Daha fazlası",
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.headerTextColor,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )),
              )
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
            reverseDuration: Duration.zero,
            child: AnimatedOpacity(
              opacity: isMoreVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animationController,
                  curve: Curves.linear,
                )),
                child: Visibility(
                  visible: isMoreVisible,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        topInfoTextWidget("Kalkış"),
                        const SizedBox(height: 6),
                        locationWidget(widget.response!.originAddresses),
                        const SizedBox(height: 6),
                        //Divider(),
                        Icon(Icons.keyboard_double_arrow_down_sharp,
                            color: Colors.grey.shade700),
                        const SizedBox(height: 6),
                        topInfoTextWidget("Varış"),
                        const SizedBox(height: 6),
                        locationWidget(widget.response!.destinationAddresses),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text topInfoTextWidget(String text) {
    return Text("$text:",
        style: TextStyle(color: Colors.grey.shade700, fontSize: 14));
  }

  Row locationWidget(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.my_location,
          size: 16,
          color: Colors.grey.shade800,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
