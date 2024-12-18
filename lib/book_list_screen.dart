import 'package:flutter/material.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> books = [
      {
        'user': 'John Doe',
        'status': 'is requesting...',
        'bookTitle': 'The Da Vinci Code',
        'author': 'Dan Brown',
        'time': '1 d',
        'distance': '7km away',
        'likes': 5,
        'comments': 6,
        'requesting': true, // Indicates a "SELL" button.
      },
      {
        'user': 'John Doe',
        'status': 'has finished reading...',
        'bookTitle': 'The Da Vinci Code',
        'author': 'Dan Brown',
        'time': '12m',
        'likes': 5,
        'comments': 6,
        'requesting': false,
      },
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            'Available Book',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.yellow,
            tabs: [
              Tab(text: 'Notes'),
              Tab(text: 'Books'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Posts Tab
            _buildBookList(books),
            // Books Nearby Tab
            _buildBookList(books),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.yellow,
          onPressed: () {},
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildBookList(List<Map<String, dynamic>> books) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${book['user']} ${book['status']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            book['time'],
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      book['distance'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 70,
                      color: Colors.grey[300], // Placeholder for the book image
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['bookTitle'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          book['author'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.thumb_up_alt_outlined, size: 20),
                        const SizedBox(width: 5),
                        Text('${book['likes']} Like'),
                        const SizedBox(width: 20),
                        const Icon(Icons.comment_outlined, size: 20),
                        const SizedBox(width: 5),
                        Text('${book['comments']} comment'),
                      ],
                    ),
                    if (book['requesting']) // Display SELL button conditionally
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('SELL'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: BookListScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
