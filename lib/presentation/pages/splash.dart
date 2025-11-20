import 'package:bible_compass_app/domain/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/providers/authproviders.dart';
import '../../utils/checkauth.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late UserModel user;
  late AuthState userstate;

  @override
  void initState() {
    super.initState();
    user = UserModel();
    userstate = const AuthState();
  }

  final Uri _url = Uri.parse('https://snappy-fix.com');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // checking authentication
    checkAuth(ref);
    final bool isProjectAuthenticated = ref.watch(isAuthenticated);

    final primary = Theme.of(context).colorScheme.primary; // <- themed green

    return Scaffold(
      appBar: AppBar(title: const Text("Bible Compass Overview")),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/snow.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          children: [
            const SizedBox(height: 25),
            const Center(
              child: Image(
                width: 300,
                image: AssetImage("assets/images/compass-top.png"),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              width: 300,
              child: Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                "Bible Compass was built for your benefit in studying the bible and having in-depth knowledge of bible verses relating to different aspects of our life",
              ),
            ),
            const SizedBox(height: 50),

            // Uses themed primary via ElevatedButtonTheme (no need to set backgroundColor)
            ElevatedButton(
              onPressed: () async {
                if (isProjectAuthenticated) {
                  final loginState = ref.read(loginProvider);
                  final userType =
                      loginState.data['data']?['type']?.toString() ?? '';
                  await Future.delayed(const Duration(milliseconds: 800));
                  if (!context.mounted) return;
                  context.push(userType == 'admin' ? '/admin' : '/home');
                } else {
                  if (!context.mounted) return;
                  context.push('/home');
                }
              },
              child: const Text("Get Started"),
            ),

            const SizedBox(height: 40),

            // Use theme primary here too
            TextButton(
              onPressed: _launchUrl,
              child: Text(
                "Powered By Snappy-Fix Tech",
                style: TextStyle(color: primary),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
