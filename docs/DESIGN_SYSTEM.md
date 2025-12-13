# FurFriendDiary Design System Documentation

**Version:** 1.0.0  
**Date:** December 12, 2025  
**Purpose:** Complete design system reference for v1.4.0 UI redesign

---

## 📍 Design Token Locations

All design tokens are located in: `lib/theme/tokens/`

**Files:**
- `colors.dart` → `DesignColors` class
- `spacing.dart` → `DesignSpacing` class  
- `typography.dart` → `DesignTypography` class
- `shadows.dart` → `DesignShadows` class

---

## 🎨 Color System

### Usage Pattern
```dart
import 'package:fur_friend_diary/theme/tokens/colors.dart';

// Light mode colors
Container(
  color: DesignColors.lBackground,
  child: Text(
    'Hello',
    style: TextStyle(color: DesignColors.lPrimaryText),
  ),
)

// Dark mode colors  
Container(
  color: DesignColors.dBackground,
  child: Text(
    'Hello',
    style: TextStyle(color: DesignColors.dPrimaryText),
  ),
)

// Highlight colors (user-selectable accents)
Container(
  decoration: BoxDecoration(
    color: DesignColors.highlightPurple,
  ),
)
```

### Available Colors

**Light Mode (`l` prefix):**
- `lBackground` - #F8F9FA (main background)
- `lSurfaces` - #E9ECEF (cards, containers)
- `lPrimaryText` - #212529 (main text)
- `lSecondaryText` - #6C757D (subtle text)
- `lSuccess` - #6BD9A7 (green)
- `lWarning` - #FFD166 (yellow)
- `lDanger` - #FF6B6B (red)
- `lSecondary` - #FF9E5E (orange)
- `lDisabled` - #AFAFAF (disabled state)

**Dark Mode (`d` prefix):**
- `dBackground` - #121417 (main background)
- `dSurfaces` - #23272C (cards, containers)
- `dPrimaryText` - #F1F3F5 (main text)
- `dSecondaryText` - #B0B3B8 (subtle text)
- `dSuccess` - #64D1A2 (green)
- `dWarning` - #FFD860 (yellow)
- `dDanger` - #FF7F7F (red)
- `dSecondary` - #FFB27D (orange)
- `dDisabled` - #555A60 (disabled state)

**Highlight Colors (8 options):**
- `highlightBlue` - #4A8FE7
- `highlightPink` - #E3B7C4
- `highlightCoral` - #FF7C70
- `highlightPurple` - #A88ED9 (default in reference)
- `highlightYellow` - #F6C343
- `highlightTeal` - #30B2A3
- `highlightPeach` - #FDAF9D
- `highlightNavy` - #2E3A59

**List Access:**
```dart
DesignColors.highlightColors // List<Color> of all 8 colors
```

---

## 📏 Spacing System

### Usage Pattern
```dart
import 'package:fur_friend_diary/theme/tokens/spacing.dart';

// Padding
Container(
  padding: EdgeInsets.all(DesignSpacing.md),
)

// Margins
SizedBox(height: DesignSpacing.lg)

// Mixed spacing
Container(
  padding: EdgeInsets.symmetric(
    horizontal: DesignSpacing.md,
    vertical: DesignSpacing.sm,
  ),
)
```

### Spacing Scale (8-point grid)
- `xs` - 4.0 (tiny gaps, icon padding)
- `sm` - 8.0 (compact spacing)
- `md` - 16.0 (standard spacing) ⭐ Most common
- `lg` - 24.0 (section spacing)
- `xl` - 32.0 (major sections)
- `xxl` - 48.0 (screen sections)
- `xxxl` - 64.0 (major divisions)

---

## 📝 Typography System

### Font Families
1. **Poppins** - Headings, CTAs (bold, attention-grabbing)
2. **Inter** - Body text (readable, modern)
3. **Quicksand** - Playful accents (pet names, tags)

### Usage Pattern
```dart
import 'package:google_fonts/google_fonts.dart';

// Headings (Poppins)
Text(
  'Section Title',
  style: GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  ),
)

// Body text (Inter)
Text(
  'Description text',
  style: GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
)

// Pet names (Quicksand)
Text(
  'Fluffy',
  style: GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  ),
)
```

### Typography Scale
**Headings (Poppins):**
- Large: 32px, SemiBold (w600)
- Medium: 24px, SemiBold (w600)
- CTA: 16px, Bold (w700)

**Body (Inter):**
- Regular: 16px, Regular (w400)
- Medium: 18px, Medium (w500)
- Button: 16px, SemiBold (w600)

**Playful (Quicksand):**
- Pet Name: 16px, Medium (w500)
- Tag: 14px, Bold (w700)

---

## 🌑 Shadow System

### Usage Pattern
```dart
import 'package:fur_friend_diary/theme/tokens/shadows.dart';

Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: DesignShadows.md, // ← List<BoxShadow>
  ),
)
```

### Shadow Levels
- `none` - No shadow (flat elements)
- `sm` - Subtle (slight depth)
- `md` - Standard (cards, containers) ⭐ Most common
- `lg` - Raised (floating elements)
- `xl` - Elevated (modals, overlays)
- `xxl` - High elevation (dialogs, bottom sheets)

### Colored Shadows
```dart
// Primary color shadow (dynamic)
boxShadow: DesignShadows.primary(DesignColors.highlightPurple)

// Fixed colored shadows
boxShadow: DesignShadows.success // Green tint
boxShadow: DesignShadows.danger  // Red tint
```

