import 'package:flutter/material.dart';
import 'help_topic_model.dart';

// ── All app guides ────────────────────────────────────────────────────────────

abstract final class HelpContent {
  // ── Getting Started guides ─────────────────────────────────────────────────

  static const HelpGuide gettingStarted = HelpGuide(
    icon: Icons.rocket_launch_rounded,
    gradient: [Color(0xFF1B4B8C), Color(0xFF42A5F5)],
    titleKey: 'help_guide_start_title',
    subtitleKey: 'help_guide_start_subtitle',
    audience: HelpAudience.all,
    steps: [
      HelpStep(
        icon: Icons.person_add_alt_1_rounded,
        titleKey: 'help_step_start_1_title',
        bodyKey: 'help_step_start_1_body',
      ),
      HelpStep(
        icon: Icons.how_to_reg_rounded,
        titleKey: 'help_step_start_2_title',
        bodyKey: 'help_step_start_2_body',
      ),
      HelpStep(
        icon: Icons.language_rounded,
        titleKey: 'help_step_start_3_title',
        bodyKey: 'help_step_start_3_body',
      ),
      HelpStep(
        icon: Icons.explore_rounded,
        titleKey: 'help_step_start_4_title',
        bodyKey: 'help_step_start_4_body',
      ),
    ],
  );

  // ── Seeker: Search & Browse ────────────────────────────────────────────────

  static const HelpGuide searchProperties = HelpGuide(
    icon: Icons.search_rounded,
    gradient: [Color(0xFF0277BD), Color(0xFF29B6F6)],
    titleKey: 'help_guide_search_title',
    subtitleKey: 'help_guide_search_subtitle',
    audience: HelpAudience.seeker,
    steps: [
      HelpStep(
        icon: Icons.home_rounded,
        titleKey: 'help_step_search_1_title',
        bodyKey: 'help_step_search_1_body',
      ),
      HelpStep(
        icon: Icons.tune_rounded,
        titleKey: 'help_step_search_2_title',
        bodyKey: 'help_step_search_2_body',
      ),
      HelpStep(
        icon: Icons.smart_toy_rounded,
        titleKey: 'help_step_search_3_title',
        bodyKey: 'help_step_search_3_body',
      ),
      HelpStep(
        icon: Icons.touch_app_rounded,
        titleKey: 'help_step_search_4_title',
        bodyKey: 'help_step_search_4_body',
      ),
    ],
  );

  // ── Seeker: Booking ────────────────────────────────────────────────────────

  static const HelpGuide bookingGuide = HelpGuide(
    icon: Icons.calendar_today_rounded,
    gradient: [Color(0xFF1B5E20), Color(0xFF43A047)],
    titleKey: 'help_guide_booking_title',
    subtitleKey: 'help_guide_booking_subtitle',
    audience: HelpAudience.seeker,
    steps: [
      HelpStep(
        icon: Icons.bed_rounded,
        titleKey: 'help_step_booking_1_title',
        bodyKey: 'help_step_booking_1_body',
      ),
      HelpStep(
        icon: Icons.meeting_room_rounded,
        titleKey: 'help_step_booking_2_title',
        bodyKey: 'help_step_booking_2_body',
      ),
      HelpStep(
        icon: Icons.apartment_rounded,
        titleKey: 'help_step_booking_3_title',
        bodyKey: 'help_step_booking_3_body',
      ),
      HelpStep(
        icon: Icons.chat_rounded,
        titleKey: 'help_step_booking_4_title',
        bodyKey: 'help_step_booking_4_body',
      ),
    ],
  );

  // ── Owner: Add Property ────────────────────────────────────────────────────

