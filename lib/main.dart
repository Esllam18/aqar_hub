import 'package:aqar_hub/core/helpers/app_prefs.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/localization/locale_cubit.dart';
import 'package:aqar_hub/core/services/navigation/app_routes.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/features/auth/data/datasource/auth_remote_data_source_impl.dart';
import 'package:aqar_hub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqar_hub/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aqar_hub/features/house_seeker/favorites/data/datasources/favorites_datasource.dart';
import 'package:aqar_hub/features/house_seeker/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:aqar_hub/features/house_seeker/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:aqar_hub/features/shared/notifications/fcm_service.dart';
import 'package:aqar_hub/features/splash/view/splash_veiw.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await GoogleSignIn.instance.initialize(
    serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID']!,
  );

  await AppPrefs.init();
  await FcmService.instance.init();

  runApp(const AqarHubApp());
}

class AqarHubApp extends StatelessWidget {
  const AqarHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()..getSavedLanguage()),
        BlocProvider(
          create: (_) =>
              AuthCubit(AuthRepositoryImpl(AuthRemoteDataSourceImpl())),
        ),
        BlocProvider(
          create: (_) =>
              FavoritesCubit(FavoritesRepositoryImpl(FavoritesDatasourceImpl()))
                ..loadFavoriteIds(),
        ),
      ],
      child: BlocBuilder<LocaleCubit, ChangeLocaleState>(
        buildWhen: (prev, curr) => prev.locale != curr.locale,
        builder: (context, state) {
          return MaterialApp(
            title: 'AqarHub',
            debugShowCheckedModeBanner: false,
            navigatorKey: Navigation.key,
            home: const SplashView(),
            routes: AppRoutes.routes,
            locale: state.locale,
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            navigatorObservers: [routeObserver],
          );
        },
      ),
    );
  }
}