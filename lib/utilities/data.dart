
//This file contains all the static data required by the app
Map<String, String> headers = {
  'x-functions-key': 'BwtKHT3o5eAQ98LX8tS8wrrKNWXWT1EIx9Mj5Vbano5MmWYCvagnuw==',
};
String baseUrl = 'https://palota-jobs-africa-spotify-fa.azurewebsites.net/api/';
bool isEmpty(String s) => s.isEmpty || s.trim().isEmpty;

class Playlist {
  final String name;
  final int followers;
  final String id;
  final String image;

  Playlist({required this.name, required this.followers, required this.id, required this.image});
}

class Track {
  final String name, image;
  List<String> artists;

  Track({required this.name, required this.image, required this.artists});
}