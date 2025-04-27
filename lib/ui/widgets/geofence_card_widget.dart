import 'package:flutter/material.dart';

import '../../data/models/geofence_model.dart';

class GeofenceCard extends StatelessWidget {
  final GeofenceModel geofence;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const GeofenceCard({
    super.key,
    required this.geofence,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFeaeafb),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12,),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12,12,12,12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.55,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.route,color: Colors.blue,size: 16,),
                            SizedBox(width: 8,),
                            Text(geofence.title,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Icon(Icons.pin_drop,color: Colors.red,size: 16),
                            SizedBox(width: 8,),
                            Expanded(child: Text('Lat: ${geofence.latitude.toStringAsFixed(5)}, Lon: ${geofence.longitude.toStringAsFixed(5)}')),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Icon(Icons.radar,color: Colors.amber,size: 16),
                            SizedBox(width: 8,),
                            Text('Radius: ${geofence.radius} m'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8,),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    geofence.isInside ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: geofence.isInside ? Colors.green : Colors.grey,
                    size: 18,
                  ),
                  SizedBox(
                    width: 35,
                    height: 20,
                    child: IconButton(
                      icon: const Icon(Icons.edit,size: 16),
                      padding: EdgeInsets.zero,
                      onPressed: onEdit,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: IconButton(
                      icon: const Icon(Icons.delete,size: 16),
                      padding: EdgeInsets.zero,
                      onPressed: onDelete,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
