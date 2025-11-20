import 'package:bible_compass_app/domain/models/subscription/subscription.dart';
import 'package:bible_compass_app/domain/providers/subproviders.dart';
import 'package:bible_compass_app/presentation/widgets/inputfield.dart';
import 'package:bible_compass_app/presentation/widgets/snacksbar.dart';
import 'package:bible_compass_app/presentation/widgets/themebutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminUpdateSubscriprion extends ConsumerStatefulWidget {
  final String subId;
  const AdminUpdateSubscriprion(this.subId, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UpdateSubscriprionState();
}

class _UpdateSubscriprionState extends ConsumerState<AdminUpdateSubscriprion> {
  late SubscriptionModel sub;
  late SubscriptionState substate;
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _items = const [
    {'value': 'true', 'label': 'True'},
    {'value': 'false', 'label': 'False'},
  ];

  @override
  void initState() {
    super.initState();
    sub = SubscriptionModel();
    substate = const SubscriptionState();
  }

  void _message() {
    final success = ref.watch(successSubMessageProvider);
    final error = ref.watch(errorSubMessageProvider);
    final isError = error.isNotEmpty;
    SnackBarClass().snackBarMade(context, isError ? error : success, isError);
  }

  @override
  Widget build(BuildContext context) {
    // wire up notifier messages
    ref.listen(subProvider, (prev, next) {
      if (next.error.isNotEmpty) {
        ref.read(errorSubMessageProvider.notifier).state = next.error
            .toString();
      }
      final msg = next.data['message']?.toString();
      if (msg != null && msg.isNotEmpty && msg != 'null') {
        ref.read(successSubMessageProvider.notifier).state = msg;
      }
    });

    final subFuture = Future.delayed(const Duration(milliseconds: 400), () {
      return ref
          .read(subProvider.notifier)
          .performGetSingleSubRequest(widget.subId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Subscription'),
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
                final isLoading = snapshot.data?.isLoading ?? false;

                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InputField(
                        initialValue: data['type']?.toString() ?? '',
                        hintText: "Enter Sub Name",
                        validation: (v) =>
                            (v == null || v.isEmpty) ? 'Enter something' : null,
                        onSaved: (v) => sub = sub.copyWith(type: v!.trim()),
                      ),
                      InputField(
                        initialValue: data['amount']?.toString() ?? '',
                        hintText: "Enter Amount",
                        validation: (v) =>
                            (v == null || v.isEmpty) ? 'Enter something' : null,
                        onSaved: (v) =>
                            sub = sub.copyWith(amount: double.parse(v!)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Status",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SelectField(
                        items: _items,
                        label: 'Status',
                        initialValue: (data['status'] == true)
                            ? 'true'
                            : 'false',
                        onSaved: (value) {
                          sub = sub.copyWith(
                            status: (value?.toLowerCase() == 'true'),
                          );
                        },
                      ),
                      ThemeButton(
                        text: isLoading ? "loading..." : 'Update',
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          _formKey.currentState!.save();

                          final subNotifier = ref.read(subProvider.notifier);

                          await subNotifier.performUpdateSubRequest(
                            sub.toJson(),
                            widget.subId,
                          );

                          await subNotifier.performGetSingleSubRequest(
                            widget.subId,
                          );

                          if (!context.mounted) return;

                          _message();

                          final err = ref.read(errorSubMessageProvider);
                          if (err.isEmpty) {
                            await Future.delayed(
                              const Duration(milliseconds: 800),
                            );
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          }
                        },
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
