import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pulseai/services/local_hospital_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pulseai/l10n/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';


class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  final LocalHospitalService _localHospitalService = LocalHospitalService();
  final MapController _mapController = MapController();
  List<dynamic> _hospitals = [];
  bool _isLoading = true;
  LatLng? _currentPosition;
  
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredHospitals = [];

  String _selectedService = "All";

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _getCurrentLocation();
    _loadHospitals();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        throw Exception("GPS Permission denied");
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentPosition!, 13.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentPosition = const LatLng(6.1319, 1.2228); // Lomé
        });
        _mapController.move(_currentPosition!, 13.0);
      }
    }
  }

  Future<void> _loadHospitals() async {
    if (_currentPosition == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_hospitals.isEmpty) {
             _hospitals = [];
          }
        });
      }
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final hospitals = await _localHospitalService.loadHospitals(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (mounted) {
        setState(() {
          _hospitals = hospitals;
          _filteredHospitals = hospitals;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load hospitals: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showHospitalDetails(dynamic hospital) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hospital['nom'] ?? 'Hospital',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                      iconSize: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber[600], size: 22),
                    const SizedBox(width: 4),
                    Text(
                      "${hospital['note_moyenne'] ?? 0.0} (${hospital['nombre_avis'] ?? 0} reviews)",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(width: 20),
                    if (hospital['distance_km'] != null) ...[
                      const Icon(Icons.location_on_rounded, color: AppTheme.primaryBlue, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        "${(hospital['distance_km'] as num).toStringAsFixed(1)} km away",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoRow(Icons.map_rounded, hospital['adresse'] ?? 'Address unavailable'),
                _buildInfoRow(Icons.phone_rounded, hospital['telephone'] ?? 'Not provided'),
                _buildInfoRow(Icons.access_time_filled_rounded, hospital['horaires_ouverture'] ?? 'Open 24/7'),
                
                const SizedBox(height: 24),
                const Text(
                  "Available Services",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: hospital['services'] != null && (hospital['services'] as List).isNotEmpty
                      ? ListView.builder(
                          itemCount: (hospital['services'] as List).length,
                          itemBuilder: (context, index) {
                            final service = hospital['services'][index];
                            final serviceName = service is String ? service : (service['nom_service'] ?? '');
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.medical_services_rounded, color: AppTheme.primaryBlue),
                              ),
                              title: Text(serviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('Available', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            );
                          },
                        )
                      : const Center(child: Text("No services listed", style: TextStyle(fontStyle: FontStyle.italic))),
                ),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                           final lat = (hospital['latitude'] as num).toDouble();
                           final lng = (hospital['longitude'] as num).toDouble();
                           _launchMaps(lat, lng);
                        },
                        icon: const Icon(Icons.directions_rounded),
                        label: const Text('Directions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: AppTheme.primaryBlue.withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRatingDialog(hospital['id'].toString(), hospital['nom'] ?? 'Hospital');
                        },
                        icon: const Icon(Icons.star_border_rounded),
                        label: const Text('Rate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: AppTheme.textPrimary,
                          side: BorderSide(color: Colors.grey[300]!, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppTheme.primaryBlue),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800], fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _filterHospitals(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHospitals = List.from(_hospitals);
      } else {
        _filteredHospitals = _hospitals.where((hospital) {
          final name = ((hospital['nom'] ?? '') as String).toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Widget _buildServiceChip(String label, String serviceName) {
    final isSelected = _selectedService == serviceName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedService = serviceName;
          _loadHospitals();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!, width: 1.5),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _launchMaps(double lat, double lng) async {
    if (_currentPosition == null) return;
    final Uri url = Uri.parse('https://www.openstreetmap.org/directions?engine=osrm_car&route=${_currentPosition!.latitude},${_currentPosition!.longitude};$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open map')),
        );
      }
    }
  }

  void _showRatingDialog(String hospitalId, String hospitalName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Rate $hospitalName", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("What is your experience?", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: const Icon(Icons.star_border_rounded, size: 36),
                  color: Colors.amber[600],
                  onPressed: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(seconds: 1));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Thank you for your rating! (Demo mode)"), backgroundColor: AppTheme.success),
                      );
                    }
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(6.1375, 1.2125), // Lomé
              initialZoom: 13.0,
              onMapReady: () {},
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.pulseai',
              ),
              MarkerLayer(
                markers: _hospitals.map((hospital) {
                  return Marker(
                    point: LatLng(
                      (hospital['latitude'] as num).toDouble(),
                      (hospital['longitude'] as num).toDouble(),
                    ),
                    width: 48,
                    height: 48,
                    child: GestureDetector(
                      onTap: () => _showHospitalDetails(hospital),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 48,
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueAccent, width: 2),
                        ),
                        child: Center(
                          child: Container(
                            width: 16, height: 16,
                            decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Glass Search Bar Overlay
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: l10n.searchHospitalHint,
                            border: InputBorder.none,
                            hintStyle: const TextStyle(color: Colors.black54),
                          ),
                          onChanged: _filterHospitals,
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.black54),
                          onPressed: () {
                            _searchController.clear();
                            _filterHospitals('');
                          },
                        ),
                      Container(width: 1, height: 24, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
                      IconButton(
                        icon: const Icon(Icons.filter_list_rounded, color: AppTheme.primaryBlue),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Service Filters Overflowing below Search Bar
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildServiceChip(l10n.all, 'All'),
                  const SizedBox(width: 10),
                  _buildServiceChip(l10n.serviceEmergency, 'Emergency'),
                  const SizedBox(width: 10),
                  _buildServiceChip(l10n.serviceCardiology, 'Cardiology'),
                  const SizedBox(width: 10),
                  _buildServiceChip(l10n.servicePediatrics, 'Pediatrics'),
                  const SizedBox(width: 10),
                  _buildServiceChip(l10n.serviceNeurology, 'Neurology'),
                  const SizedBox(width: 10),
                  _buildServiceChip(l10n.serviceGeneral, 'General'),
                  const SizedBox(width: 10),
                  _buildServiceChip(l10n.serviceMaternity, 'Maternity'),
                ],
              ),
            ),
          ),

          // Bottom Sheet List with Blur Effect
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.15,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5)),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(3)),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Text(
                                "Nearby Hospitals",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _filteredHospitals.isEmpty
                                  ? const Center(child: Text("No hospitals found nearby", style: TextStyle(color: Colors.black54)))
                                  : ListView.builder(
                                      controller: scrollController,
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      itemCount: _filteredHospitals.length,
                                      itemBuilder: (context, index) {
                                        return _buildHospitalCard(context, _filteredHospitals[index]);
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(BuildContext context, dynamic hospital) {
    final name = hospital['nom'] ?? 'Hospital';
    final dist = hospital['distance_km'] != null ? (hospital['distance_km'] as num).toStringAsFixed(1) : '0';
    final hours = hospital['horaires_ouverture'] ?? 'Closed';
    final rating = hospital['note_moyenne'] != null ? (hospital['note_moyenne'] as num).toDouble() : 0.0;
    
    return InkWell(
      onTap: () => _showHospitalDetails(hospital),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.health_and_safety_rounded, color: AppTheme.primaryBlue, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$dist km away', style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(hours, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: Colors.amber[600]),
                      const SizedBox(width: 4),
                      Text(rating.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.directions_rounded, color: Colors.blueAccent, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
