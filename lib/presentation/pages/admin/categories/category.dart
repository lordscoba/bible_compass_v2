import 'package:bible_compass_app/domain/models/category/category.dart';
import 'package:bible_compass_app/domain/providers/adminusersproviders.dart';
import 'package:bible_compass_app/domain/providers/categoryproviders.dart';
import 'package:bible_compass_app/presentation/pages/admin/categories/createcategory.dart';
import 'package:bible_compass_app/presentation/pages/admin/categories/deletecategory.dart';
import 'package:bible_compass_app/presentation/pages/admin/categories/updatecategory.dart';
import 'package:bible_compass_app/presentation/pages/admin/categories/viewcategory.dart';
import 'package:bible_compass_app/presentation/widgets/addsomething.dart';
import 'package:bible_compass_app/presentation/widgets/drawer.dart';
import 'package:bible_compass_app/presentation/widgets/header.dart';
import 'package:bible_compass_app/presentation/widgets/inputfield.dart';
import 'package:bible_compass_app/presentation/widgets/navigations.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/tophome.dart';

class AdminCategory extends StatelessWidget {
  const AdminCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminHeader(title: 'Admin Categories'),
      drawer: const AdminDraw(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0BA37F),
        onPressed: () {
          context.go('/admin');
        },
        child: const Icon(Icons.home),
      ),
      bottomNavigationBar: const AdminBottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: const Color(0xFFE2E2E2),
      body: SizedBox(
        height: 1200,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const TopHomeCategory(),
              AddSomething(
                text: 'Want to add Category?',
                icon: Icons.add_circle_outline,
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return const CreateCategory();
                    },
                  );
                },
              ),
              const InnerClayListCategory(),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/presentation/pages/admin/categories/category.dart
// (Only showing changed widgets)

class TopHomeCategory extends ConsumerStatefulWidget {
  const TopHomeCategory({super.key});
  @override
  ConsumerState<TopHomeCategory> createState() => _TopHomeCategoryState();
}

class _TopHomeCategoryState extends ConsumerState<TopHomeCategory> {
  late final Future<CategoryState> _statsFuture;
  @override
  void initState() {
    super.initState();
    _statsFuture = ref
        .read(categoryProvider.notifier)
        .performGetCategoryStats();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Align(
        alignment: Alignment.center,
        child: ClayContainer(
          height: 180,
          width: MediaQuery.of(context).size.width - 30,
          borderRadius: 20,
          child: FutureBuilder<CategoryState>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data =
                    snapshot.data?.data['data'] as Map<String, dynamic>? ?? {};
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TopHomeChildren(
                      icons: Icons.category_rounded,
                      title: 'Total cat',
                      total: (data['total_category'] ?? '').toString(),
                    ),
                    TopHomeChildren(
                      icons: Icons.category_outlined,
                      title: 'Subed cat',
                      total: (data['subscribers_category'] ?? '').toString(),
                    ),
                    TopHomeChildren(
                      icons: Icons.category_outlined,
                      title: 'Total keywords',
                      total: (data['total_keywords'] ?? '').toString(),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }
}

class InnerClayListCategory extends ConsumerStatefulWidget {
  const InnerClayListCategory({super.key});
  @override
  ConsumerState<InnerClayListCategory> createState() =>
      _InnerClayListCategoryState();
}

class _InnerClayListCategoryState extends ConsumerState<InnerClayListCategory> {
  late Future<CategoryState> _catsFuture;

  @override
  void initState() {
    super.initState();
    _catsFuture = ref
        .read(categoryProvider.notifier)
        .performGetCategoriesRequest(search: ref.read(searchText));
  }

  Future<void> _refresh() async {
    _catsFuture = ref
        .read(categoryProvider.notifier)
        .performGetCategoriesRequest(search: ref.read(searchText));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const double listSize = 450;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Align(
        alignment: Alignment.center,
        child: ClayContainer(
          height: listSize,
          width: MediaQuery.of(context).size.width - 30,
          borderRadius: 20,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    "Categories",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SearchTextCategory(),
                  SizedBox(
                    height: listSize - 50,
                    child: FutureBuilder<CategoryState>(
                      future: _catsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final List<dynamic> fulldata =
                              snapshot.data?.data['data'] as List<dynamic>? ??
                              [];
                          return ListView.builder(
                            itemCount: fulldata.length,
                            itemBuilder: (context, index) {
                              final item =
                                  fulldata[index] as Map<String, dynamic>;
                              return ListTile(
                                title: Text(item['category_name'].toString()),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: "update",
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (_) => UpdateCategory(
                                            catId: item['id'].toString(),
                                          ),
                                        ).then((_) => _refresh());
                                      },
                                      icon: const Icon(Icons.edit, size: 20),
                                    ),
                                    IconButton(
                                      tooltip: "delete",
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (_) => DeleteModalCategory(
                                            item['id'].toString(),
                                          ),
                                        );
                                        if (!mounted) return;
                                        await _refresh();
                                      },
                                      icon: const Icon(Icons.delete, size: 20),
                                    ),
                                    IconButton(
                                      tooltip: "show",
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (_) => ViewCategory(
                                            item['id'].toString(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 20,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: "show keywords",
                                      onPressed: () => context.push(
                                        "/admin/keywords/${item['id']}",
                                      ),
                                      icon: const Icon(
                                        Icons.list_alt,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return const Center(
                            child: CupertinoActivityIndicator(radius: 50),
                          );
                        }
                      },
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

class SearchTextCategory extends ConsumerWidget {
  const SearchTextCategory({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchInputField(
      onChanged: (value) async {
        ref.read(searchText.notifier).state = value;
        // Let the surrounding widget decide how to refresh (keeps this pure)
        // If you prefer immediate fetch here:
        await ref
            .read(categoryProvider.notifier)
            .performGetCategoriesRequest(search: value);
      },
    );
  }
}
