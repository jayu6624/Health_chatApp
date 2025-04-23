import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'gemini_service.dart';
import 'login_signup_screen.dart';
import 'history_screen.dart';
import 'theme/app_theme.dart';
import 'theme_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final GeminiService geminiService = GeminiService();
  final TextEditingController _controller = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speechToText = stt.SpeechToText();
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool isReading = false;
  bool isListening = false;
  bool isNewMessage = false;
  late AnimationController _animationController;
  bool isGenerating = false;
  bool isAnimating = false;
  String animatedResponse = '';
  bool _stopGenerating = false;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeSpeech();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      messages.insert(0, {
        "role": "bot",
        "text": "Hello! I'm your AI assistant. How can I help you today?",
      });
    });
  }

  void _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.awaitSpeakCompletion(true);

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  void _initializeSpeech() async {
    await speechToText.initialize();
  }

  void sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.insert(0, {"role": "user", "text": userMessage});
      _controller.clear();
      isGenerating = true;
      animatedResponse = '';
      _stopGenerating = false;
    });

    _scrollToBottom();

    try {
      String botResponse = await geminiService.sendMessage(userMessage);

      if (!_stopGenerating) {
        setState(() {
          messages.insert(0, {"role": "bot", "text": botResponse});
          isGenerating = false;
          _startTypingAnimation(botResponse);
        });
      }
    } catch (e) {
      debugPrint("AI Response Error: $e");
      setState(() {
        isGenerating = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startTypingAnimation(String response) async {
    setState(() {
      isAnimating = true;
    });

    for (int i = 0; i < response.length; i++) {
      if (_stopGenerating) break;
      await Future.delayed(const Duration(milliseconds: 10), () {
        setState(() {
          animatedResponse = response.substring(0, i + 1);
        });
      });
    }

    setState(() {
      isAnimating = false;
    });
  }

  Future<void> _pickImage() async {
    final XFile? imageFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      textRecognizer.close();
      String extractedText = recognizedText.text.trim();
      if (extractedText.isNotEmpty) {
        setState(() {
          _controller.text = extractedText;
        });
      }
    }
  }

  Future<void> startListening() async {
    bool available = await speechToText.initialize();
    if (!available) return;

    setState(() {
      isListening = true;
    });

    speechToText.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      },
    );
  }

  void stopListening() {
    speechToText.stop();
    setState(() {
      isListening = false;
    });
  }

  void stopGenerating() {
    setState(() {
      _stopGenerating = true;
      isGenerating = false;
      isAnimating = false;
    });
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
        return AlertDialog(
          backgroundColor: isDarkMode ? AppTheme.backgroundDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "How to Use",
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppTheme.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpItem(
                  icon: Icons.chat_bubble_outline,
                  title: "Chat",
                  description:
                      "Type your message in the text field and tap the send button",
                  isDarkMode: isDarkMode,
                ),
                _buildHelpItem(
                  icon: Icons.mic,
                  title: "Voice Input",
                  description: "Tap the microphone icon to use speech-to-text",
                  isDarkMode: isDarkMode,
                ),
                _buildHelpItem(
                  icon: Icons.image,
                  title: "Extract Text",
                  description: "Upload an image to extract text from it",
                  isDarkMode: isDarkMode,
                ),
                _buildHelpItem(
                  icon: Icons.volume_up,
                  title: "Text-to-Speech",
                  description:
                      "Listen to the AI's response with text-to-speech",
                  isDarkMode: isDarkMode,
                ),
                _buildHelpItem(
                  icon: Icons.content_copy,
                  title: "Copy to Clipboard",
                  description: "Copy the AI's response to your clipboard",
                  isDarkMode: isDarkMode,
                ),
                _buildHelpItem(
                  icon: Icons.share,
                  title: "Share",
                  description: "Share conversations as PDF files",
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Got it",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isDarkMode ? Colors.white : AppTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareConversationAsPdf(
      Map<String, String> userMessage, Map<String, String> aiMessage) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "User: ${userMessage["text"]}",
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.blue,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "AI: ${aiMessage["text"]}",
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.black,
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/conversation.pdf");
    await file.writeAsBytes(await pdf.save());

    final xFile = XFile(file.path);
    await Share.shareXFiles([xFile],
        text: 'Here is the conversation in PDF format.');
  }

  Future<void> toggleTts(String text) async {
    if (isSpeaking) {
      await flutterTts.pause();
      setState(() {
        isSpeaking = false;
      });
    } else {
      await flutterTts.speak(text);
      setState(() {
        isSpeaking = true;
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    speechToText.stop();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI Assistant",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(messages: messages),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : Colors.white,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "AI Chat Assistant",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your smart conversation companion",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                icon: Icons.history,
                title: "Conversation History",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(messages: messages),
                    ),
                  );
                },
                isDarkMode: isDarkMode,
              ),
              _buildDrawerItem(
                icon: Icons.help_outline,
                title: "Help & Instructions",
                onTap: () {
                  Navigator.pop(context);
                  _showHelpDialog(context);
                },
                isDarkMode: isDarkMode,
              ),
              _buildDrawerItem(
                icon: isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                title: isDarkMode ? "Light Mode" : "Dark Mode",
                onTap: () {
                  Navigator.pop(context);
                  themeProvider.toggleTheme();
                },
                isDarkMode: isDarkMode,
              ),
              const Divider(),
              _buildDrawerItem(
                icon: Icons.logout,
                title: "Logout",
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginSignupScreen()),
                  );
                },
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundDark,
                    const Color(0xFF1A1A2E),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    const Color(0xFFF0F4F9),
                  ],
                ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: messages.length + (isGenerating ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show typing indicator when generating
                  if (index == 0 && isGenerating) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16, right: 80),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAvatar(false),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? AppTheme.primaryColor.withOpacity(0.2)
                                    : AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomRight: Radius.circular(18),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  TypingIndicator(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final messageIndex = isGenerating ? index - 1 : index;
                  final message = messages[messageIndex];
                  final bool isUser = message["role"] == "user";
                  final bool isLastMessage = messageIndex == 0;
                  final String displayText =
                      isLastMessage && !isUser && isAnimating
                          ? animatedResponse
                          : message["text"]!;

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: 16,
                        left: isUser ? 80 : 0,
                        right: isUser ? 0 : 80,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isUser) _buildAvatar(false),
                          if (!isUser) const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? AppTheme.primaryColor
                                    : isDarkMode
                                        ? AppTheme.primaryColor.withOpacity(0.2)
                                        : AppTheme.primaryColor
                                            .withOpacity(0.1),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: isUser
                                      ? const Radius.circular(18)
                                      : const Radius.circular(0),
                                  bottomRight: isUser
                                      ? const Radius.circular(0)
                                      : const Radius.circular(18),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Message text
                                  Text(
                                    displayText,
                                    style: TextStyle(
                                      color: isUser
                                          ? Colors.white
                                          : isDarkMode
                                              ? Colors.white
                                              : AppTheme.textPrimaryLight,
                                      fontSize: 15,
                                    ),
                                  ),

                                  // Action buttons for AI messages
                                  if (!isUser && displayText.length > 10)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildActionButton(
                                            icon: Icons.content_copy,
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: message["text"]!));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Copied to clipboard"),
                                                  duration:
                                                      Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                            isDarkMode: isDarkMode,
                                          ),
                                          _buildActionButton(
                                            icon: Icons.share,
                                            onTap: () {
                                              if (messageIndex <
                                                      messages.length - 1 &&
                                                  messages[messageIndex + 1]
                                                          ["role"] ==
                                                      "user") {
                                                final userMessage =
                                                    messages[messageIndex + 1];
                                                final aiMessage =
                                                    messages[messageIndex];
                                                _shareConversationAsPdf(
                                                    userMessage, aiMessage);
                                              }
                                            },
                                            isDarkMode: isDarkMode,
                                          ),
                                          _buildActionButton(
                                            icon: isSpeaking
                                                ? Icons.stop_circle
                                                : Icons.volume_up,
                                            onTap: () =>
                                                toggleTts(message["text"]!),
                                            isDarkMode: isDarkMode,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (isUser) const SizedBox(width: 8),
                          if (isUser) _buildAvatar(true),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildInputBar(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? AppTheme.accentColor : AppTheme.secondaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person : Icons.smart_toy,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Function() onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Function() onTap,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : AppTheme.textPrimaryLight,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildInputBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.image,
                color: AppTheme.primaryColor.withOpacity(0.7),
              ),
              onPressed: _pickImage,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black12 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (text) => sendMessage(),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade500,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        maxLines: null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: isListening
                            ? AppTheme.accentColor
                            : AppTheme.primaryColor.withOpacity(0.7),
                      ),
                      onPressed: isListening ? stopListening : startListening,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: sendMessage,
              ),
            ),
            if (isGenerating || isAnimating)
              IconButton(
                icon: const Icon(
                  Icons.stop_circle,
                  color: AppTheme.accentColor,
                ),
                onPressed: stopGenerating,
              ),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double beginTime = index * 0.2;
            final double endTime = beginTime + 0.6;

            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 0),
                end: Offset(0, -0.5),
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(beginTime, endTime, curve: Curves.easeInOut),
                ),
              ),
              child: child,
            );
          },
          child: Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