  static const HelpGuide addPropertyGuide = HelpGuide(
    icon: Icons.add_home_work_rounded,
    gradient: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
    titleKey: 'help_guide_addprop_title',
    subtitleKey: 'help_guide_addprop_subtitle',
    audience: HelpAudience.owner,
    steps: [
      HelpStep(
        icon: Icons.add_circle_outline_rounded,
        titleKey: 'help_step_addprop_1_title',
        bodyKey: 'help_step_addprop_1_body',
      ),
      HelpStep(
        icon: Icons.photo_library_rounded,
        titleKey: 'help_step_addprop_2_title',
        bodyKey: 'help_step_addprop_2_body',
      ),
      HelpStep(
        icon: Icons.attach_money_rounded,
        titleKey: 'help_step_addprop_3_title',
        bodyKey: 'help_step_addprop_3_body',
      ),
      HelpStep(
        icon: Icons.smart_toy_rounded,
        titleKey: 'help_step_addprop_4_title',
        bodyKey: 'help_step_addprop_4_body',
      ),
      HelpStep(
        icon: Icons.publish_rounded,
        titleKey: 'help_step_addprop_5_title',
        bodyKey: 'help_step_addprop_5_body',
      ),
    ],
  );

  // ── Owner: Manage Listings ─────────────────────────────────────────────────

  static const HelpGuide manageListings = HelpGuide(
    icon: Icons.dashboard_rounded,
    gradient: [Color(0xFFE65100), Color(0xFFFF8F00)],
    titleKey: 'help_guide_manage_title',
    subtitleKey: 'help_guide_manage_subtitle',
    audience: HelpAudience.owner,
    steps: [
      HelpStep(
        icon: Icons.edit_rounded,
        titleKey: 'help_step_manage_1_title',
        bodyKey: 'help_step_manage_1_body',
      ),
      HelpStep(
        icon: Icons.toggle_on_rounded,
        titleKey: 'help_step_manage_2_title',
        bodyKey: 'help_step_manage_2_body',
      ),
      HelpStep(
        icon: Icons.bar_chart_rounded,
        titleKey: 'help_step_manage_3_title',
        bodyKey: 'help_step_manage_3_body',
      ),
      HelpStep(
        icon: Icons.notifications_active_rounded,
        titleKey: 'help_step_manage_4_title',
        bodyKey: 'help_step_manage_4_body',
      ),
    ],
  );

  // ── Shared: Chat & Community ───────────────────────────────────────────────

  static const HelpGuide chatGuide = HelpGuide(
    icon: Icons.forum_rounded,
    gradient: [Color(0xFF006064), Color(0xFF00BCD4)],
    titleKey: 'help_guide_chat_title',
    subtitleKey: 'help_guide_chat_subtitle',
    audience: HelpAudience.all,
    steps: [
      HelpStep(
        icon: Icons.chat_bubble_outline_rounded,
        titleKey: 'help_step_chat_1_title',
        bodyKey: 'help_step_chat_1_body',
      ),
      HelpStep(
        icon: Icons.mic_rounded,
        titleKey: 'help_step_chat_2_title',
        bodyKey: 'help_step_chat_2_body',
      ),
      HelpStep(
        icon: Icons.image_rounded,
        titleKey: 'help_step_chat_3_title',
        bodyKey: 'help_step_chat_3_body',
      ),
      HelpStep(
        icon: Icons.comment_rounded,
        titleKey: 'help_step_chat_4_title',
        bodyKey: 'help_step_chat_4_body',
      ),
    ],
  );

  // ── AI Broker guide ───────────────────────────────────────────────────────

  static const HelpGuide aiGuide = HelpGuide(
    icon: Icons.smart_toy_rounded,
    gradient: [Color(0xFF0D47A1), Color(0xFF1976D2)],
    titleKey: 'help_guide_ai_title',
    subtitleKey: 'help_guide_ai_subtitle',
    audience: HelpAudience.all,
    steps: [
      HelpStep(
        icon: Icons.search_rounded,
        titleKey: 'help_step_ai_1_title',
        bodyKey: 'help_step_ai_1_body',
      ),
      HelpStep(
        icon: Icons.filter_alt_rounded,
        titleKey: 'help_step_ai_2_title',
        bodyKey: 'help_step_ai_2_body',
      ),
      HelpStep(
        icon: Icons.price_check_rounded,
        titleKey: 'help_step_ai_3_title',
        bodyKey: 'help_step_ai_3_body',
      ),
    ],
  );

  // ── Account & Profile guide ────────────────────────────────────────────────

