import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImgViewer extends StatefulWidget {
  @override
  _ImgViewerState createState() => _ImgViewerState();
  final ds;
  ImgViewer(this.ds) : super();
}

class _ImgViewerState extends State<ImgViewer> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  _appBarSection(),
                  _imgSection(),
                  _detailSection(),
                ],
              ),
              Positioned(top: 0.0, child: _appBarSection()),
            ],
          ),
        ),
      ),
    );
  }

  // PhotoView(
  //   imageProvider: AssetImage(),
  // )

  Widget _appBarSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            splashColor: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgSection() {
    return Expanded(
      child: Container(
        child: Hero(
            tag: widget.ds["postId"] != null
                ? "${widget.ds["postId"]}"
                : "${widget.ds["imgMsgId"]}",
            child: PhotoView(
                imageProvider: NetworkImage(widget.ds["postImg"] != null
                    ? widget.ds["postImg"]
                    : widget.ds["imgUrl"]))),
      ),
    );
  }

  Widget _detailSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                          child: widget.ds["postStatus"] != null
                              ? Text(
                                  widget.ds["postStatus"],
                                  style: TextStyle(
                                    fontFamily: "Mont",
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none,
                                    color: Colors.black,
                                  ),
                                )
                              : SizedBox(
                                  height: 0.0,
                                ))),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        ClipOval(
                          child: Container(
                            height: 50.0,
                            width: 50.0,
                            child: FadeInImage.assetNetwork(
                              image: widget.ds["postUploaderProfileImg"],
                              placeholder: "images/person.png",
                              fadeInDuration: Duration(seconds: 3),
                              fadeOutDuration: Duration(seconds: 3),
                              fit: BoxFit.cover,
                              placeholderScale: 1.0,
                            ),
                          ),
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          widget.ds["postUploaderName"],
                          style: TextStyle(
                            fontFamily: "Mont",
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                    // StreamBuilder(
                    //   stream: Firestore.instance
                    //       .collection("Triankle")
                    //       .document("All posts")
                    //       .collection("All posts")
                    //       .document(widget.ds["postId"])
                    //       .collection("Likers")
                    //       .snapshots(),
                    //   builder:
                    //       (BuildContext context, AsyncSnapshot snapshot) {
                    //     if (snapshot.hasData) {
                    //       return Row(
                    //         mainAxisAlignment: MainAxisAlignment.start,
                    //         children: <Widget>[
                    //           Text(
                    //             snapshot.data.documents.length.toString(),
                    //             style: TextStyle(
                    //               fontFamily: "Mont",
                    //               fontSize: 12.0,
                    //               fontWeight: FontWeight.w400,
                    //               decoration: TextDecoration.none,
                    //               color: Colors.black,
                    //             ),
                    //           ),
                    //           SizedBox(width: 5.0),
                    //           Icon(Icons.star, color: Colors.deepOrange)
                    //         ],
                    //       );
                    //     } else if (snapshot.hasError) {
                    //       return Text(snapshot.error.toString());
                    //     }
                    //     return SizedBox();
                    //   },
                    // )
                  ],
                ),
              ),
            ),
          ],
        )
        // : StreamBuilder(
        //     stream: Firestore.instance
        //         .collection("Triankle")
        //         .document("Users")
        //         .collection("Users info")
        //         .document(widget.ds["senderId"])
        //         .snapshots(),
        //     builder: (BuildContext context, AsyncSnapshot snapshot) {
        //       if (snapshot.hasData) {
        //         return Column(
        //           children: <Widget>[
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.start,
        //               children: <Widget>[
        //                 Expanded(
        //                   child: Padding(
        //                       padding: const EdgeInsets.all(10.0),
        //                       child: Container(
        //                           child: widget.ds["imgMsg"] != null
        //                               ? Text(
        //                                   widget.ds["imgMsg"],
        //                                   style: TextStyle(
        //                                     fontFamily: "Mont",
        //                                     fontSize: 14.0,
        //                                     fontWeight: FontWeight.w400,
        //                                     decoration: TextDecoration.none,
        //                                     color: Colors.black,
        //                                   ),
        //                                 )
        //                               : SizedBox(
        //                                   height: 0.0,
        //                                 ))),
        //                 ),
        //               ],
        //             ),
        //             Container(
        //               width: MediaQuery.of(context).size.width,
        //               child: Padding(
        //                 padding: const EdgeInsets.all(10.0),
        //                 child: Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   children: <Widget>[
        //                     Row(
        //                       mainAxisAlignment: MainAxisAlignment.start,
        //                       children: <Widget>[
        //                         ClipOval(
        //                           child: Container(
        //                             height: 50.0,
        //                             width: 50.0,
        //                             child: Image.network(
        //                               snapshot.data["userProfileImg"],
        //                               fit: BoxFit.cover,
        //                             ),
        //                           ),
        //                         ),
        //                         SizedBox(width: 5.0),
        //                         Text(
        //                           snapshot.data["userName"],
        //                           style: TextStyle(
        //                             fontFamily: "Mont",
        //                             fontSize: 16.0,
        //                             fontWeight: FontWeight.w600,
        //                             decoration: TextDecoration.none,
        //                             color: Colors.black,
        //                           ),
        //                         )
        //                       ],
        //                     ),
        //                     SizedBox()
        //                   ],
        //                 ),
        //               ),
        //             ),
        //           ],
        //         );
        //       } else if (snapshot.hasError) {
        //         return Text(snapshot.error.toString());
        //       }
        //       return Center(child: CircularProgressIndicator());
        //     },
        //   )
        // : Column(
        //     children: <Widget>[
        //       Row(
        //         children: <Widget>[
        //           Expanded(
        //             child: Padding(
        //               padding: const EdgeInsets.all(10.0),
        //               child: Text(
        //                 widget.ds["imgMsg"],
        //                 style: TextStyle(
        //                   fontFamily: "Mont",
        //                   fontSize: 14.0,
        //                   fontWeight: FontWeight.w400,
        //                   decoration: TextDecoration.none,
        //                   color: Colors.black,
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   )
        );
  }
}
