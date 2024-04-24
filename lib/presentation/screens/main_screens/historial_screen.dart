import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../conf/connectivity.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';

class HistorialScreen extends ConsumerWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
    return NetworkSensitive(
      child: Scaffold(
        appBar: AppBar(
          title: customAppBar(
            isDarkMode: isDarkMode,
            colors: colors,
            ref: ref,
            titulo: 'HISTORIAL',
          ),
        ),
      ),
    );
  }
}
