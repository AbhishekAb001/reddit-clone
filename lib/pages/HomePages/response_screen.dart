import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:reddit/model/message.dart';
import 'package:reddit/pages/PostPages/services/gemini_service.dart';

class ResponseScreen extends StatefulWidget {
  final String question;

  const ResponseScreen({
    super.key,
    required this.question,
  });

  @override
  State<ResponseScreen> createState() => _ResponseScreenState();
}

class _ResponseScreenState extends State<ResponseScreen> {
  final TextEditingController _followUpController = TextEditingController();
  final RxBool _isLoading = false.obs;
  final RxList<Message> _messages = <Message>[].obs;
  final RxString _currentResponse = ''.obs;
  final RxString _error = ''.obs;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add(Message(content: widget.question, isUser: true));
    _sendMessage(widget.question);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String message) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      _currentResponse.value = '';

      final stream = await GeminiService.getResponse(message);

      await for (final output in stream) {
        if (output.isNotEmpty) {
          for (int i = 0; i < output.length; i++) {
            await Future.delayed(const Duration(milliseconds: 20));
            _currentResponse.value += output[i];
          }
        }
      }

      // Add the completed response as a new message
      if (_currentResponse.value.isNotEmpty) {
        _messages.add(Message(
          content: _currentResponse.value,
          isUser: false,
        ));
        _currentResponse.value = '';
      }

      _scrollToBottom();
    } catch (e) {
      _error.value = 'Failed to get response: ${e.toString()}';
      log('Error in _sendMessage: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.symmetric(
          vertical: 4,
          horizontal: MediaQuery.of(context).size.width * 0.04,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFFFF4500) : Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: SelectableText(
          message.content,
          style: GoogleFonts.inter(
            color: message.isUser ? Colors.white : Colors.white70,
            fontSize: MediaQuery.of(context).size.width * 0.035,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: screenWidth * 0.01,
          horizontal: screenWidth * 0.04,
        ),
        padding: EdgeInsets.all(screenWidth * 0.02),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Text(
          'typing...',
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.question,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView(
                controller: _scrollController,
                children: [
                  ..._messages.map((message) => _buildMessageBubble(message)),
                  if (_currentResponse.value.isNotEmpty)
                    _buildMessageBubble(Message(
                      content: _currentResponse.value,
                      isUser: false,
                    )),
                  if (_isLoading.value) _buildTypingIndicator(),
                  if (_error.value.isNotEmpty)
                    Container(
                      margin: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.04,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        _error.value,
                        style: GoogleFonts.inter(
                          color: Colors.red[300],
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                top: BorderSide(color: Colors.grey[800]!, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _followUpController,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Ask a followup...',
                              hintStyle: GoogleFonts.inter(
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                _messages.add(Message(
                                  content: value,
                                  isUser: true,
                                ));
                                _sendMessage(value);
                                _followUpController.clear();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            final value = _followUpController.text;
                            if (value.trim().isNotEmpty) {
                              _messages.add(Message(
                                content: value,
                                isUser: true,
                              ));
                              _sendMessage(value);
                              _followUpController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _followUpController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
