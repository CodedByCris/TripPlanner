import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:trip_planner/presentation/screens/chat/chat_conversacion_screen.dart';
import 'package:trip_planner/presentation/screens/chat/helpers.dart';

import '../models/models.dart';
import '../widget/widgets.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      const SliverToBoxAdapter(child: _Stories()),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return _delegate(context, index);
        }),
      ),
    ]);
  }

//!DATOS ALEATORIOS A CAMBIAR POR LOS DE LA API
  Widget _delegate(BuildContext context, int index) {
    final Faker faker = Faker();
    final date = Helpers.randomDate();
    return _MessageTitle(
        messageData: MessageData(
            senderName: faker.person.name(),
            message: faker.lorem.sentence(),
            messageDate: date,
            datemessage: "A day ago",
            profilePicture: Helpers.randomPictureUrl()));
  }
}

//!TEXTO DE LOS MENSAJES
class _MessageTitle extends StatelessWidget {
  final MessageData messageData;

  const _MessageTitle({super.key, required this.messageData});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(ChatScreen.route(messageData));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: 100,
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2))),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Avatar.medium(url: messageData.profilePicture),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      messageData.senderName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          letterSpacing: 0.2,
                          wordSpacing: 1.5,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  SizedBox(
                      height: 20,
                      child: Text(
                        messageData.message,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Color.fromARGB(138, 0, 0, 0)),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    messageData.datemessage.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.blueAccent),
                    child: const Center(
                      child: Text(
                        "1",
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

//!STORIES
class _Stories extends StatelessWidget {
  const _Stories({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: SizedBox(
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
              child: Text(
                "Stories",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final faker = Faker();
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 60,
                      child: _StoryCard(
                        storyData: StoryData(
                            name: faker.person.name(),
                            url: Helpers.randomPictureUrl()),
                      ),
                    ),
                  );
                },
                scrollDirection: Axis.horizontal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//!CARD DE LAS HISTORIAS
class _StoryCard extends StatelessWidget {
  final StoryData storyData;
  const _StoryCard({super.key, required this.storyData});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Avatar.medium(url: storyData.url),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(storyData.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.bold)),
        ))
      ],
    );
  }
}
