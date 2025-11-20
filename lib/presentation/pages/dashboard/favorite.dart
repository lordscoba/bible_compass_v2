import 'package:bible_compass_app/domain/models/favourites/favorite.dart';
import 'package:bible_compass_app/domain/providers/authproviders.dart';
import 'package:bible_compass_app/domain/providers/favproviders.dart';
import 'package:bible_compass_app/presentation/widgets/drawer.dart';
import 'package:bible_compass_app/presentation/widgets/header.dart';
import 'package:bible_compass_app/presentation/widgets/navigations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavouritePage extends ConsumerStatefulWidget {
  const FavouritePage({super.key});

  @override
  ConsumerState<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends ConsumerState<FavouritePage> {
  Future<FavoriteState>? _future;

  // Extract user email safely
  String _extractEmail(WidgetRef ref) {
    final auth = ref.watch(loginProvider);
    final data = auth.data['data'];
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      return (map['email'] ?? '').toString();
    }
    return '';
  }

  // Load favorites safely
  Future<void> _load() async {
    final email = _extractEmail(ref);

    if (email.isEmpty) {
      setState(() {
        _future = Future.value(
          const FavoriteState(
            isLoading: false,
            data: {'data': []},
            error: 'No user email found. Sign in and try again.',
          ),
        );
      });
      return;
    }

    final future = ref.read(favProvider.notifier).perfromGetFavsRequest(email);

    // Assign synchronously to rebuild UI
    setState(() {
      _future = future;
    });

    try {
      await future; // wait for result quietly
    } catch (e, st) {
      debugPrint('Error fetching favorites: $e\n$st');
    }
  }

  Future<void> _refresh() async {
    await _load();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0BA37F);

    return Scaffold(
      appBar: const Header(title: 'Favourites'),
      drawer: const Draw(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () => context.go('/home'),
        child: const Icon(Icons.home),
      ),
      bottomNavigationBar: const BottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: const Color(0xFFF6F8FF),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/jesus1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<FavoriteState>(
            future: _future,
            builder: (context, snapshot) {
              // Debug snapshot
              debugPrint(
                'Connection: ${snapshot.connectionState}, '
                'HasData: ${snapshot.hasData}, '
                'Error: ${snapshot.error}',
              );

              // Loading state
              if (_future == null ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CupertinoActivityIndicator(radius: 50),
                );
              }

              // Error
              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 48),
                    Center(child: Text('Error: ${snapshot.error}')),
                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                );
              }

              final state = snapshot.data ?? const FavoriteState();

              // Internal API error
              if (state.error.isNotEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 48),
                    Center(child: Text(state.error)),
                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                );
              }

              // Parse list safely
              final root = state.data;
              final raw = root['data'];
              final List<Map<String, dynamic>> items = (raw is List)
                  ? raw
                        .whereType<Map>()
                        .map((e) => Map<String, dynamic>.from(e))
                        .toList()
                  : const <Map<String, dynamic>>[];

              if (items.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 50),
                    ListTile(
                      title: Text(
                        'No data',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF0BA37F),
                        ),
                      ),
                      subtitle: Text(
                        'Try making some keywords your favorite',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Favorites list
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final it = items[index];
                  final keyword = (it['keyword'] ?? '').toString();
                  final id = (it['id'] ?? '').toString();

                  return FadeIn(
                    duration: Duration(milliseconds: 300 + (300 * index)),
                    curve: Curves.easeIn,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 10,
                      ),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF0BA37F),
                            Color.fromARGB(255, 9, 144, 99),
                            Color.fromARGB(255, 3, 47, 34),
                          ],
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          keyword,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                final email = _extractEmail(ref);
                                if (email.isEmpty) return;

                                final notifier = ref.read(favProvider.notifier);
                                await notifier.perfromUnLikeRequest(
                                  keyword,
                                  email,
                                );
                                await _load(); // reload after unlike
                              },
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (id.isNotEmpty) {
                                  context.push('/verse/$id');
                                }
                              },
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 20,
                        ),
                        enabled: true,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
