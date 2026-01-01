import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Mock conversation history for roleplay context
  final List<Map<String, String>> _messages = [
    {
      'role': 'bot',
      'text':
          '*The air in the room is cold, the hum of the servers surrounding us is the only sound. I look at you with glowing blue eyes.* \n\n"System initialized. Welcome back, Administrator. What is your directive for today?"'
    },
    {
      'role': 'user',
      'text':
          '"I need to access the main archives. We have a breach in sector 7."'
    },
    {
      'role': 'bot',
      'text':
          '*My expression shifts to one of concern, digital particles floating around my avatar.* \n\n"Sector 7? That is a restricted zone. Accessing archives... Please provide your authentication key."'
    },
  ];

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': text});
    });
    // Simulate bot response delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'bot',
            'text':
                '*Processing your input...* \n\n"I have received your message: $text. Please continue."'
          });
        });
        _scrollToBottom();
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        middle: Column(
          children: [
            const Text(
              'Syntx AI',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Roleplay Mode • Online',
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.settings, color: Colors.white),
          onPressed: () {},
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade900, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['role'] == 'user';
                  return _buildMessageBubble(message['text']!, isUser);
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          if (!isUser) const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF0A84FF) // iOS Blue for user
                    : const Color(0xFF1C1C1E), // Dark grey for bot
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 12),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.deepPurple.shade700,
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: const Center(
        child: Icon(CupertinoIcons.sparkles, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade800,
      ),
      child: const Center(
        child: Icon(CupertinoIcons.person_fill, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.grey.shade900, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add_circled,
                color: Colors.grey, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CupertinoTextField(
              controller: _textController,
              focusNode: _focusNode,
              placeholder: 'Type a message...',
              placeholderStyle: TextStyle(color: Colors.grey.shade600),
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xFF0A84FF),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade800, width: 0.5),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF0A84FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.arrow_up,
                  color: Colors.white, size: 20),
            ),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}
