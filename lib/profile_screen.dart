import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// You can replace the below import statements with your actual screen imports
import 'change_password_screen.dart';
import 'privacy_settings_screen.dart';
import 'my_books_screen.dart';
import 'order_history_screen.dart';
import 'create_event_screen.dart';
import 'past_events_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

        // Delete user books
        await FirebaseFirestore.instance
          .collection('books')
          .where('userId', isEqualTo: user.uid)
          .get()
          .then((snapshot) {
            for (DocumentSnapshot doc in snapshot.docs) {
              doc.reference.delete();
            }
          });

        // Delete user events
        await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: user.uid)
          .get()
          .then((snapshot) {
            for (DocumentSnapshot doc in snapshot.docs) {
              doc.reference.delete();
            }
          });

        // Delete user authentication
        await user.delete();
        
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Failed to delete account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          MouseRegion(
            onEnter: (_) {
              _controller.forward();
            },
            onExit: (_) {
              _controller.reverse();
            },
            child: ScaleTransition(
              scale: _animation,
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
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
                    await _logout();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage == null
                        ? const NetworkImage('https://example.com/default-avatar.jpg')
                        : FileImage(_profileImage!) as ImageProvider,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.userName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.userEmail,
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

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

          ListTile(
            title: const Text('Account Settings'),
            leading: const Icon(Icons.settings),
            tileColor: Colors.grey.shade200,
          ),
          ListTile(
            title: const Text('Change Password'),
            leading: const Icon(Icons.lock),
            onTap: () {
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
              // Navigate to Notification Settings screen
            },
          ),
          ListTile(
            title: const Text('Delete Account'),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                    'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (shouldDelete == true) {
                await _deleteAccount();
              }
            },
          ),

          ListTile(
            title: const Text('Book Collection'),
            leading: const Icon(Icons.book),
            tileColor: Colors.grey.shade200,
          ),
          ListTile(
            title: const Text('My Books'),
            leading: const Icon(Icons.library_books),
            onTap: () {
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
              );
            },
          ),

          ListTile(
            title: const Text('Upcoming Events'),
            leading: const Icon(Icons.event),
            tileColor: Colors.grey.shade200,
          ),
          ListTile(
            title: const Text('View Past Events'),
            leading: const Icon(Icons.event_note),
            onTap: () {
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateEventScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}