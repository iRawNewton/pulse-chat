import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_chat/config/routes/app_routes.dart';
import 'package:pulse_chat/core/di/injection.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/authentication/bloc/auth_bloc.dart';
import 'package:pulse_chat/features/authentication/bloc/auth_state.dart';
import 'package:pulse_chat/features/authentication/widgets/auth_background.dart';
import 'package:pulse_chat/features/chats/data/chat_realtime_service.dart';
import 'package:pulse_chat/features/home/data/chat_item_model.dart';
import 'package:pulse_chat/features/home/data/chat_list_repository.dart';
import 'package:pulse_chat/features/home/data/nav_item.dart';
import 'package:pulse_chat/features/home/widgets/app_bar_icon.dart';
import 'package:pulse_chat/features/home/widgets/chat_tile.dart';
import 'package:pulse_chat/features/home/widgets/home_popup_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;
  late final ChatListRepository _chatListRepository;
  late final ChatRealtimeService _realtimeService;
  StreamSubscription<RealtimeEvent>? _realtimeSubscription;
  List<ChatItem> _chats = const [];
  bool _isLoadingChats = true;

  final List<NavItem> navItems = const [
    NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Chats'),
    NavItem(icon: Icons.circle_outlined, activeIcon: Icons.circle, label: 'Status'),
    NavItem(icon: Icons.call_outlined, activeIcon: Icons.call_rounded, label: 'Calls'),
  ];

  @override
  void initState() {
    super.initState();
    _chatListRepository = getIt<ChatListRepository>();
    _realtimeService = getIt<ChatRealtimeService>();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    unawaited(_loadChats());
    unawaited(_realtimeService.connect());
    _realtimeSubscription = _realtimeService.events.listen(_handleRealtimeEvent);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  List<ChatItem> get _filteredChats {
    final all = List<ChatItem>.from(_chats)
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });
    if (_searchQuery.isEmpty) return all;
    return all.where((c) => c.name.toLowerCase().contains(_searchQuery) || c.lastMessage.toLowerCase().contains(_searchQuery)).toList();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoadingChats = true);
    try {
      final chats = await _chatListRepository.getChats();
      if (!mounted) return;
      setState(() {
        _chats = chats
            .map(
              (chat) => _copyChat(
                chat,
                isOnline: _realtimeService.isOnline(chat.id),
              ),
            )
            .toList();
        _isLoadingChats = false;
      });
    } on Exception {
      if (!mounted) return;
      setState(() => _isLoadingChats = false);
    }
  }

  void _handleRealtimeEvent(RealtimeEvent event) {
    if (!mounted) return;

    switch (event.name) {
      case 'contacts_presence':
        _applyContactsPresence(event.payload);
        break;
      case 'presence':
        _applyPresence(event.payload);
        break;
      case 'message':
      case 'local_message':
        _applyIncomingMessage(event.payload);
        break;
      case 'contact_request':
      case 'contact_accept':
      case 'contact_reject':
        unawaited(_loadChats());
        break;
    }
  }

  void _applyContactsPresence(Map<String, dynamic> payload) {
    final onlineContacts = payload['onlineContacts'];
    if (onlineContacts is! Map<String, dynamic>) return;
    setState(() {
      _chats = _chats
          .map(
            (chat) => _copyChat(
              chat,
              isOnline: onlineContacts[chat.id] == 'online',
            ),
          )
          .toList();
    });
  }

  void _applyPresence(Map<String, dynamic> payload) {
    final userId = payload['userId'] as String?;
    final status = payload['status'] as String?;
    if (userId == null || status == null) return;

    setState(() {
      _chats = _chats
          .map(
            (chat) => chat.id == userId ? _copyChat(chat, isOnline: status == 'online') : chat,
          )
          .toList();
    });
  }

  void _applyIncomingMessage(Map<String, dynamic> payload) {
    final senderId = payload['senderId'] as String?;
    final receiverId = payload['receiverId'] as String?;
    final content = payload['content'] as String?;
    if (content == null) return;

    setState(() {
      _chats = _chats
          .map(
            (chat) => chat.id == senderId || chat.id == receiverId
                ? _copyChat(
                    chat,
                    lastMessage: content,
                    time: _formatSocketTime(payload['createdAt'] as String?),
                    unreadCount: chat.id == senderId ? chat.unreadCount + 1 : chat.unreadCount,
                  )
                : chat,
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          unawaited(_realtimeService.disconnect());
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        // backgroundColor: colors.background,
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: AuthBackground(
          child: Column(
            children: [
              _buildAppBar(colors),
              Expanded(
                child: _selectedIndex == 0 ? _buildChatList(colors) : _buildPlaceholder(colors, navItems[_selectedIndex].label),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(colors),
        floatingActionButton: _selectedIndex == 0 ? _buildFAB(colors) : null,
      ),
    );
  }

  // ── App Bar ──────────────────────────────────

  Widget _buildAppBar(AppColors colors) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isSearching ? _buildSearchBar(colors) : _buildTitleBar(colors),
          ),
          _buildFilterChips(colors),
          8.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildTitleBar(AppColors colors) {
    return Padding(
      key: const ValueKey('title'),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          Text(
            'Pulse',
            style: AppTextStyles.w700.copyWith(
              fontSize: 26.sp,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          AppBarIcon(
            icon: Icons.search_rounded,
            colors: colors,
            onTap: () => setState(() => _isSearching = true),
          ),
          SizedBox(width: 4.w),
          AppBarIcon(
            icon: Icons.camera_alt_outlined,
            colors: colors,
            onTap: () {},
          ),
          SizedBox(width: 4.w),
          HomePopupMenu(colors: colors),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppColors colors) {
    return Padding(
      key: const ValueKey('search'),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: colors.border),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTextStyles.w400.copyWith(
                  fontSize: 15.sp,
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: AppTextStyles.w400.copyWith(
                    fontSize: 15.sp,
                    color: colors.textTertiary,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: colors.textTertiary, size: 20.sp),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            },
            child: Text(
              'Cancel',
              style: AppTextStyles.w600.copyWith(
                fontSize: 14.sp,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(AppColors colors) {
    final chips = ['All', 'Unread', 'Groups', 'Pinned'];
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: chips.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final selected = i == 0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: selected ? colors.primary : colors.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: selected ? colors.primary : colors.border,
              ),
            ),
            child: Text(
              chips[i],
              style: AppTextStyles.w600.copyWith(
                fontSize: 13.sp,
                color: selected ? Colors.white : colors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Chat List ────────────────────────────────

  Widget _buildChatList(AppColors colors) {
    if (_isLoadingChats) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
        ),
      );
    }

    final chats = _filteredChats;
    final pinned = chats.where((c) => c.isPinned).toList();
    final others = chats.where((c) => !c.isPinned).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 80.h, top: 8.h),
      children: [
        if (pinned.isNotEmpty) ...[
          _buildSectionLabel('Pinned', colors),
          ...pinned.map((c) => ChatTile(chat: c, colors: colors, onTap: () => _openChat(c))),
          _buildSectionLabel('All Chats', colors),
        ],
        ...others.map((c) => ChatTile(chat: c, colors: colors, onTap: () => _openChat(c))),
        if (chats.isEmpty) _buildEmptyState(colors),
      ],
    );
  }

  Future<void> _openChat(ChatItem chat) async {
    await context.push(AppRoutes.chatScreen, extra: _copyChat(chat, unreadCount: 0));
    if (!mounted) return;
    setState(() {
      _chats = _chats.map((item) => item.id == chat.id ? _copyChat(item, unreadCount: 0) : item).toList();
    });
  }

  ChatItem _copyChat(
    ChatItem chat, {
    String? lastMessage,
    String? time,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ChatItem(
      id: chat.id,
      name: chat.name,
      lastMessage: lastMessage ?? chat.lastMessage,
      time: time ?? chat.time,
      type: chat.type,
      avatarUrl: chat.avatarUrl,
      unreadCount: unreadCount ?? chat.unreadCount,
      isPinned: chat.isPinned,
      isMuted: chat.isMuted,
      isOnline: isOnline ?? chat.isOnline,
      members: chat.members,
      senderName: chat.senderName,
    );
  }

  String _formatSocketTime(String? value) {
    final dateTime = DateTime.tryParse(value ?? '') ?? DateTime.now();
    final h = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final m = dateTime.minute.toString().padLeft(2, '0');
    final ampm = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  Widget _buildSectionLabel(String label, AppColors colors) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
      child: Text(
        label,
        style: AppTextStyles.w600.copyWith(
          fontSize: 12.sp,
          color: colors.textTertiary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Padding(
      padding: EdgeInsets.only(top: 80.h),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 56.sp, color: colors.textTertiary),
          SizedBox(height: 12.h),
          Text(
            'No conversations found',
            style: AppTextStyles.w500.copyWith(
              fontSize: 16.sp,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Placeholder ──────────────────────────────

  Widget _buildPlaceholder(AppColors colors, String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            label == 'Status' ? Icons.circle_outlined : Icons.call_outlined,
            size: 64.sp,
            color: colors.primaryMuted,
          ),
          SizedBox(height: 16.h),
          Text(
            '$label coming soon',
            style: AppTextStyles.w500.copyWith(
              fontSize: 18.sp,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────

  Widget _buildBottomNav(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60.h,
          child: Row(
            children: List.generate(navItems.length, (i) {
              final item = navItems[i];
              final selected = _selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedIndex = i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: selected ? colors.primaryMuted : Colors.transparent,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected ? colors.primary : colors.textTertiary,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.label,
                        style: AppTextStyles.w600.copyWith(
                          fontSize: 11.sp,
                          color: selected ? colors.primary : colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── FAB ──────────────────────────────────────

  Widget _buildFAB(AppColors colors) {
    return FloatingActionButton(
      onPressed: () {
        unawaited(context.push(AppRoutes.contacts));
      },
      backgroundColor: colors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Icon(Icons.chat_bubble_outline_rounded, size: 22.sp),
    );
  }
}
