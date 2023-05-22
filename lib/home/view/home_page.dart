import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _todoRef = _firestore.collection("todo task");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          TextButton(
              onPressed: () async {
               await _todoRef.add({
                  "title": _titleController.text,
                  "description": _descriptionController.text,
                  "status": false,
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
                      // trailing: Checkbox(
                      //   value: document['completed'],
                      //   onChanged: (bool? value) async {
                      //     if (value != null) {
                      //       // Update the document
                      //       final docRef = _todoRef.doc(document.id);
                      //       await docRef.update({
                      //         'completed': value,
                      //       });
                      //     }
                      //   },
                      // ),
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
