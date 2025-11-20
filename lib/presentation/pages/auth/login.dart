import 'package:bible_compass_app/domain/providers/authproviders.dart';
import 'package:bible_compass_app/presentation/widgets/snacksbar.dart';
import 'package:bible_compass_app/presentation/widgets/themebutton.dart';
import 'package:bible_compass_app/presentation/widgets/widgets.dart';
import 'package:bible_compass_app/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/user/user.dart';
import '../../widgets/inputfield.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late UserModel user;
  late UserState userstate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    user = UserModel();
    userstate = const UserState();
  }

  void message() {
    final String message;
    final bool error;
    final sucessmessage = ref.watch(successMessageProvider);
    final errormessage = ref.watch(errorMessageProvider);
    if (errormessage.isEmpty) {
      message = sucessmessage;
      error = false;
    } else {
      message = errormessage;
      error = true;
    }
    SnackBarClass().snackBarMade(context, message, error);
  }

  final Uri _url = Uri.parse('https://bible-compass.com');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState checkState = ref.watch(loginProvider);
    final primary = Theme.of(context).colorScheme.primary;

    ref.listen(loginProvider, (prev, next) {
      if (next.error.isNotEmpty) {
        ref.read(errorMessageProvider.notifier).state = next.error.toString();
      }
      final msg = next.data['message']?.toString();
      if (msg != null && msg.isNotEmpty && msg != 'null') {
        ref.read(successMessageProvider.notifier).state = msg;
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.push("/home"),
          icon: const Icon(Icons.home),
        ),
        title: const Text("Account Login"),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CompassTop(width: 200),
                  InputField(
                    hintText: " Enter your email",
                    validation: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter something';
                      }
                      if (!validateEmail(value.trim().toLowerCase())) {
                        return 'Enter valid email';
                      }
                      return null;
                    },
                    onSaved: (value) =>
                        user = user.copyWith(email: value!.trim()),
                  ),

                  InputField(
                    obscureText: true,
                    hintText: " Enter your password",
                    validation: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter something';
                      }
                      return null;
                    },
                    onSaved: (value) =>
                        user = user.copyWith(password: value!.trim()),
                  ),
                  ThemeButton(
                    text: checkState.isLoading ? "loading..." : 'Login',
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      _formKey.currentState!.save();

                      final loginNotifier = ref.read(loginProvider.notifier);

                      await loginNotifier.performLogin(user.toJson());

                      if (!context.mounted) return;

                      message();

                      final err = ref.read(errorMessageProvider);
                      if (err.isNotEmpty) return;

                      // Save password (consider secure storage!)
                      final prefs = await ref.read(sharedPrefProvider.future);
                      await prefs.setString('password', user.password);

                      await Future.delayed(const Duration(seconds: 3));
                      if (!context.mounted) return;

                      final loginState = ref.read(loginProvider);
                      final userType =
                          loginState.data['data']?['type']?.toString() ?? '';

                      context.go(userType == 'admin' ? '/admin' : '/home');
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("You don't have an account?"),
                      AHref(
                        text: 'Sign up',
                        onPressed: () => context.go("/signup"),
                      ),
                    ],
                  ),
                  AHref(
                    text: 'Forgot Password',
                    onPressed: () => context.go("/verify"),
                  ),
                  TextButton(
                    onPressed: _launchUrl,
                    child: Text(
                      "About Us",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decorationStyle: TextDecorationStyle.solid,
                        decoration: TextDecoration.underline,
                        color: primary,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
