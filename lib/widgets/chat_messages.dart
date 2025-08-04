import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/message_bubble.dart';
import 'package:intl/intl.dart'; // Add this import at the top

// Enhanced ChatMessages Widget
class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    String _formatTimestamp(Timestamp timestamp) {
      final dateTime = timestamp.toDate();
      return DateFormat('h:mm a').format(dateTime); // Format like "2:30 PM"
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('chat')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Loading messages...",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 60,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No messages yet",
                      style: TextStyle(
                        color: Colors.white54,

                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Start the conversation!",
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          if (chatSnapshots.hasError) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 50,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Something went wrong...',
                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final loadedMessages = chatSnapshots.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 15,
              right: 15,
              top: 10,
            ),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadedMessages[index].data();
              final nextChatMessage =
                  index + 1 < loadedMessages.length
                      ? loadedMessages[index + 1].data()
                      : null;

              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;
              final timestamp = _formatTimestamp(chatMessage['createdAt']);

              if (nextUserIsSame) {
                return MessageBubble.next(
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUserId,
                  timestamp: timestamp, // Pass the timestamp
                );
              } else {
                return MessageBubble.first(
                  userImage: chatMessage['image_url'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUserId,
                  timestamp: timestamp, // Pass the timestamp
                );
              }
            },
          );
        },
      ),
    );
  }
}
