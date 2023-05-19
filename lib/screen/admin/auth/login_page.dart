// ignore_for_file: use_build_context_synchronousl
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//pages
import 'package:flutter_application_1/route_names.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _controller;
  bool _rememberMe = false;
  late Box box1;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    createBox();
    _controller = AnimationController(vsync: this);
  }

  void createBox() async {
    box1 = await Hive.openBox('logindata');
    getdata();
  }

  void getdata() {
    if (box1.get('email') != null) {
      _emailController.text = box1.get('email');
    }
    if (box1.get('password') != null) {
      _passwordController.text = box1.get('password');
    }

    setState(() {
      _rememberMe = _emailController.text.isNotEmpty ||
          _passwordController.text.isNotEmpty;
    });
  }

  void login() {
    if (_rememberMe) {
      box1.put('email', _emailController.text);
      box1.put('password', _passwordController.text);
    } else {
      box1.delete('email');
      box1.delete('password');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await writeSecureData('email', _emailController.text);
      await writeSecureData('password', _passwordController.text);
      context.goNamed(RouteNames.loading, queryParameters: {
        "fn": "login",
        "route": "login",
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
        title: const Text('Login'),
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
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  const Text('Remember me'),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _submitForm();
                  login();
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  context.goNamed(RouteNames.register);
                },
                child: const Text('Sign up'),
              ),
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
        return 'Please enter your email';
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
      return null;
    },
  );
}
