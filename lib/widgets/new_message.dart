import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Enhanced NewMessage Widget
class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> with TickerProviderStateMixin {
  final messageController = TextEditingController();
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = messageController.text.trim();
    if (enteredMessage.isEmpty) return;

    // Animate send button
    _sendButtonController.forward().then((_) {
      _sendButtonController.reverse();
    });

    FocusScope.of(context).unfocus();
    messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userData =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

    // Save message to Firestore
    await FirebaseFirestore.instance.collection("chat").add({
      "text": enteredMessage,
      "createdAt": Timestamp.now(),
      "userId": user.uid,
      "username": userData.data()!['username'],
      "image_url": userData.data()!["image_url"],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 0.7),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              style: TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.black54, fontSize: 16),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _sendButtonAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _sendButtonAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _submitMessage,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
