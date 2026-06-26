import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_chat/config/routes/app_routes.dart';
import 'package:pulse_chat/core/di/injection.dart';
import 'package:pulse_chat/features/authentication/presentation/login_screen.dart';
import 'package:pulse_chat/features/authentication/presentation/signup_screen.dart';
import 'package:pulse_chat/features/chats/presentation/chat_screen.dart';
import 'package:pulse_chat/features/contacts/bloc/contacts_bloc.dart';
import 'package:pulse_chat/features/contacts/bloc/contacts_event.dart';
import 'package:pulse_chat/features/contacts/bloc/search_users_bloc.dart';
import 'package:pulse_chat/features/contacts/presentation/contacts_screen.dart';
import 'package:pulse_chat/features/contacts/presentation/search_users_screen.dart';
import 'package:pulse_chat/features/home/data/chat_item_model.dart';
import 'package:pulse_chat/features/home/presentation/home_screen.dart';
import 'package:pulse_chat/features/profile/bloc/profile_bloc.dart';
import 'package:pulse_chat/features/profile/bloc/profile_event.dart';
import 'package:pulse_chat/features/profile/profile_screen_wrapper.dart';
import 'package:pulse_chat/features/splash_screen/splash_screen_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreenPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.chatScreen,
      builder: (context, state) {
        final chat = state.extra is ChatItem ? state.extra! as ChatItem : null;
        final chatId = chat?.type == ChatType.individual && chat != null ? _directChatId(chat.id) : chat?.id;
        return ChatScreen(
          contactName: chat?.name ?? 'Pulse Chat',
          contactId: chat?.id,
          chatId: chatId,
          isOnline: chat?.isOnline ?? false,
          isGroup: chat?.type == ChatType.group,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.contacts,
      builder: (context, state) => BlocProvider.value(
        value: getIt<ContactsBloc>()..add(const FetchContactsEvent()),
        child: const ContactsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.searchUsers,
      builder: (context, state) => BlocProvider(
        create: (context) => getIt<SearchUsersBloc>(),
        child: const SearchUsersScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) {
        final uid = state.pathParameters['uid']!;
        return BlocProvider(
          create: (context) => getIt<ProfileBloc>()..add(FetchProfileEvent(uid)),
          child: ProfileScreenWrapper(uid: uid),
        );
      },
    ),
  ],
);

String _directChatId(String contactId) {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUid == null || currentUid.isEmpty) return contactId;

  final ids = [currentUid, contactId]..sort();
  return 'dm_${ids[0]}_${ids[1]}';
}
