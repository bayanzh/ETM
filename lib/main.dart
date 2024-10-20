import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/core/constant/app_dark_colors.dart';
import 'package:e_training_mate/core/services/fire_notification_service.dart';
import 'package:e_training_mate/features/home/screens/main_screen.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_home/screens/ta_main_screen.dart';
import 'package:e_training_mate/firebase_options.dart';
import 'package:e_training_mate/core/services/app_binding.dart';
import 'package:e_training_mate/localization/translation.dart';
import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:e_training_mate/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/local_notification_service.dart';
import 'core/services/server_key_service.dart';
import 'features/authentication/screens/initial_settings_screen.dart';
import 'features/authentication/screens/verify_email_screen.dart';
import 'core/utils/logger.dart';
import 'dart:ui';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Logger.logError("------ From FlutterError.onError details: $details");
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    Logger.logError("------ From PlatformDispatcher.onError details: $error");
    return true;
  };

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: "e-trainig-mate",
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) {
    Logger.logError("::::::: Firebase then:::");
  }, onError: (error) {
    Logger.logError("---------------------------- Error in firebase init: $error");
  });

  // -- initialize SharedPreferences instance
  await Get.putAsync(() => SharedPreferences.getInstance());

  

  LocalNotificationService.instance;
  await FireNotificationService.instance.initialize();  


  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    
    // تأكد من تمكين التخزين المؤقت في العملية الرئيسية فقط
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      
      runAuthenticationListening();
    }
  }

  StreamSubscription<User?>? authSubscription;

  // This function checks the user's login verification so that it takes
  // the user to the login page if he or she is logged out of the application
  // for any reason.
  void runAuthenticationListening() {
    authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Logger.log(":::::: The user currently signed out.");
        Get.offAll(() => const WelcomeScreen());

        // إيقاف الاستماع عند تحقق الشرط
        authSubscription?.cancel();
        authSubscription = null; // تنظيف المتغير
      } else {
        Logger.log(":::::: The user is signed in.");
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'E-Training Mate',
      navigatorKey: navigatorKey,
      builder: (context, widget) {
        Widget error = const Text('...rendering error...');
        if (widget is Scaffold || widget is Navigator) {
          error = Scaffold(body: Center(child: error));
        }
        ErrorWidget.builder = (errorDetails) => error;
        if (widget != null) return widget;
        throw StateError('widget is null');
      },
    
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        highlightColor: Colors.grey, 
        splashColor: AppColors.primary.withOpacity(0.3),
        
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(fillColor: Colors.white),
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: AppColors.primary,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppDarkColors.scaffold,
      ),
      
      themeMode: PrefHelper.getThemeMode() == "light"? ThemeMode.light : ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      locale: Locale(PrefHelper.getLangCode()),
      translations: AppTranslation(),

      home: FirebaseAuth.instance.currentUser == null
          ? const WelcomeScreen()
          : FirebaseAuth.instance.currentUser?.emailVerified == false
              ? const VerifyEmailScreen()
              : PrefHelper.isDisplayIntialSettings()
                  ? const InitialSettingsScreen()
                  : PrefHelper.getUserType() == UserTypeEnum.learner
                      ? const MainScreen()
                      : const TaMainScreen(),

    );
  }
}
