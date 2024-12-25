import 'package:flutter/material.dart';
import 'add_book_screen.dart';
import 'profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Open WhatsApp with a pre-filled message
  void _openWhatsApp(BuildContext context, String whatsappNumber, String itemTitle) async {
    final message = Uri.encodeComponent('Hi, I am interested in "$itemTitle". Can we connect?');
    final whatsappUrl = 'https://wa.me/$whatsappNumber?text=$message';

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch user data from Firebase Auth
    User? user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName ?? 'No Name';
    String userEmail = user?.email ?? 'No Email';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow,
          elevation: 1,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userName: userName,
                    userEmail: userEmail,
                  ),
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                // Search functionality
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Books'),
              Tab(text: 'Notes'),
            ],
          ),
          title: Image.asset(
            'assets/images/logo.png',
            color: Colors.black, // Use the correct path to your logo
            height: 230, // Adjust the size of the logo
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookList(context),
            _buildNoteList(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.yellow,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddBookScreen()),
            );
          },
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  /// Build the Book List from the `Books` collection
  Widget _buildBookList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Books')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching books'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No books available'));
        } else {
          final books = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['title'] != null &&
                data['title'].toString().isNotEmpty &&
                data['author'] != null &&
                data['author'].toString().isNotEmpty;
          }).toList();

          if (books.isEmpty) {
            return const Center(child: Text('No valid books available'));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index].data() as Map<String, dynamic>;
              return _buildCard(context, book, true); // true indicates it's a book
            },
          );
        }
      },
    );
  }

  /// Build the Note List from the `Notes` collection
  Widget _buildNoteList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Notes')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching notes'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No notes available'));
        } else {
          final notes = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['title'] != null &&
                data['title'].toString().isNotEmpty &&
                data['author'] != null &&
                data['author'].toString().isNotEmpty;
          }).toList();

          if (notes.isEmpty) {
            return const Center(child: Text('No valid notes available'));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index].data() as Map<String, dynamic>;
              return _buildCard(context, note, false); // false indicates it's a note
            },
          );
        }
      },
    );
  }

  /// Card for displaying Books or Notes
  Widget _buildCard(BuildContext context, Map<String, dynamic> item, bool isBook) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Item image
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item['imageUrl'] != null
                  ? Image.network(item['imageUrl'], fit: BoxFit.cover)
                  : const Icon(Icons.insert_drive_file, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 10),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['title']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'By ${item['author']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),

                  if (isBook && item['price'] != null)
                    Text(
                      'Price: RS:${item['price']}',
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),

            // WhatsApp button
            IconButton(
              onPressed: () {
                final whatsappNumber = item['whatsappNumber'];
                if (whatsappNumber != null && whatsappNumber.isNotEmpty) {
                  _openWhatsApp(context, whatsappNumber, item['title']);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('WhatsApp number not available.')),
                  );
                }
              },
              icon: Image.asset(
                'assets/icons/whatsapp.png', // Add your WhatsApp icon here
                width: 100.0,
                height: 100.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
