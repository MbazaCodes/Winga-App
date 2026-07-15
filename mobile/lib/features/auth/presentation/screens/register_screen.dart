// RegisterScreen routes to WingaRegisterScreen for type registration
// Customer registration happens via OTP — this is the Winga partner registration
export 'winga_register_screen.dart';

// Re-export with alias so router can use RegisterScreen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'winga_register_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WingaRegisterScreen();
  }
}
