import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/authentication/widgets/auth_background.dart';
import 'package:pulse_chat/features/contacts/bloc/search_users_bloc.dart';
import 'package:pulse_chat/features/contacts/bloc/search_users_event.dart';
import 'package:pulse_chat/features/contacts/bloc/search_users_state.dart';
import 'package:pulse_chat/features/contacts/widgets/contact_user_tile.dart';
import 'package:pulse_chat/features/contacts/widgets/pulse_empty_state.dart';

/// Screen to search users at GET /api/v1/users/search
class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      context.read<SearchUsersBloc>().add(const SearchQueryChanged(''));
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) {
        context.read<SearchUsersBloc>().add(SearchQueryChanged(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          'Find people',
          style: AppTextStyles.w600.copyWith(fontSize: 18.sp, color: colors.textPrimary),
        ),
      ),
      body: AuthBackground(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
              child: _SearchField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onQueryChanged,
                onClear: () {
                  _controller.clear();
                  _onQueryChanged('');
                },
              ),
            ),
            Expanded(child: _buildBody(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppColors colors) {
    return BlocBuilder<SearchUsersBloc, SearchUsersState>(
      builder: (context, state) {
        if (state is SearchIdle) {
          return const Center(
            child: PulseEmptyState(
              icon: Icons.search_rounded,
              title: 'Search for people',
              message: 'Find friends by their name or username\nto start chatting on Pulse.',
            ),
          );
        }

        if (state is SearchLoading) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: 5,
            itemBuilder: (_, _) => const _SearchResultSkeleton(),
          );
        }

        if (state is SearchEmpty) {
          return const Center(
            child: PulseEmptyState(
              icon: Icons.person_search_rounded,
              title: 'No one found',
              message: 'Try a different name or check the\nusername spelling.',
            ),
          );
        }

        if (state is SearchFailure) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, color: colors.error, size: 48.sp),
                  SizedBox(height: 16.h),
                  Text(
                    state.error,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.w500.copyWith(fontSize: 14.sp, color: colors.textPrimary),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is SearchSuccess) {
          final results = state.results;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: ListView.builder(
              key: const ValueKey('results'),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: results.length,
              itemBuilder: (context, i) {
                final user = results[i];
                return ContactUserTile(
                  key: ValueKey(user.uid),
                  user: user,
                  onTap: () => context.push('/profile/${user.uid}'),
                  onSendRequest: () => context.read<SearchUsersBloc>().add(SendRequest(user)),
                  onCancelRequest: () => context.read<SearchUsersBloc>().add(CancelRequest(user)),
                  onMessage: () {
                    // Navigate to chat screen or show details in future releases
                  },
                  onUnblock: () => context.read<SearchUsersBloc>().add(UnblockUserInSearch(user)),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: AppTextStyles.w400.copyWith(fontSize: 14.5.sp, color: colors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          hintText: 'Search by name or @username',
          hintStyle: AppTextStyles.w400.copyWith(fontSize: 14.sp, color: colors.textTertiary),
          prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary, size: 22.sp),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.close_rounded, color: colors.textSecondary, size: 19.sp),
                onPressed: onClear,
              );
            },
          ),
          filled: true,
          fillColor: colors.background,
        ),
      ),
    );
  }
}

class _SearchResultSkeleton extends StatefulWidget {
  const _SearchResultSkeleton();

  @override
  State<_SearchResultSkeleton> createState() => _SearchResultSkeletonState();
}

class _SearchResultSkeletonState extends State<_SearchResultSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    unawaited(_controller.repeat(reverse: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.4 + (_controller.value * 0.3);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
              Opacity(
                opacity: opacity,
                child: Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(color: colors.border, shape: BoxShape.circle),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 130.w,
                        height: 14.h,
                        decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(4.r)),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 90.w,
                        height: 11.h,
                        decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(4.r)),
                      ),
                    ),
                  ],
                ),
              ),
              Opacity(
                opacity: opacity,
                child: Container(
                  width: 64.w,
                  height: 30.h,
                  decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(20.r)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
