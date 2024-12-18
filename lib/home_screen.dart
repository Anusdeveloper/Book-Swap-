import 'package:flutter/material.dart';
import 'add_book_screen.dart';
import 'profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            _buildBookList(),
            _buildNoteList(),
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
  Widget _buildBookList() {
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
              return _buildBookCard(book);
            },
          );
        }
      },
    );
  }

  /// Card for displaying a Book
  Widget _buildBookCard(Map<String, dynamic> book) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Book image
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: book['imageUrl'] != null
                  ? Image.network(book['imageUrl'], fit: BoxFit.cover)
                  : const Icon(Icons.book, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 10),

            // Book details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${book['title']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'By ${book['author']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),

                  // Grade (optional)
                  if (book['grade'] != null)
                    Text(
                      'Grade: ${book['grade']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 5),

                  // Price, Rent, or Exchange details
                  if (book['price'] != null)
                    Text(
                      'Price: Rs${book['price']}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else if (book['rent'] != null)
                    Text(
                      'Rent: ₹${book['rent']}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  if (book['exchange'] != null && book['exchange'] == true)
                    const Text(
                      'Available for Exchange',
                      style: TextStyle(
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            // Contact button
            IconButton(
              onPressed: () {
                // Handle contact action
              },
              icon: const Icon(Icons.contact_phone, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the Note List from the `Notes` collection
  Widget _buildNoteList() {
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
              return _buildBookCard(note); // Reuse book card for notes
            },
          );
        }
      },
    );
  }
}
