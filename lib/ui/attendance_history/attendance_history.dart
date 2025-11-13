import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final CollectionReference dataCollection = 
      FirebaseFirestore.instance.collection('attendance');
  
  String _filterType = 'All';
  final List<String> _filterOptions = ['All', 'Attendance', 'Permission'];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _isLoading = false;
      _errorMessage = null;
    });
  }

  // Function untuk mendapatkan type dengan safe check
  String _getDocumentType(QueryDocumentSnapshot doc) {
    try {
      return doc['type'] ?? 'attendance'; // Default to attendance if type doesn't exist
    } catch (e) {
      return 'attendance'; // Default if field doesn't exist
    }
  }

  // Function untuk mendapatkan data dengan safe check
  String _getDocumentField(QueryDocumentSnapshot doc, String field, [String defaultValue = '-']) {
    try {
      return doc[field]?.toString() ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  // Function Edit Data dengan safe data access
  void _editData(QueryDocumentSnapshot doc) {
    String docId = doc.id;
    String currentName = _getDocumentField(doc, 'name');
    String currentAddress = _getDocumentField(doc, 'address');
    String currentDescription = _getDocumentField(doc, 'description');
    String currentDatetime = _getDocumentField(doc, 'datetime');

    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController addressController = TextEditingController(text: currentAddress);
    TextEditingController descriptionController = TextEditingController(text: currentDescription);
    TextEditingController datetimeController = TextEditingController(text: currentDatetime);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Edit Attendance Data",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Form Fields
              _buildEditFormField(
                controller: nameController,
                label: "Name",
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),
              _buildEditFormField(
                controller: addressController,
                label: "Address", 
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              _buildEditFormField(
                controller: descriptionController,
                label: "Description",
                icon: Icons.description_outlined,
              ),
              const SizedBox(height: 16),
              _buildEditFormField(
                controller: datetimeController,
                label: "Date & Time",
                icon: Icons.access_time_rounded,
              ),
              const SizedBox(height: 32),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        try {
                          await dataCollection.doc(docId).update({
                            'name': nameController.text,
                            'address': addressController.text,
                            'description': descriptionController.text,
                            'datetime': datetimeController.text,
                            'updated_at': FieldValue.serverTimestamp(),
                            'type': _getDocumentType(doc), // Preserve existing type
                          });
                          Navigator.pop(context);
                          setState(() {});
                        } catch (e) {
                          // Handle update error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating data: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.grey.shade500),
        ),
      ),
    );
  }

  // Function Delete Data
  void _deleteData(String docId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade600,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Delete Data?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to delete this attendance record? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        try {
                          await dataCollection.doc(docId).delete();
                          Navigator.pop(context);
                          setState(() {});
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error deleting data: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function untuk mendapatkan warna berdasarkan type
  Color _getTypeColor(String type) {
    switch (type) {
      case 'permission':
        return Colors.orange.shade600;
      case 'attendance':
        return Colors.green.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  // Function untuk mendapatkan icon berdasarkan type
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'permission':
        return Icons.beach_access_rounded;
      case 'attendance':
        return Icons.fingerprint_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  // Function untuk format timestamp
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('dd MMM yyyy - HH:mm').format(timestamp.toDate());
    }
    return timestamp?.toString() ?? 'Unknown date';
  }

  // Function untuk menentukan type berdasarkan description
  String _inferTypeFromDescription(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('permission') || desc.contains('leave') || desc.contains('sick')) {
      return 'permission';
    }
    return 'attendance';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Custom Header
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade800,
                  Colors.lightBlue.shade600,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Attendance History",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "View and manage all attendance records",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list_rounded, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Text(
                    "Filter:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterType,
                        onChanged: (value) {
                          setState(() {
                            _filterType = value!;
                          });
                        },
                        items: _filterOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                              ),
                            ),
                          );
                        }).toList(),
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Data List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: dataCollection.orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                var data = snapshot.data!.docs;
                
                // Apply filter dengan safe type checking
                var filteredData = data.where((doc) {
                  if (_filterType == 'All') return true;
                  
                  String type;
                  try {
                    type = _getDocumentType(doc);
                  } catch (e) {
                    // Jika type field tidak ada, infer dari description
                    type = _inferTypeFromDescription(_getDocumentField(doc, 'description'));
                  }

                  if (_filterType == 'Attendance') {
                    return type != 'permission';
                  }
                  if (_filterType == 'Permission') {
                    return type == 'permission';
                  }
                  return true;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    var doc = filteredData[index];
                    
                    // Safe data access dengan error handling
                    String docId = doc.id;
                    String name = _getDocumentField(doc, 'name', 'Unknown');
                    String address = _getDocumentField(doc, 'address');
                    String description = _getDocumentField(doc, 'description');
                    String datetime = _getDocumentField(doc, 'datetime');
                    dynamic createdAt = _getDocumentField(doc, 'created_at', '');
                    
                    String type;
                    try {
                      type = _getDocumentType(doc);
                    } catch (e) {
                      type = _inferTypeFromDescription(description);
                    }

                    return _buildHistoryCard(
                      doc: doc,
                      name: name,
                      address: address,
                      description: description,
                      datetime: datetime,
                      type: type,
                      createdAt: createdAt,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required QueryDocumentSnapshot doc,
    required String name,
    required String address,
    required String description,
    required String datetime,
    required String type,
    required dynamic createdAt,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar dengan type indicator
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _getTypeIcon(type),
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan name dan type
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTypeColor(type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _getTypeColor(type).withOpacity(0.3)),
                          ),
                          child: Text(
                            type == 'permission' ? 'Permission' : 'Attendance',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getTypeColor(type),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Details
                    _buildDetailRow(Icons.description_outlined, description),
                    const SizedBox(height: 4),
                    _buildDetailRow(Icons.access_time_rounded, datetime),
                    const SizedBox(height: 4),
                    if (createdAt is Timestamp) 
                      _buildDetailRow(Icons.calendar_today_rounded, _formatTimestamp(createdAt)),
                    if (address.isNotEmpty && address != '-')
                      _buildDetailRow(Icons.location_on_outlined, address),
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  // Edit Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit_rounded, color: Colors.blue.shade700, size: 20),
                      onPressed: () => _editData(doc),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Delete Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete_rounded, color: Colors.red.shade600, size: 20),
                      onPressed: () => _deleteData(doc.id),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Loading History...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade600,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Error Loading Data",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_toggle_off_rounded,
              color: Colors.grey.shade400,
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No Attendance Records",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Attendance records will appear here once they are created",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}