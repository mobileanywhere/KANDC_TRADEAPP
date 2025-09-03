import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  String? uid;
  String? senderId;
  String? receiverId;
  String? photoUrl;
  String? messageType;
  bool? isMe;
  bool? isMessageRead;
  String? message;
  int? createdAt;
  Timestamp? createdAtTime;
  Timestamp? updatedAtTime;
  DocumentReference? chatDocumentReference;

  ChatMessageModel({this.uid, this.chatDocumentReference, this.senderId, this.createdAtTime, this.updatedAtTime, this.receiverId, this.createdAt, this.message, this.isMessageRead, this.photoUrl, this.messageType});

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      uid: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      isMessageRead: json['isMessageRead'],
      photoUrl: json['photoUrl'],
      messageType: json['messageType'],
      createdAt: json['createdAt'],
      createdAtTime: json['createdAtTime'],
      updatedAtTime: json['updatedAtTime'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = uid;
    data['createdAt'] = createdAt;
    data['message'] = message;
    data['senderId'] = senderId;
    data['isMessageRead'] = isMessageRead;
    data['receiverId'] = receiverId;
    data['photoUrl'] = photoUrl;
    data['createdAtTime'] = createdAtTime;
    data['updatedAtTime'] = updatedAtTime;
    data['messageType'] = messageType;
    return data;
  }
}
