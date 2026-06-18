import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pulse_chat/config/routes/app_router.dart';
import 'package:pulse_chat/core/database/app_prefs.dart';
import 'package:pulse_chat/core/database/cubit/settings_cubit.dart';
import 'package:pulse_chat/core/database/prefs_store.dart';
import 'package:pulse_chat/core/di/injection.dart';
import 'package:pulse_chat/core/theme/app_theme.dart';
import 'package:pulse_chat/features/authentication/bloc/auth_bloc.dart';
import 'package:pulse_chat/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeFirebase();

  // Initialize dependency injection
  configureDependencies();

  // Pre-load local preferences to prevent startup flashes
  await getIt<PrefsStore>().init();

  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (error) {
    if (error.code != 'duplicate-app') {
      rethrow;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
      ],
      child: OKToast(
        child: BlocBuilder<SettingsCubit, AppPrefs>(
          builder: (context, prefs) {
            return ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Pulse Chat',
                  themeMode: prefs.themeMode,
                  theme: AppTheme.lightTheme(context),
                  darkTheme: AppTheme.darkTheme(context),
                  routerConfig: appRouter,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
