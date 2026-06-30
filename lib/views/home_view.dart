import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/convention_models.dart';
import '../services/auth_view_model.dart';
import '../theme/design_system.dart';
import '../widgets/shared_components.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.onNavigateTab, required this.onNavigateMore});
  final ValueChanged<int> onNavigateTab;
  final ValueChanged<InfoAccountSection> onNavigateMore;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Timer _timer;
  int days = 0, hours = 0, minutes = 0, seconds = 0;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final target = DateTime(2026, 7, 3, 9, 0, 0);
    final chicago = target; // July 3 9AM Chicago approximated
    final diff = chicago.difference(DateTime.now());
    if (diff.isNegative) {
      setState(() { days = hours = minutes = seconds = 0; });
      return;
    }
    final total = diff.inSeconds;
    setState(() {
      seconds = total % 60;
      minutes = (total ~/ 60) % 60;
      hours = (total ~/ 3600) % 24;
      days = total ~/ 86400;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    return Column(
      children: [
        const HAANavBar(
          title: 'HAA Convention 2026',
          subtitle: '21st Biennial Havyaka Samagama',
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _heroSection(),
                _countdownBar(),
                _quickAccess(auth),
                _starAttractions(),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroSection() {
    return Container(
      width: double.infinity,
      color: HAAColors.charcoal,
      padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: HAAColors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(HAARadius.pill),
              border: Border.all(color: HAAColors.orange.withValues(alpha: 0.4), width: 0.5),
            ),
            child: Text(
              'July 3 – 5, 2026  ·  Aurora, Illinois',
              style: HAAFonts.sans(10, weight: FontWeight.w600).copyWith(
                color: HAAColors.orange.withValues(alpha: 0.9),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('ಹವ್ಯಕ ಸಮಾಗಮ', style: HAAFonts.serif(28, weight: FontWeight.bold).copyWith(color: HAAColors.heroText)),
          Text('ನಮ್ಮ ಜನ, ನಮ್ಮತನ, ನಮ್ಮ ಧನ, ನಮ್ಮ ಋಣ',
              style: HAAFonts.sans(13).copyWith(color: HAAColors.mutedLight)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.place, size: 12, color: HAAColors.mutedLight),
              const SizedBox(width: 4),
              Text('Rosary College Prep', style: HAAFonts.sans(12).copyWith(color: HAAColors.mutedLight)),
              const SizedBox(width: 16),
              Icon(Icons.groups, size: 12, color: HAAColors.mutedLight),
              const SizedBox(width: 4),
              Text('~500 attendees', style: HAAFonts.sans(12).copyWith(color: HAAColors.mutedLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _countdownBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg, vertical: 14),
      color: HAAColors.goldLight,
      child: Row(
        children: [
          Text('Convention starts in', style: HAAFonts.sans(10, weight: FontWeight.w600).copyWith(color: HAAColors.muted)),
          const Spacer(),
          _countUnit(days.toString().padLeft(2, '0'), 'days'),
          _colon(),
          _countUnit(hours.toString().padLeft(2, '0'), 'hrs'),
          _colon(),
          _countUnit(minutes.toString().padLeft(2, '0'), 'min'),
          _colon(),
          _countUnit(seconds.toString().padLeft(2, '0'), 'sec'),
        ],
      ),
    );
  }

  Widget _colon() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(':', style: HAAFonts.sans(16, weight: FontWeight.bold).copyWith(color: HAAColors.gold, fontFamily: 'monospace')),
      );

  Widget _countUnit(String value, String label) => SizedBox(
        width: 32,
        child: Column(
          children: [
            Text(value, style: HAAFonts.sans(20, weight: FontWeight.bold).copyWith(fontFamily: 'monospace', color: HAAColors.charcoal)),
            Text(label, style: HAAFonts.sans(8, weight: FontWeight.w600).copyWith(color: HAAColors.muted)),
          ],
        ),
      );

  Widget _quickAccess(AuthViewModel auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Access'),
        if (!auth.isLoggedIn)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg),
            child: GestureDetector(
              onTap: () => widget.onNavigateMore(InfoAccountSection.account),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: HAAColors.orange, borderRadius: BorderRadius.circular(HAARadius.md)),
                child: Row(
                  children: [
                    const Icon(Icons.account_circle, color: Colors.white, size: 16),
                    const SizedBox(width: 10),
                    Text('Log in here', style: HAAFonts.sans(14, weight: FontWeight.bold).copyWith(color: Colors.white)),
                    const Spacer(),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 12),
                  ],
                ),
              ),
            ),
          ),
        if (!auth.isLoggedIn) const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: [
              _quickCard(Icons.calendar_month, 'Schedule', '3-day full program', HAAColors.orange, () => widget.onNavigateTab(1)),
              _quickCard(Icons.map, 'Locations', 'Hotels & venue', HAAColors.gold, () => widget.onNavigateTab(2)),
              _quickCard(Icons.photo_library, 'Photos', 'Share memories', HAAColors.orange, () => widget.onNavigateTab(3)),
              _quickCard(Icons.info, 'Convention Info', 'Committees & FAQ', HAAColors.gold, () => widget.onNavigateMore(InfoAccountSection.info)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickCard(IconData icon, String label, String sub, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(HAASpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(HAARadius.lg),
          border: Border.all(color: HAAColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const Spacer(),
            Text(label, style: HAAFonts.sans(14, weight: FontWeight.bold).copyWith(color: HAAColors.charcoal)),
            Text(sub, style: HAAFonts.sans(11).copyWith(color: HAAColors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _starAttractions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Star Attractions'),
        ...StarAttraction.highlights.map((a) => Padding(
              padding: const EdgeInsets.fromLTRB(HAASpacing.lg, 0, HAASpacing.lg, 10),
              child: GestureDetector(
                onTap: () => _showAttractionDetail(a),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: HAAColors.charcoal,
                    borderRadius: BorderRadius.circular(HAARadius.lg),
                    border: Border.all(color: HAAColors.gold.withValues(alpha: 0.12), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: HAAColors.charcoal, borderRadius: BorderRadius.circular(12)),
                        child: Icon(a.icon, size: 22, color: a.iconColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title, style: HAAFonts.sans(14, weight: FontWeight.bold).copyWith(color: HAAColors.heroText)),
                            Text(a.subtitle, style: HAAFonts.sans(12).copyWith(color: HAAColors.mutedLight)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 12, color: HAAColors.mutedLight),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  void _showAttractionDetail(StarAttraction attraction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HAAColors.cream,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Done', style: HAAFonts.sans(15, weight: FontWeight.w600).copyWith(color: HAAColors.orange)),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(HAASpacing.lg),
                children: [
                  Container(
                    padding: const EdgeInsets.all(HAASpacing.lg),
                    color: HAAColors.goldLight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HighlightBadge(),
                        const SizedBox(height: 12),
                        Text(attraction.title, style: HAAFonts.serif(22, weight: FontWeight.bold).copyWith(color: HAAColors.charcoal)),
                        if (attraction.kannada != null) ...[
                          const SizedBox(height: 8),
                          Text(attraction.kannada!, style: HAAFonts.serif(15).copyWith(color: HAAColors.muted)),
                        ],
                        const SizedBox(height: 8),
                        Text(attraction.subtitle, style: HAAFonts.sans(14, weight: FontWeight.w500).copyWith(color: HAAColors.orange)),
                      ],
                    ),
                  ),
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(color: HAAColors.charcoal, borderRadius: BorderRadius.circular(14)),
                        child: Icon(attraction.icon, size: 24, color: attraction.iconColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('WHAT TO EXPECT', style: HAAFonts.sans(11, weight: FontWeight.w600).copyWith(color: HAAColors.muted, letterSpacing: 0.8)),
                            const SizedBox(height: 4),
                            Text(attraction.description, style: HAAFonts.sans(15).copyWith(color: HAAColors.charcoal, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
