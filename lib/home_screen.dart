import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_book_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp(BuildContext context, String whatsappNumber, String itemTitle) async {
    setState(() => _isLoading = true);
    try {
      final message = Uri.encodeComponent('Hi, I am interested in "$itemTitle". Can we connect?');
      final whatsappUrl = 'https://wa.me/$whatsappNumber?text=$message';

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar(context, 'Could not open WhatsApp.');
      }
    } catch (e) {
      _showSnackBar(context, 'Error opening WhatsApp: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'No Name';
    final userEmail = user?.email ?? 'No Email';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(userName, userEmail),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                _buildBookList(),
                _buildNoteList(),
              ],
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.yellow,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBookScreen()),
          ),
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String userName, String userEmail) {
    return AppBar(
      backgroundColor: Colors.yellow,
      elevation: 1,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              userName: userName,
              userEmail: userEmail,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_showSearch ? Icons.close : Icons.search, color: Colors.black),
          onPressed: () => setState(() {
            _showSearch = !_showSearch;
            if (!_showSearch) {
              _searchController.clear();
              _searchQuery = '';
            }
          }),
        ),
      ],
      title: _showSearch
          ? _buildSearchField()
          : Image.asset(
              'assets/images/logo.png',
              color: Colors.black,
              height: 230,
            ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(text: 'Books'),
          Tab(text: 'Notes'),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search books or notes...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.black54),
        ),
        style: const TextStyle(color: Colors.black),
        onChanged: (value) => setState(() => _searchQuery = value),
        autofocus: true,
      ),
    );
  }

  Widget _buildBookList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Books')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = _filterItems(snapshot.data?.docs ?? [], isBook: true);

        if (items.isEmpty) {
          return _buildEmptyState('books');
        }

        return ListView.builder(
          itemCount: items.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) => _buildItemCard(items[index], isBook: true),
        );
      },
    );
  }

  Widget _buildNoteList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Notes')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = _filterItems(snapshot.data?.docs ?? [], isBook: false);

        if (items.isEmpty) {
          return _buildEmptyState('notes');
        }

        return ListView.builder(
          itemCount: items.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) => _buildItemCard(items[index], isBook: false),
        );
      },
    );
  }

  List<DocumentSnapshot> _filterItems(List<DocumentSnapshot> docs, {required bool isBook}) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || !_isValidItem(data)) return false;

      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      final title = data['title'].toString().toLowerCase();
      final author = data['author'].toString().toLowerCase();

      return title.contains(query) || author.contains(query);
    }).toList();
  }

  bool _isValidItem(Map<String, dynamic> data) {
    return data['title'] != null &&
        data['title'].toString().isNotEmpty &&
        data['author'] != null &&
        data['author'].toString().isNotEmpty;
  }

  Widget _buildEmptyState(String itemType) {
    return Center(
      child: Text(
        _searchQuery.isEmpty
            ? 'No $itemType available'
            : 'No $itemType found matching "$_searchQuery"',
      ),
    );
  }

  Widget _buildItemCard(DocumentSnapshot doc, {required bool isBook}) {
    final item = doc.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildItemImage(item),
            const SizedBox(width: 16),
            Expanded(child: _buildItemDetails(item, isBook)),
            _buildWhatsAppButton(item),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(Map<String, dynamic> item) {
    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: item['imageUrl'] != null
          ? Image.network(
              item['imageUrl'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 50, color: Colors.grey),
            )
          : const Icon(Icons.insert_drive_file, size: 50, color: Colors.grey),
    );
  }

  Widget _buildItemDetails(Map<String, dynamic> item, bool isBook) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['title'] ?? '',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'By ${item['author'] ?? ''}',
          style: const TextStyle(color: Colors.grey),
        ),
        if (isBook) ...[
          const SizedBox(height: 8),
          _buildTransactionType(item),
        ],
        if (!isBook) ...[
          const SizedBox(height: 8),
          Text(
            'Class: ${item['class']}',
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 8),
          _buildTransactionType(item),
        ],
      ],
    );
  }

  Widget _buildTransactionType(Map<String, dynamic> item) {
    final transactionType = item['transactionType'];
    if (transactionType == null || transactionType.isEmpty) {
      return const Text(
        'Transaction Type: Not Available',
        style: TextStyle(color: Colors.red),
      );
    }

    String displayText;
    switch (transactionType) {
      case 'Sell':
        displayText = 'Sell: RS:${item['price'] ?? 'Not Specified'}';
        break;
      case 'Rent':
        displayText = 'Rent: RS:${item['price'] ?? 'Not Specified'}';
        break;
      case 'Exchange':
        displayText = 'Exchange';
        break;
      default:
        displayText = 'Unknown';
    }

    return Chip(
      label: Text(displayText),
      backgroundColor: Colors.yellow,
    );
  }

  Widget _buildWhatsAppButton(Map<String, dynamic> item) {
    return IconButton(
      onPressed: () {
        final whatsappNumber = item['whatsappNumber'];
        if (whatsappNumber != null && whatsappNumber.isNotEmpty) {
          _openWhatsApp(context, whatsappNumber, item['title']);
        } else {
          _showSnackBar(context, 'WhatsApp number not available.');
        }
      },
      icon: Image.asset(
        'assets/icons/whatsapp.png',
        width: 40.0,
        height: 40.0,
      ),
    );
  }
}
