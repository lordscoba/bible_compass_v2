import 'package:bible_compass_app/domain/models/subscription/subscription.dart';
import 'package:bible_compass_app/domain/providers/adminusersproviders.dart';
import 'package:bible_compass_app/domain/providers/subproviders.dart';
import 'package:bible_compass_app/presentation/pages/admin/subscription/deletesub.dart';
import 'package:bible_compass_app/presentation/pages/admin/subscription/updatesubscirption.dart';
import 'package:bible_compass_app/presentation/pages/admin/subscription/viewsubscription.dart';
import 'package:bible_compass_app/presentation/widgets/drawer.dart';
import 'package:bible_compass_app/presentation/widgets/header.dart';
import 'package:bible_compass_app/presentation/widgets/inputfield.dart';
import 'package:bible_compass_app/presentation/widgets/navigations.dart';
import 'package:bible_compass_app/presentation/widgets/tophome.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminSubscription extends StatelessWidget {
  const AdminSubscription({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: const AdminHeader(title: 'Admin • Subscriptions'),
      drawer: const AdminDraw(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () => context.go('/admin'),
        child: const Icon(Icons.home),
      ),
      bottomNavigationBar: const AdminBottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: const Color(0xFFE2E2E2),
      body: const SizedBox(
        height: 1200,
        child: SingleChildScrollView(
          child: Column(
            children: [TopHomeSubscription(), InnerClayListSubscription()],
          ),
        ),
      ),
    );
  }
}

class TopHomeSubscription extends ConsumerWidget {
  const TopHomeSubscription({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsFuture = Future.delayed(const Duration(milliseconds: 100), () {
      return ref.watch(subProvider.notifier).performGetSubStats();
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
            future: statsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data =
                    snapshot.data?.data['data'] as Map<String, dynamic>? ?? {};
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TopHomeChildren(
                      icons: Icons.category_rounded,
                      title: 'Total',
                      total: data['total_subscription']?.toString() ?? '0',
                    ),
                    TopHomeChildren(
                      icons: Icons.check_circle_outline,
                      title: 'Active',
                      total: data['active_subscription']?.toString() ?? '0',
                    ),
                    TopHomeChildren(
                      icons: Icons.remove_circle_outline,
                      title: 'Inactive',
                      total: data['inactive_subscription']?.toString() ?? '0',
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

class InnerClayListSubscription extends ConsumerWidget {
  const InnerClayListSubscription({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(searchText);
    final subFuture = Future.delayed(const Duration(milliseconds: 10), () {
      return ref
          .watch(subProvider.notifier)
          .performGetSubsRequest(search: search);
    });

    const double listSize = 500;
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
                    "Subscriptions",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SearchTextSub(),
                  SizedBox(
                    height: listSize - 50,
                    child: FutureBuilder<SubscriptionState>(
                      future: subFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final List<dynamic> list =
                              snapshot.data?.data['data'] as List<dynamic>? ??
                              [];
                          return ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final item = list[index] as Map<String, dynamic>;
                              return ListTile(
                                title: Text(item['type']?.toString() ?? ''),
                                subtitle: Text(
                                  (item['amount'] != null)
                                      ? item['amount'].toString()
                                      : '',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: "Edit",
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (_) =>
                                              AdminUpdateSubscriprion(
                                                item['id'].toString(),
                                              ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      tooltip: "Delete",
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (_) => DeleteModalSub(
                                            item['id'].toString(),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      tooltip: "Show",
                                      icon: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (_) => AdminViewSub(
                                            item['id'].toString(),
                                          ),
                                        );
                                      },
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

class SearchTextSub extends ConsumerWidget {
  const SearchTextSub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchInputField(
      onChanged: (value) {
        // Update search state; the FutureBuilder re-runs thanks to `ref.watch(searchText)`
        ref.read(searchText.notifier).state = value;
      },
    );
  }
}
