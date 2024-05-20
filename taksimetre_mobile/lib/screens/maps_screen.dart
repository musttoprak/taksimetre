import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:taksimetre_mobile/widgets/distance_matrix_response_model_widget.dart';

import '../bloc/map_screen_cubit.dart';
import '../constants/app_colors.dart';
import '../models/distance_matrix_response_model.dart';
import '../widgets/route_response_widget.dart';

class MapsScreen extends StatefulWidget {
  final DistanceMatrixResponseModel? distanceMatrixResponseModel;
  final bool isAdmin;

  const MapsScreen(this.distanceMatrixResponseModel, this.isAdmin, {super.key});

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
      create: (context) => MapScreenCubit(
          context,
          widget.distanceMatrixResponseModel,
          widget.isAdmin,
          animationController,
          myLocationController,
          locationController),
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
  TextEditingController myLocationController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  void _onMapCreated(GoogleMapController controller, BuildContext context) {
    mapController = controller;
    context.read<MapScreenCubit>().mapsControllerInitalize(mapController);
  }

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        !context.watch<MapScreenCubit>().isLoading
            ? googleMap(context)
            : const Center(child: CircularProgressIndicator()),
        bottomBar(context),
        topInfo(context),
        taxiTopInfo(context),
        SafeArea(
          child: IconButton(
            icon: const Icon(Icons.arrow_back_outlined,color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        )
      ]),
    );
  }

  GoogleMap googleMap(BuildContext context) {
    LatLng target = LatLng(
        context.read<MapScreenCubit>().currentLocation!.latitude!,
        context.read<MapScreenCubit>().currentLocation!.longitude!);
    return GoogleMap(
      onMapCreated: (controller) => _onMapCreated(controller, context),
      initialCameraPosition: CameraPosition(target: target, zoom: 11.0),
      markers: context.watch<MapScreenCubit>().allMarkers,
      polylines:
          Set<Polyline>.of(context.watch<MapScreenCubit>().polylines.values),
      onTap: (position) {
        context.read<MapScreenCubit>().addMarker(position);
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  Visibility topInfo(BuildContext context) {
    return Visibility(
      visible: context.watch<MapScreenCubit>().response != null &&
          MediaQuery.of(context).viewInsets.bottom <= 0,
      child: Positioned(
        top: 0,
        right: 0,
        left: 0,
        child: SafeArea(
          child: Stack(
            children: [
              DistanceMatrixResponseWidget(
                  response: context.watch<MapScreenCubit>().response),
              Padding(
                padding: const EdgeInsets.all(24),
                child: InkWell(
                  onTap: () {
                    context.read<MapScreenCubit>().clearResult();
                  },
                  child: const Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.close,
                        color: AppColors.headerTextColor,
                        size: 18,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomBar(BuildContext context) {
    return Visibility(
      visible: context.watch<MapScreenCubit>().response == null &&
          context.watch<MapScreenCubit>().routeResponseModel == null,
      child: Positioned(
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
                context.watch<MapScreenCubit>().isStackVisible
                    ? Icons.keyboard_arrow_down_outlined
                    : Icons.keyboard_arrow_up_outlined,
              ),
              iconSize: 36,
              color: AppColors.secondaryAccent,
            ),
            Visibility(
              visible: context.watch<MapScreenCubit>().isStackVisible,
              child: AnimatedOpacity(
                opacity:
                    context.watch<MapScreenCubit>().isStackVisible ? 1.0 : 0.0,
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
                  child: Column(
                    children: [
                      Visibility(
                        visible: context.watch<MapScreenCubit>().model != null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white,
                              border:
                                  Border.all(color: AppColors.headerTextColor)),
                          child: InkWell(
                            onTap: () {
                              context.read<MapScreenCubit>().completeSearch();
                              context.read<MapScreenCubit>().clearSearch();
                              FocusScope.of(context).nextFocus();
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    context
                                            .watch<MapScreenCubit>()
                                            .model
                                            ?.formattedAddress ??
                                        "",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.golf_course)
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextFormField(
                          controller: myLocationController,
                          maxLines: 1,
                          validator: (value) {
                            return (value ?? "").isNotEmpty
                                ? null
                                : "Lütfen bu alanı doldurun.";
                          },
                          onEditingComplete: () {
                            context.read<MapScreenCubit>().clearSearch();
                            FocusScope.of(context).nextFocus();
                          },
                          onChanged: (value) {
                            if (value.length > 6) {
                              context
                                  .read<MapScreenCubit>()
                                  .searchText(value, true);
                            }
                          },
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            focusColor: Colors.white,
                            icon: const Icon(
                              Icons.my_location,
                              color: AppColors.headerTextColor,
                            ),
                            labelText: "Konumum",
                            labelStyle: Theme.of(context)
                                .inputDecorationTheme
                                .labelStyle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextFormField(
                          controller: locationController,
                          maxLines: 1,
                          validator: (value) {
                            return (value ?? "").isNotEmpty
                                ? null
                                : "Lütfen bu alanı doldurun.";
                          },
                          onEditingComplete: () {
                            context.read<MapScreenCubit>().clearSearch();
                            FocusScope.of(context).nextFocus();
                          },
                          onChanged: (value) {
                            context
                                .read<MapScreenCubit>()
                                .searchText(value, false);
                          },
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            focusColor: Colors.white,
                            icon: const Icon(
                              Icons.my_location,
                              color: AppColors.headerTextColor,
                            ),
                            labelText: "Konum Ara",
                            labelStyle: Theme.of(context)
                                .inputDecorationTheme
                                .labelStyle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                    color: context.watch<MapScreenCubit>().isButtonActive
                        ? AppColors.secondaryAccent
                        : Colors.red,
                    borderRadius: BorderRadius.circular(32)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.watch<MapScreenCubit>().isButtonActive
                          ? "Ücretini Hesapla"
                          : "Lütfen konum seçiniz",
                      style:
                          const TextStyle(color: AppColors.primaryWhiteColor),
                    ),
                    const SizedBox(width: 32),
                    const Icon(Icons.route, color: Colors.white, size: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget taxiTopInfo(BuildContext context) {
    return Visibility(
      visible: context.watch<MapScreenCubit>().isTaxiInfoVisible &&
          MediaQuery.of(context).viewInsets.bottom <= 0,
      child: Positioned(
        top: 0,
        right: 0,
        left: 0,
        child: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                width: double.maxFinite,
                child: RouteResponseWidget(
                    response:
                        context.watch<MapScreenCubit>().routeResponseModel),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: InkWell(
                  onTap: () {
                    context.read<MapScreenCubit>().clearResult();
                  },
                  child: const Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.close,
                        color: AppColors.headerTextColor,
                        size: 18,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
