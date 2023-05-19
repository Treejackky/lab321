// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//pages
import 'package:flutter_application_1/route_names.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late AnimationController _controller;

  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await writeSecureData('email', _emailController.text);
      await writeSecureData('password', _passwordController.text);
      context.goNamed(RouteNames.loading, queryParameters: {
        "fn": "create",
        "route": "register",
      });
    }
  }

  Future<void> writeSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed(RouteNames.login);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _Email(_emailController),
              const SizedBox(height: 20),
              _Password(_passwordController),
              const SizedBox(height: 20),
              _CheckPassword(_confirmPasswordController, _passwordController),
              ElevatedButton(
                onPressed: () {
                  _submitForm();
                },
                child: const Text('Register'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _Email(TextEditingController emailController) {
  return TextFormField(
    controller: emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: const InputDecoration(
      labelText: 'Email',
      prefixIcon: Icon(Icons.email),
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value!.isEmpty) {
        return 'Please enter your password';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters long';
      }
      return null;
    },
  );
}

Widget _Password(TextEditingController passwordController) {
  return TextFormField(
    controller: passwordController,
    obscureText: true,
    decoration: const InputDecoration(
      labelText: 'Password',
      prefixIcon: Icon(Icons.lock),
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value!.isEmpty) {
        return 'Please enter your password';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters long';
      }
      return null;
    },
  );
}

Widget _CheckPassword(TextEditingController confirmPasswordController,
    TextEditingController passwordController) {
  return TextFormField(
    controller: confirmPasswordController,
    obscureText: true,
    decoration: const InputDecoration(
      labelText: 'Password',
      prefixIcon: Icon(Icons.lock),
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value!.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != passwordController.text) {
        return 'Passwords do not match';
      }
      return null;
    },
  );
}
