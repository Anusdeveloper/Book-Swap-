import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// You can replace the below import statements with your actual screen imports
import 'change_password_screen.dart'; // Example screen for changing password
import 'privacy_settings_screen.dart'; // Example screen for privacy settings
import 'my_books_screen.dart'; // Example screen for the user's books
import 'order_history_screen.dart'; // Example screen for order history
import 'create_event_screen.dart'; // Example screen for creating new event
import 'past_events_screen.dart'; // Example screen for past events
import 'language_settings_screen.dart'; // Example screen for language settings
import 'feedback_support_screen.dart'; // Example screen for feedback and support
import 'terms_of_service_screen.dart'; // Example screen for terms of service
import 'privacy_policy_screen.dart'; // Example screen for privacy policy

class ProfileScreen extends StatefulWidget {
  final String userName;  // The user name passed from login or authentication
  final String userEmail; // The user email passed from login or authentication

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  File? _profileImage;
  late AnimationController _controller;
  late Animation<double> _animation;

  // Method to pick an image from the user's device
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery); // Choose gallery or camera

    if (image != null) {
      setState(() {
        _profileImage = File(image.path); // Update the profile image
      });
    }
  }

  // Logout function
  Future<void> _logout() async {
    // Perform logout action (e.g., Firebase sign-out)
    // Example: await FirebaseAuth.instance.signOut();
    print('Logged out');
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to the login screen after logout
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.yellow,  // Main AppBar Color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        actions: [
          // Logout Animated Icon in the top-right corner
          MouseRegion(
            onEnter: (_) {
              _controller.forward(); // Start the animation when the mouse enters
            },
            onExit: (_) {
              _controller.reverse(); // Reverse the animation when the mouse exits
            },
            child: ScaleTransition(
              scale: _animation,
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  // Confirm logout with the user
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    _logout(); // Call the logout function
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Header Section: Profile Picture, Name, and Status
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.shade50, // Use Colors.blue.shade50 dynamically, no `const` here
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage, // Allow the user to tap to change profile picture
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage == null
                        ? const NetworkImage('https://example.com/default-avatar.jpg') // Default profile image
                        : FileImage(_profileImage!) as ImageProvider, // Display picked image
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.userName,  // Use the user name from the passed parameters
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.userEmail,  // Use the user email from the passed parameters
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          // Personal Information Section
          ListTile(
            title: const Text('Personal Information'),
            leading: const Icon(Icons.person),
            tileColor: Colors.grey.shade200,
          ),
          ListTile(
            title: Text('Email: ${widget.userEmail}'),
            leading: const Icon(Icons.email),
          ),
          const ListTile(
            title: Text('Phone: +1 234 567 890'),
            leading: Icon(Icons.phone),
          ),
          const ListTile(
            title: Text('Location: New York, USA'),
            leading: Icon(Icons.location_on),
          ),
          const ListTile(
            title: Text('Bio: A passionate book lover.'),
            leading: Icon(Icons.info),
          ),

          // Account Settings Section
          ListTile(
            title: const Text('Account Settings'),
            leading: const Icon(Icons.settings),
            tileColor: Colors.grey.shade200,
          ),
          ListTile(
            title: const Text('Change Password'),
            leading: const Icon(Icons.lock),
            onTap: () {
              // Navigate to the Change Password screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Privacy Settings'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {
              // Navigate to Privacy Settings screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacySettingsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Notification Settings'),
            leading: const Icon(Icons.notifications),
            onTap: () {
              // Navigate to Notification Settings screen (optional, you can add it)
            },
          ),
          ListTile(
            title: const Text('Delete Account'),
            leading: const Icon(Icons.delete_forever),
            onTap: () {
              // Handle account deletion
            },
          ),

          // Book Collection Section
          ListTile(
            title: const Text('Book Collection'),
            leading: const Icon(Icons.book),
            tileColor: Colors.grey.shade200,
          ),
          ListTile(
            title: const Text('My Books'),
            leading: const Icon(Icons.library_books),
            onTap: () {
              // Navigate to the user's book collection screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyBooksScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Add New Book'),
            leading: const Icon(Icons.add),
            onTap: () {
              // Navigate to Add New Book screen
            },
          ),

          // Order History Section
          ListTile(
            title: const Text('Order History'),
            leading: const Icon(Icons.history),
            tileColor: Colors.grey.shade200,
          ),
          ListTile(
            title: const Text('Past Orders'),
            leading: const Icon(Icons.shopping_cart),
            onTap: () {
              // Navigate to Order History screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
              );
            },
          ),

          // Events Section
          ListTile(
            title: const Text('Upcoming Events'),
            leading: const Icon(Icons.event),
            tileColor: Colors.grey.shade200,
          ),
          ListTile(
            title: const Text('View Past Events'),
            leading: const Icon(Icons.event_note),
            onTap: () {
              // Navigate to Past Events screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PastEventsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Create New Event'),
            leading: const Icon(Icons.add_circle_outline),
            onTap: () {
              // Navigate to Create New Event screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateEventScreen()),
              );
            },
          ),

          // Additional Features
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: true, // Replace with actual dark mode state
            onChanged: (bool value) {
              // Toggle Dark Mode
            },
          ),
          ListTile(
            title: const Text('Language Settings'),
            leading: const Icon(Icons.language),
            onTap: () {
              // Navigate to Language Settings screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LanguageSettingsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Feedback & Support'),
            leading: const Icon(Icons.feedback),
            onTap: () {
              // Navigate to Feedback & Support screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackSupportScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            leading: const Icon(Icons.description),
            onTap: () {
              // Navigate to Terms of Service screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsOfServiceScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {
              // Navigate to Privacy Policy screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
