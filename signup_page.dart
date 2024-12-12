import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _signup() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields!')),
      );
    } else if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match!')),
      );
    } else {
      bool emailExists = await DatabaseHelper.instance.emailExist(email);
      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email already registered!')),
        );
      } else {
        await DatabaseHelper.instance.insertUser({
          'username': username,
          'email': email,
          'password': password,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
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
              'SIGN UP',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900,color: Colors.white),
            ),
            Padding(
              padding: EdgeInsets.all(40.0),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                prefixIcon: Icon(Icons.person,color: Colors.white,),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
          labelText: 'Username',labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                  ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email,color: Colors.white,),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        labelText: 'Email',labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock,color: Colors.white,),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        labelText: 'Password',labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline,color: Colors.white,),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        labelText: 'Confirm Password',labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: _signup,
                    child: Image.asset(
                      'assets/images/signU.png', // Replace with your image path
                      width: 150,
                      fit: BoxFit.contain,// Adjust size as needed
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text('Already have an account? Log in',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,) ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
