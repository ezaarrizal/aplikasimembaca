// lib/main.dart - UPDATED with Spelling Game Support

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/game.dart';

// Import providers
import 'providers/auth_provider.dart';
import 'providers/user_management_provider.dart';
import 'providers/feedback_provider.dart';
import 'providers/game_provider.dart';

// Import screens
import 'screens/auth/login_screen.dart';
import 'screens/guru/guru_dashboard.dart';
import 'screens/siswa/siswa_dashboard.dart';
import 'screens/siswa/game_huruf_screen.dart';
import 'screens/siswa/game_detective_screen.dart';
import 'screens/siswa/game_spelling_screen.dart'; // ⚡ NEW: Spelling Game
import 'screens/siswa/game_completed_screen.dart';
import 'screens/siswa/badges_screen.dart';
import 'screens/orangtua/orangtua_dashboard_screen.dart';
import 'screens/feedback/feedback_list_screen.dart';
import 'screens/feedback/create_feedback_screen.dart';
import 'screens/feedback/feedback_detail_screen.dart';
import 'screens/guru/user_management_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        title: 'Aplikasi Membaca Edukatif',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/guru/dashboard': (context) => const GuruDashboard(),
          '/siswa/dashboard': (context) => const SiswaDashboard(),
          '/orangtua/dashboard': (context) => const OrangtuaDashboardScreen(),

          // Game routes
          '/siswa/badges': (context) => const BadgesScreen(),

          // Feedback routes
          '/guru/feedback': (context) =>
              const FeedbackListScreen(isParentMode: false),
          '/orangtua/feedback': (context) =>
              const FeedbackListScreen(isParentMode: true),
          '/guru/manage-users': (context) => const UserManagementScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle dynamic routes
          switch (settings.name) {
            // Feedback routes - EXISTING
            case '/feedback/create':
              return MaterialPageRoute(
                builder: (context) => const CreateFeedbackScreen(),
              );
            case '/feedback/detail':
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
                return MaterialPageRoute(
                  builder: (context) => FeedbackDetailScreen(
                    feedback: args['feedback'],
                    isParentMode: args['isParentMode'] ?? false,
                  ),
                );
              }
              break;

            // ✅ EXISTING: Vocal Game route
            case '/siswa/game/huruf':
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null && args['game'] != null) {
                return MaterialPageRoute(
                  builder: (context) => GameHurufScreen(
                    game: args['game'],
                  ),
                );
              }
              return MaterialPageRoute(
                builder: (context) => const SiswaDashboard(),
              );

            // ✅ EXISTING: Detective Game route
            case '/siswa/game/detektif':
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null && args['game'] != null) {
                return MaterialPageRoute(
                  builder: (context) => GameDetectiveScreen(
                    game: args['game'],
                  ),
                );
              }
              return MaterialPageRoute(
                builder: (context) => const SiswaDashboard(),
              );

            // ⚡ NEW: Spelling Game route
            case '/siswa/game/spelling':
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null && args['game'] != null) {
                return MaterialPageRoute(
                  builder: (context) => GameSpellingScreen(
                    game: args['game'],
                  ),
                );
              }
              return MaterialPageRoute(
                builder: (context) => const SiswaDashboard(),
              );

            // ✅ EXISTING: Game completed route
            case '/siswa/game/completed':
              return MaterialPageRoute(
                builder: (context) => const GameCompletedScreen(),
              );

            // ⚡ UPDATED: Enhanced auto game route detection
            case '/siswa/game/auto':
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null && args['game'] != null) {
                final game = args['game'];
                
                // Auto-detect game type based on title
                if (game.title == 'Permainan Huruf Vokal') {
                  return MaterialPageRoute(
                    builder: (context) => GameHurufScreen(game: game),
                  );
                } else if (game.title == 'Detektif Huruf') {
                  return MaterialPageRoute(
                    builder: (context) => GameDetectiveScreen(game: game),
                  );
                } else if (game.title == 'Belajar Mengeja') {
                  // ⚡ NEW: Spelling game detection
                  return MaterialPageRoute(
                    builder: (context) => GameSpellingScreen(game: game),
                  );
                } else {
                  // Default to vocal game for unknown types
                  return MaterialPageRoute(
                    builder: (context) => GameHurufScreen(game: game),
                  );
                }
              }
              return MaterialPageRoute(
                builder: (context) => const SiswaDashboard(),
              );

            // ⚡ NEW: Enhanced game type detection based on skill focus
            case '/siswa/game/detect':
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null && args['game'] != null) {
                final game = args['game'];
                
                // Enhanced detection based on multiple factors
                String gameType = _detectGameType(game);
                
                switch (gameType) {
                  case 'vocal':
                    return MaterialPageRoute(
                      builder: (context) => GameHurufScreen(game: game),
                    );
                  case 'detective':
                    return MaterialPageRoute(
                      builder: (context) => GameDetectiveScreen(game: game),
                    );
                  case 'spelling':
                    return MaterialPageRoute(
                      builder: (context) => GameSpellingScreen(game: game),
                    );
                  default:
                    // Fallback to vocal game
                    return MaterialPageRoute(
                      builder: (context) => GameHurufScreen(game: game),
                    );
                }
              }
              return MaterialPageRoute(
                builder: (context) => const SiswaDashboard(),
              );
          }
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  // ⚡ NEW: Enhanced game type detection
  static String _detectGameType(dynamic game) {
    // Get game properties
    String title = game.title?.toString().toLowerCase() ?? '';
    String theme = game.theme?.toString().toLowerCase() ?? '';
    String skillFocus = game.skillFocus?.toString().toLowerCase() ?? '';
    String targetAge = game.targetAge?.toString().toLowerCase() ?? '';
    
    print('🎮 DEBUG: Detecting game type for: $title');
    print('🎮 DEBUG: Theme: $theme, Skill: $skillFocus, Age: $targetAge');

    // Primary detection by title
    if (title.contains('vokal') || title.contains('huruf vokal')) {
      return 'vocal';
    }
    
    if (title.contains('detektif') || title.contains('detective')) {
      return 'detective';
    }
    
    if (title.contains('mengeja') || title.contains('spelling')) {
      return 'spelling';
    }

    // Secondary detection by theme
    if (theme.contains('vokal') || theme.contains('vocal')) {
      return 'vocal';
    }
    
    if (theme.contains('detektif') || theme.contains('detective')) {
      return 'detective';
    }
    
    if (theme.contains('mengeja') || theme.contains('spelling')) {
      return 'spelling';
    }

    // Tertiary detection by skill focus
    if (skillFocus.contains('vokal')) {
      return 'vocal';
    }
    
    if (skillFocus.contains('detektif') || skillFocus.contains('puzzle')) {
      return 'detective';
    }
    
    if (skillFocus.contains('mengeja') || skillFocus.contains('suku kata') || skillFocus.contains('kalimat')) {
      return 'spelling';
    }

    // Quaternary detection by target age
    if (targetAge.contains('tk a') || targetAge.contains('playgroup')) {
      // Younger kids typically start with vocal
      return 'vocal';
    }
    
    if (targetAge.contains('tk b')) {
      // TK B is suitable for spelling game
      return 'spelling';
    }

    // Default fallback
    print('⚠️ WARNING: Could not detect game type, defaulting to vocal');
    return 'vocal';
  }
}