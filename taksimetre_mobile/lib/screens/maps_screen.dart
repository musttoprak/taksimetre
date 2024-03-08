import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taksimetre_mobile/models/distance_matrix_response_model.dart';

import '../constants/app_colors.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen>
    with SingleTickerProviderStateMixin {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  final LatLng _center = const LatLng(41.092719466676016, 28.991484519531493);
  bool _isStackVisible = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> changeVisible() async {
    if (_isStackVisible) {
      _animationController.reverse();
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isStackVisible = false;
      });
    } else {
      setState(() {
        _isStackVisible = true;
      });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _center, zoom: 11.0),
          markers: _markers,
          onTap: (position) {
            _addMarker(position);
          },
        ),
        Positioned(
          bottom: 12,
          left: 12,
          right: 12,
          child: Column(
            children: [
              IconButton.outlined(
                  onPressed: () {
                    setState((){
                      changeVisible();
                    });
                  },
                  icon: Icon(
                    _isStackVisible
                        ? Icons.keyboard_arrow_down_outlined
                        : Icons.keyboard_arrow_up_outlined,
                  ),
                  iconSize: 36,
                  color: AppColors.secondaryAccent,
                ),
              Visibility(
                visible: _isStackVisible,
                child: AnimatedOpacity(
                  opacity: _isStackVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
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
                            onTap: () {
                              setState(() {
                                //
                              });
                            },
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
                  _onSubmitButtonPressed();
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
                        style: TextStyle(color: AppColors.primaryWhiteColor),
                      ),
                      SizedBox(width: 32),
                      Icon(Icons.route, color: Colors.white, size: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }

  void _addMarker(LatLng position) {
    setState(() {
      if (_markers.length < 2) {
        _markers.add(Marker(
          markerId: MarkerId('${position.latitude}-${position.longitude}'),
          position: position,
          onTap: () {
            _removeMarker(
                MarkerId('${position.latitude}-${position.longitude}'));
          },
        ));
      } else {
        print("Lütfen 2 konum seçiniz");
      }
    });
  }

  void _removeMarker(MarkerId markerId) {
    setState(() {
      _markers.removeWhere((element) => element.markerId == markerId);
    });
  }

  Future<void> _onSubmitButtonPressed() async {
    if (_markers.length >= 2) {
      LatLng? firstPosition;
      LatLng? secondPosition;
      int i = 0;
      for (Marker marker in _markers) {
        if (i == 0) {
          firstPosition = marker.position;
        } else if (i == 1) {
          secondPosition = marker.position;
        }
        i++;
      }

      await _checkPriceApi(firstPosition!,secondPosition!);
      print('First position: $firstPosition');
      print('Second position: $secondPosition');
    } else {
      print('Lütfen iki konum seçiniz');
    }
  }


  Future<void> _checkPriceApi(LatLng firstPosition, LatLng secondPosition) async {

    Dio dio = Dio();
    var result = await dio.get("http://192.168.1.16:6060/api",queryParameters: {
      'destinations' : "${firstPosition.latitude},${firstPosition.longitude}",
      'origins' : "${secondPosition.latitude},${secondPosition.longitude}"
    });
    var data = jsonDecode(result.data);
    DistanceMatrixResponseModel responseModel = DistanceMatrixResponseModel.fromJson(data);
    // DistanceMatrixResponseModel içinden value'yi alarak ekrana bastırabiliriz
    print('Value: ${responseModel.rows[0].elements[0].distance.value}');
  }
}
