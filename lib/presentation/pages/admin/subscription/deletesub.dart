import 'package:bible_compass_app/domain/providers/subproviders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteModalSub extends ConsumerWidget {
  final String subId;
  const DeleteModalSub(this.subId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        width: 400,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E2E2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Delete Subscription",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.black54),
                  tooltip: 'Close',
                ),
              ],
            ),
            const Text(
              "Are you sure you want to delete this subscription?",
              style: TextStyle(color: Colors.black54),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20.0,
                    ),
                  ),
                  onPressed: () async {
                    final subNotifier = ref.read(subProvider.notifier);

                    // 1) Delete
                    await subNotifier.performDeleteSubRequest(subId);

                    // 2) Refresh list
                    await subNotifier.performGetSubsRequest();

                    // 3) UI feedback with mounted check
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Subscription deleted')),
                    );

                    // 4) Small delay before close
                    await Future.delayed(const Duration(milliseconds: 600));
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
