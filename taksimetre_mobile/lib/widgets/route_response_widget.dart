import 'package:flutter/material.dart';
import 'package:taksimetre_mobile/constants/app_colors.dart';

import '../components/star_rating_widget.dart';
import '../models/distance_matrix_response_model.dart';
import '../models/route_response_model.dart';

class RouteResponseWidget extends StatefulWidget {
  final RouteResponseModel? response;

  const RouteResponseWidget({Key? key, required this.response})
      : super(key: key);

  @override
  State<RouteResponseWidget> createState() => _RouteResponseWidgetState();
}

class _RouteResponseWidgetState extends State<RouteResponseWidget>
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.response!.steps.map((e) {
          return listItemWidget(e);
        }).toList(),
      ),
    );
  }

  Container listItemWidget(RouteStepModel e) {
    return Container(
      width: MediaQuery.sizeOf(context).width - 24,
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
                flex: 2,
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
                      topInfoTextWidget("Rota"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(e.duration.toString(),
                                style: const TextStyle(
                                    fontSize: 26,
                                    color: AppColors.headerTextColor,
                                    fontWeight: FontWeight.bold),
                                maxLines: 1),
                          ),
                          const SizedBox(width: 6),
                          Text("(${e.distance})",
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      walkWidget(e.recipe),
                      const SizedBox(height: 12)
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
                                widget.response!.duration,
                                style: const TextStyle(
                                    fontSize: 26,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text("(${widget.response!.distance})",
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 14))
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
                                  fontSize: 14,
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
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: widget.response!.steps.map((e) {
                        return Column(
                          children: [
                            const SizedBox(height: 6),
                            walkWidget(e.recipe),
                            const SizedBox(height: 6),
                            const Divider(thickness: 2,)
                          ],
                        );
                      }).toList(),
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

  Row walkWidget(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.directions_walk,
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
