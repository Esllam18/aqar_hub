import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/enums/app_role.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/profile_view/profile_role_badge.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/profile_model.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
    required this.profile,
    required this.role, // ✅ was bool isOwner
  });

  final AppRole role;
  final ProfileModel profile;

  String? _resolveAvatarUrl() {
    if (profile.profileImageUrl != null &&
        profile.profileImageUrl!.isNotEmpty) {
      return profile.profileImageUrl;
    }
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    return meta?['avatar_url'] as String? ?? meta?['picture'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _resolveAvatarUrl();

    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B4B8C), Color(0xFF1E88E5), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(height: context.r(20)),
              Padding(
                padding: context.rOnly(left: 20, right: 20, bottom: 52),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppAnimations.fade(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 100),
                            child: Text(
                              profile.fullName.isNotEmpty
                                  ? profile.fullName
                                  : 'profile_unknown_name'.tr(context),
                              style: GoogleFonts.cairo(
                                fontSize: context.sp(22),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: context.r(6)),
                          if (profile.email != null)
                            _InfoRow(
                              icon: Icons.email_outlined,
                              text: profile.email!,
                            ),
                          if (profile.phoneNumber != null)
                            _InfoRow(
                              icon: Icons.phone_outlined,
                              text: profile.phoneNumber!,
                              delay: 50,
                            ),
                          SizedBox(height: context.r(10)),
                          AppAnimations.combined(
                            type: CombineType.fadeScale,
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 250),
                            child: ProfileRoleBadge(role: role),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.r(16)),
                    AppAnimations.scale(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: context.r(90),
                            height: context.r(90),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.3),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 2.5,
                              ),
                            ),
                          ),
                          ClipOval(
                            child: Container(
                              width: context.r(90),
                              height: context.r(90),
                              color: Colors.white.withValues(alpha: 0.2),
                              child: avatarUrl != null
                                  ? _BustingNetworkImage(
                                      url: avatarUrl,
                                      size: context.r(90),
                                    )
                                  : _DefaultAvatar(size: context.r(90)),
                            ),
                          ),
                        ],
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

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 32);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 16,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 32,
      size.width,
      size.height - 12,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.delay = 0});

  final int delay;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.rOnly(bottom: 4),
      child: AppAnimations.fade(
        duration: const Duration(milliseconds: 400),
        delay: Duration(milliseconds: 150 + delay),
        child: Row(
          children: [
            Icon(
              icon,
              size: context.r(13),
              color: Colors.white.withValues(alpha: 0.7),
            ),
            SizedBox(width: context.r(5)),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(12),
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.white.withValues(alpha: 0.2),
      child: Icon(Icons.person_rounded, size: size * 0.5, color: Colors.white),
    );
  }
}

class _BustingNetworkImage extends StatefulWidget {
  const _BustingNetworkImage({required this.url, required this.size});
  final double size;
  final String url;

  @override
  State<_BustingNetworkImage> createState() => _BustingNetworkImageState();
}

class _BustingNetworkImageState extends State<_BustingNetworkImage> {
  late String _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolvedUrl = _bust(widget.url);
  }

  @override
  void didUpdateWidget(_BustingNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      imageCache.evict(NetworkImage(oldWidget.url));
      imageCache.evict(NetworkImage(oldWidget.url.split('?').first));
      setState(() => _resolvedUrl = _bust(widget.url));
    }
  }

  String _bust(String url) {
    final base = url.split('?').first;
    imageCache.evict(NetworkImage(url));
    imageCache.evict(NetworkImage(base));
    return '$base?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _resolvedUrl,
      fit: BoxFit.cover,
      width: widget.size,
      height: widget.size,
      errorBuilder: (_, __, ___) => _DefaultAvatar(size: widget.size),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
            color: Colors.white,
            strokeWidth: 2,
          ),
        );
      },
    );
  }
}
