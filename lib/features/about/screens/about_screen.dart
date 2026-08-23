import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/widgets/app_logo_widget.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static const String discordUrl = AppConstants.discordInviteUrl;
  static const String githubUrl = AppConstants.githubRepoUrl;
  static const String websiteUrl = AppConstants.websiteUrl;
  static const String buyMeACoffeeUrl = AppConstants.buyMeACoffeeUrl;
  static const String githubSponsorsUrl = AppConstants.githubSponsorsUrl;
  static const String privacyDocUrl = AppConstants.privacyPolicyDocUrl;

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    bool launched = false;
    try {
      launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank',
      );
    } catch (_) {
      launched = false;
    }

    if (!launched) {
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.copy_rounded, color: AppColors.primaryCyan, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Link copied to clipboard: $url',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _shareApp(BuildContext context, WidgetRef ref) {
    final shareMsg = ref.tr('about_share_message');
    Clipboard.setData(ClipboardData(text: shareMsg));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(ref.tr('about_share_copied'))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(effectiveThemeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Header Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.tr('about_title'),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ref.tr('about_subtitle'),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppLogoWidget(
                      size: 34,
                      gamingTheme: theme,
                      showGlow: true,
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. HERO IDENTITY CARD
                  _buildHeroCard(context, ref, theme),
                  const SizedBox(height: 20),

                  // 2. MISSION & HADITH CARD
                  _buildMissionCard(context, ref, theme),
                  const SizedBox(height: 20),

                  // 3. COMMUNITY & SOCIALS
                  _buildSectionHeader(ref.tr('about_community_title'), Icons.people_alt_rounded, theme.primaryAccent),
                  const SizedBox(height: 10),
                  _buildCommunitySection(context, ref, theme),
                  const SizedBox(height: 20),

                  // 4. SUPPORT & SADAQAH JARIYAH (DONATE)
                  _buildSectionHeader(ref.tr('about_support_title'), Icons.volunteer_activism_rounded, const Color(0xFFF59E0B)),
                  const SizedBox(height: 10),
                  _buildSupportCard(context, ref, theme),
                  const SizedBox(height: 20),

                  // 5. PRIVACY & SECURITY
                  _buildSectionHeader(ref.tr('about_privacy_title'), Icons.security_rounded, const Color(0xFF10B981)),
                  const SizedBox(height: 10),
                  _buildPrivacyCard(context, ref, theme),
                  const SizedBox(height: 20),

                  // 6. METHODOLOGY & ASTRONOMY
                  _buildSectionHeader(ref.tr('about_methodology_title'), Icons.auto_awesome_rounded, AppColors.primaryCyan),
                  const SizedBox(height: 10),
                  _buildMethodologyCard(context, ref, theme),
                  const SizedBox(height: 20),

                  // 7. FEEDBACK & SUGGESTIONS
                  _buildSectionHeader(ref.tr('about_feedback_title'), Icons.chat_bubble_outline_rounded, theme.primaryAccent),
                  const SizedBox(height: 10),
                  _buildFeedbackSection(context, ref, theme),
                  const SizedBox(height: 24),

                  // 8. FOOTER CREDITS & VERSION
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '${AppConstants.appName} • ${ref.trFormat('about_version_label', {'version': AppConstants.version, 'build': 'Build 2026.1'})}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Open Source under MIT License • Made with ❤️ for the Ummah',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, WidgetRef ref, AppGamingTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primaryAccent.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryAccent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AppLogoWidget(
                size: 56,
                gamingTheme: theme,
                showGlow: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppConstants.tagline,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryAccent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.primaryAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'v${AppConstants.version} • Ready & Stable',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, WidgetRef ref, AppGamingTheme theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.surfaceHighlight.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.primaryAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.stars_rounded, size: 16, color: theme.primaryAccent),
              ),
              const SizedBox(width: 8),
              Text(
                ref.tr('about_mission_title'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ref.tr('about_mission_desc'),
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.surfaceHighlight.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: theme.primaryAccent,
                  width: 3.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.tr('about_hadith_quote'),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ref.tr('about_hadith_ref'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitySection(BuildContext context, WidgetRef ref, AppGamingTheme theme) {
    return Column(
      children: [
        // Discord Card
        _buildActionTile(
          icon: Icons.discord,
          iconColor: const Color(0xFF5865F2),
          iconBg: const Color(0xFF5865F2).withValues(alpha: 0.15),
          title: ref.tr('about_discord_title'),
          subtitle: ref.tr('about_discord_sub'),
          theme: theme,
          trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF5865F2)),
          onTap: () => _launchUrl(context, discordUrl),
        ),
        const SizedBox(height: 8),

        // GitHub Card
        _buildActionTile(
          icon: Icons.code_rounded,
          iconColor: !theme.isLight ? Colors.white : Colors.black87,
          iconBg: theme.surfaceHighlight.withValues(alpha: 0.6),
          title: ref.tr('about_github_title'),
          subtitle: ref.tr('about_github_sub'),
          theme: theme,
          trailing: Icon(Icons.star_rounded, size: 18, color: Colors.amber.shade600),
          onTap: () => _launchUrl(context, githubUrl),
        ),
        const SizedBox(height: 8),

        // Website Card
        _buildActionTile(
          icon: Icons.language_rounded,
          iconColor: AppColors.primaryCyan,
          iconBg: AppColors.primaryCyan.withValues(alpha: 0.15),
          title: ref.tr('about_website_title'),
          subtitle: ref.tr('about_website_sub'),
          theme: theme,
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryCyan),
          onTap: () => _launchUrl(context, websiteUrl),
        ),
        const SizedBox(height: 8),

        // Share App Card
        _buildActionTile(
          icon: Icons.share_rounded,
          iconColor: theme.primaryAccent,
          iconBg: theme.primaryAccent.withValues(alpha: 0.15),
          title: ref.tr('about_share_title'),
          subtitle: ref.tr('about_share_sub'),
          theme: theme,
          trailing: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textMuted),
          onTap: () => _shareApp(context, ref),
        ),
      ],
    );
  }

  Widget _buildSupportCard(BuildContext context, WidgetRef ref, AppGamingTheme theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('about_support_desc'),
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(context, buyMeACoffeeUrl),
                  icon: const Icon(Icons.coffee_rounded, size: 16, color: Colors.black87),
                  label: Text(
                    ref.tr('about_donate_coffee'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFDD00),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchUrl(context, githubSponsorsUrl),
                  icon: const Icon(Icons.favorite_rounded, size: 15, color: Color(0xFFEA4AAA)),
                  label: Text(
                    ref.tr('about_donate_sponsors'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: const Color(0xFFEA4AAA).withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard(BuildContext context, WidgetRef ref, AppGamingTheme theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('about_privacy_desc'),
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),

          _buildPrivacyPillar(
            icon: Icons.offline_bolt_rounded,
            title: ref.tr('about_privacy_local'),
            subtitle: ref.tr('about_privacy_local_sub'),
            theme: theme,
          ),
          const SizedBox(height: 10),

          _buildPrivacyPillar(
            icon: Icons.location_off_rounded,
            title: ref.tr('about_privacy_location'),
            subtitle: ref.tr('about_privacy_location_sub'),
            theme: theme,
          ),
          const SizedBox(height: 10),

          _buildPrivacyPillar(
            icon: Icons.shield_rounded,
            title: ref.tr('about_privacy_no_ads'),
            subtitle: ref.tr('about_privacy_no_ads_sub'),
            theme: theme,
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showPrivacyPolicyModal(context, ref, theme),
              icon: const Icon(Icons.policy_rounded, size: 16),
              label: Text(
                ref.tr('about_view_full_policy'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPillar({
    required IconData icon,
    required String title,
    required String subtitle,
    required AppGamingTheme theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: const Color(0xFF10B981)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodologyCard(BuildContext context, WidgetRef ref, AppGamingTheme theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.surfaceHighlight.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('about_methodology_desc'),
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context, WidgetRef ref, AppGamingTheme theme) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            icon: Icons.lightbulb_outline_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            title: ref.tr('about_suggest_game'),
            subtitle: 'Discord #suggestions',
            theme: theme,
            onTap: () => _launchUrl(context, discordUrl),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            icon: Icons.bug_report_outlined,
            iconColor: const Color(0xFFEF4444),
            iconBg: const Color(0xFFEF4444).withValues(alpha: 0.12),
            title: ref.tr('about_report_issue'),
            subtitle: 'Discord #support',
            theme: theme,
            onTap: () => _launchUrl(context, discordUrl),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required AppGamingTheme theme,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.surfaceHighlight.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyModal(BuildContext context, WidgetRef ref, AppGamingTheme theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: theme.surfaceHighlight.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Sheet Grabber
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.policy_rounded, size: 20, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Pray Then Play - Privacy Policy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    const Text(
                      'Last Updated: August 2026',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Introduction\n'
                      'Pray Then Play ("we," "our," or "app") is an Islamic prayer companion and gaming session helper designed to assist Muslim gamers with accurate prayer times, smart break reminders, and healthy balance between worship and gaming.\n\n'
                      '2. Information We Handle\n'
                      '• Location Information: Pray Then Play uses your device location (coordinates or chosen city) solely to calculate astronomical prayer times accurately on your device. Your location coordinates are processed locally on-device and are NEVER uploaded, transmitted, or sold to any remote server.\n'
                      '• Game Profiles & Activity Settings: Customized game names, modes, round durations, and buffer preferences are stored strictly in local device storage (SharedPreferences / Hive).\n'
                      '• Prayer Tracking History: Your daily prayer logs, streaks, and heatmap data are stored exclusively on your local hardware.\n\n'
                      '3. Third-Party Analytics & Advertisements\n'
                      'Pray Then Play is 100% free of third-party advertisements, behavioral trackers, and telemetry SDKs. We do not integrate data broker trackers or analytics services.\n\n'
                      '4. Device Permissions\n'
                      '• Location Permission: Used exclusively when requested by the user to automatically detect coordinates for prayer times calculation.\n'
                      '• Notification Permission: Used strictly to trigger on-device adhan and match wrap-up alerts.\n\n'
                      '5. Data Retention & User Control\n'
                      'You retain 100% ownership and control over your data. You may reset or wipe all saved records at any time directly in Settings -> Clear History.\n\n'
                      '6. Contact & Open Source Inquiries\n'
                      'For questions regarding privacy or source audits, please visit our GitHub repository or reach out via our official Discord community.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _launchUrl(context, privacyDocUrl),
                      icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                      label: const Text('Open Official Google Doc Policy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryAccent,
                        foregroundColor: theme.buttonTextColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
