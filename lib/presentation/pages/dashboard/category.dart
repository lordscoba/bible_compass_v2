// lib/presentation/pages/dashboard/category.dart
import 'package:bible_compass_app/domain/models/category/category.dart';
import 'package:bible_compass_app/domain/providers/authproviders.dart';
import 'package:bible_compass_app/domain/providers/categoryproviders.dart';
import 'package:bible_compass_app/presentation/widgets/drawer.dart';
import 'package:bible_compass_app/presentation/widgets/header.dart';
import 'package:bible_compass_app/presentation/widgets/navigations.dart';
import 'package:bible_compass_app/presentation/widgets/sign_in_check_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/upgrade_modal.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});
  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  @override
  void initState() {
    super.initState();

    // Run AFTER first frame => safe provider write
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetch(); // first load

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Welcome to Category page'),
          content: const Text('The dark green categories are premium.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _fetch() async {
    // Use your existing notifier method name
    await ref
        .read(categoryProvider.notifier)
        .performGetCategoriesRequest(); // <— calls API
  }

  // Defensive coercion to a list of maps
  List<Map<String, dynamic>> _asItemList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  void _goOrGate({
    required bool requiresSub,
    required bool isLoggedIn,
    required bool hasUpgrade,
    required String categoryId,
  }) {
    if (!requiresSub || (isLoggedIn && hasUpgrade)) {
      context.push("/keywords/$categoryId");
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          isLoggedIn ? const UserUpgradeModal() : const SignInCheckModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(isAuthenticated);
    final auth = ref.watch(loginProvider);
    final hasUpgrade =
        ((auth.data['data'] ?? const {}) as Map)['upgrade'] == true;

    final CategoryState state = ref.watch(categoryProvider);
    final items = _asItemList(state.data['data']);

    return Scaffold(
      appBar: const Header(title: 'Categories'),
      drawer: const Draw(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0BA37F),
        onPressed: () => context.go("/home"),
        child: const Icon(Icons.home),
      ),
      bottomNavigationBar: const BottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: const Color(0xFFF6F8FF),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/holy.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Builder(
            builder: (context) {
              if (state.isLoading && items.isEmpty) {
                return const Center(
                  child: CupertinoActivityIndicator(
                    radius: 50,
                    color: Colors.white,
                  ),
                );
              }

              if (state.error.isNotEmpty && items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: ${state.error}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetch,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 300,
                        width: 300,
                        color: Colors.white,
                        child: const Center(
                          child: Text(
                            "Switch on your internet",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetch,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }

              // Pull-to-refresh + list
              return RefreshIndicator(
                onRefresh: _fetch,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final requiresSub = item['for_subscribers'] == true;
                    final catId = '${item['id']}';
                    final name = (item['category_name'] ?? '').toString();

                    final gradient = requiresSub
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF045240),
                              Color(0xFF042C1F),
                              Color(0xFF032F22),
                            ],
                          )
                        : const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF0BA37F),
                              Color(0xFF099063),
                              Color(0xFF032F22),
                            ],
                          );

                    return FadeIn(
                      duration: Duration(milliseconds: 300 + (400 * index)),
                      curve: Curves.slowMiddle,
                      child: GestureDetector(
                        onTap: () => _goOrGate(
                          requiresSub: requiresSub,
                          isLoggedIn: isLoggedIn,
                          hasUpgrade: hasUpgrade,
                          categoryId: catId,
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                            gradient: gradient,
                          ),
                          child: ListTile(
                            title: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 26,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
