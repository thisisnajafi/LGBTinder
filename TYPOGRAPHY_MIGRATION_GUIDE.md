# Typography Migration Guide

**Status**: Ready to Start
**Total Instances**: 929 (fontSize: 252, fontWeight: 677)
**Files**: 117 files
**Estimated**: 6-8 hours

## fontSize Mappings

| fontSize | AppTypography | Context |
|----------|---------------|---------|
| 11-12 | bodySmall | Captions, metadata |
| 14 | bodyMedium | Body text |
| 16 | bodyLarge | Primary text |
| 18 | titleMedium | Section titles |
| 20-22 | titleLarge | Headers |
| 24 | headlineSmall | Headlines |
| 28+ | headlineMedium/Large | Hero text |

## fontWeight Mappings

| fontWeight | Use Instead |
|-----------|-------------|
| w400 (normal) | bodyMedium |
| w500 (medium) | labelMedium |
| w600 (semibold) | titleMedium |
| w700 (bold) | headlineMedium |

## Top Files (By Impact)

fontSize instances:
1. pages/profile_wizard_page.dart (19)
2. utils/success_feedback.dart (19)
3. components/statistics/match_statistics.dart (12)
4. components/super_like/super_like_sheet.dart (10)
5. pages/profile_page.dart (10)

fontWeight instances:
1. pages/home_page_old.dart (26)
2. screens/auth/profile_wizard_screen.dart (21)
3. components/gamification/gamification_components.dart (14)
4. components/templates/template_components.dart (14)
5. pages/home_page.dart (13)

## Common Patterns

Simple fontSize:
TextStyle(fontSize: 14) â†’ AppTypography.bodyMedium

fontSize + color:
TextStyle(fontSize: 14, color: Colors.white)
â†’ AppTypography.bodyMedium.copyWith(color: ...)

fontSize + fontWeight:
TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
â†’ AppTypography.titleMedium

## Migration Strategy

Phase A: Fix top 10 high-impact files
Phase B: Batch fix simple patterns
Phase C: Manual fix complex cases

See UI_CONSISTENCY_AUDIT_REPORT.md for full details.
