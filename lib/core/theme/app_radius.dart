import 'package:flutter/material.dart';

abstract class AppRadius {
  // ==================== RADIUS TOKENS ====================
  // Tiered system: tighter on inner elements, softer on containers

  static const double xs = 4.0;      // Badges, chips, small pills
  static const double sm = 8.0;      // Inputs, buttons, badges (square)
  static const double md = 12.0;     // Cards, dialogs, bottom sheets
  static const double lg = 16.0;     // Hero containers, large cards, modals
  static const double xl = 24.0;     // Major sections, splash, hero
  static const double xxl = 32.0;    // Full-screen containers
  static const double pill = 9999.0; // Pills only (legacy, avoid)

  // BorderRadius getters
  static BorderRadius get rXs => BorderRadius.circular(xs);
  static BorderRadius get rSm => BorderRadius.circular(sm);
  static BorderRadius get rMd => BorderRadius.circular(md);
  static BorderRadius get rLg => BorderRadius.circular(lg);
  static BorderRadius get rXl => BorderRadius.circular(xl);
  static BorderRadius get rXxl => BorderRadius.circular(xxl);
  static BorderRadius get rPill => BorderRadius.circular(pill);

  // Composite radius for specific use cases
  static BorderRadius get card => BorderRadius.circular(lg);       // 16px - Cards
  static BorderRadius get input => BorderRadius.circular(sm);      // 8px - Inputs
  static BorderRadius get button => BorderRadius.circular(lg);     // 16px - Buttons
  static BorderRadius get badge => BorderRadius.circular(sm);      // 8px - Badges (square)
  static BorderRadius get modal => BorderRadius.vertical(top: Radius.circular(xl)); // 24px - Bottom sheets
  static BorderRadius get hero => BorderRadius.circular(xl);       // 24px - Hero sections
  static BorderRadius get avatar => BorderRadius.circular(9999);   // Circle - Avatars
  static BorderRadius get squircle => BorderRadius.circular(24);   // 24% of 100 - Squircle avatar
}