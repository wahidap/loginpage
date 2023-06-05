import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:my_app/login/login.dart';
import 'package:my_app/myproduct/view/item_page.dart';
import 'package:my_app/profile/product.dart';


class HomePage extends StatefulWidget {
  

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late CollectionReference _todoRef;
  late FirebaseStorage _storage;

  // Future <void> getImage()async {
  //   final imagePicker=ImagePicker();
  //   images=await imagePicker.pickMultiImage();
  // }

  @override
  void initState() {
    super.initState();
    _todoRef = _firestore.collection("todo task");
    _storage = FirebaseStorage.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey,
        title: Text("Todo",style: TextStyle(fontSize: 20),),
        actions: [
           IconButton(onPressed: () {
            Navigator.push(context,MaterialPageRoute(builder:(context)=>MyProducts() ));
          }, icon: Icon(Icons.person)),
          
          IconButton(onPressed: () {
            Navigator.push(context,MaterialPageRoute(builder:(context)=>Product() ));
          }, icon: Icon(Icons.shop)),
           IconButton(onPressed: () {
            Navigator.push(context,MaterialPageRoute(builder:(context)=>loginPage() ));
          }, icon: Icon(Icons.logout)),
        ],

      ),
      body: Column(
        children: [
          SizedBox(
            height: 42,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'title',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'description',
                ),
              ),
            ),
          ),


          // SizedBox(height: 50,
          //   child: TextButton(onPressed: () {
          //     getImage();
              
          //   }, child: Text("IMAGE")),


          // ),
          TextButton(
              onPressed: () async {
                final time=DateTime.now();
               await _todoRef.add({
                  "title": _titleController.text,
                  "description": _descriptionController.text,
                  "time": time,
                "userid": _auth.currentUser!.uid,
               
                });
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Task added")));

                _titleController.clear();
                _descriptionController.clear();
              },
              child: Text("Add")),



          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _todoRef
                  .where('userid', isEqualTo: _auth.currentUser!.uid) // Query the tasks by user ID
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final List<DocumentSnapshot> documents = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    final document = documents[index];
                    
                   
                    return ListTile(
                      title: Text(document['title'] as String),
                      subtitle: Text(document['description'] as String),
                     trailing: IconButton(onPressed:() {
                       showDialog(context: context, builder: (BuildContext context) {
                        final document1=documents[index];
                        return AlertDialog(
                          title: Text("edit task"),
                          content: Column(
                            children: [
                              TextField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  hintText: "title",
                                  
                                ),
                              ),
                               TextField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  hintText: "description",
                                  
                                ),
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(onPressed: () {
                                    FirebaseFirestore.instance.collection("todo task").doc(document.id).update(
                                      {"title":_titleController.text,
                                      "description":_descriptionController.text
                                      }
                                    );
                                    _titleController.clear();
                                    _descriptionController.clear();
                                    Navigator.pop(context);
                                  }, child: Text("save",style: TextStyle(fontSize: 20),)),
                                  TextButton(onPressed: () {
                                    Navigator.pop(context);
                                  }, child: Text("cancel",style: TextStyle(fontSize: 20),)),
                                ],
                              )
                            ],
                          ),
                        );
                         
                       },);

                     }, 
                      icon: Icon(Icons.edit)),

                      onLongPress: () async {
                        // Delete the document
                        final docRef = _todoRef.doc(document.id);
                        await docRef.delete();
                      },
                    );
                  },
                );
              },
            ),
          ),


        ],
      ),
    );
  }
}
