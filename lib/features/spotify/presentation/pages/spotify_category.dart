import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spotify_africa_assessment/colors.dart';
import 'package:flutter_spotify_africa_assessment/routes.dart';
import 'package:flutter_spotify_africa_assessment/utilities/data.dart';
import 'package:http/http.dart' as http;
import '../../../../colors.dart';

// TODO: fetch and populate playlist info and allow for click-through to detail
// Feel free to change this to a stateful widget if necessary
class SpotifyCategory extends StatefulWidget {
  final String categoryId;

  const SpotifyCategory({
    Key? key,
    required this.categoryId,
  }) : super(key: key);

  @override
  _SpotifyCategoryState createState() => _SpotifyCategoryState();
}

class _SpotifyCategoryState extends State<SpotifyCategory> {
  //Category data variables
  late String afroCategoryName, afroCategoryImage;
  bool hasData = false;
  bool isLoading = false;
  int limit = 20;
  int offset = 0;
  var playlists;
  List<int> followers = [];
  List<Playlist> myPlaylists = [];

  //Scroll Controller for Pagination
  ScrollController _scrollController = ScrollController();

  //Future function for fetching category details from Spotify API
  Future<void> getData() async {
    setState(() {
      followers.clear();
      isLoading = true;
    });
    //Perform GET requestS
    var response = await http.get(Uri.parse(baseUrl + 'browse/categories/afro'), headers: headers);
    var playlistsResponse = await http.get(Uri.parse(baseUrl + 'browse/categories/afro/playlists'), headers: headers);
    if(response.statusCode == 200 || playlistsResponse.statusCode == 200){

      //If request is successful, load category data
      var decodeHttp = json.decode(response.body);
      var decodePlaylistsHttp = json.decode(playlistsResponse.body);
      setState(() {
        isLoading = false;
        hasData = true;
        playlists = decodePlaylistsHttp['playlists']['items'];
        afroCategoryName = decodeHttp['name'] ;
        afroCategoryImage = decodeHttp['icons'][0]['url'] ;
      });

      //Populate list of playlists
      playlists.forEach((item) async{
        String id = item['id'];
        String name = item['name'];
        String image = item['images'][0]['url'];
        int followers = 0;
        //Perform GET request for followers data
        var response = await http.get(Uri.parse(baseUrl + 'playlists/$id'), headers: headers);
        if(response.statusCode == 200){
          this.setState(() {
            var decodeHttp = json.decode(response.body);
            int temp = decodeHttp['followers']['total'];
            followers = temp;
          });
        }
        myPlaylists.add(Playlist(name: name, id: id, followers: followers, image: image));
      });
    }
    else {
      setState(() {
        isLoading = false;
        hasData = false;
      });
    }
  }

  //Get next page
  Future<void> getDataPerPage(int limit, int offset) async {
    var response = await http.get(Uri.parse(baseUrl + 'browse/categories/afro/playlists?limit=$limit&offset=$offset'), headers: headers,);
    if(response.statusCode == 200){
      var decodeHttp = json.decode(response.body);
      playlists = decodeHttp['playlists']['items'];

      //Populate list of playlists
      playlists.forEach((item) async{
        String id = item['id'];
        String name = item['name'];
        String image = item['images'][0]['url'];
        int followers = 0;
        //Perform GET request for followers data
        var response = await http.get(Uri.parse(baseUrl + 'playlists/$id'), headers: headers);
        if(response.statusCode == 200){
          this.setState(() {
            var decodeHttp = json.decode(response.body);
            int temp = decodeHttp['followers']['total'];
            followers = temp;
          });
        }
        if(myPlaylists.contains(Playlist(name: name, id: id, followers: followers, image: image))){

        }
        else {
          myPlaylists.add(
              Playlist(name: name, id: id, followers: followers, image: image));
        }
      });
      setState(() {
      });
    }
  }

  //Initial State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.getData();
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        //Load next page
        setState(() {
          offset+= 20;
        });
        getDataPerPage(limit, offset);
      }
      else if(_scrollController.position.pixels == _scrollController.position.minScrollExtent){
        //Load previous page
        if(offset != 0) {
          setState(() {
            offset -= 20;
          });
        }
        else {
          setState(() {
            offset = 0;
          });
        }
        getDataPerPage(limit, offset);
      }
    });
    setState(() {

    });
  }

  //Dispose controller on exit page
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: hasData ? Text("$afroCategoryName") : Text("No Category"),
              actions: [
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.about),
                ),
              ],
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      AppColors.blue,
                      AppColors.cyan,
                      AppColors.green,
                    ],
                  ),
                ),
              ),
            ),
            body: Container(
              padding: const EdgeInsets.all(16),
              child: hasData
              ? Column(
                children: [
                  //Category Image
                  Expanded(
                    child: !isEmpty(afroCategoryImage)
                    ? Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                          padding: EdgeInsets.all(4.0),
                        ),
                        imageUrl: afroCategoryImage,
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
                  ),

                  //Playlists
                  Expanded(
                      child: Container(
                        child: GridView.builder(
                          controller: _scrollController,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                            itemCount: myPlaylists == null
                                ? 0 : myPlaylists.length,
                            itemBuilder: (BuildContext context, int index) {
                              var item = myPlaylists[index];
                              String name = item.name;
                              String id =  item.id;
                              String image = item.image;
                              int myfollowers = item.followers;
                              return GestureDetector(
                                onTap: ()=> Navigator.of(context).pushReplacementNamed(AppRoutes.spotifyPlaylist,
                                    arguments: item),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Expanded(
                                            child: !isEmpty(image)
                                    ? Material(
                                    child: CachedNetworkImage(
                                        placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                  //width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  padding: EdgeInsets.all(20.0),
                              ),
                              imageUrl: image,
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
                              )
                                        ),
                                        Center(
                                          child: Text('$name',
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                          ),
                                        ),Text('$myfollowers followers')
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                        ),
                      )
                  ),
                ],
              )
              : Center(
                child: Text("Could not load category details, please try again later."),
              )
              ,
            ),
          ),
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
                      Text('Loading Category Data')
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
