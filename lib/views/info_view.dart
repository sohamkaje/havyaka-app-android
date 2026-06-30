import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/convention_models.dart';
import '../services/auth_view_model.dart';
import '../services/network_monitor.dart';
import '../theme/design_system.dart';
import '../widgets/shared_components.dart';
import 'account_view.dart';

class InfoAccountView extends StatefulWidget {
  const InfoAccountView({super.key, this.moreSectionRequest, required this.onSectionHandled});
  final InfoAccountSection? moreSectionRequest;
  final VoidCallback onSectionHandled;

  @override
  State<InfoAccountView> createState() => _InfoAccountViewState();
}

class _InfoAccountViewState extends State<InfoAccountView> {
  InfoAccountSection section = InfoAccountSection.info;

  @override
  void didUpdateWidget(InfoAccountView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.moreSectionRequest != null) {
      setState(() => section = widget.moreSectionRequest!);
      widget.onSectionHandled();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final network = context.watch<NetworkMonitor>();

    return Column(
      children: [
        HAANavBar(
          title: section == InfoAccountSection.info ? 'Convention Info' : 'My Account',
          subtitle: section == InfoAccountSection.info ? 'Everything you need to know' : 'Registration & profile',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(HAASpacing.lg, 12, HAASpacing.lg, 12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(HAARadius.md),
              border: Border.all(color: HAAColors.border, width: 0.5),
            ),
            child: Row(
              children: InfoAccountSection.values.map((item) {
                final selected = section == item;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => section = item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? HAAColors.orange : Colors.transparent,
                        borderRadius: BorderRadius.circular(HAARadius.sm),
                      ),
                      child: Text(
                        item == InfoAccountSection.info ? 'Info' : 'Account',
                        textAlign: TextAlign.center,
                        style: HAAFonts.sans(13, weight: FontWeight.w600).copyWith(color: selected ? Colors.white : HAAColors.muted),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (section == InfoAccountSection.account && !network.isConnected)
          const OfflineBanner(message: 'No internet connection. Sign in, sign up, and check-in require service.'),
        Expanded(
          child: section == InfoAccountSection.info
              ? const InfoTabContent()
              : auth.isLoggedIn
                  ? const ProfileView()
                  : const AccessView(),
        ),
      ],
    );
  }
}

class InfoTabContent extends StatefulWidget {
  const InfoTabContent({super.key});

  @override
  State<InfoTabContent> createState() => _InfoTabContentState();
}

class _InfoTabContentState extends State<InfoTabContent> {
  String? expandedCard = 'venue';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _quickContactBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(HAASpacing.lg, 14, HAASpacing.lg, 90),
            child: Column(
              children: [
                _accordion('venue', Icons.place, 'Venue & Dates', HAAColors.orange, _venueContent()),
                const SizedBox(height: 10),
                _accordion('committees', Icons.groups, 'Organizing Committees', HAAColors.gold, _committeesContent()),
                const SizedBox(height: 10),
                _accordion('faq', Icons.help, 'FAQ & Need to Know', HAAColors.orange, _faqContent()),
                const SizedBox(height: 10),
                _accordion('sponsors', Icons.star, 'Sponsors', HAAColors.gold, _sponsorsContent()),
                const SizedBox(height: 10),
                _accordion('about', Icons.business, 'About HAA', HAAColors.orange, _aboutContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickContactBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          _linkChip('Convention Site', Icons.language, HAAColors.orange, Colors.white, 'https://haaconvention.org'),
          const SizedBox(width: 10),
          _linkChip('Email Us', Icons.email, HAAColors.orange, HAAColors.orange, 'mailto:secretary@havyak.org', outline: true),
        ],
      ),
    );
  }

  Widget _linkChip(String label, IconData icon, Color fg, Color bg, String url, {bool outline = false}) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: outline ? HAAColors.orangeLight : bg,
          borderRadius: BorderRadius.circular(HAARadius.pill),
          border: outline ? Border.all(color: HAAColors.orange.withValues(alpha: 0.3)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 6),
            Text(label, style: HAAFonts.sans(12, weight: FontWeight.w600).copyWith(color: fg)),
          ],
        ),
      ),
    );
  }

  Widget _accordion(String id, IconData icon, String title, Color accent, Widget content) {
    final expanded = expandedCard == id;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HAARadius.lg),
        border: Border.all(color: expanded ? accent.withValues(alpha: 0.3) : HAAColors.border, width: expanded ? 1 : 0.5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => expandedCard = expanded ? null : id),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
                    child: Icon(icon, size: 16, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title, style: HAAFonts.sans(15, weight: FontWeight.bold).copyWith(color: HAAColors.charcoal))),
                  Icon(Icons.expand_more, size: 12, color: HAAColors.muted),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1),
            Padding(padding: const EdgeInsets.all(14), child: content),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: HAAFonts.sans(9, weight: FontWeight.bold).copyWith(color: HAAColors.muted, letterSpacing: 0.6)),
                Text(value, style: HAAFonts.sans(13).copyWith(color: HAAColors.charcoal, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _venueContent() {
    return Column(
      children: [
        _infoRow(Icons.account_balance, 'Venue', 'Rosary College Prep', HAAColors.orange),
        _infoRow(Icons.map, 'Address', '901 N Edgelawn Dr, Aurora, IL 60506', HAAColors.orange),
        _infoRow(Icons.calendar_month, 'Dates', 'July 3, 4 & 5, 2026', HAAColors.gold),
        _infoRow(Icons.nightlight, 'Arrive', 'Thursday evening, July 2', HAAColors.gold),
        _infoRow(Icons.email, 'Contact', 'secretary@havyak.org', HAAColors.orange),
      ],
    );
  }

  Widget _committeesContent() {
    const committees = [
      ('Cultural Programs', '15 Chapters', 1.0),
      ('Vedic & Religious', 'Core Team', 0.75),
      ('Youth Forum', 'HAA Youth', 0.6),
      ('Havyasiri Publication', 'Editorial', 0.5),
      ('Sponsorship & Finance', 'Treasurer', 0.45),
      ('Accommodations', 'Logistics', 0.4),
      ('Technology & App', 'Tech Team', 0.35),
    ];
    return Column(
      children: [
        ...committees.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(c.$1, style: HAAFonts.sans(13, weight: FontWeight.w600))),
                      Text(c.$2, style: HAAFonts.sans(11).copyWith(color: HAAColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(value: c.$3, minHeight: 4, backgroundColor: HAAColors.orangeLight, color: HAAColors.orange),
                  ),
                ],
              ),
            )),
        const Divider(),
        GestureDetector(
          onTap: () => launchUrl(Uri.parse('https://haaconvention.org/haa2026-organizing-committee/'), mode: LaunchMode.externalApplication),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: HAAColors.orangeLight, borderRadius: BorderRadius.circular(HAARadius.md)),
            child: Text('View Full Committee List', textAlign: TextAlign.center, style: HAAFonts.sans(13, weight: FontWeight.w600).copyWith(color: HAAColors.orange)),
          ),
        ),
      ],
    );
  }

  Widget _faqContent() {
    const faqs = [
      ('What food is served?', 'All meals are 100% vegetarian (Satvika). Traditional Havyaka cuisine is served including South Indian breakfasts, full rice lunches with sambar/rasam, and light dinners.'),
      ('Which airport should I fly into?', 'Chicago O\'Hare (ORD) is ~40 min drive and preferred. Chicago Midway (MDW) is ~50 min.'),
      ('What is the dress code?', 'Traditional attire is encouraged for ceremonies and cultural events. Business casual is acceptable for daytime programs.'),
      ('Is there parking at the venue?', 'Yes, ample free parking is available on the Rosary College Prep campus.'),
      ('When does registration close?', 'Early bird registration ended Feb 8, 2026. Standard registration is still open.'),
    ];
    return Column(children: faqs.map((f) => _FAQItem(q: f.$1, a: f.$2)).toList());
  }

  Widget _sponsorsContent() {
    return Column(
      children: [
        Text(
          'Become a sponsor and support the Havyaka community across the Americas. Various sponsorship tiers are available.',
          style: HAAFonts.sans(13).copyWith(color: HAAColors.muted, height: 1.3),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => launchUrl(Uri.parse('https://haaconvention.org/sponsor/'), mode: LaunchMode.externalApplication),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(color: HAAColors.gold, borderRadius: BorderRadius.circular(HAARadius.md)),
            child: Text('View Sponsorship Packages', textAlign: TextAlign.center, style: HAAFonts.sans(13, weight: FontWeight.w600).copyWith(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _aboutContent() {
    return Column(
      children: [
        _infoRow(Icons.calendar_month, 'Founded', '1982 · Registered in New Jersey, USA', HAAColors.gold),
        _infoRow(Icons.map, 'Chapters', '15 chapters across North America', HAAColors.orange),
        _infoRow(Icons.groups, 'Members', '~500 at this convention', HAAColors.gold),
        _infoRow(Icons.favorite, 'Mission', 'Promoting Sanatana Dharma, Satvika lifestyle, and Havyaka cultural heritage', HAAColors.orange),
        const Divider(),
        GestureDetector(
          onTap: () => launchUrl(Uri.parse('https://www.havyak.org'), mode: LaunchMode.externalApplication),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: HAAColors.orangeLight, borderRadius: BorderRadius.circular(HAARadius.md)),
            child: Text('Visit HAA Website', textAlign: TextAlign.center, style: HAAFonts.sans(13, weight: FontWeight.w600).copyWith(color: HAAColors.orange)),
          ),
        ),
      ],
    );
  }
}

class _FAQItem extends StatefulWidget {
  const _FAQItem({required this.q, required this.a});
  final String q;
  final String a;

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(expanded ? Icons.expand_more : Icons.chevron_right, size: 11, color: HAAColors.orange),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.q, style: HAAFonts.sans(13, weight: FontWeight.w600).copyWith(color: HAAColors.charcoal))),
            ],
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 19),
            child: Text(widget.a, style: HAAFonts.sans(12).copyWith(color: HAAColors.muted, height: 1.3)),
          ),
        ],
        const Divider(height: 16),
      ],
    );
  }
}
