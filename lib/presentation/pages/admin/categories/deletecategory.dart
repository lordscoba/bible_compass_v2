// lib/presentation/pages/admin/categories/deletecategory.dart
import 'package:bible_compass_app/domain/providers/categoryproviders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteModalCategory extends ConsumerWidget {
  final String id;
  const DeleteModalCategory(this.id, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  "Delete Category",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.black54),
                ),
              ],
            ),
            const Text(
              "Are you sure you want to delete this?",
              style: TextStyle(color: Colors.black54),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0BA37F),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20.0,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0BA37F),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20.0,
                    ),
                  ),
                  onPressed: () async {
                    final notifier = ref.read(categoryProvider.notifier);
                    await notifier.performDeleteCategoryRequest(id);

                    if (!context.mounted) return;
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Category deleted')),
                    );

                    // Let the parent refresh; or you can trigger here if needed.
                    // await notifier.performGetCategoriesRequest();
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
