import 'package:flutter/material.dart';
import 'package:taksimetre_mobile/constants/app_colors.dart';

import '../models/distance_matrix_response_model.dart';

class DistanceMatrixResponseWidget extends StatelessWidget {
  final DistanceMatrixResponseModel? response;

  const DistanceMatrixResponseWidget({Key? key, required this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return response != null ? Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondaryAccent,style: BorderStyle.solid,width: 2),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 4),
            color: Colors.black,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Başlangıç Konumu:',
            style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.secondaryAccent),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildAddressList(response!.originAddresses),
          ),
          const SizedBox(height: 10),
          const Text(
            'Bitiş Konumu:',
            style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.secondaryAccent),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildAddressList(response!.destinationAddresses),
          ),
          const SizedBox(height: 10),
          const Text(
            'Mesafe ve Süre:',
            style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.secondaryAccent),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildDistanceAndDurationList(response!.rows),
          ),
        ],
      ),
    ): SizedBox.fromSize();
  }

  List<Widget> _buildAddressList(List<String> addresses) {
    return addresses.map((address) => Text(address,style: const TextStyle(color: Colors.black,fontSize: 12),)).toList();
  }

  List<Widget> _buildDistanceAndDurationList(List<DistanceRow> rows) {
    List<Widget> widgets = [];
    for (var row in rows) {
      for (var element in row.elements) {
        widgets.add(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mesafe: ${element.distance.text}',style: const TextStyle(color: Colors.black,fontSize: 12)),
            Text('Süre: ${element.duration.text}',style: const TextStyle(color: Colors.black,fontSize: 12)),
            const SizedBox(height: 10),
          ],
        ));
      }
    }
    return widgets;
  }
}
