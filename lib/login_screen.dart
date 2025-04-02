// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

// class LoginScreen extends StatelessWidget {
//   // final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<void> _signIn(String email, String password) async {
//     // await _auth.signInWithEmailAndPassword(email: email, password: password);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Admin Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
//             TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
//             ElevatedButton(onPressed: () => _signIn(emailController.text, passwordController.text), child: Text("Login")),
//           ],
//         ),
//       ),
//     );
//   }
// }
