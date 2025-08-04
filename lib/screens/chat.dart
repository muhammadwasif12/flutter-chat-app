import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/chat_messages.dart';
import '../widgets/new_message.dart';
import '../services/local_notification_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late Stream<QuerySnapshot> _messagesStream;
  bool _isFirstLoad = true;
  late AnimationController _appBarController;
  late Animation<double> _appBarAnimation;

  @override
  void initState() {
    super.initState();
    _setupMessageListener();
    _requestNotificationPermissions();

    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _appBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appBarController, curve: Curves.easeInOut),
    );
    _appBarController.forward();
  }

  @override
  void dispose() {
    _appBarController.dispose();
    super.dispose();
  }

  void _requestNotificationPermissions() async {
    await LocalNotificationService.requestPermissions();
  }

  void _setupMessageListener() {
    _messagesStream =
        FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots();

    // Listen to new messages for notifications
    _messagesStream.listen((snapshot) {
      if (_isFirstLoad) {
        _isFirstLoad = false;
        return; // Skip first load to avoid showing notifications for existing messages
      }

      // Check for new messages
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;

          LocalNotificationService.showChatNotification(
            username: data['username'] ?? 'Someone',
            message: data['text'] ?? '',
            senderId: data['userId'] ?? '',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AnimatedBuilder(
          animation: _appBarAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -50 * (1 - _appBarAnimation.value)),
              child: Opacity(
                opacity: _appBarAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    title: ShaderMask(
                      shaderCallback:
                          (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.8),
                            ],
                          ).createShader(bounds),
                      child: const Text(
                        "Flutter Chat",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: const Text(
                                      "Logout",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: const Text(
                                      "Are you sure you want to logout?",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                          FirebaseAuth.instance.signOut();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red
                                              .withOpacity(0.8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "Logout",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          icon: const Icon(
                            Icons.exit_to_app_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.03),
              Colors.white.withOpacity(0.9),
            ],
          ),
        ),
        child: const Column(
          children: [Expanded(child: ChatMessages()), NewMessage()],
        ),
      ),
    );
  }
}