  static const HelpGuide accountGuide = HelpGuide(
    icon: Icons.manage_accounts_rounded,
    gradient: [Color(0xFF37474F), Color(0xFF78909C)],
    titleKey: 'help_guide_account_title',
    subtitleKey: 'help_guide_account_subtitle',
    audience: HelpAudience.all,
    steps: [
      HelpStep(
        icon: Icons.edit_rounded,
        titleKey: 'help_step_account_1_title',
        bodyKey: 'help_step_account_1_body',
      ),
      HelpStep(
        icon: Icons.lock_outline_rounded,
        titleKey: 'help_step_account_2_title',
        bodyKey: 'help_step_account_2_body',
      ),
      HelpStep(
        icon: Icons.notifications_rounded,
        titleKey: 'help_step_account_3_title',
        bodyKey: 'help_step_account_3_body',
      ),
      HelpStep(
        icon: Icons.language_rounded,
        titleKey: 'help_step_account_4_title',
        bodyKey: 'help_step_account_4_body',
      ),
    ],
  );

  // ── Home screen categories ─────────────────────────────────────────────────

  static const List<HelpCategory> seekerCategories = [
    HelpCategory(
      icon: Icons.rocket_launch_rounded,
      gradient: [Color(0xFF1B4B8C), Color(0xFF42A5F5)],
      titleKey: 'help_cat_start',
      subtitleKey: 'help_cat_start_sub',
      audience: HelpAudience.seeker,
    ),
    HelpCategory(
      icon: Icons.search_rounded,
      gradient: [Color(0xFF0277BD), Color(0xFF29B6F6)],
      titleKey: 'help_cat_search',
      subtitleKey: 'help_cat_search_sub',
      audience: HelpAudience.seeker,
    ),
    HelpCategory(
      icon: Icons.calendar_today_rounded,
      gradient: [Color(0xFF1B5E20), Color(0xFF43A047)],
      titleKey: 'help_cat_booking',
      subtitleKey: 'help_cat_booking_sub',
      audience: HelpAudience.seeker,
    ),
    HelpCategory(
      icon: Icons.smart_toy_rounded,
      gradient: [Color(0xFF0D47A1), Color(0xFF1976D2)],
      titleKey: 'help_cat_ai',
      subtitleKey: 'help_cat_ai_sub',
      audience: HelpAudience.seeker,
    ),
    HelpCategory(
      icon: Icons.forum_rounded,
      gradient: [Color(0xFF006064), Color(0xFF00BCD4)],
      titleKey: 'help_cat_chat',
      subtitleKey: 'help_cat_chat_sub',
    ),
    HelpCategory(
      icon: Icons.manage_accounts_rounded,
      gradient: [Color(0xFF37474F), Color(0xFF78909C)],
      titleKey: 'help_cat_account',
      subtitleKey: 'help_cat_account_sub',
    ),
  ];

  static const List<HelpCategory> ownerCategories = [
    HelpCategory(
      icon: Icons.rocket_launch_rounded,
      gradient: [Color(0xFF1B4B8C), Color(0xFF42A5F5)],
      titleKey: 'help_cat_start',
      subtitleKey: 'help_cat_start_sub',
      audience: HelpAudience.owner,
    ),
    HelpCategory(
      icon: Icons.add_home_work_rounded,
      gradient: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
      titleKey: 'help_cat_addprop',
      subtitleKey: 'help_cat_addprop_sub',
      audience: HelpAudience.owner,
    ),
    HelpCategory(
      icon: Icons.dashboard_rounded,
      gradient: [Color(0xFFE65100), Color(0xFFFF8F00)],
      titleKey: 'help_cat_manage',
      subtitleKey: 'help_cat_manage_sub',
      audience: HelpAudience.owner,
    ),
    HelpCategory(
      icon: Icons.smart_toy_rounded,
      gradient: [Color(0xFF0D47A1), Color(0xFF1976D2)],
      titleKey: 'help_cat_ai',
      subtitleKey: 'help_cat_ai_sub',
      audience: HelpAudience.owner,
    ),
    HelpCategory(
      icon: Icons.forum_rounded,
      gradient: [Color(0xFF006064), Color(0xFF00BCD4)],
      titleKey: 'help_cat_chat',
      subtitleKey: 'help_cat_chat_sub',
    ),
    HelpCategory(
      icon: Icons.manage_accounts_rounded,
      gradient: [Color(0xFF37474F), Color(0xFF78909C)],
      titleKey: 'help_cat_account',
      subtitleKey: 'help_cat_account_sub',
    ),
  ];

