import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/presentation/providers/theme_provider.dart';
import 'package:trip_planner/presentation/screens/screen_widgets/guest_view.dart';

import '../../../conf/connectivity.dart';
import '../../providers/token_provider.dart';
import '../../widgets/widgets.dart';
import '../screen_widgets/home_view.dart';

String? correo;

class TabIndex extends StateNotifier<int> {
  TabIndex() : super(0);

  void setIndex(int index) {
    state = index;
  }
}

final tabIndexProvider =
    StateNotifierProvider<TabIndex, int>((ref) => TabIndex());

final tokenChangeProvider = Provider<bool>((ref) {
  correo = ref.watch(tokenProvider);
  return correo?.isNotEmpty ?? false;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = ref.read(themeNotifierProvider).isDarkMode;
    final hasToken = ref.watch(tokenChangeProvider);
    print(correo);
    print(hasToken);
    const Map<int, Widget> myTabs = <int, Widget>{
      0: Text('VIAJE ACTUAL', style: TextStyle(fontSize: 14)),
      1: Text(
        'COMPARADOR DE VIAJES',
        style: TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      ),
    };

    final sharedValue = ref.watch(tabIndexProvider);

    return NetworkSensitive(
      child: Scaffold(
        appBar: AppBar(
          title: CustomAppBar(
            isDarkMode: isDarkMode,
            colors: colors,
            ref: ref,
            titulo: 'TRIP PLANNER',
          ),
          bottom: hasToken
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(50.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CupertinoSegmentedControl<int>(
                      children: myTabs,
                      onValueChanged: (int val) {
                        ref.read(tabIndexProvider.notifier).setIndex(val);
                      },
                      groupValue: sharedValue,
                    ),
                  ),
                )
              : null,
        ),
        body: hasToken
            ? (sharedValue == 0)
                ? const HomeView()
                : (sharedValue == 1)
                    ? const GuestView()
                    : null
            : const GuestView(),
      ),
    );
  }
}
