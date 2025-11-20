import 'package:bible_compass_app/domain/models/category/category.dart';
import 'package:bible_compass_app/domain/providers/authproviders.dart';
import 'package:bible_compass_app/domain/providers/categoryproviders.dart';
import 'package:bible_compass_app/presentation/widgets/inputfield.dart';
import 'package:bible_compass_app/presentation/widgets/snacksbar.dart';
import 'package:bible_compass_app/presentation/widgets/themebutton.dart';
import 'package:bible_compass_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateCategory extends ConsumerStatefulWidget {
  final String catId;
  const UpdateCategory({required this.catId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UpdateCategoryState();
}

class _UpdateCategoryState extends ConsumerState<UpdateCategory> {
  late CategoryModel _cat;
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _items = const [
    {'value': 'true', 'label': 'True'},
    {'value': 'false', 'label': 'False'},
  ];

  @override
  void initState() {
    super.initState();
    _cat = CategoryModel();
  }

  void _message(BuildContext context) {
    final success = ref.read(successMessageProvider);
    final error = ref.read(errorMessageProvider);
    final isError = error.isNotEmpty;
    SnackBarClass().snackBarMade(context, isError ? error : success, isError);
  }

  @override
  Widget build(BuildContext context) {
    // keep listeners tiny, side-effect free
    ref.listen(categoryProvider, (prev, next) {
      if (next.error.isNotEmpty) {
        ref.read(errorMessageProvider.notifier).state = next.error.toString();
      }
      final msg = next.data['message']?.toString();
      if (msg != null && msg.isNotEmpty && msg != 'null') {
        ref.read(successMessageProvider.notifier).state = msg;
      }
    });

    final catsFuture = Future.delayed(
      const Duration(milliseconds: 250),
      () => ref
          .read(categoryProvider.notifier)
          .performGetSingleCategoryRequest(widget.catId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Category'),
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
            future: catsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final state = snapshot.data!;
                final data =
                    (state.data['data'] as Map<String, dynamic>? ?? {});

                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InputField(
                        initialValue: data['category_name']?.toString() ?? '',
                        hintText: " Enter category name",
                        validation: (value) => (value == null || value.isEmpty)
                            ? 'Enter something'
                            : null,
                        onSaved: (value) {
                          _cat = _cat.copyWith(categoryName: value ?? '');
                        },
                      ),
                      const HorizontalSpace(),
                      const Text(
                        "For Subscribers",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const HorizontalSpace(),
                      SelectField(
                        items: _items,
                        label: 'For Subscribers',
                        initialValue: data['for_subscribers'].toString(),
                        onSaved: (value) {
                          _cat = _cat.copyWith(
                            forSubscribers: value?.toLowerCase() == 'true',
                          );
                        },
                      ),
                      ThemeButton(
                        text: state.isLoading ? "loading..." : 'Update',
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          _formKey.currentState!.save();

                          final notifier = ref.read(categoryProvider.notifier);

                          // 1) Update (await)
                          await notifier.performUpdateCategoryRequest(
                            _cat.toJson(),
                            widget.catId,
                          );

                          // 2) Using context after await? Guard with context.mounted
                          if (!context.mounted) return;
                          _message(context);

                          // 3) Optionally close if success (still using context)
                          if (ref.read(errorMessageProvider).isEmpty) {
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            return; // stop here if we closed
                          }

                          // 4) Optional refresh (no context usage)
                          await notifier.performGetSingleCategoryRequest(
                            widget.catId,
                          );
                        },
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
