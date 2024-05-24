import 'package:flutter/material.dart';

@immutable
class MessageData {
  final String senderName;
  final String message;
  final DateTime messageDate;
  final String datemessage;
  final String profilePicture;

  const MessageData(
      {required this.senderName,
      required this.message,
      required this.messageDate,
      required this.datemessage,
      required this.profilePicture});
}
