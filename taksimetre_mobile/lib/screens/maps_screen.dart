import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:taksimetre_mobile/widgets/distance_matrix_response_model_widget.dart';

import '../bloc/map_screen_cubit.dart';
import '../constants/app_colors.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen>
    with SingleTickerProviderStateMixin, MapsScreenMixin {
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
    return BlocProvider(
      create: (context) => MapScreenCubit(context, animationController),
      child: BlocBuilder<MapScreenCubit, MapScreenState>(
        builder: (context, state) {
          return buildScaffold(context);
        },
      ),
    );
  }
}

mixin MapsScreenMixin {
  late GoogleMapController mapController;
  late AnimationController animationController;
  Set<Circle> circles = {
    const Circle(
      circleId: CircleId("id"),
      center: LatLng(40.823916196655624, 29.923867000458213),
      radius: 4000,
    )
  };

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        !context
            .watch<MapScreenCubit>()
            .isLoading
            ? googleMap(context)
            : const Center(child: CircularProgressIndicator()),
        bottomBar(context),
        topInfo(context)
      ]),
    );
  }

  Visibility topInfo(BuildContext context) {
    return Visibility(
        visible: context
            .watch<MapScreenCubit>()
            .response != null,
        child: Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: SafeArea(
              child: DistanceMatrixResponseWidget(
                  response: context
                      .watch<MapScreenCubit>()
                      .response),
            )));
  }

  Positioned bottomBar(BuildContext context) {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Column(
        children: [
          IconButton.outlined(
            onPressed: () {
              context.read<MapScreenCubit>().changeVisible();
            },
            icon: Icon(
              context
                  .watch<MapScreenCubit>()
                  .isStackVisible
                  ? Icons.keyboard_arrow_down_outlined
                  : Icons.keyboard_arrow_up_outlined,
            ),
            iconSize: 36,
            color: AppColors.secondaryAccent,
          ),
          Visibility(
            visible: context
                .watch<MapScreenCubit>()
                .isStackVisible,
            child: AnimatedOpacity(
              opacity:
              context
                  .watch<MapScreenCubit>()
                  .isStackVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animationController,
                  curve: Curves.easeInOut,
                )),
                child: Stack(
                  children: [
                    const Column(
                      children: [
                        SearchBar(
                          hintText: "Konumum",
                          leading: Icon(
                            Icons.my_location,
                            color: AppColors.headerTextColor,
                          ),
                          padding: MaterialStatePropertyAll<EdgeInsets>(
                              EdgeInsets.only(
                                  left: 16, bottom: 12, right: 16, top: 12)),
                        ),
                        SizedBox(height: 12),
                        SearchBar(
                          hintText: "Konum Ara",
                          leading: Icon(
                            Icons.my_location,
                            color: AppColors.headerTextColor,
                          ),
                          padding: MaterialStatePropertyAll<EdgeInsets>(
                              EdgeInsets.only(
                                  left: 16, bottom: 12, right: 16, top: 12)),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: AppColors.secondaryAccent,
                              borderRadius: BorderRadius.circular(32)),
                          child: const Icon(Icons.change_circle_outlined,
                              color: Colors.white, size: 32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              context.read<MapScreenCubit>().onSubmitButtonPressed();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                  color: context
                      .watch<MapScreenCubit>()
                      .isButtonActive
                      ? AppColors.secondaryAccent
                      : Colors.red,
                  borderRadius: BorderRadius.circular(32)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context
                        .watch<MapScreenCubit>()
                        .isButtonActive
                        ? "Ücretini Hesapla" : "Lğtfen en az 1 konum seçiniz",
                    style: const TextStyle(color: AppColors.primaryWhiteColor),
                  ),
                  const SizedBox(width: 32),
                  const Icon(Icons.route, color: Colors.white, size: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  GoogleMap googleMap(BuildContext context) {
    LatLng target = LatLng(context
        .read<MapScreenCubit>()
        .currentLocation!
        .latitude!, context
        .read<MapScreenCubit>()
        .currentLocation!
        .longitude!);
    return GoogleMap(
      onMapCreated: (controller) => _onMapCreated(controller,context),
      initialCameraPosition: CameraPosition(
          target: target,
          zoom: 11.0),
      markers: context
          .watch<MapScreenCubit>()
          .markers,
      polylines:
      Set<Polyline>.of(context
          .watch<MapScreenCubit>()
          .polylines
          .values),
      onTap: (position) {
        context.read<MapScreenCubit>().addMarker(position);
      },
      trafficEnabled: true,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      circles: circles,
    );
  }

  void _onMapCreated(GoogleMapController controller,BuildContext context) {
    mapController = controller;
  }
}
