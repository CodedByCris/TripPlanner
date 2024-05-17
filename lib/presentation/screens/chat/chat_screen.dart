import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';

import '../../Database/connections.dart';
import '../../providers/theme_provider.dart';

class ChatScreen extends StatefulWidget {
  final String imagen;
  final String nombre;
  final String idGrupo;
  final String correo;
  const ChatScreen(
      {super.key,
      required this.idGrupo,
      required this.correo,
      required this.imagen,
      required this.nombre});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  String? selectedMessage;
  final db = DatabaseHelper();
  MySqlConnection? conn;
  List<ResultRow> messages = [];

  @override
  void initState() {
    print("key-> ${widget.idGrupo}");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    fetchData();
  }

  Future<String> uploadImage(XFile image) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('images')
        .child(DateTime.now().toString());
    await ref.putFile(File(image.path));
    return await ref.getDownloadURL();
  }

  Future<void> insertMessage(String content, bool isImage) async {
    final date = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final timeStr = DateFormat('HH:mm').format(date);

    await conn!.query(
      'INSERT INTO Mensajes_del_Grupo (Contenido, FechaMensaje, HoraMensaje, Correo, IdGrupo) VALUES (?, ?, ?, ?, ?)',
      [content, dateStr, timeStr, widget.correo, widget.idGrupo],
    );

    await fetchData();
  }

  Future<void> openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final imageUrl = await uploadImage(photo);
      await insertMessage(imageUrl, true);
    }
  }

  Future<void> fetchData() async {
    conn = await db.getConnection();

    final messageResult = await conn!.query(
        'SELECT Contenido, FechaMensaje, HoraMensaje, Correo FROM Mensajes_del_Grupo WHERE IdGrupo = ?',
        [widget.idGrupo]);

    setState(() {
      messages = messageResult.toList();
    });

    // Add a post frame callback to jump to the bottom of the list after the UI has been updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final colors = Theme.of(context).colorScheme;
      final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const SizedBox(width: 8.0),
              CircleAvatar(
                backgroundImage: widget.imagen.compareTo("null") == 0
                    ? NetworkImage(widget.imagen)
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
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isSender = message['Correo'] == widget.correo;
                  final isImageURL = message['Contenido'].contains("https:");

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMessage = message['Contenido'];
                      });
                    },
                    child: Padding(
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
                  );
                },
              ),
            ),
            MessageBar(
              messageBarHintText: 'Escribe un mensaje',
              replying: selectedMessage != null,
              replyingTo: selectedMessage ?? '',
              onSend: (message) => insertMessage(message, false),
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
    });
  }
}
