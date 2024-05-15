import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  String? selectedMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    // Aquí puedes manejar la imagen tomada por la cámara
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemBuilder: (context, index) {
              final String message =
                  index % 2 == 0 ? 'Sinverguenza' : 'Hola david';
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMessage = message;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: BubbleSpecialThree(
                    text: message,
                    color:
                        Color.fromARGB(255, index % 2 == 0 ? 18 : 23, 37, 18),
                    tail: true,
                    textStyle:
                        const TextStyle(color: Colors.white, fontSize: 16),
                    isSender: index % 2 == 0,
                    delivered: true,
                  ),
                ),
              );
            },
            itemCount: 10,
          ),
          MessageBar(
            replying: selectedMessage != null,
            replyingTo: selectedMessage ?? '',
            onSend: (message) => print(message),
            messageBarColor: Colors.white,
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
