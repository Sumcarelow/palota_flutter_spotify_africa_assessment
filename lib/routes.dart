import 'package:flutter/material.dart';
import 'package:flutter_spotify_africa_assessment/features/about/presentation/pages/about.dart';
import 'package:flutter_spotify_africa_assessment/features/landing/presentation/pages/landing.dart';
import 'package:flutter_spotify_africa_assessment/features/spotify/presentation/pages/spotify_category.dart';
import 'package:flutter_spotify_africa_assessment/utilities/data.dart';

import 'features/spotify/presentation/pages/spotify_playlist.dart';

class AppRoutes {
  /// App start up (loading) page
  static const String startUp = '/';

  /// App start up (loading) page
  static const String about = '/about';

  /// Spotify Category Page
  static const String spotifyCategory = '/spotify/category';

  /// Spotify Playlist Page
  static const String spotifyPlaylist = '/spotify/playlist';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case startUp:
        return MaterialPageRoute(
          builder: (BuildContext context) => LandingPage(),
          settings: settings,
        );
      case about:
        return MaterialPageRoute(
          builder: (BuildContext context) => AboutPage(),
          settings: settings,
        );
      case spotifyCategory:
        final String categoryId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (BuildContext context) => SpotifyCategory(
            categoryId: categoryId,
          ),
          settings: settings,
        );

      case spotifyPlaylist:
        final Playlist playlist = settings.arguments as Playlist;
        return MaterialPageRoute(
          builder: (BuildContext context) => SpotifyPlaylist(
            playlist: playlist,
          ),
          settings: settings,
        );
      /* TODO: handle other routes
      you can extract parameters from settings.arguments if necessary 
      https://flutter.dev/docs/cookbook/navigation/navigate-with-arguments#alternatively-extract-the-arguments-using-ongenerateroute*/
      default:
        throw UnimplementedError();
    }
  }
}
