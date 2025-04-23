import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/glass_container.dart';
import '../widgets/loading_indicator.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://blog.ipleaders.in/wp-content/uploads/2020/01/Health-Insurance.jpg',
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(0.3),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    size: 64,
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                GlassContainer(
                  opacity: 0.3,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.health_and_safety,
                          color: AppTheme.primaryColor,
                          size: 30,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Healthcare Assistant',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Chat Area
                Expanded(
                  child: GlassContainer(
                    opacity: 0.15,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: 0, // Replace with your messages list length
                      itemBuilder: (context, index) {
                        return Container(); // Replace with your message widget
                      },
                    ),
                  ),
                ),

                // Input Area
                GlassContainer(
                  opacity: 0.3,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Ask your health question...',
                              fillColor: Colors.white.withOpacity(0.7),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                Icons.medical_services,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryColor.withOpacity(0.8)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.send_rounded, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black26,
              child: HealthcareLoadingIndicator(),
            ),
        ],
      ),
    );
  }
}
