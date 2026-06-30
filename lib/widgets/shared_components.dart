import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import '../models/convention_models.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: HAAColors.orangeLight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wifi_off, size: 15, color: HAAColors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: HAAFonts.sans(12).copyWith(color: HAAColors.charcoal),
            ),
          ),
        ],
      ),
    );
  }
}

class HAANavBar extends StatelessWidget {
  const HAANavBar({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg, vertical: 12),
      color: HAAColors.charcoal,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 34,
              height: 34,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: HAAFonts.serif(16, weight: FontWeight.w600).copyWith(color: HAAColors.heroText)),
                if (subtitle != null)
                  Text(subtitle!, style: HAAFonts.sans(11).copyWith(color: HAAColors.mutedLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(HAASpacing.lg, 20, HAASpacing.lg, 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: HAAFonts.sans(11, weight: FontWeight.w600).copyWith(
              color: HAAColors.muted,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: HAAFonts.sans(12, weight: FontWeight.w600).copyWith(color: HAAColors.orange),
              ),
            ),
        ],
      ),
    );
  }
}

class EventTagChip extends StatelessWidget {
  const EventTagChip({super.key, required this.tag});
  final EventTag tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: tag.backgroundColor,
        borderRadius: BorderRadius.circular(HAARadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tag.icon, size: 9, color: tag.foregroundColor),
          const SizedBox(width: 4),
          Text(
            tag.label,
            style: HAAFonts.sans(10, weight: FontWeight.w600).copyWith(color: tag.foregroundColor),
          ),
        ],
      ),
    );
  }
}

class HighlightBadge extends StatelessWidget {
  const HighlightBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: HAAColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(HAARadius.pill),
        border: Border.all(color: HAAColors.gold.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 8, color: HAAColors.gold),
          const SizedBox(width: 3),
          Text('Highlight', style: HAAFonts.sans(9, weight: FontWeight.bold).copyWith(color: HAAColors.gold)),
        ],
      ),
    );
  }
}

class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? HAAColors.charcoal : Colors.white,
          borderRadius: BorderRadius.circular(HAARadius.pill),
          border: isSelected ? null : Border.all(color: HAAColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: isSelected ? HAAColors.gold : HAAColors.muted),
            const SizedBox(width: 5),
            Text(
              label,
              style: HAAFonts.sans(12, weight: FontWeight.w600)
                  .copyWith(color: isSelected ? HAAColors.gold : HAAColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class HAAButton extends StatelessWidget {
  const HAAButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.outline = false,
    this.enabled = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool outline;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: outline ? Colors.transparent : (enabled ? HAAColors.orange : HAAColors.muted),
        borderRadius: BorderRadius.circular(HAARadius.md),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(HAARadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(HAARadius.md),
              border: outline ? Border.all(color: HAAColors.orange) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 13, color: outline ? HAAColors.orange : Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: HAAFonts.sans(14, weight: FontWeight.w600)
                      .copyWith(color: outline ? HAAColors.orange : Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HAATabBar extends StatelessWidget {
  const HAATabBar({super.key, required this.selectedTab, required this.onTabSelected});

  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  static const _tabs = [
    (Icons.home, 'Home'),
    (Icons.calendar_today, 'Schedule'),
    (Icons.map, 'Map'),
    (Icons.photo, 'Photos'),
    (Icons.more_horiz, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HAAColors.charcoal,
        border: Border(top: BorderSide(color: HAAColors.gold.withValues(alpha: 0.2), width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final selected = selectedTab == i;
            return Expanded(
              child: InkWell(
                onTap: () => onTabSelected(i),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _tabs[i].$1,
                        size: 19,
                        color: selected ? HAAColors.gold : Colors.white.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tabs[i].$2,
                        style: HAAFonts.sans(8, weight: FontWeight.w500).copyWith(
                          color: selected ? HAAColors.gold : Colors.white.withValues(alpha: 0.4),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
