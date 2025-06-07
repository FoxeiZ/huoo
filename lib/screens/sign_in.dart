import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as images;

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Use background color from the theme
      body: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: theme.colorScheme.onSurface, // Use text color from the theme
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
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  "Let's get you in",
                  style: theme.textTheme.headlineLarge, // Use headline1 from the theme
                ),
                const SizedBox(height: 20.0),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface, // Use surface color
                      foregroundColor: theme.colorScheme.onSurface, // Use text color on surface
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
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
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
                        Text("Continue with Facebook"),
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
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
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
                        child: const Text("Log in with a password"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50.0),
                SizedBox(
                  height: 50.0,
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
        ],
      ),
    );
  }
}
