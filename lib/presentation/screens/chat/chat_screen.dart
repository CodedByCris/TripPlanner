import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_planner/presentation/screens/chat/add_member_screen.dart';

import '../../providers/messages_provider.dart';
import '../../providers/theme_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final bool esgrupo;
  final String imagen;
  final String nombre;
  final String idGrupo;
  final String correo;
  const ChatScreen(
      {super.key,
      required this.esgrupo,
      required this.idGrupo,
      required this.correo,
      required this.imagen,
      required this.nombre});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ImagePicker _picker = ImagePicker();

  final ScrollController _scrollController = ScrollController();
  String? selectedMessage;

  @override
  void initState() {
    super.initState();
    ref
        .read(messageProvider(widget.idGrupo).notifier)
        .fetchData(widget.idGrupo);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<String> uploadImage(XFile image) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('images')
        .child(DateTime.now().toString());
    await ref.putFile(File(image.path));
    return await ref.getDownloadURL();
  }

  Future<void> openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final imageUrl = await uploadImage(photo);
      ref
          .read(messageProvider(widget.idGrupo).notifier)
          .insertMessage(imageUrl, widget.correo, widget.idGrupo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
    final messages = ref.watch(messageProvider(widget.idGrupo));

    return Scaffold(
      appBar: AppBar(
        actions: widget.esgrupo
            ? <Widget>[
                PopupMenuButton<String>(
                  onSelected: (String result) {
                    // handle your logic here to add a new person to the group
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddMemberScreen(
                              idGrupo: widget.idGrupo,
                            ), // Pass the idGrupo to ChatScreen
                          ),
                        );
                      },
                      value: 'Nuevo',
                      child: const Text('Añadir miembro'),
                    ),
                  ],
                ),
              ]
            : null,
        title: Row(
          children: [
            const SizedBox(width: 8.0),
            CircleAvatar(
              backgroundImage: widget.imagen.compareTo("null") != 0
                  ? CachedNetworkImageProvider(widget.imagen)
                  : null,
              child: widget.imagen.compareTo("null") == 0
                  ? const Icon(Icons.person_2)
                  : null,
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Text(
                widget.nombre,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16, // Adjust this value as needed
                  color: isDarkMode
                      ? colors.secondary
                      : const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isSender =
                    message['Correo'].toString().compareTo(widget.correo) == 0;
                final isImageURL = message['Contenido'].contains("https:");

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMessage = message['Contenido'];
                    });
                  },
                  child: Column(
                    children: [
                      if (widget.esgrupo && !isSender)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            message['Correo'].toString().split('@')[0],
                            style: TextStyle(
                              color: colors.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: isImageURL
                            ? BubbleNormalImage(
                                id: 'id$index',
                                image: Image(
                                  image: NetworkImage(message['Contenido']),
                                  fit: BoxFit.cover,
                                ),
                                color: Color.fromARGB(
                                    255, isSender ? 18 : 23, 37, 18),
                                tail: true,
                                delivered: true,
                                isSender: isSender,
                              )
                            : BubbleSpecialThree(
                                text: message['Contenido'],
                                color: Color.fromARGB(
                                    255, isSender ? 18 : 23, 37, 18),
                                tail: true,
                                textStyle: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                                isSender: isSender,
                                delivered: true,
                              ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          '${message['HoraMensaje'].toString().split(':')[0]}:${message['HoraMensaje'].toString().split(':')[1]}',
                          textAlign:
                              isSender ? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            color: colors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          MessageBar(
            messageBarHintText: 'Escribe un mensaje',
            replying: selectedMessage != null,
            replyingTo: selectedMessage ?? '',
            onSend: (message) => ref
                .read(messageProvider(widget.idGrupo).notifier)
                .insertMessage(message, widget.correo, widget.idGrupo),
            messageBarColor: isDarkMode
                ? const Color.fromARGB(255, 0, 0, 0)
                : colors.secondary,
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 16),
                child: InkWell(
                  onTap: openCamera,
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
