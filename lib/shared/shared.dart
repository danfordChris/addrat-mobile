// Buttons
export 'components/buttons/app_primary_button.dart';
export 'components/buttons/app_secondary_button.dart';
export 'components/buttons/app_text_button.dart';
export 'components/buttons/app_icon_button.dart';

// Inputs
export 'components/inputs/app_text_field.dart';
export 'components/inputs/app_phone_field.dart';
export 'components/inputs/app_otp_field.dart';
export 'components/inputs/app_dropdown_field.dart';
export 'components/inputs/app_searchable_dropdown.dart';

// Cards
export 'components/cards/app_card.dart';
export 'components/cards/info_tile.dart';
export 'components/cards/stat_card.dart';
export 'components/cards/loan_card.dart';

// Navigation
export 'components/navigation/app_bottom_nav.dart';
export 'components/navigation/app_back_button.dart';

// Feedback
export 'components/feedback/app_snackbar.dart';
export 'components/feedback/app_loading_overlay.dart';
export 'components/feedback/app_empty_state.dart';
export 'components/feedback/app_error_state.dart';

// Badges
export 'components/badges/status_badge.dart';
export 'components/badges/count_badge.dart';

// Sheets
export 'components/sheets/app_bottom_sheet.dart';
export 'components/sheets/confirmation_sheet.dart';

// Selection
export 'components/selection/language_card.dart';
export 'components/selection/segmented_control.dart';
export 'components/selection/radio_option_tile.dart';

// Misc
export 'components/misc/app_divider.dart';
export 'components/misc/app_avatar.dart';
export 'components/misc/step_progress_bar.dart';
export 'components/misc/scan_overlay.dart';
export 'components/misc/countdown_timer.dart';
export 'components/misc/legal_links_footer.dart';

// Legacy widgets (backwards compatibility for existing screens)
// StatusBadge hidden to avoid conflict — use the new StatusBadge from components/badges
export 'widgets/shared_widgets.dart' hide StatusBadge;
