// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

// class AddQuestionScreen extends StatefulWidget {
//   @override
//   _AddQuestionScreenState createState() => _AddQuestionScreenState();
// }

// class _AddQuestionScreenState extends State<AddQuestionScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String questionType = "multipleChoice"; // Default type
//   Map<String, dynamic> questionData = {};

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Add Question")),
//       body: FutureBuilder(
//         future: FirebaseFirestore.instance.collection('questionTypes').doc(questionType).get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();

//           final fields = snapshot.data['fields'];
//           return Form(
//             key: _formKey,
//             child: ListView(
//               padding: EdgeInsets.all(16),
//               children: [
//                 for (String field in fields)
//                   TextFormField(
//                     decoration: InputDecoration(labelText: field),
//                     onChanged: (value) => questionData[field] = value,
//                   ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       FirebaseFirestore.instance.collection('questions').add(questionData);
//                     }
//                   },
//                   child: Text("Save"),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
