// lib/presentation/pages/dashboard/sub.dart
import 'package:bible_compass_app/domain/models/subscription/subscription.dart';
import 'package:bible_compass_app/domain/providers/authproviders.dart';
import 'package:bible_compass_app/domain/providers/subproviders.dart';
import 'package:bible_compass_app/presentation/pages/dashboard/createsub.dart';
import 'package:bible_compass_app/presentation/pages/dashboard/viewsub.dart';
import 'package:bible_compass_app/presentation/widgets/addsomething.dart';
import 'package:bible_compass_app/presentation/widgets/drawer.dart';
import 'package:bible_compass_app/presentation/widgets/header.dart';
import 'package:bible_compass_app/presentation/widgets/navigations.dart';
import 'package:bible_compass_app/presentation/widgets/tophome.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SubPage extends ConsumerWidget {
  const SubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(loginProvider);
    final authData = auth.data['data'] ?? {};
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: const Header(title: 'Subscription'),
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
        color: Colors.grey.shade200,
        width: double.infinity,
        child: SizedBox(
          height: 1200,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const TopHomeSub(),
                AddSomething(
                  text: 'Want to add Subscription',
                  icon: Icons.add_circle_outline,
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => const CreateSub(),
                    );
                  },
                ),
                if (authData['id'] != null)
                  InnerClayListCategory(userId: authData['id'].toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopHomeSub extends ConsumerWidget {
  const TopHomeSub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(loginProvider);
    final authData = auth.data['data'] ?? {};

    final statsfuture = Future.delayed(const Duration(milliseconds: 400), () {
      return ref
          .watch(subProvider.notifier)
          .performGetUserSubStats(authData['id'].toString());
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Align(
        alignment: Alignment.center,
        child: ClayContainer(
          height: 180,
          width: MediaQuery.of(context).size.width - 30,
          borderRadius: 20,
          child: FutureBuilder<SubscriptionState>(
            future: statsfuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final fulldata =
                    (snapshot.data?.data['data'] as Map?) ?? const {};
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TopHomeChildren(
                      icons: Icons.payment,
                      title: 'Total Sub',
                      total: fulldata['total_subscription']?.toString() ?? '',
                    ),
                    TopHomeChildren(
                      icons: Icons.payment,
                      title: 'Active Sub',
                      total: fulldata['active_subscription']?.toString() ?? '',
                    ),
                    TopHomeChildren(
                      icons: Icons.payment,
                      title: 'Inactive Sub',
                      total:
                          fulldata['inactive_subscription']?.toString() ?? '',
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

class InnerClayListCategory extends ConsumerWidget {
  final String userId;
  const InnerClayListCategory({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subfuture = Future.delayed(const Duration(milliseconds: 400), () {
      return ref.watch(subProvider.notifier).performGetUserSubsRequests(userId);
    });

    // Update cached 'upgrade' flag (run once when subfuture resolves)
    Future<void> updateUpgradeAuth() async {
      final prefs = await ref.read(sharedPrefProvider.future);
      subfuture.then((result) async {
        final list = (result.data['data'] as List?) ?? const [];
        bool itemExists = false;
        for (final content in list.cast<Map<dynamic, dynamic>>()) {
          final dateCreate = DateTime.parse(content['date_created']);
          final dateExpire = DateTime.parse(content['date_expiring']);
          final valid = dateExpire.isAfter(dateCreate);
          if (content['status'] &&
              !content['processing'] &&
              valid &&
              !content['failed']) {
            itemExists = true;
            break;
          }
        }
        await prefs.setBool('upgrade', itemExists);
      });
    }

    // ignore: discarded_futures
    updateUpgradeAuth();

    const double listSize = 350;
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
                  const Text("Subs", style: TextStyle(color: Colors.black54)),
                  SizedBox(
                    height: listSize - 50,
                    child: FutureBuilder<SubscriptionState>(
                      future: subfuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final fulldata =
                              (snapshot.data?.data['data'] as List?) ??
                              const [];
                          return ListView.builder(
                            itemCount: fulldata.length,
                            itemBuilder: (context, index) {
                              final item =
                                  fulldata[index] as Map<String, dynamic>;
                              final dateCreate = DateTime.parse(
                                item['date_created'],
                              );
                              final dateExpire = DateTime.parse(
                                item['date_expiring'],
                              );
                              final expire = dateCreate.isAfter(dateExpire);

                              late final String substats;
                              late final TextStyle substyle;

                              if (item['status'] &&
                                  !item['processing'] &&
                                  !expire &&
                                  !item['failed']) {
                                substats = "active";
                                substyle = const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                );
                              } else if (!item['status'] &&
                                  item['processing'] &&
                                  !item['failed']) {
                                substats =
                                    "processing..., Click to continue payment!";
                                substyle = const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                );
                              } else if (item['failed'] && !item['status']) {
                                substats = "failed";
                                substyle = const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                );
                              } else if (!item['processing'] && expire) {
                                substats = "expired";
                                substyle = const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                );
                              } else {
                                substats = "Unknown";
                                substyle = const TextStyle(
                                  color: Color.fromARGB(255, 44, 42, 42),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                );
                              }

                              return ListTile(
                                title: Text(
                                  "${index + 1}, ${item['type'].toString().toUpperCase()},  Amount: \$ ${item['amount']}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                subtitle: Text(substats, style: substyle),
                                trailing: IconButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (_) => ViewSub(item['id']),
                                    );
                                    await ref
                                        .read(paystackProvider.notifier)
                                        .performGetVerifySubRequest(
                                          item['reference'],
                                        );
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 20,
                                  ),
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