### Dark Mode Shadows
```dart
boxShadow: DesignShadows.darkMd  // For dark backgrounds
boxShadow: DesignShadows.darkLg  // Elevated in dark mode
```

---

## 🎨 Design Patterns from Reference

### Icon Background Pattern (PetiCare)
```dart
// Colored circular icon backgrounds
Container(
  width: 56,
  height: 56,
  decoration: BoxDecoration(
    color: DesignColors.highlightPurple.withOpacity(0.2),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Icon(
    Icons.settings,
    color: DesignColors.highlightPurple,
    size: 28,
  ),
)
```

### Section Header Pattern
```dart
// Muted section headers
Padding(
  padding: EdgeInsets.only(
    left: DesignSpacing.md,
    top: DesignSpacing.lg,
    bottom: DesignSpacing.sm,
  ),
  child: Text(
    'SECTION NAME',
    style: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: DesignColors.highlightTeal,
      letterSpacing: 0.5,
    ),
  ),
)
```

### List Item Pattern
```dart
ListTile(
  contentPadding: EdgeInsets.symmetric(
    horizontal: DesignSpacing.md,
    vertical: DesignSpacing.sm,
  ),
  leading: _buildIconBackground(),
  title: Text(
    'Item Title',
    style: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
  ),
  subtitle: Text(
    'Subtitle description',
    style: GoogleFonts.inter(
      fontSize: 14,
      color: DesignColors.dSecondaryText,
    ),
  ),
  trailing: Icon(
    Icons.chevron_right,
    color: DesignColors.dSecondaryText,
  ),
)
```

### Card Pattern
```dart
Container(
  margin: EdgeInsets.symmetric(
    horizontal: DesignSpacing.md,
    vertical: DesignSpacing.sm,
  ),
  padding: EdgeInsets.all(DesignSpacing.md),
  decoration: BoxDecoration(
    color: DesignColors.dSurfaces,
    borderRadius: BorderRadius.circular(16),
    boxShadow: DesignShadows.sm,
  ),
  child: // content
)
```

---

## ⚠️ CRITICAL: Flutter 3.38+ Color API Bug

**Date Discovered:** December 13, 2025
**Affects:** Flutter 3.38.x with custom color classes (DesignColors)

### The Problem
Flutter 3.38+ introduced `.withValues(alpha:)` as a replacement for `.withOpacity()`. However, when used with custom color constants from design token classes, **icons and text may fail to render** while container backgrounds appear correctly.

**Symptom:** Empty teal/coral squares where icons should appear, missing badge text.

### Root Cause
The `.withValues(alpha:)` API has rendering issues when:
1. Used with static `const Color` definitions in custom classes
2. Combined with `BoxDecoration` backgrounds
3. Applied to Icon or Text widget colors

### Solution
**Always use `.withOpacity()` instead of `.withValues(alpha:)`**

```dart
// ❌ DON'T - May cause rendering bugs
color: DesignColors.highlightTeal.withValues(alpha: 26),

// ✅ DO - Battle-tested, reliable
color: DesignColors.highlightTeal.withOpacity(0.1),
```

### Conversion Table
| Alpha (0-255) | Opacity (0.0-1.0) |
|---------------|-------------------|
| 26            | 0.10              |
| 38            | 0.15              |
| 51            | 0.20              |
| 77            | 0.30              |
| 102           | 0.40              |
| 128           | 0.50              |
| 180           | 0.70              |

**Note:** IDE will show deprecation warning for `.withOpacity()` - this is safe to ignore. The deprecation is informational only; the API works correctly.

---

## 🚨 Important Rules

### DO ✅
- Always use design tokens (never hardcode values)
- Use Google Fonts for typography
- Apply proper spacing scale (xs to xxxl)
- Use semantic colors (success, warning, danger)
- Include shadows for depth
- Support both light and dark mode

### DON'T ❌
- Never hardcode colors like `Color(0xFF...)`
- Never use arbitrary spacing like `8.5` or `17.0`
- Never mix font families randomly
- Never skip shadows on elevated elements
- Never assume light mode only
- **Never use `.withValues(alpha:)` - use `.withOpacity()` instead** (see Flutter 3.38+ bug above)

---

## 📱 Responsive Considerations

**Screen Padding:**
```dart
// Standard screen padding
EdgeInsets.all(DesignSpacing.md) // 16px

// List items
EdgeInsets.symmetric(
  horizontal: DesignSpacing.md,
  vertical: DesignSpacing.sm,
)
```

**Border Radius:**
```dart
// Cards/Containers: 12-16px
BorderRadius.circular(12)
BorderRadius.circular(16)

// Buttons: 8-12px
BorderRadius.circular(8)
BorderRadius.circular(12)

// Icon backgrounds: 12-20px
BorderRadius.circular(16)
```

---

## 🎯 Quick Reference

**Most Common Combinations:**

```dart
// Standard card
Container(
  padding: EdgeInsets.all(DesignSpacing.md),
  decoration: BoxDecoration(
    color: DesignColors.dSurfaces,
    borderRadius: BorderRadius.circular(16),
    boxShadow: DesignShadows.md,
  ),
)

// Section header
Text(
  'SECTION',
  style: GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: DesignColors.highlightTeal,
  ),
)

// List item
ListTile(
  contentPadding: EdgeInsets.symmetric(
    horizontal: DesignSpacing.md,
    vertical: DesignSpacing.sm,
  ),
  title: Text(
    'Title',
    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
  ),
)
```

---

**End of Design System Documentation**