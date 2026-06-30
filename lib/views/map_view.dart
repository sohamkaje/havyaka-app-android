import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/convention_models.dart';
import '../theme/design_system.dart';
import '../widgets/shared_components.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  LocationCategory selectedCategory = LocationCategory.all;
  ConventionLocation? selectedLocation;
  final _mapController = MapController();

  List<ConventionLocation> get filteredLocations {
    if (selectedCategory == LocationCategory.all) return ConventionData.locations;
    return ConventionData.locations.where((l) => l.category == selectedCategory).toList();
  }

  void _focusLocation(ConventionLocation loc) {
    setState(() => selectedLocation = loc);
    _mapController.move(loc.coordinate, 13);
  }

  void _updateCameraForCategory() {
    final locs = filteredLocations;
    if (locs.length == 1) {
      _focusLocation(locs.first);
    } else {
      setState(() => selectedLocation = null);
      _mapController.move(const LatLng(41.7750, -88.2850), 11);
    }
  }

  void _showLocationDetail(ConventionLocation location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HAAColors.cream,
      builder: (ctx) => _LocationDetailSheet(location: location),
    );
  }

  void _showBlueprintSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HAAColors.cream,
      builder: (ctx) => const _VenueBlueprintSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HAANavBar(title: 'Locations', subtitle: 'Hotels, venue & more'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg, vertical: 10),
          child: Row(
            children: LocationCategory.values.map((cat) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryPill(
                  label: cat.label,
                  icon: cat.icon,
                  isSelected: selectedCategory == cat,
                  onTap: () {
                    setState(() => selectedCategory = cat);
                    _updateCameraForCategory();
                  },
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          height: 210,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(41.7750, -88.2850),
              initialZoom: 11,
              onTap: (_, __) => setState(() => selectedLocation = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'org.havyak.haa_convention',
              ),
              MarkerLayer(
                markers: filteredLocations.map((loc) {
                  final selected = selectedLocation?.name == loc.name;
                  return Marker(
                    point: loc.coordinate,
                    width: selected ? 80 : 40,
                    height: selected ? 60 : 40,
                    child: GestureDetector(
                      onTap: () => _focusLocation(loc),
                      child: Column(
                        children: [
                          Container(
                            width: selected ? 40 : 32,
                            height: selected ? 40 : 32,
                            decoration: BoxDecoration(
                              color: loc.accentColor,
                              shape: BoxShape.circle,
                              border: selected ? Border.all(color: Colors.white, width: 2.5) : null,
                              boxShadow: [BoxShadow(color: loc.accentColor.withValues(alpha: 0.4), blurRadius: selected ? 8 : 4)],
                            ),
                            child: Icon(loc.icon, color: Colors.white, size: selected ? 17 : 13),
                          ),
                          if (selected)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(HAARadius.pill)),
                              child: Text(loc.name, style: HAAFonts.sans(10, weight: FontWeight.bold).copyWith(color: HAAColors.charcoal)),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _showBlueprintSheet(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg, vertical: 12),
            color: HAAColors.orangeLight,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: HAAColors.orange.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.map, color: HAAColors.orange, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rosary College Prep — Campus Layout', style: HAAFonts.sans(13, weight: FontWeight.bold).copyWith(color: HAAColors.charcoal)),
                      Text('Single-floor venue map · pinch to zoom', style: HAAFonts.sans(11).copyWith(color: HAAColors.muted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: HAAColors.orange, size: 13),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(HAASpacing.lg, 12, HAASpacing.lg, 90),
            itemCount: filteredLocations.length,
            itemBuilder: (_, i) {
              final loc = filteredLocations[i];
              final selected = selectedLocation?.name == loc.name;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    _focusLocation(loc);
                    _showLocationDetail(loc);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(HAARadius.lg),
                      border: Border.all(
                        color: selected ? loc.accentColor.withValues(alpha: 0.5) : HAAColors.border,
                        width: selected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: loc.accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(loc.icon, color: loc.accentColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.name, style: HAAFonts.sans(14, weight: FontWeight.bold).copyWith(color: HAAColors.charcoal)),
                              Text(loc.subtitle, style: HAAFonts.sans(12).copyWith(color: loc.accentColor)),
                              if (loc.distanceNote != null)
                                Text(loc.distanceNote!, style: HAAFonts.sans(11).copyWith(color: HAAColors.muted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 12, color: HAAColors.muted),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LocationDetailSheet extends StatelessWidget {
  const _LocationDetailSheet({required this.location});
  final ConventionLocation location;

  Future<void> _openDirections() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${location.coordinate.latitude},${location.coordinate.longitude}',
    );
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done', style: HAAFonts.sans(15, weight: FontWeight.w600).copyWith(color: HAAColors.orange)),
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(HAASpacing.lg),
              children: [
                      SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(initialCenter: location.coordinate, initialZoom: 14, interactionOptions: const InteractionOptions(flags: InteractiveFlag.none)),
                          children: [
                            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'org.havyak.haa_convention'),
                            MarkerLayer(markers: [Marker(point: location.coordinate, width: 40, height: 40, child: Icon(location.icon, color: location.accentColor, size: 30))]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(color: location.accentColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                            child: Icon(location.icon, color: location.accentColor, size: 17),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(location.name, style: HAAFonts.serif(18, weight: FontWeight.bold).copyWith(color: HAAColors.charcoal)),
                                Text(location.subtitle, style: HAAFonts.sans(13).copyWith(color: location.accentColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.place, size: 20, color: HAAColors.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ADDRESS', style: HAAFonts.sans(11, weight: FontWeight.w600).copyWith(color: HAAColors.muted)),
                                Text(location.address, style: HAAFonts.sans(14).copyWith(color: HAAColors.charcoal)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Text('DETAILS', style: HAAFonts.sans(11, weight: FontWeight.w600).copyWith(color: HAAColors.muted)),
                      const SizedBox(height: 8),
                      Text(location.detail, style: HAAFonts.sans(14).copyWith(color: HAAColors.charcoal, height: 1.4)),
                      const SizedBox(height: 20),
                      HAAButton(label: 'Get Directions in Maps', icon: Icons.directions, onPressed: _openDirections),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueBlueprintSheet extends StatefulWidget {
  const _VenueBlueprintSheet();

  @override
  State<_VenueBlueprintSheet> createState() => _VenueBlueprintSheetState();
}

class _VenueBlueprintSheetState extends State<_VenueBlueprintSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      maxChildSize: 0.98,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Row(
            children: [
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Done', style: HAAFonts.sans(15, weight: FontWeight.w600).copyWith(color: HAAColors.orange)),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg, vertical: 10),
            child: Row(
              children: [
                _legendChip(const Color(0xFFF5C6A5), 'Meals / Tea'),
                _legendChip(const Color(0xFFF5D76E), 'Auditorium'),
                _legendChip(const Color(0xFF90CAF9), 'Library / Youth'),
                _legendChip(const Color(0xFFA5D6A7), 'Outdoor Lawn'),
                _legendChip(const Color(0xFFCE93D8), 'Registration'),
                _legendChip(const Color(0xFFF5F0E1), 'Hallways', stroke: true),
                _legendChip(Colors.white, 'Breakout Rooms', stroke: true),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: SingleChildScrollView(
                controller: controller,
                child: Padding(
                  padding: const EdgeInsets.all(HAASpacing.lg),
                  child: Image.asset('assets/images/rosary_campus_map.png', width: 360),
                ),
              ),
            ),
          ),
          Container(
            height: 180,
            color: HAAColors.cream,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(HAASpacing.lg, 12, HAASpacing.lg, 8),
                  child: Text('VENUE AREAS', style: HAAFonts.sans(10, weight: FontWeight.bold).copyWith(color: HAAColors.muted, letterSpacing: 0.8)),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg),
                    itemCount: CampusArea.conventionAreas.length,
                    itemBuilder: (_, i) {
                      final area = CampusArea.conventionAreas[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(HAARadius.md),
                          border: Border.all(color: HAAColors.border, width: 0.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: area.color,
                                borderRadius: BorderRadius.circular(4),
                                border: area.needsBorder ? Border.all(color: HAAColors.border) : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(area.label, style: HAAFonts.sans(13, weight: FontWeight.bold).copyWith(color: HAAColors.charcoal)),
                                  Text(area.description, style: HAAFonts.sans(12).copyWith(color: HAAColors.muted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendChip(Color color, String label, {bool stroke = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: stroke ? Border.all(color: HAAColors.border) : null,
            ),
          ),
          const SizedBox(width: 5),
          Text(label, style: HAAFonts.sans(10, weight: FontWeight.w600).copyWith(color: HAAColors.muted)),
        ],
      ),
    );
  }
}
