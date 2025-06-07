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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/6cfbd001ff75178285fac1db2202d54d9a71e994.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      "Login to your account",
                      style: theme.textTheme.headlineLarge, // Use headlineLarge from the theme
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: 330,
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: theme.colorScheme.onSurface,
                              width: 1.0,
                            ),
                          ),
                          labelText: 'Email',
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: theme.colorScheme.onSurface,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    SizedBox(
                      width: 330,
                      child: TextFormField(
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: theme.colorScheme.onSurface,
                              width: 1.0,
                            ),
                          ),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: theme.colorScheme.onSurface,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: theme.colorScheme.onSurface,
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
                        style: TextStyle(color: theme.colorScheme.onSurface),
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
                            activeColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          Text(
                            "Remember me",
                            style: TextStyle(color: theme.colorScheme.onSurface),
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
                                  color: theme.colorScheme.primary.withOpacity(0.6),
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
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
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
                        color: theme.colorScheme.secondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      width: 300,
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(thickness: 1, color: theme.colorScheme.onSurface),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('or', style: TextStyle(color: theme.colorScheme.onSurface)),
                          ),
                          Expanded(
                            child: Divider(thickness: 1, color: theme.colorScheme.onSurface),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialButton('assets/images/google.png', theme),
                        _buildSocialButton('assets/images/fb.png', theme),
                        _buildSocialButton('assets/images/apple.png', theme),
                      ],
                    ),
                    const SizedBox(height: 100.0),
                    SizedBox(
                      width: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don’t have an account? ",
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
                          Text(
                            "Sign Up",
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 20,
                                  color: theme.colorScheme.primary,
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
              icon: const Icon(Icons.arrow_back),
              color: theme.colorScheme.onSurface,
              onPressed: () {
                Navigator.pop(context); // Navigate back
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String assetPath, ThemeData theme) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.onSurface,
          width: 1.0,
        ),
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: 30,
          height: 30,
          color: assetPath.contains('apple') ? Colors.white : null, // Apply white color for Apple logo
        ),
      ),
    );
  }
}
