import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'game_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields!')),
      );
    } else {
      int? userId = await DatabaseHelper.instance.userLogin(email, password);
      if (userId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GamePage(userId: userId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid credentials!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image:
          AssetImage("assets/images/loginBg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'LOG IN',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900,color: Colors.white),
            ),
            Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration:InputDecoration(
                          prefixIcon: Icon(Icons.person,color: Colors.white,),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                            labelText: 'Email',labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,)),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock,color: Colors.white,),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                        ),
                            labelText: 'Password',labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,)),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: _login,
                        child: Image.asset(
                          'assets/images/loginB.png', // Replace with your image path
                          width: 150, // Adjust size as needed
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SignupPage()),
                          );
                        },
                        child: Text('Don\'t have an account? Sign up',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
