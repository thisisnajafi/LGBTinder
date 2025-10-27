# Phase 3.3: Colors Migration Strategy

## Tier-Based Approach

### Tier 1: High-Impact Pages (Start Here)
1. discovery_page.dart (11 instances)
2. home_page.dart (22 instances)
3. chat_page.dart (20 instances)
4. profile_page.dart (21 instances)

### Tier 2: Core Components
1. message_bubble.dart (34 instances)
2. profile_header.dart (19 instances)
3. chat components (10+ files)

### Tier 3: Settings & Screens
1. Settings screens (47 files)
2. Auth screens
3. Profile screens

### Color Mapping Strategy

**Colors.white Mappings**:
- Text on dark bg â†’ AppColors.textPrimaryDark
- Icons on colored bg â†’ Colors.white (keep for contrast)
- Backgrounds â†’ AppColors.backgroundLight

**Colors.black Mappings**:
- Text on light bg â†’ AppColors.textPrimary
- Shadows â†’ Keep as Colors.black.withOpacity()
- Backgrounds â†’ AppColors.backgroundDark

**Colors.grey/gray Mappings**:
- Secondary text â†’ AppColors.textSecondary
- Borders â†’ AppColors.border
- Disabled states â†’ AppColors.textSecondary.withOpacity()

---

**Starting with Tier 1: High-Impact Pages**
