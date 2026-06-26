import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_chat/config/routes/app_routes.dart';
import 'package:pulse_chat/core/di/injection.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/chats/data/chat_realtime_service.dart';
import 'package:pulse_chat/features/authentication/widgets/auth_background.dart';
import 'package:pulse_chat/features/contacts/bloc/contacts_bloc.dart';
import 'package:pulse_chat/features/contacts/bloc/contacts_event.dart';
import 'package:pulse_chat/features/contacts/bloc/contacts_state.dart';
import 'package:pulse_chat/features/contacts/data/contact_list_type.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';
import 'package:pulse_chat/features/contacts/widgets/contact_user_tile.dart';
import 'package:pulse_chat/features/contacts/widgets/pulse_empty_state.dart';

/// Hub screen combining:
/// - GET /users/contacts?status=accepted -> "Contacts" tab
/// - GET /users/contacts?status=pending  -> "Requests" tab
/// - GET /users/contacts?status=sent     -> "Sent" tab
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ChatRealtimeService _realtimeService;
  StreamSubscription<RealtimeEvent>? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _realtimeService = getIt<ChatRealtimeService>();
    unawaited(_realtimeService.connect());
    _realtimeSubscription = _realtimeService.events.listen((event) {
      if (!mounted) return;
      if (event.name == 'contact_request' || event.name == 'contact_accept' || event.name == 'contact_reject') {
        context.read<ContactsBloc>().add(const FetchContactsEvent(forceRefresh: true));
      }
    });
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshContacts() async {
    final bloc = context.read<ContactsBloc>()..add(const FetchContactsEvent(forceRefresh: true));
    try {
      await bloc.stream
          .firstWhere((state) => state is! ContactsLoaded || !state.isRefreshing)
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      // Keep the refresh gesture from hanging if the request never completes.
    }
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
          'Contacts',
          style: AppTextStyles.w600.copyWith(fontSize: 18.sp, color: colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1_rounded, color: colors.primary, size: 22.sp),
            onPressed: () async {
              // Push search and wait; when we return, keep any loaded contacts visible.
              await context.push(AppRoutes.searchUsers);
              if (context.mounted) {
                context.read<ContactsBloc>().add(const FetchContactsEvent());
              }
            },
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: AuthBackground(
        child: BlocBuilder<ContactsBloc, ContactsState>(
          builder: (context, state) {
            if (state is ContactsLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              );
            }

            if (state is ContactsFailure) {
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
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () => context.read<ContactsBloc>().add(const FetchContactsEvent()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        ),
                        child: Text(
                          'Retry',
                          style: AppTextStyles.w600.copyWith(fontSize: 14.sp, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ContactsLoaded) {
              final contacts = state.contacts;
              final incoming = state.incoming;
              final sent = state.sent;

              return Column(
                children: [
                  _PulseTabBar(
                    controller: _tabController,
                    tabs: [
                      _TabSpec(label: 'Contacts', count: state.contactsTotal),
                      _TabSpec(label: 'Requests', count: state.incomingTotal, highlight: state.incomingTotal > 0),
                      _TabSpec(label: 'Sent', count: state.sentTotal),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _ContactsTab(
                          contacts: contacts,
                          hasMore: state.contactsHasMore,
                          isLoadingMore: state.isLoadingMoreContacts,
                          onRefresh: _refreshContacts,
                          onLoadMore: () => context.read<ContactsBloc>().add(const LoadMoreContactsEvent(ContactListType.contacts)),
                          onBlock: (user) => context.read<ContactsBloc>().add(BlockUserEvent(user)),
                          onUnblock: (user) => context.read<ContactsBloc>().add(UnblockUserEvent(user)),
                        ),
                        _RequestsTab(
                          requests: incoming,
                          hasMore: state.incomingHasMore,
                          isLoadingMore: state.isLoadingMoreIncoming,
                          onRefresh: _refreshContacts,
                          onLoadMore: () => context.read<ContactsBloc>().add(const LoadMoreContactsEvent(ContactListType.incoming)),
                          onAccept: (user) => context.read<ContactsBloc>().add(AcceptContactRequestEvent(user)),
                          onReject: (user) => context.read<ContactsBloc>().add(RejectContactRequestEvent(user)),
                        ),
                        _SentTab(
                          sent: sent,
                          hasMore: state.sentHasMore,
                          isLoadingMore: state.isLoadingMoreSent,
                          onRefresh: _refreshContacts,
                          onLoadMore: () => context.read<ContactsBloc>().add(const LoadMoreContactsEvent(ContactListType.sent)),
                          onCancel: (user) => context.read<ContactsBloc>().add(CancelContactRequestEvent(user)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _TabSpec {
  _TabSpec({required this.label, required this.count, this.highlight = false});
  final String label;
  final int count;
  final bool highlight;
}

class _PulseTabBar extends StatelessWidget {
  const _PulseTabBar({required this.controller, required this.tabs});

  final TabController controller;
  final List<_TabSpec> tabs;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: AnimatedBuilder(
        animation: controller.animation!,
        builder: (context, _) {
          final index = controller.animation!.value;
          return LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / tabs.length;
              return Stack(
                children: [
                  Positioned(
                    left: tabWidth * index,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(tabs.length, (i) {
                      final spec = tabs[i];
                      final selected = controller.index == i;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.animateTo(i),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  spec.label,
                                  style: AppTextStyles.w600.copyWith(
                                    fontSize: 13.sp,
                                    color: selected ? Colors.white : colors.textSecondary,
                                  ),
                                ),
                                if (spec.count > 0) ...[
                                  SizedBox(width: 5.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? Colors.white.withValues(alpha: 0.25)
                                          : (spec.highlight ? colors.primaryMuted : colors.background),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      '${spec.count}',
                                      style: AppTextStyles.w600.copyWith(
                                        fontSize: 10.5.sp,
                                        color: selected ? Colors.white : (spec.highlight ? colors.primary : colors.textSecondary),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ContactsTab extends StatelessWidget {
  const _ContactsTab({
    required this.contacts,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onBlock,
    required this.onUnblock,
  });

  final List<ContactUser> contacts;
  final bool hasMore;
  final bool isLoadingMore;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final ValueChanged<ContactUser> onBlock;
  final ValueChanged<ContactUser> onUnblock;

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: const Center(
                child: PulseEmptyState(
                  icon: Icons.people_outline_rounded,
                  title: 'No contacts yet',
                  message: 'Search for people you know and send\nthem a request to start chatting.',
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: _PagedListNotification(
        hasMore: hasMore,
        isLoadingMore: isLoadingMore,
        onLoadMore: onLoadMore,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: contacts.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, i) {
            if (i >= contacts.length) return const _LoadMoreIndicator();

            final user = contacts[i];
            return ContactUserTile(
              user: user,
              onTap: () => context.push('/profile/${user.uid}'),
              onMessage: () {
                // Can navigate to chat or perform other actions in future
              },
              onUnblock: () => onUnblock(user),
              onLongPress: user.status == ContactStatus.friends ? () => _showBlockSheet(context, user, onBlock) : null,
            );
          },
        ),
      ),
    );
  }

  Future<void> _showBlockSheet(BuildContext context, ContactUser user, ValueChanged<ContactUser> onBlock) async {
    final colors = AppColors(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.w,
                  height: 4.h,
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(4.r)),
                ),
                ListTile(
                  leading: Icon(Icons.block_rounded, color: colors.error),
                  title: Text(
                    'Block ${user.displayName}',
                    style: AppTextStyles.w500.copyWith(fontSize: 14.5.sp, color: colors.error),
                  ),
                  subtitle: Text(
                    "They won't be able to message you",
                    style: AppTextStyles.w400.copyWith(fontSize: 12.sp, color: colors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onBlock(user);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab({
    required this.requests,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onAccept,
    required this.onReject,
  });

  final List<ContactUser> requests;
  final bool hasMore;
  final bool isLoadingMore;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final ValueChanged<ContactUser> onAccept;
  final ValueChanged<ContactUser> onReject;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: const Center(
                child: PulseEmptyState(
                  icon: Icons.mark_email_read_outlined,
                  title: 'No pending requests',
                  message: "When someone wants to connect with\nyou, it'll show up here.",
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: _PagedListNotification(
        hasMore: hasMore,
        isLoadingMore: isLoadingMore,
        onLoadMore: onLoadMore,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: requests.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, i) {
            if (i >= requests.length) return const _LoadMoreIndicator();

            final user = requests[i];
            return ContactUserTile(
              user: user,
              onTap: () => context.push('/profile/${user.uid}'),
              onAccept: () => onAccept(user),
              onReject: () => onReject(user),
            );
          },
        ),
      ),
    );
  }
}

class _SentTab extends StatelessWidget {
  const _SentTab({
    required this.sent,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onCancel,
  });

  final List<ContactUser> sent;
  final bool hasMore;
  final bool isLoadingMore;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final ValueChanged<ContactUser> onCancel;

  @override
  Widget build(BuildContext context) {
    if (sent.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: const Center(
                child: PulseEmptyState(
                  icon: Icons.outgoing_mail,
                  title: 'No sent requests',
                  message: 'Requests you send to other people\nwill be listed here until they respond.',
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: _PagedListNotification(
        hasMore: hasMore,
        isLoadingMore: isLoadingMore,
        onLoadMore: onLoadMore,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: sent.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, i) {
            if (i >= sent.length) return const _LoadMoreIndicator();

            final user = sent[i];
            return ContactUserTile(
              user: user,
              onTap: () => context.push('/profile/${user.uid}'),
              onCancelRequest: () => onCancel(user),
            );
          },
        ),
      ),
    );
  }
}

class _PagedListNotification extends StatelessWidget {
  const _PagedListNotification({
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.child,
  });

  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 240 && hasMore && !isLoadingMore) {
          onLoadMore();
        }
        return false;
      },
      child: child,
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: SizedBox(
          width: 22.r,
          height: 22.r,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
          ),
        ),
      ),
    );
  }
}
