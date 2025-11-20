import 'package:bible_compass_app/domain/models/subscription/subscription.dart';
import 'package:bible_compass_app/domain/providers/authproviders.dart';
import 'package:bible_compass_app/domain/providers/subproviders.dart';
import 'package:bible_compass_app/presentation/pages/dashboard/verifysub.dart';
import 'package:bible_compass_app/presentation/widgets/inputfield.dart';
import 'package:bible_compass_app/presentation/widgets/snacksbar.dart';
import 'package:bible_compass_app/presentation/widgets/themebutton.dart';
import 'package:bible_compass_app/presentation/widgets/widgets.dart';
import 'package:bible_compass_app/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateSub extends ConsumerStatefulWidget {
  const CreateSub({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateSubState();
}

class _CreateSubState extends ConsumerState<CreateSub> {
  late PaystackModel sub;
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> _asMap(dynamic raw) =>
      (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    sub = PaystackModel();
  }

  void _message() {
    final success = ref.read(successSubMessageProvider);
    final error = ref.read(errorSubMessageProvider);
    final isError = error.isNotEmpty;
    SnackBarClass().snackBarMade(context, isError ? error : success, isError);
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      if (!mounted) return;
      SnackBarClass().snackBarMade(
        context,
        'Could not open payment page',
        true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkState = ref.watch(subProvider);
    final primary = Theme.of(context).colorScheme.primary;

    // Keep listeners side-effect free and tiny
    ref.listen(subProvider, (prev, next) {
      if (next.error.isNotEmpty) {
        ref.read(errorSubMessageProvider.notifier).state = next.error
            .toString();
      }
      final msg = next.data['message']?.toString();
      if (msg != null && msg.isNotEmpty && msg != 'null') {
        ref.read(successSubMessageProvider.notifier).state = msg;
      }
    });

    // Safer auth map extraction
    final auth = ref.watch(loginProvider);
    final authData = _asMap(auth.data['data']);
    final email = (authData['email'] ?? '').toString();
    final userId = (authData['id'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activate Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color(0xFFE2E2E2),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 200, child: CompassTop()),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "You are about to make a payment of \$2 to upgrade. Tap Initialize to continue.",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withValues(alpha: .6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                InputField(
                  readOnly: true,
                  controller: TextEditingController(text: email),
                  hintText: "Enter Email",
                  validation: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter something';
                    }
                    if (!validateEmail(value.trim())) {
                      return 'Enter valid email';
                    }
                    return null;
                  },
                  onSaved: (_) {
                    sub = sub.copyWith(email: email);
                  },
                ),
                ThemeButton(
                  text: checkState.isLoading ? "loading..." : 'Initialize',
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    _formKey.currentState!.save();

                    if (userId.isEmpty) {
                      ref.read(errorSubMessageProvider.notifier).state =
                          'Missing user id';
                      _message();
                      return;
                    }

                    final paystackNotifier = ref.read(
                      paystackProvider.notifier,
                    );
                    final subNotifier = ref.read(subProvider.notifier);

                    await paystackNotifier.performPayStackInitRequest(
                      sub.toJson(),
                      userId,
                    );

                    if (!mounted) return;
                    _message();

                    final err = ref.read(errorSubMessageProvider);
                    if (err.isNotEmpty) return;

                    // Optional: wait a bit for backend to stage
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (!mounted) return;

                    // Verification dialog
                    await showDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => VerifySub(userId),
                    );

                    // Pull the auth url safely
                    final paystack = ref.read(paystackProvider);
                    final pRoot = _asMap(paystack.data['data']);
                    final pData = _asMap(pRoot['data']);
                    final authUrl = (pData['authorization_url'] ?? '')
                        .toString();
                    if (authUrl.isNotEmpty) {
                      await _launchUrl(Uri.parse(authUrl));
                    }

                    // refresh user subs
                    await subNotifier.performGetUserSubsRequests(userId);
                  },
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Payments are processed securely. If your browser didn’t open, please try again.",
                    style: TextStyle(
                      fontSize: 12,
                      color: primary.withValues(alpha: .9),
                    ),
                    textAlign: TextAlign.center,
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
