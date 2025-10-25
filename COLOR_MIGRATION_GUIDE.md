# Colors.* Migration Guide

## Status: In Progress (Phase 3.3)

**Last Updated**: October 25, 2025  
**Total Instances**: 4,838 across 146 files  
**Completed**: 119 hardcoded Color(0x...) instances  
**Remaining**: 4,838 Colors.* instances

## Quick Reference

### KEEP AS-IS
- Colors.transparent - Always OK

### CONTEXT-DEPENDENT (Requires Manual Review)

#### Colors.white (1,522 instances in 138 files)
- Text on dark background â†’ Theme.of(context).colorScheme.onPrimary
- Card/Surface background â†’ Theme.of(context).colorScheme.surface
- Icon color on dark â†’ Theme.of(context).colorScheme.onPrimary
- With opacity â†’ Colors.white.withOpacity(0.x)

#### Colors.black (161 instances in 61 files)
- Text on light background â†’ Theme.of(context).colorScheme.onSurface
- Shadows â†’ Keep Colors.black.withOpacity(0.x)
- Icon color on light â†’ Theme.of(context).colorScheme.onSurface

#### Colors.grey (111 instances in 27 files)
- Disabled state â†’ Theme.of(context).colorScheme.onSurface.withOpacity(0.38)
- Secondary text â†’ AppColors.textSecondaryLight/Dark
- Borders â†’ Theme.of(context).colorScheme.outline

## Priority Files (High Impact)

### Tier 1 - Critical (437 instances)
1. pages/home_page_old.dart (181)
2. pages/chat_page.dart (71)
3. pages/home_page.dart (67)
4. pages/discovery_page.dart (48)
5. pages/profile_page.dart (48)
6. pages/chat_list_page.dart (22)

### Tier 2 - Important (189 instances)
7. screens/auth/register_screen.dart (74)
8. screens/auth/login_screen.dart (41)
9. screens/profile_edit_screen.dart (38)
10. screens/settings_screen.dart (36)

## Migration Progress

Completed: 119/4,957 (2.4%)
Estimated Time: 20-30 hours remaining
Strategy: Fix high-impact files first, then components

See UI_CONSISTENCY_AUDIT_REPORT.md for full details.