  // ── FAQ items ──────────────────────────────────────────────────────────────

  static const List<FaqItem> allFaqs = [
    // Getting started
    FaqItem(
      questionKey: 'faq_q_create_account',
      answerKey: 'faq_a_create_account',
      audience: HelpAudience.all,
      categoryKey: 'faq_cat_start',
    ),
    FaqItem(
      questionKey: 'faq_q_change_role',
      answerKey: 'faq_a_change_role',
      audience: HelpAudience.all,
      categoryKey: 'faq_cat_start',
    ),
    // Seeker
    FaqItem(
      questionKey: 'faq_q_how_book',
      answerKey: 'faq_a_how_book',
      audience: HelpAudience.seeker,
      categoryKey: 'faq_cat_booking',
    ),
    FaqItem(
      questionKey: 'faq_q_book_types',
      answerKey: 'faq_a_book_types',
      audience: HelpAudience.seeker,
      categoryKey: 'faq_cat_booking',
    ),
    FaqItem(
      questionKey: 'faq_q_ai_search',
      answerKey: 'faq_a_ai_search',
      audience: HelpAudience.seeker,
      categoryKey: 'faq_cat_ai',
    ),
    FaqItem(
      questionKey: 'faq_q_favorites',
      answerKey: 'faq_a_favorites',
      audience: HelpAudience.seeker,
      categoryKey: 'faq_cat_start',
    ),
    // Owner
    FaqItem(
      questionKey: 'faq_q_add_property',
      answerKey: 'faq_a_add_property',
      audience: HelpAudience.owner,
      categoryKey: 'faq_cat_addprop',
    ),
    FaqItem(
      questionKey: 'faq_q_rental_options',
      answerKey: 'faq_a_rental_options',
      audience: HelpAudience.owner,
      categoryKey: 'faq_cat_addprop',
    ),
    FaqItem(
      questionKey: 'faq_q_ai_price',
      answerKey: 'faq_a_ai_price',
      audience: HelpAudience.owner,
      categoryKey: 'faq_cat_ai',
    ),
    FaqItem(
      questionKey: 'faq_q_mark_rented',
      answerKey: 'faq_a_mark_rented',
      audience: HelpAudience.owner,
      categoryKey: 'faq_cat_manage',
    ),
    // Shared
    FaqItem(
      questionKey: 'faq_q_chat',
      answerKey: 'faq_a_chat',
      audience: HelpAudience.all,
      categoryKey: 'faq_cat_chat',
    ),
    FaqItem(
      questionKey: 'faq_q_notifications',
      answerKey: 'faq_a_notifications',
      audience: HelpAudience.all,
      categoryKey: 'faq_cat_start',
    ),
    FaqItem(
      questionKey: 'faq_q_change_language',
      answerKey: 'faq_a_change_language',
      audience: HelpAudience.all,
      categoryKey: 'faq_cat_start',
    ),
    FaqItem(
      questionKey: 'faq_q_change_password',
      answerKey: 'faq_a_change_password',
      audience: HelpAudience.all,
      categoryKey: 'faq_cat_start',
    ),
  ];

  // ── Map category key → guide ───────────────────────────────────────────────

  static HelpGuide? guideForCategory(String catKey) {
    return switch (catKey) {
      'help_cat_start' => gettingStarted,
      'help_cat_search' => searchProperties,
      'help_cat_booking' => bookingGuide,
      'help_cat_addprop' => addPropertyGuide,
      'help_cat_manage' => manageListings,
      'help_cat_chat' => chatGuide,
      'help_cat_ai' => aiGuide,
      'help_cat_account' => accountGuide,
      _ => null,
    };
  }
}
