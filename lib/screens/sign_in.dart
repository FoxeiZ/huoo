import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as images;

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background

      body: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/6cfbd001ff75178285fac1db2202d54d9a71e994.png',
                      ), // Replace with your logo path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Text(
                  "Let's get you in",
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Light text for contrast
                  ),
                ),
                const SizedBox(height: 20.0),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Image(
                          image: images.AssetImage('assets/images/google.png'),
                          width: 24.0,
                          height: 24.0,
                        ),
                        SizedBox(width: 10.0),
                        Text("Continue with Google"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Image(
                          image: images.AssetImage('assets/images/fb.png'),
                          width: 24.0,
                          height: 24.0,
                        ),
                        SizedBox(width: 10.0),
                        Text("Continue with Apple"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Image(
                          image: images.AssetImage('assets/images/apple.png'),
                          width: 24.0,
                          height: 24.0,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10.0),
                        Text("Continue with Apple"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
                SizedBox(
                  width: 300, // or any width you want
                  child: Row(
                    children: const [
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('or', style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25.0),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(153, 78, 230, 250),
                              blurRadius: 10.0,
                              spreadRadius: 5.0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(6, 160, 181, 1),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text("Log in with a password"),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50.0,
                  width: 300, // or any width you want
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Don’t have an account? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xFF7BEEFF),
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 20,
                              color: Color(0xFF06A0B5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
