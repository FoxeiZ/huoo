import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool _obscurePassword = true;
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus(); // Hide keyboard on tap outside
            },
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 180.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/6cfbd001ff75178285fac1db2202d54d9a71e994.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Text(
                      "Login to your account",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      width: 330,
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Colors.white70,
                              width: 1.0,
                            ),
                          ),
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.white70,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      width: 330,
                      child: TextFormField(
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Colors.white70,
                              width: 1.0,
                            ),
                          ),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.white70,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 70.0,
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked = value ?? false;
                              });
                            },
                            activeColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          const Text(
                            "Remember me",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
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
                            child: const Text("Log in"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      "Forgot your password?",
                      style: TextStyle(
                        color: Color.fromRGBO(6, 160, 181, 1),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(height: 15.0),
                    SizedBox(
                      width: 300,
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
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(30, 30, 30, 1),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/google.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(30, 30, 30, 1),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/fb.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(30, 30, 30, 1),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/apple.png',
                              color: Colors.white,
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 100.0,
                      width: 300,
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
            ),
          ),
          Positioned(
            top: 20.0,
            left: 10.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // Navigate back
              },
            ),
          ),
        ],
      ),
    );
  }
}
