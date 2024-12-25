import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  String _category = 'Book'; // Default category
  String _transactionType = 'Sell'; // Default transaction type
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  // Save data to Firestore
  Future<void> _saveData() async {
    final String title = _titleController.text.trim();
    final String author = _authorController.text.trim();
    final String classStandard = _classController.text.trim();
    final String priceText = _priceController.text.trim();
    final String whatsappNumber = _whatsappController.text.trim();

    if (title.isEmpty || author.isEmpty || (_category == 'Note' && classStandard.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    // Validate WhatsApp number
    if (whatsappNumber.isEmpty || !RegExp(r'^\+\d{10,15}$').hasMatch(whatsappNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid WhatsApp number with country code.')),
      );
      return;
    }

    double? price;
    if (_transactionType == 'Sell' || _transactionType == 'Rent') {
      if (priceText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Price is required for Sell or Rent.')),
        );
        return;
      }

      try {
        price = double.parse(priceText);
        if (price <= 0) throw Exception();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid price format. Enter a valid number.')),
        );
        return;
      }
    }

    String? imageUrl;
    if (_selectedImage != null) {
      setState(() {
        isLoading = true;
      });
      try {
        final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child('book_images/$fileName')
            .putFile(_selectedImage!);
        final TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
        return;
      }
    }

    try {
      final data = {
        'title': title,
        'author': author,
        'category': _category,
        'transactionType': _transactionType,
        'timestamp': FieldValue.serverTimestamp(),
        'whatsappNumber': whatsappNumber, // WhatsApp number added here
        if (_category == 'Note') 'class': classStandard,
        if (_transactionType != 'Exchange' && price != null) 'price': price,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      final String collection = _category == 'Book' ? 'Books' : 'Notes';
      await FirebaseFirestore.instance.collection(collection).add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_category "$title" added successfully!')),
      );
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding $_category: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Optional: Limit image quality
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  // Clear the form
  void _clearForm() {
    _titleController.clear();
    _authorController.clear();
    _classController.clear();
    _priceController.clear();
    _whatsappController.clear(); // Clear WhatsApp field
    setState(() {
      _category = 'Book';
      _transactionType = 'Sell';
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Entry', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.yellow,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _authorController,
                      decoration: const InputDecoration(labelText: 'Author', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    if (_category == 'Note')
                      TextField(
                        controller: _classController,
                        decoration: const InputDecoration(labelText: 'Class/Standard', border: OutlineInputBorder()),
                      ),
                    const SizedBox(height: 16),
                    if (_transactionType != 'Exchange')
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price (INR)', border: OutlineInputBorder()),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp Number (with country code)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedImage != null)
                      Image.file(_selectedImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Add Image'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
                      value: _category,
                      items: ['Book', 'Note']
                          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                          .toList(),
                      onChanged: (value) => setState(() => _category = value!),
                      isExpanded: true,
                      hint: const Text('Select Category'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
                      value: _transactionType,
                      items: ['Sell', 'Rent', 'Exchange']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) => setState(() => _transactionType = value!),
                      isExpanded: true,
                      hint: const Text('Select Transaction Type'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                      child: const Text('Add Entry', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
