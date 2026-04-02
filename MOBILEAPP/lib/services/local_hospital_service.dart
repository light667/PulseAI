import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class LocalHospitalService {
  static const String _assetPath = 'assets/data/hospitals.geojson';

  Future<List<Map<String, dynamic>>> loadHospitals(double userLat, double userLng) async {
    try {
      final String jsonString = await rootBundle.loadString(_assetPath);
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> features = data['features'];

      final Distance distance = const Distance();

      List<Map<String, dynamic>> hospitals = features.map((feature) {
        final geometry = feature['geometry'];
        final properties = feature['properties'];

        if (geometry == null || geometry['coordinates'] == null) {
          return null;
        }

        final List<dynamic> coords = geometry['coordinates'];
        // GeoJSON is [longitude, latitude]
        final double lng = (coords[0] as num).toDouble();
        final double lat = (coords[1] as num).toDouble();

        final double distKm = distance.as(
          LengthUnit.Kilometer,
          LatLng(userLat, userLng),
          LatLng(lat, lng),
        );

        // Map GeoJSON properties to app model
        return {
          'id': properties['osm_id'] ?? properties['id'] ?? DateTime.now().millisecondsSinceEpoch,
          'nom': properties['name'] ?? 'Hôpital sans nom',
          'latitude': lat,
          'longitude': lng,
          'distance_km': distKm,
          'adresse': _formatAddress(properties),
          'telephone': properties['phone'] ?? properties['contact:phone'] ?? 'Non renseigné',
          'horaires_ouverture': properties['opening_hours'] ?? '24h/24',
          'services': _extractServices(properties),
          'note_moyenne': 0.0, // Default as we don't have ratings in GeoJSON
          'nombre_avis': 0,
          'type': properties['amenity'] ?? 'hospital',
        };
      }).where((h) => h != null).cast<Map<String, dynamic>>().toList();

      // Sort by distance
      hospitals.sort((a, b) => (a['distance_km'] as double).compareTo(b['distance_km'] as double));

      return hospitals;
    } catch (e) {
      print('Error loading local hospitals: $e');
      return [];
    }
  }

  String _formatAddress(Map<String, dynamic> props) {
    final List<String> parts = [];
    if (props['addr:street'] != null) parts.add(props['addr:street']);
    if (props['addr:city'] != null) parts.add(props['addr:city']);
    
    if (parts.isEmpty) return 'Adresse non disponible';
    return parts.join(', ');
  }

  List<String> _extractServices(Map<String, dynamic> props) {
    final List<String> services = [];
    if (props['healthcare'] != null) services.add(props['healthcare']);
    if (props['healthcare:speciality'] != null) {
      services.addAll((props['healthcare:speciality'] as String).split(';'));
    }
    if (props['emergency'] == 'yes') services.add('Urgences');
    
    if (services.isEmpty) return ['Médecine générale'];
    return services;
  }
}
