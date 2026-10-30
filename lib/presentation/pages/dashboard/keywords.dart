import 'package:bible_compass_app/data/remote/favoritesrequest.dart';
import 'package:bible_compass_app/data/remote/keywordrequest.dart';
import 'package:bible_compass_app/domain/providers/authproviders.dart';
import 'package:bible_compass_app/domain/providers/favproviders.dart';
import 'package:bible_compass_app/domain/providers/keywordproviders.dart';
import 'package:bible_compass_app/presentation/widgets/drawer.dart';
import 'package:bible_compass_app/presentation/widgets/header.dart';
import 'package:bible_compass_app/presentation/widgets/inputfield.dart';
import 'package:bible_compass_app/presentation/widgets/navigations.dart';
import 'package:bible_compass_app/presentation/widgets/upgrade_modal.dart';
import 'package:bible_compass_app/utils/snacksbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tuple/tuple.dart';

import '../../widgets/sign_in_check_modal.dart';

class KeywordPage extends ConsumerWidget {
  final String catId;
  const KeywordPage({required this.catId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // auth
    final isLoggedIn = ref
        .watch(authStatusProvider)
        .maybeWhen(data: (v) => v, orElse: () => false);

    final authState = ref.watch(loginProvider);
    final authData = (authState.data['data'] ?? const {}) as Map;

    // extra cached “upgrade” (falls back to server value)
    final cachedUpgrade = ref
        .watch(sharedPrefProvider)
        .maybeWhen(
          data: (p) => p.getBool('upgrade') ?? false,
          orElse: () => false,
        );
    final hasUpgrade = (authData['upgrade'] == true) || cachedUpgrade;

    // search & API
    final search = ref.watch(userKeywordSearchProvider);
    final args = Tuple2<String, String>(catId, search);
    final asyncKeywords = ref.watch(keywordApiProvider(args));

    final primary = Theme.of(context).colorScheme.primary;

    Future<void> refresh() async {
      // If you want to wait for completion:
      // ignore: unused_result
      await ref.refresh(keywordApiProvider(args).future);
    }

    return Scaffold(
      appBar: const Header(title: 'Keywords'),
      drawer: const Draw(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () => context.go("/home"),
        child: const Icon(Icons.home),
      ),
      bottomNavigationBar: const BottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: const Color(0xFFF6F8FF),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/jesus1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            SearchTextUserKeyword(catId: catId),
            Expanded(
              child: CupertinoScrollbar(
                child: RefreshIndicator(
                  onRefresh: refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: asyncKeywords.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: CupertinoActivityIndicator(radius: 28),
                          ),
                        ),
                        error: (e, _) => Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              Text('Error: $e'),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: refresh,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                        data: (map) {
                          final raw = map['data'];
                          // defensive coercion
                          final List<Map<String, dynamic>> items = (raw is List)
                              ? raw
                                    .whereType<Map>()
                                    .map<Map<String, dynamic>>(
                                      (e) => Map<String, dynamic>.from(e),
                                    )
                                    .toList()
                              : const [];

                          if (items.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48,
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'No keywords found.',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Try another search or pull to refresh.',
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: refresh,
                                      child: const Text('Refresh'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (var i = 0; i < items.length; i++)
                                _KeywordChip(
                                  index: i,
                                  item: items[i],
                                  isLoggedIn: isLoggedIn,
                                  hasUpgrade: hasUpgrade,
                                  catId: catId,
                                  email: (authData['email'] ?? '').toString(),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final int index;
  final Map<String, dynamic> item;
  final bool isLoggedIn;
  final bool hasUpgrade;
  final String catId;
  final String email;

  const _KeywordChip({
    required this.index,
    required this.item,
    required this.isLoggedIn,
    required this.hasUpgrade,
    required this.catId,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final keyword = (item['keyword'] ?? '').toString();
    final id = '${item['id']}';
    final forSubs = item['for_subscribers'] == true;

    void open() {
      if (!forSubs) {
        context.push('/verse/$id');
        return;
      }
      if (!isLoggedIn) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => const SignInCheckModal(),
        );
        return;
      }
      if (hasUpgrade) {
        context.push('/verse/$id');
      } else {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => const UserUpgradeModal(),
        );
      }
    }

    final List<Color> colors = forSubs
        ? const [
            Color.fromARGB(255, 4, 82, 64),
            Color.fromARGB(255, 4, 44, 31),
            Color.fromARGB(255, 3, 47, 34),
          ]
        : const [
            Color(0xFF0BA37F),
            Color.fromARGB(255, 9, 144, 99),
            Color.fromARGB(255, 3, 47, 34),
          ];

    return FadeIn(
      duration: Duration(milliseconds: 200 + (100 * index)),
      curve: Curves.easeIn,
      child: MyChip(
        text: keyword,
        onTap: open,
        colors: colors,
        favButton: isLoggedIn
            ? LikeButton(
                email: email,
                keyword: keyword,
                catId: catId,
                forSubscribers: forSubs,
                upgrade: hasUpgrade,
              )
            : const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.self_improvement, color: Colors.white),
              ),
      ),
    );
  }
}

class LikeButton extends ConsumerStatefulWidget {
  final String keyword;
  final bool forSubscribers;
  final bool upgrade;
  final String email;
  final String catId;
  const LikeButton({
    required this.upgrade,
    required this.forSubscribers,
    required this.catId,
    required this.keyword,
    required this.email,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<LikeButton> {
  @override
  Widget build(BuildContext context) {
    // Keep the notifier alive while this widget exists.
    ref.watch(favProvider);

    final tuple = Tuple2<String, String>(widget.keyword, widget.email);
    final asyncFav = ref.watch(favoriteApiProvider(tuple));

    Future<void> toggle() async {
      if (widget.forSubscribers && !widget.upgrade) {
        showSnackBar(
          context,
          "You are not subscribed. Please upgrade to use the like button.",
        );
        return;
      }

      // Cache the notifier before any await (safer)
      final fav = ref.read(favProvider.notifier);

      final data = (asyncFav.asData?.value['data'] ?? const {}) as Map;
      final isLiked = data['status'] == true;

      if (isLiked) {
        await fav.perfromUnLikeRequest(widget.keyword, widget.email);
      } else {
        await fav.perfromLikeRequest(widget.keyword, widget.email);
      }

      // Refresh the status provider and await completion
      // ignore: unused_result
      await ref.refresh(favoriteApiProvider(tuple).future);
    }

    return asyncFav.when(
      loading: () => const Icon(Icons.favorite_border, color: Colors.white),
      error: (_, _) => const Icon(Icons.favorite_border, color: Colors.white),
      data: (map) {
        final data = (map['data'] ?? const {}) as Map;
        final isLiked = data['status'] == true;
        return IconButton(
          onPressed: toggle,
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

class MyChip extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final Widget? favButton;
  final List<Color> colors;
  const MyChip({
    super.key,
    required this.text,
    this.onTap,
    this.favButton,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26, width: 3),
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              ?favButton,
            ],
          ),
        ),
      ),
    );
  }
}

class SearchTextUserKeyword extends ConsumerStatefulWidget {
  final String catId;
  const SearchTextUserKeyword({required this.catId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SearchTextUserKeywordState();
}

class _SearchTextUserKeywordState extends ConsumerState<SearchTextUserKeyword> {
  @override
  Widget build(BuildContext context) {
    return SearchInputField(
      onChanged: (value) {
        // Update the search term only; parent watches and rebuilds.
        ref.read(userKeywordSearchProvider.notifier).state = value.trim();
      },
    );
  }
}
