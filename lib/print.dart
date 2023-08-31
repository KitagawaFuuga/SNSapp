import 'package:chatapp/Data.dart';
import 'package:flutter/material.dart';
import 'Login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CommentsList extends StatefulWidget {
  final String name;


  CommentsList({Key? key, required this.name}) : super(key: key);
 
  @override
  _CommentsList createState() => _CommentsList();
}

class _CommentsList extends State<CommentsList> {
  late Future<List<DocumentSnapshot>> _dateList;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _dateList = _getData();
  }

  Future<List<DocumentSnapshot>> _getData() async {
    final _firestore = FirebaseFirestore.instance;
    final snapshot = await _firestore.collection('comments').orderBy('timeStamp',descending: true).get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('comments').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('データの取得に失敗しました');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('ロード中...'));
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('コメントリスト'),
            leading:IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
            ),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                Builder(builder: (context) => ListTile(
                  title: Text('コメントリスト'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )),
                Builder(builder: (context) => ListTile(
                  title: Text('ログアウト'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
              )
              ],
            ),
            ),
          body:  Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RefreshIndicator( 
                    onRefresh: () async{
                      setState(() { _dateList = _getData(); });
                    },
                    child: FutureBuilder<List<DocumentSnapshot>>(
                      future: _dateList,
                      builder: (context,snapshot){
                        if(snapshot.hasData){
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context,index){
                              Map<String, dynamic> data = snapshot.data![index].data() as Map<String, dynamic>;
                              return ListTile(
                                title: Text(data['content'] ?? ''),
                                subtitle: Column(
                                  children: [
                                    Text(data['username'] ?? 'Unknown'),
                                    Text(data['timeStamp']?.toDate().toString() ?? ''),
                                  ],
                                ),
                               trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(data['likeCount'].toString()),
                                    SizedBox(width: 8.0),
                                    ElevatedButton(
                                      child: Icon(Icons.thumb_up),
                                      onPressed: () async {
                                        final _firestore = FirebaseFirestore.instance;
                                        final docRef = _firestore.collection('comments').doc(snapshot.data![index].id);
                                        await _firestore.runTransaction((transaction) async {
                                          final snapshot = await transaction.get(docRef);
                                          final updatedData = snapshot.data()!;
                                          updatedData['likeCount'] = updatedData['likeCount'] + 1;
                                          transaction.update(docRef, updatedData);
                                        });
                                        setState(() { _dateList = _getData(); });
                                      },
                                    ),
                                  ],
                                ),
                                leading: 
                                data['image'] == null ? null :
                                Container(
                                  width: 50.0,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(data['image']),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }else if(snapshot.hasError){
                          return Text('データの取得に失敗しました');
                        }
                        return Center(child: Text('ロード中...'));
                      }
                    ) 
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.9,
                    child: ElevatedButton(
                      child: Text('コメントする'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CommentScreen(name: widget.name)),
                        );
                      },
                    ),
                ),
              ],
            ),
          )
        );
      },
    );
  }
}
