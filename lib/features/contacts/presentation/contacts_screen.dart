import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_chat/config/routes/app_routes.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/authentication/widgets/auth_background.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';
import 'package:pulse_chat/features/contacts/widgets/contact_user_tile.dart';
import 'package:pulse_chat/features/contacts/widgets/pulse_empty_state.dart';

/// Hub screen combining:
/// - GET /users/contacts          -> "Contacts" tab
/// - incoming pending records     -> "Requests" tab (accept/reject buttons)
/// - outgoing pending records     -> "Sent" tab (cancel button)
///
/// Your backend's GET /users/contacts probably returns all three buckets
/// (or you fetch them as separate calls) — split the response into the
/// three lists below by status once wired to a ContactsBloc.
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  List<ContactUser> _contacts = List.of(_mockContacts);
  final List<ContactUser> _incoming = List.of(_mockIncoming);
  final List<ContactUser> _sent = List.of(_mockSent);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _accept(ContactUser user) {
    setState(() {
      _incoming.removeWhere((u) => u.uid == user.uid);
      _contacts = [user.copyWith(status: ContactStatus.friends), ..._contacts];
    });
  }

  void _reject(ContactUser user) {
    setState(() => _incoming.removeWhere((u) => u.uid == user.uid));
  }

  void _cancelSent(ContactUser user) {
    setState(() => _sent.removeWhere((u) => u.uid == user.uid));
  }

  void _block(ContactUser user) {
    setState(() {
      _contacts = _contacts.map((u) => u.uid == user.uid ? u.copyWith(status: ContactStatus.blockedByMe) : u).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.displayName} has been blocked'), behavior: SnackBarBehavior.floating),
    );
  }

  void _unblock(ContactUser user) {
    setState(() {
      _contacts = _contacts.map((u) => u.uid == user.uid ? u.copyWith(status: ContactStatus.friends) : u).toList();
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
          'Contacts',
          style: AppTextStyles.w600.copyWith(fontSize: 18.sp, color: colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1_rounded, color: colors.primary, size: 22.sp),
            onPressed: () => context.push(AppRoutes.searchUsers),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: AuthBackground(
        child: Column(
          children: [
            _PulseTabBar(
              controller: _tabController,
              tabs: [
                _TabSpec(label: 'Contacts', count: _contacts.where((u) => u.status != ContactStatus.blockedByMe).length),
                _TabSpec(label: 'Requests', count: _incoming.length, highlight: _incoming.isNotEmpty),
                _TabSpec(label: 'Sent', count: _sent.length),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ContactsTab(contacts: _contacts, onBlock: _block, onUnblock: _unblock),
                  _RequestsTab(requests: _incoming, onAccept: _accept, onReject: _reject),
                  _SentTab(sent: _sent, onCancel: _cancelSent),
                ],
              ),
            ),
          ],
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
  const _ContactsTab({required this.contacts, required this.onBlock, required this.onUnblock});

  final List<ContactUser> contacts;
  final ValueChanged<ContactUser> onBlock;
  final ValueChanged<ContactUser> onUnblock;

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return const Center(
        child: PulseEmptyState(
          icon: Icons.people_outline_rounded,
          title: 'No contacts yet',
          message: 'Search for people you know and send\nthem a request to start chatting.',
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: contacts.length,
      itemBuilder: (context, i) {
        final user = contacts[i];
        return ContactUserTile(
          user: user,
          onMessage: () {},
          onUnblock: () => onUnblock(user),
          onLongPress: user.status == ContactStatus.friends ? () => _showBlockSheet(context, user, onBlock) : null,
        );
      },
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
                    'They won\'t be able to message you',
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
  const _RequestsTab({required this.requests, required this.onAccept, required this.onReject});

  final List<ContactUser> requests;
  final ValueChanged<ContactUser> onAccept;
  final ValueChanged<ContactUser> onReject;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(
        child: PulseEmptyState(
          icon: Icons.mark_email_read_outlined,
          title: 'No pending requests',
          message: 'When someone wants to connect with\nyou, it\'ll show up here.',
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: requests.length,
      itemBuilder: (context, i) {
        final user = requests[i];
        return ContactUserTile(
          user: user,
          onAccept: () => onAccept(user),
          onReject: () => onReject(user),
        );
      },
    );
  }
}

class _SentTab extends StatelessWidget {
  const _SentTab({required this.sent, required this.onCancel});

  final List<ContactUser> sent;
  final ValueChanged<ContactUser> onCancel;

  @override
  Widget build(BuildContext context) {
    if (sent.isEmpty) {
      return const Center(
        child: PulseEmptyState(
          icon: Icons.outgoing_mail,
          title: 'No sent requests',
          message: 'Requests you send to other people\nwill be listed here until they respond.',
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: sent.length,
      itemBuilder: (context, i) {
        final user = sent[i];
        return ContactUserTile(
          user: user,
          onCancelRequest: () => onCancel(user),
        );
      },
    );
  }
}

// ----- Mock data: remove once ContactsBloc is wired in -----
final _mockContacts = <ContactUser>[
  const ContactUser(uid: '4', username: 'sneha.codes', displayName: 'Sneha Iyer', status: ContactStatus.friends, isOnline: true),
  const ContactUser(uid: '6', username: 'aditya.r', displayName: 'Aditya Rao', status: ContactStatus.friends),
  const ContactUser(uid: '5', username: 'vikram_t', displayName: 'Vikram Thakur', status: ContactStatus.blockedByMe),
];

final _mockIncoming = <ContactUser>[
  const ContactUser(uid: '7', username: 'meera.j', displayName: 'Meera Joshi', status: ContactStatus.pendingReceived, mutualContactsCount: 2),
  const ContactUser(uid: '8', username: 'karan_s', displayName: 'Karan Singh', status: ContactStatus.pendingReceived),
];

final _mockSent = <ContactUser>[
  const ContactUser(uid: '2', username: 'priya_dev', displayName: 'Priya Sharma', status: ContactStatus.pendingSent),
];
