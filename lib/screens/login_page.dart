import 'package:flutter/material.dart';
import 'package:flutter_juna/services/api_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ApiService api = ApiService();

  bool isloading = false;

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email dan password wajib diisi"),
        ),
      );
      return;
    }

    setState(() {
      isloading = true;
    });

    final token = await api.login(
      emailController.text.trim(),
      passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      isloading = false;
    });

    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login gagal"),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              children: [
                const Icon(
                  Icons.shopping_bag,
                  size: 50,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 11),
                const Text(
                  "Application CRUD",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 41),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 41),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 31),
                SizedBox(
                  width: double.infinity,
                  height: 51,
                  child: ElevatedButton(
                    onPressed: isloading ? null : login,
                    child: isloading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("LOGIN"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}