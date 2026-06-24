import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/database/app_prefs.dart';
import 'package:pulse_chat/core/database/cubit/settings_cubit.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/authentication/bloc/auth_bloc.dart';
import 'package:pulse_chat/features/authentication/bloc/auth_event.dart';
import 'package:pulse_chat/features/home/widgets/theme_toggle_menu.dart';

class HomePopupMenu extends StatefulWidget {
  const HomePopupMenu({required this.colors});

  final AppColors colors;

  @override
  State<HomePopupMenu> createState() => HomePopupMenuState();
}

class HomePopupMenuState extends State<HomePopupMenu> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _closeMenu(rebuild: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        icon: Icon(Icons.more_vert_rounded, color: colors.textPrimary, size: 22.sp),
        onPressed: _toggleMenu,
        style: IconButton.styleFrom(
          minimumSize: Size(40.w, 40.w),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  void _toggleMenu() {
    if (_overlayEntry == null) {
      _openMenu();
    } else {
      _closeMenu();
    }
  }

  void _openMenu() {
    final authBloc = context.read<AuthBloc>();
    final settingsCubit = context.read<SettingsCubit>();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeMenu,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(-190.w, 42.h),
              child: BlocBuilder<SettingsCubit, AppPrefs>(
                bloc: settingsCubit,
                builder: (context, prefs) {
                  final colors = AppColors(context);
                  final isDark = prefs.themeMode == ThemeMode.dark || (prefs.themeMode == ThemeMode.system && colors.isDarkMode);
                  return Material(
                    color: colors.card,
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16.r),
                    clipBehavior: Clip.antiAlias,
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tightFor(width: 230.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PopupMenuAction(
                            colors: colors,
                            icon: Icons.group_add_outlined,
                            label: 'New Group',
                            onTap: _closeMenu,
                          ),
                          _PopupMenuAction(
                            colors: colors,
                            icon: Icons.broadcast_on_personal_outlined,
                            label: 'New Broadcast',
                            onTap: _closeMenu,
                          ),
                          _PopupMenuAction(
                            colors: colors,
                            icon: Icons.star_outline_rounded,
                            label: 'Starred Messages',
                            onTap: _closeMenu,
                          ),
                          ThemeToggleMenuRow(
                            colors: colors,
                            isDark: isDark,
                            onChanged: (value) async {
                              await settingsCubit.updateTheme(value ? ThemeMode.dark : ThemeMode.light);
                              _overlayEntry?.markNeedsBuild();
                            },
                          ),
                          _PopupMenuAction(
                            colors: colors,
                            icon: Icons.settings_outlined,
                            label: 'Settings',
                            onTap: _closeMenu,
                          ),
                          _PopupMenuAction(
                            colors: colors,
                            icon: Icons.logout,
                            label: 'Logout',
                            onTap: () {
                              _closeMenu();
                              authBloc.add(const SignOutRequested());
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _closeMenu({bool rebuild = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (rebuild && mounted) {
      setState(() {});
    }
  }
}

class _PopupMenuAction extends StatelessWidget {
  const _PopupMenuAction({
    required this.colors,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final AppColors colors;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 48.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: colors.textSecondary),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.w500.copyWith(
                    fontSize: 14.sp,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
