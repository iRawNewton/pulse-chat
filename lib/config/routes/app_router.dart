import 'package:go_router/go_router.dart';
import 'package:pulse_chat/config/routes/app_routes.dart';
import 'package:pulse_chat/features/authentication/presentation/login_screen.dart';
import 'package:pulse_chat/features/authentication/presentation/signup_screen.dart';
import 'package:pulse_chat/features/chats/presentation/chat_screen.dart';
import 'package:pulse_chat/features/contacts/presentation/contacts_screen.dart';
import 'package:pulse_chat/features/contacts/presentation/search_users_screen.dart';
import 'package:pulse_chat/features/home/data/chat_item_model.dart';
import 'package:pulse_chat/features/home/presentation/home_screen.dart';
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
        return ChatScreen(
          contactName: chat?.name ?? 'Pulse Chat',
          isOnline: chat?.isOnline ?? false,
          isGroup: chat?.type == ChatType.group,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.contacts,
      builder: (context, state) => const ContactsScreen(),
    ),
    GoRoute(
      path: AppRoutes.searchUsers,
      builder: (context, state) => const SearchUsersScreen(),
    ),
  ],
);
