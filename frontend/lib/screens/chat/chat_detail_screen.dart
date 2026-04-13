import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart';

class ChatDetailScreen extends StatefulWidget {
  final int appId;
  final String title;
  final String? subtitle;
  const ChatDetailScreen({super.key, required this.appId, required this.title, this.subtitle});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _pollingTimer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      provider.clearMessages();
      provider.fetchMessages(widget.appId).then((_) => _scrollToBottom());

      // Listen for new messages and auto-scroll
      provider.addListener(_onMessagesUpdated);
    });

    // Poll every 3 seconds for new messages
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        Provider.of<ChatProvider>(context, listen: false)
            .fetchMessages(widget.appId, silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    // Remove listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) return;
      try {
        Provider.of<ChatProvider>(context, listen: false).removeListener(_onMessagesUpdated);
      } catch (_) {}
    });
    super.dispose();
  }

  void _onMessagesUpdated() {
    _scrollToBottom(animated: true);
  }

  void _scrollToBottom({bool animated = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _msgController.clear();

    final error = await Provider.of<ChatProvider>(context, listen: false)
        .sendMessage(widget.appId, text);

    if (mounted) {
      setState(() => _isSending = false);
      if (error != null) {
        // Restore the text so user doesn't lose it
        _msgController.text = text;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $error'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        _scrollToBottom(animated: true);
      }
    }
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$hour:$min';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final myId = Provider.of<AuthProvider>(context, listen: false).user?.id;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primary.withOpacity(0.15),
              child: Text(
                widget.title.isNotEmpty ? widget.title[0].toUpperCase() : '?',
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                if (widget.subtitle != null)
                  Text(widget.subtitle!,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: AppTheme.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                const Text('Live',
                    style: TextStyle(
                        color: AppTheme.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: chatProvider.isLoading && chatProvider.messages.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : chatProvider.error != null && chatProvider.messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 56, color: Color(0xFFEF4444)),
                              const SizedBox(height: 16),
                              Text(
                                chatProvider.error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 15),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => Provider.of<ChatProvider>(context, listen: false)
                                    .fetchMessages(widget.appId),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : chatProvider.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 64,
                                color: AppTheme.textSecondary.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet.\nSay hello! 👋',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, i) {
                          final msg = chatProvider.messages[i];
                          final isMe = msg.sender == myId;

                          return Column(
                            children: [
                              if (i == 0)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    'Chat started',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary
                                            .withOpacity(0.6),
                                        fontSize: 12),
                                  ),
                                ),
                              Row(
                                mainAxisAlignment: isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!isMe) ...[
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppTheme.surface,
                                      child: Text(
                                        widget.title.isNotEmpty
                                            ? widget.title[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.68,
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: isMe
                                            ? const LinearGradient(
                                                colors: [
                                                  AppTheme.primary,
                                                  AppTheme.primaryDark
                                                ],
                                              )
                                            : null,
                                        color:
                                            isMe ? null : AppTheme.surface,
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(18),
                                          topRight: const Radius.circular(18),
                                          bottomLeft:
                                              Radius.circular(isMe ? 18 : 4),
                                          bottomRight:
                                              Radius.circular(isMe ? 4 : 18),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: isMe
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            msg.content,
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                  : AppTheme.textPrimary,
                                              fontSize: 15,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatTime(msg.createdAt),
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                      .withOpacity(0.65)
                                                  : AppTheme.textSecondary,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isMe) const SizedBox(width: 8),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                          );
                        },
                      ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 15),
                      maxLines: 4,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle:
                            const TextStyle(color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppTheme.background,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isSending ? null : _send,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _isSending
                            ? null
                            : const LinearGradient(
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.primaryDark
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: _isSending ? AppTheme.textSecondary : null,
                        boxShadow: _isSending
                            ? []
                            : [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: _isSending
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
