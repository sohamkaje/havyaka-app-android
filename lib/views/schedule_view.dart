import 'package:flutter/material.dart';
import '../models/convention_models.dart';
import '../theme/design_system.dart';
import '../widgets/shared_components.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  late int selectedDayIndex;
  ScheduleEvent? selectedEvent;

  @override
  void initState() {
    super.initState();
    selectedDayIndex = _smartDefaultDay();
  }

  static int _smartDefaultDay() {
    final now = DateTime.now();
    if (now.month == 7) {
      if (now.day == 2) return 0;
      if (now.day == 3) return 1;
      if (now.day == 4) return 2;
      if (now.day >= 5) return 3;
      return 0;
    }
    if (now.month > 7) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final days = ConventionData.days;
    final day = days[selectedDayIndex];
    return Column(
      children: [
        const HAANavBar(title: 'Schedule', subtitle: ConventionData.scheduleSubtitle),
        _daySelector(days),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _scheduleBanner(),
                _dayHeader(day),
                ...day.events.map((e) => Padding(
                      padding: const EdgeInsets.fromLTRB(HAASpacing.lg, 0, HAASpacing.lg, 10),
                      child: _EventCard(event: e, onTap: () => _showEventDetail(e)),
                    )),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _daySelector(List<ConventionDay> days) {
    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(days.length, (idx) {
          final selected = selectedDayIndex == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedDayIndex = idx),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? HAAColors.orange : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(days[idx].shortDay,
                        style: HAAFonts.sans(18, weight: FontWeight.bold)
                            .copyWith(color: selected ? HAAColors.orange : HAAColors.muted)),
                    Text(days[idx].monthDay,
                        style: HAAFonts.sans(10).copyWith(color: selected ? HAAColors.orange : HAAColors.muted)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _scheduleBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(HAASpacing.lg),
      color: HAAColors.charcoal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ConventionData.scheduleTitle, style: HAAFonts.serif(18, weight: FontWeight.bold).copyWith(color: HAAColors.heroText)),
          Text(ConventionData.scheduleSubtitle, style: HAAFonts.serif(13).copyWith(color: HAAColors.mutedLight)),
          Text(ConventionData.scheduleTagline, style: HAAFonts.sans(11).copyWith(color: HAAColors.mutedLight)),
        ],
      ),
    );
  }

  Widget _dayHeader(ConventionDay day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg, vertical: 14),
      color: Colors.white,
      child: Row(
        children: [
          Text(day.fullDate, style: HAAFonts.serif(15, weight: FontWeight.w600).copyWith(color: HAAColors.charcoal)),
          const Spacer(),
          Text('${day.events.length} events', style: HAAFonts.sans(12).copyWith(color: HAAColors.muted)),
        ],
      ),
    );
  }

  void _showEventDetail(ScheduleEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HAAColors.cream,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
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
                    color: event.isHighlight ? HAAColors.goldLight : HAAColors.cream,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            EventTagChip(tag: event.tag),
                            if (event.isHighlight) const HighlightBadge(),
                            if (event.chapter != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: HAAColors.goldLight, borderRadius: BorderRadius.circular(HAARadius.pill)),
                                child: Text(event.chapter!, style: HAAFonts.sans(10, weight: FontWeight.bold).copyWith(color: HAAColors.gold)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(event.title, style: HAAFonts.serif(22, weight: FontWeight.bold).copyWith(color: HAAColors.charcoal)),
                        if (event.kannada != null) ...[
                          const SizedBox(height: 8),
                          Text(event.kannada!, style: HAAFonts.serif(15).copyWith(color: HAAColors.muted)),
                        ],
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
                        decoration: BoxDecoration(color: event.tag.backgroundColor, borderRadius: BorderRadius.circular(14)),
                        child: Icon(event.tag.icon, size: 24, color: event.tag.foregroundColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ABOUT THIS EVENT', style: HAAFonts.sans(11, weight: FontWeight.w600).copyWith(color: HAAColors.muted, letterSpacing: 0.8)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 12, color: HAAColors.gold),
                                const SizedBox(width: 6),
                                Text(event.time, style: HAAFonts.sans(14, weight: FontWeight.w600).copyWith(color: HAAColors.charcoal)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(event.details, style: HAAFonts.sans(15).copyWith(color: HAAColors.charcoal, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text('LOCATION', style: HAAFonts.sans(11, weight: FontWeight.w600).copyWith(color: HAAColors.muted, letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.place, size: 22, color: HAAColors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.venue, style: HAAFonts.sans(14, weight: FontWeight.w600).copyWith(color: HAAColors.charcoal)),
                            Text(event.locationAddress, style: HAAFonts.sans(12).copyWith(color: HAAColors.muted)),
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

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.onTap});
  final ScheduleEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(HAARadius.lg),
          border: Border.all(
            color: event.isHighlight ? HAAColors.gold.withValues(alpha: 0.4) : HAAColors.border,
            width: event.isHighlight ? 1 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (event.isHighlight) const HighlightBadge(),
                EventTagChip(tag: event.tag),
                if (event.chapter != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: HAAColors.goldLight, borderRadius: BorderRadius.circular(HAARadius.pill)),
                    child: Text(event.chapter!, style: HAAFonts.sans(9, weight: FontWeight.bold).copyWith(color: HAAColors.gold)),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(event.title, style: HAAFonts.sans(15, weight: FontWeight.w600).copyWith(color: HAAColors.charcoal)),
            if (event.kannada != null)
              Text(event.kannada!, style: HAAFonts.serif(12).copyWith(color: HAAColors.muted)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.place, size: 10, color: HAAColors.orange.withValues(alpha: 0.85)),
                const SizedBox(width: 4),
                Text(event.venue, style: HAAFonts.sans(11, weight: FontWeight.w500).copyWith(color: HAAColors.orange.withValues(alpha: 0.85))),
              ],
            ),
            const SizedBox(height: 4),
            Text(event.details, style: HAAFonts.sans(12).copyWith(color: HAAColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tap for details', style: HAAFonts.sans(11, weight: FontWeight.w500).copyWith(color: HAAColors.orange)),
                  const Icon(Icons.open_in_new, size: 9, color: HAAColors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
