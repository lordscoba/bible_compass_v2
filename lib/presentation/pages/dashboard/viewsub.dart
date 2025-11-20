import 'package:bible_compass_app/domain/models/subscription/subscription.dart';
import 'package:bible_compass_app/domain/providers/subproviders.dart';
import 'package:bible_compass_app/presentation/pages/dashboard/verifysub.dart';
import 'package:bible_compass_app/presentation/widgets/themebutton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewSub extends ConsumerWidget {
  final String id;
  const ViewSub(this.id, {super.key});

  // ---------- helpers ----------
  Map<String, dynamic> _asMap(dynamic raw) =>
      (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

  bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    return false;
  }

  int _asInt(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  String _asString(dynamic v) => (v ?? '').toString();

  DateTime? _asDate(dynamic v) {
    final s = _asString(v).trim();
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s).toLocal();
    } catch (_) {
      return null;
    }
  }

  Future<void> _launchUrl(Uri url, BuildContext context) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open payment page')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // small delay to avoid doing provider writes in build synchronously
    final subFuture = Future.delayed(const Duration(milliseconds: 300), () {
      return ref.read(subProvider.notifier).performGetSingleSubRequest(id);
    });

    final primary = Theme.of(context).colorScheme.primary;

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
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CupertinoActivityIndicator(radius: 50),
                );
              }

              // subscription state payload
              final root = _asMap(snapshot.data!.data);
              final data = _asMap(root['data']);

              if (data.isEmpty) {
                return const Center(child: Text('No subscription data found.'));
              }

              final dateCreate = _asDate(data['date_created']);
              final dateExpire = _asDate(data['date_expiring']);

              // Treat expired as "now is after expiry"
              final expired = (dateExpire != null)
                  ? DateTime.now().isAfter(dateExpire)
                  : false;

              final isStatus = _asBool(data['status']);
              final isProcessing = _asBool(data['processing']);
              final isFailed = _asBool(data['failed']);

              // status label + color
              late final String subStatus;
              late final Color statusColor;

              if (isStatus && !isProcessing && !isFailed && !expired) {
                subStatus = 'active';
                statusColor = Colors.green;
              } else if (!isStatus && isProcessing && !isFailed) {
                subStatus = 'processing';
                statusColor = Colors.orange;
              } else if (isFailed && !isStatus) {
                subStatus = 'failed';
                statusColor = Colors.red;
              } else if (!isProcessing && expired) {
                subStatus = 'expired';
                statusColor = Colors.red;
              } else {
                subStatus = 'unknown';
                statusColor = Colors.grey;
              }

              final amount = _asInt(data['amount']);
              final durationDays = _asInt(data['duration']);
              final type = _asString(data['type']);
              final userId = _asString(data['user_id']);
              final authUrl = _asString(data['authorization_url']);

              String formatDate(DateTime? dt) =>
                  (dt == null) ? '-' : DateFormat('yyyy-MM-dd').format(dt);

              return Padding(
                padding: const EdgeInsets.all(28.0),
                child: ListView(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(color: statusColor),
                      child: Text(
                        switch (subStatus) {
                          'processing' => 'Payment Still Processing ...',
                          'active' => 'Payment Success',
                          'failed' => 'Payment Failed',
                          'expired' => 'Payment Expired',
                          _ => 'Payment Status: Unknown',
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: const Text("Sub type:"),
                      trailing: Text(type),
                    ),
                    ListTile(
                      title: const Text("Sub status:"),
                      trailing: Text(
                        subStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text("Sub amount:"),
                      trailing: Text("$amount USD"),
                    ),
                    ListTile(
                      title: const Text("Sub duration:"),
                      trailing: Text(
                        "$durationDays day${durationDays == 1 ? '' : 's'}",
                      ),
                    ),
                    ListTile(
                      title: const Text("Date created:"),
                      trailing: Text(
                        formatDate(dateCreate),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    ListTile(
                      title: const Text("Date expiring:"),
                      trailing: Text(
                        formatDate(dateExpire),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),

                    // Continue Payment button if processing and not failed/active.
                    if (!isStatus && isProcessing && !isFailed)
                      ThemeButton(
                        text: "Continue Payment",
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => VerifySub(userId),
                          );

                          if (authUrl.isNotEmpty) {
                            await _launchUrl(Uri.parse(authUrl), context);
                          }
                        },
                      )
                    else
                      const SizedBox.shrink(),

                    const SizedBox(height: 8),
                    Text(
                      "Need help? Contact support with your reference code.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primary.withValues(alpha: .9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
