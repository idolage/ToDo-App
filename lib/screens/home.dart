import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud03/screens/description.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'add_task.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String uid = '';

  @override
  void initState(){
    getuid();
    super.initState();
  }
  getuid()async{
    FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    setState(() {
      uid = user.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TODO"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async{
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
        backgroundColor: Colors.purple,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('tasks').doc(uid).collection('mytasks').snapshots(),
          builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final docs = (snapshot.data! as QuerySnapshot).docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context,index){
                var time = (docs[index]['timestamp'] as Timestamp).toDate();
                return InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context)=> Description(
                          title: docs[index]['title'],
                          description: docs[index]['description'],
                        )));
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xff121211),
                    ),
                    height: 90,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin: EdgeInsets.only(left:20),
                                child: Text(
                                  docs[index]['title'],
                                  style: GoogleFonts.roboto(fontSize: 18),
                                )),
                            SizedBox(height: 5,),
                            Container(
                              margin: EdgeInsets.only(left:20),
                              child: Text(
                                DateFormat.yMd().add_jm().format(time),
                                style: GoogleFonts.roboto(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: IconButton(
                            icon: Icon(Icons.delete,),
                            onPressed: () async{
                              await FirebaseFirestore.instance
                                  .collection('tasks')
                                  .doc(uid)
                                  .collection('mytasks')
                                  .doc(docs[index]['time'])
                                  .delete();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddTask()));
        },),
    );
  }
}
