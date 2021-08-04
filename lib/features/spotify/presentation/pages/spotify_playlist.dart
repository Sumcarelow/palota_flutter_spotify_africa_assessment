import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spotify_africa_assessment/utilities/data.dart';
import 'package:http/http.dart' as http;

import '../../../../colors.dart';
import '../../../../colors.dart';

//TODO: complete this page - you may choose to change it to a stateful widget if necessary
class SpotifyPlaylist extends StatefulWidget {
  final Playlist playlist;
  const SpotifyPlaylist({Key? key, required this.playlist}) : super(key: key);

  @override
  _SpotifyPlaylistState createState() => _SpotifyPlaylistState();
}

class _SpotifyPlaylistState extends State<SpotifyPlaylist> {
  bool isLoading = false;
  bool hasData = false;
  late String description;
  List<Track> tracks = [];

  //Get playlist data from API
  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    var response = await http.get(Uri.parse(baseUrl + 'playlists/${widget.playlist.id}'), headers: headers);
    if(response.statusCode == 200){
      var decodeHttp = json.decode(response.body);
      var mytracks = decodeHttp['tracks']['items'];
      setState(() {
        description = decodeHttp['description'];
        hasData = true;
        isLoading = false;
      });
      mytracks.forEach((track){
        var temp = track['track']['artists'];
        List<String> artists = [];
        //Build list of artists
        temp.forEach((item){
          artists.add(item['name']);
        });

        //Populate tracklist
        tracks.add(
          Track(name: track['track']['name'], image: track['track']['album']['images'][1]['url'], artists: artists)
        );
      });
    }
  }

  //initial state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          //Main page
          Scaffold(
            body: hasData
            ? CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text('${widget.playlist.name}'),
                  backgroundColor: AppColors.cyan,
                  centerTitle: true,
                  floating: true,
                  automaticallyImplyLeading: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      //Playlist cover image
                      !isEmpty(widget.playlist.image)
                          ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ),
                            padding: EdgeInsets.all(4.0),
                          ),
                          imageUrl: widget.playlist.image,
                          width: MediaQuery.of(context).size.width * 0.57,
                          height: MediaQuery.of(context).size.height* 0.57,
                          fit: BoxFit.contain,
                        ),
                        //borderRadius: BorderRadius.all(Radius.circular(45.0)),
                        clipBehavior: Clip.hardEdge,
                      )
                          : Icon(
                        Icons.account_circle,
                        size: 90.0,
                      ),
                    ]
                  ),
                ),

                //Tracks in playlis
                SliverList(
                    delegate: SliverChildBuilderDelegate((context, index){
                      var item;
                      String artists = '';
                      if (tracks.isEmpty || tracks.length == 0){

                      } else {
                        item = tracks[index];
                        artists = item.artists.join(',');
                      }
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: !isEmpty(item.image)
                                    ? Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                      ),
                                      padding: EdgeInsets.all(4.0),
                                    ),
                                    imageUrl: item.image,
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.height * 0.2,
                                    fit: BoxFit.contain,
                                  ),
                                  //borderRadius: BorderRadius.all(Radius.circular(45.0)),
                                  clipBehavior: Clip.hardEdge,
                                )
                                    : Icon(
                                  Icons.account_circle,
                                  size: 90.0,
                                ),
                              ),

                              //Name of track and artists
                              Expanded(
                                child: Column(
                                  children: [
                                    Text('${item.name}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16
                                      ),
                                    ),
                                    Text('$artists')
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    })
                )
              ],
            )
            : Container(
              child: Center(
                child: Text('Error: Could not load playlist, please try again later'),
              ),
            ),
          ),

          //Overlay for when loading data
          isLoading
              ? Positioned(
              child: Container(
                color: AppColors.blue,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                      ),
                      Text('Loading Playlist Data')
                    ],

                  ),
                ),
              )
          )
              : Container()
        ],
      ),
    );
  }
}
