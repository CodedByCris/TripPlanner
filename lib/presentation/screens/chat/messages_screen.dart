import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/presentation/providers/theme_provider.dart';
import 'package:trip_planner/presentation/screens/chat/chat_screen.dart';

import '../../../conf/connectivity.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
    return NetworkSensitive(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Mensajes",
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 15),
                child: IconButton(
                  icon: const Icon(Icons.add_comment_outlined),
                  color: colors.primary,
                  onPressed: () {},
                ),
              ),
            ],
            centerTitle: true,
          ),
          body: Center(
            child: ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChatScreen())),
                child: const Text('Hola mundo')),
          )),
    );
  }
}
