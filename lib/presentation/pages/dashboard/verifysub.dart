import 'package:bible_compass_app/domain/providers/subproviders.dart';
import 'package:bible_compass_app/presentation/widgets/themebutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VerifySub extends ConsumerWidget {
  final String rid; // fallback reference/userId (depending on your backend)
  const VerifySub(this.rid, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paystack = ref.watch(paystackProvider);
    final paystackData = paystack.data['data'];
    // Prefer reference from init response; fall back to rid
    final reference = paystackData?['data']?['reference']?.toString() ?? rid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            Navigator.of(context).pop();
            await ref
                .read(paystackProvider.notifier)
                .performGetVerifySubRequest(reference);
          },
        ),
      ),
      backgroundColor: const Color(0xFFE2E2E2),
      body: Center(
        child: ThemeButton(
          text: "Click to verify payment",
          onPressed: () async {
            await ref
                .read(paystackProvider.notifier)
                .performGetVerifySubRequest(reference);
            if (!context.mounted) return;
            context.push("/sub");
          },
        ),
      ),
    );
  }
}
