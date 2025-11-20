import 'package:bible_compass_app/domain/providers/authproviders.dart';
import 'package:bible_compass_app/domain/providers/categoryproviders.dart';
import 'package:bible_compass_app/domain/providers/keywordproviders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class Draw extends ConsumerStatefulWidget {
  const Draw({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DrawState();
}

class _DrawState extends ConsumerState<Draw> {
  final Uri _urlRateUs = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.snappyfix.bible_compass_app',
  );
  final Uri _urlTermsOfService = Uri.parse(
    'https://www.bible-compass.com/terms',
  );
  final Uri _urlPrivacyPolicy = Uri.parse(
    'https://www.bible-compass.com/privacy',
  );
  final Uri _urlAcknowledgement = Uri.parse(
    'https://www.bible-compass.com/acknowledgement',
  );

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProjectAuthenticated = ref
        .watch(authStatusProvider)
        .maybeWhen(data: (v) => v, orElse: () => false);

    return Drawer(
      width: 300,
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black45),
            child: Image(
              width: 50,
              image: AssetImage("assets/images/compass-top.png"),
            ),
          ),
          DrawerPart(
            text: 'Home',
            icon: Icons.home,
            onTap: () => context.push('/home'),
          ),
          DrawerPart(
            text: 'Categories',
            icon: Icons.category_outlined,
            onTap: () => context.push('/category'),
          ),
          DrawerPart(
            text: 'Upgrade Plan',
            icon: Icons.payment,
            onTap: () => context.push('/sub'),
          ),
          DrawerPart(
            text: 'favorite',
            icon: Icons.favorite_border,
            onTap: () => context.push('/favorite'),
          ),
          DrawerPart(
            text: 'profile',
            icon: Icons.account_circle_outlined,
            onTap: () => context.push('/profile'),
          ),
          DrawerPart(
            text: 'Rate Us',
            icon: Icons.rate_review_outlined,
            onTap: () async => _launchUrl(_urlRateUs),
          ),
          DrawerPart(
            text: 'Faq',
            icon: Icons.question_answer_outlined,
            onTap: () => context.push('/faq'),
          ),
          isProjectAuthenticated
              ? DrawerPart(
                  icon: Icons.logout_outlined,
                  text: 'logout',
                  onTap: () async {
                    // Clear app state & logout
                    ref.invalidate(categoryProvider);
                    ref.invalidate(keywordProvider);
                    await ref.read(loginProvider.notifier).performLogout();
                    if (!context.mounted) return;
                    context.go('/login');
                  },
                )
              : DrawerPart(
                  icon: Icons.login,
                  text: 'Log in',
                  onTap: () => context.push("/login"),
                ),
          const SizedBox(height: 40),
          DrawerPart(
            text: 'Acknowledgements',
            icon: Icons.picture_as_pdf_outlined,
            onTap: () async => _launchUrl(_urlAcknowledgement),
          ),
          DrawerPart(
            text: 'Privacy Policy',
            icon: Icons.picture_as_pdf_outlined,
            onTap: () async => _launchUrl(_urlPrivacyPolicy),
          ),
          DrawerPart(
            text: 'Terms of Services',
            icon: Icons.picture_as_pdf_outlined,
            onTap: () async => _launchUrl(_urlTermsOfService),
          ),
        ],
      ),
    );
  }
}

class AdminDraw extends ConsumerWidget {
  const AdminDraw({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      width: 300,
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black45),
            child: Image(
              width: 50,
              image: AssetImage("assets/images/compass-top.png"),
            ),
          ),
          DrawerPart(
            text: 'Home',
            icon: Icons.home,
            onTap: () => context.go('/admin'),
          ),
          DrawerPart(
            text: 'Users',
            icon: Icons.account_circle,
            onTap: () => context.push('/admin/users'),
          ),
          DrawerPart(
            text: 'Categories',
            icon: Icons.category_outlined,
            onTap: () => context.push('/admin/categories'),
          ),
          DrawerPart(
            text: 'Subscription',
            icon: Icons.money,
            onTap: () => context.push('/admin/subscription'),
          ),
          DrawerPart(
            icon: Icons.logout_outlined,
            text: 'logout',
            onTap: () async {
              await ref.read(loginProvider.notifier).performLogout();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class DrawerPart extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final IconData? icon;

  const DrawerPart({super.key, required this.text, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      // Remove the big left-only padding; let ListTile handle spacing
      // contentPadding: const EdgeInsets.only(left: 50),
      leading: Icon(icon, color: Colors.black45, size: 24),
      title: Text(
        text, // ← put the label here
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      dense: true, // a bit tighter vertically
      visualDensity: VisualDensity.compact, // trims extra space
      // Remove subtitle entirely to keep it a 1-line tile
    );
  }
}

// class DrawerPart extends StatelessWidget {
//   final String text;
//   final void Function()? onTap;
//   final IconData? icon;
//   const DrawerPart({super.key, required this.text, this.onTap, this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: onTap,
//       contentPadding: const EdgeInsets.only(left: 50),
//       leading: Icon(icon, color: Colors.black45),
//       title: const Text(
//         '',
//         // This is intentionally blank to avoid hard rebuilding; replace below:
//       ),
//       // Better text (keeps style in one place)
//       subtitle: Text(
//         text,
//         style: const TextStyle(color: Colors.black54, fontSize: 19),
//       ),
//     );
//   }
// }
