import 'package:bible_compass_app/domain/models/subscription/subscription.dart';
import 'package:bible_compass_app/domain/providers/subproviders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminViewSub extends ConsumerWidget {
  final String id;
  const AdminViewSub(this.id, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subFuture = Future.delayed(const Duration(milliseconds: 400), () {
      return ref.read(subProvider.notifier).performGetSingleSubRequest(id);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color(0xFFE2E2E2),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder<SubscriptionState>(
            future: subFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data =
                    snapshot.data?.data['data'] as Map<String, dynamic>? ?? {};
                return Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text("Sub type:"),
                        trailing: Text(data['type']?.toString() ?? ''),
                      ),
                      ListTile(
                        title: const Text("Sub status:"),
                        trailing: Text(data['status']?.toString() ?? ''),
                      ),
                      ListTile(
                        title: const Text("Sub amount:"),
                        trailing: Text(data['amount']?.toString() ?? ''),
                      ),
                      ListTile(
                        title: const Text("Sub Duration:"),
                        trailing: Text(data['duration']?.toString() ?? ''),
                      ),
                      ListTile(
                        title: const Text("Date created:"),
                        trailing: Text(data['date_created']?.toString() ?? ''),
                      ),
                      ListTile(
                        title: const Text("Date expiring:"),
                        trailing: Text(data['date_expiring']?.toString() ?? ''),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
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
