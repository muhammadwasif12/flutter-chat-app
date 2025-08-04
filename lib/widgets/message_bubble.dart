import 'package:flutter/material.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
    required this.timestamp,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  final bool isFirstInSequence;
  final String? userImage;
  final String? username;
  final String message;
  final bool isMe;
  final String timestamp;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              children: [
                if (widget.userImage != null && widget.isFirstInSequence)
                  Positioned(
                    top: 15,
                    right: widget.isMe ? 0 : null,
                    left: !widget.isMe ? 0 : null,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.userImage!),
                      radius: 16,
                    ),
                  ),

                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: widget.isFirstInSequence ? 46 : 50,
                  ),
                  child: Row(
                    mainAxisAlignment: widget.isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: widget.isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (widget.isFirstInSequence)
                              const SizedBox(height: 18),

                            if (widget.username != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 13,
                                  right: 13,
                                  bottom: 4,
                                ),
                                child: Text(
                                  widget.username!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                            Container(
                              decoration: BoxDecoration(
                                color: widget.isMe
                                    ? theme.colorScheme.primary.withOpacity(0.9)
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: !widget.isMe
                                      ? const Radius.circular(4)
                                      : const Radius.circular(18),
                                  topRight: widget.isMe
                                      ? const Radius.circular(4)
                                      : const Radius.circular(18),
                                  bottomLeft: const Radius.circular(18),
                                  bottomRight: const Radius.circular(18),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 14,
                              ),
                              margin: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.message,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: widget.isMe
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.timestamp,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: widget.isMe
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}