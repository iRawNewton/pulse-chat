import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/profile/profile_avatar.dart';
import 'package:pulse_chat/features/profile/profile_models.dart';
import 'package:pulse_chat/features/profile/profile_text_field.dart';

/// Edit-profile form. UI-only: [onSave] receives the fully-built
/// [ProfileUserEntity] so the integration layer can dispatch it to a
/// Bloc (e.g. context.read<ProfileBloc>().updateProfile(updated)).
///
/// Email is shown read-only here since changing it usually needs a
/// verification flow elsewhere — swap `readOnly: true` if that's not
/// the case for your backend.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    required this.user,
    required this.onSave,
    this.onChangePhoto,
    super.key,
  });

  final ProfileUserEntity user;
  final ValueChanged<ProfileUserEntity> onSave;

  /// Hook for an image-picker flow; left to the integration layer so this
  /// screen doesn't need to depend on image_picker directly.
  final VoidCallback? onChangePhoto;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _customUrlCtrl;
  String? _photoUrl;

  late final Map<SocialPlatform, TextEditingController> _socialCtrls;

  static const _socialMeta = <SocialPlatform, (IconData, String, String)>{
    SocialPlatform.facebook: (Icons.facebook_rounded, 'Facebook', 'facebook.com/username'),
    SocialPlatform.x: (Icons.close_rounded, 'X', 'x.com/username'),
    SocialPlatform.instagram: (Icons.camera_alt_rounded, 'Instagram', 'instagram.com/username'),
    SocialPlatform.snapchat: (Icons.camera_rounded, 'Snapchat', 'snapchat.com/add/username'),
    SocialPlatform.linkedin: (Icons.work_rounded, 'LinkedIn', 'linkedin.com/in/username'),
  };

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameCtrl = TextEditingController(text: u.name);
    _usernameCtrl = TextEditingController(text: u.username);
    _emailCtrl = TextEditingController(text: u.email);
    _mobileCtrl = TextEditingController(text: u.mobile ?? '');
    _bioCtrl = TextEditingController(text: u.bio ?? '');
    _customUrlCtrl = TextEditingController(text: u.customUrl ?? '');
    _photoUrl = u.photoUrl;

    _socialCtrls = {
      for (final platform in SocialPlatform.values) platform: TextEditingController(text: _urlFor(u, platform)),
    };
  }

  String _urlFor(ProfileUserEntity u, SocialPlatform platform) {
    for (final link in u.socialLinks) {
      if (link.platform == platform) return link.url;
    }
    return '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _bioCtrl.dispose();
    _customUrlCtrl.dispose();
    for (final c in _socialCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _showPhotoUrlDialog() async {
    final controller = TextEditingController(text: _photoUrl ?? '');
    final colors = AppColors(context);
    final newUrl = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'Edit Profile Photo URL',
          style: AppTextStyles.w600.copyWith(fontSize: 16.sp, color: colors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          style: AppTextStyles.w400.copyWith(fontSize: 14.sp, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter image URL (https://...)',
            hintStyle: AppTextStyles.w400.copyWith(fontSize: 14.sp, color: colors.textTertiary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.w500.copyWith(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('Save', style: AppTextStyles.w600.copyWith(color: colors.primary)),
          ),
        ],
      ),
    );

    if (newUrl != null) {
      setState(() {
        _photoUrl = newUrl.isEmpty ? null : newUrl;
      });
    }
  }

  void _handleSave() {
    final updatedLinks = <SocialLink>[
      for (final entry in _socialCtrls.entries)
        if (entry.value.text.trim().isNotEmpty) SocialLink(platform: entry.key, url: entry.value.text.trim()),
    ];

    final updated = widget.user.copyWith(
      name: _nameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      photoUrl: _photoUrl,
      mobile: _mobileCtrl.text.trim().isEmpty ? null : _mobileCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      socialLinks: updatedLinks,
      customUrl: _customUrlCtrl.text.trim().isEmpty ? null : _customUrlCtrl.text.trim(),
    );

    widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, size: 22.sp, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.w600.copyWith(fontSize: 17.sp, color: colors.textPrimary),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: TextButton(
              onPressed: _handleSave,
              style: TextButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              ),
              child: Text(
                'Save',
                style: AppTextStyles.w600.copyWith(fontSize: 14.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  ProfileAvatar(
                    name: widget.user.name,
                    initials: widget.user.initials,
                    photoUrl: _photoUrl,
                    size: 100,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showPhotoUrlDialog,
                      child: Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.background, width: 2.5.w),
                        ),
                        child: Icon(Icons.camera_alt_rounded, size: 15.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            ProfileTextField(label: 'Name', controller: _nameCtrl, icon: Icons.badge_outlined, hint: 'Your full name'),
            SizedBox(height: 18.h),
            ProfileTextField(
              label: 'Username',
              controller: _usernameCtrl,
              icon: Icons.alternate_email_rounded,
              hint: 'username',
            ),
            SizedBox(height: 18.h),
            ProfileTextField(
              label: 'Email',
              controller: _emailCtrl,
              icon: Icons.email_outlined,
              readOnly: true,
              enabled: false,
            ),
            SizedBox(height: 18.h),
            ProfileTextField(
              label: 'Mobile',
              controller: _mobileCtrl,
              icon: Icons.phone_outlined,
              hint: '+91 00000 00000',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 18.h),
            ProfileTextField(
              label: 'Bio',
              controller: _bioCtrl,
              hint: 'Tell people a little about yourself',
              maxLines: 4,
              maxLength: 160,
            ),
            SizedBox(height: 30.h),
            _SectionLabel('SOCIAL LINKS', colors),
            SizedBox(height: 14.h),
            for (final platform in SocialPlatform.values) ...[
              ProfileTextField(
                label: _socialMeta[platform]!.$2,
                controller: _socialCtrls[platform]!,
                icon: _socialMeta[platform]!.$1,
                hint: _socialMeta[platform]!.$3,
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 16.h),
            ],
            _SectionLabel('CUSTOM LINK', colors),
            SizedBox(height: 6.h),
            Text(
              'Add one more link — your portfolio, blog, anything.',
              style: AppTextStyles.w400.copyWith(fontSize: 12.5.sp, color: colors.textTertiary),
            ),
            SizedBox(height: 14.h),
            ProfileTextField(
              label: 'Website',
              controller: _customUrlCtrl,
              icon: Icons.link_rounded,
              hint: 'https://yourwebsite.com',
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.colors);
  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.w700.copyWith(fontSize: 12.sp, color: colors.textSecondary, letterSpacing: 0.6),
    );
  }
}
