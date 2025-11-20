// lib/presentation/pages/admin/categories/viewcategory.dart
import 'package:bible_compass_app/domain/models/category/category.dart';
import 'package:bible_compass_app/domain/providers/categoryproviders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewCategory extends ConsumerWidget {
  final String id;
  const ViewCategory(this.id, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fut = Future.delayed(
      const Duration(milliseconds: 200),
      () => ref
          .read(categoryProvider.notifier)
          .performGetSingleCategoryRequest(id),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Category'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color(0xFFE2E2E2),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder<CategoryState>(
            future: fut,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data =
                    snapshot.data?.data['data'] as Map<String, dynamic>? ?? {};
                final List<dynamic> keywords =
                    data['keywords'] as List<dynamic>? ?? [];

                return Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text("Category Name:"),
                        trailing: Text(data['category_name']?.toString() ?? ''),
                      ),
                      ListTile(
                        title: const Text("For Subscribers:"),
                        trailing: Text(
                          (data['for_subscribers'] ?? false).toString(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const ListTile(title: Text("Keywords:")),
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: keywords.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              dense: true,
                              title: Text("${index + 1}: ${keywords[index]}"),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
