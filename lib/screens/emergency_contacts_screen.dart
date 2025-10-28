import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/emergency_contact.dart';
import '../services/api_services/emergency_contact_api_service.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Emergency Contacts Management Screen
/// 
/// Features:
/// - Add/edit/delete emergency contacts
/// - Verify contacts via SMS/email
/// - Set relationships
/// - Quick emergency alert button
class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  late EmergencyContactApiService _apiService;
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = EmergencyContactApiService(
      authService: AuthService(),
    );
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);

    try {
      final contacts = await _apiService.getEmergencyContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contacts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addContact() async {
    final result = await showDialog<EmergencyContact>(
      context: context,
      builder: (context) => const _AddEditContactDialog(),
    );

    if (result != null) {
      await _loadContacts();
    }
  }

  Future<void> _editContact(EmergencyContact contact) async {
    final result = await showDialog<EmergencyContact>(
      context: context,
      builder: (context) => _AddEditContactDialog(contact: contact),
    );

    if (result != null) {
      await _loadContacts();
    }
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Delete Contact',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${contact.name}?',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTypography.button.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteEmergencyContact(contact.id);
        await _loadContacts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _verifyContact(EmergencyContact contact) async {
    try {
      await _apiService.sendVerificationCode(contact.id);
      if (mounted) {
        final code = await showDialog<String>(
          context: context,
          builder: (context) => _VerificationDialog(contact: contact),
        );

        if (code != null && code.isNotEmpty) {
          await _apiService.verifyContact(
            contactId: contact.id,
            code: code,
          );
          await _loadContacts();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contact verified successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        title: Text(
          'Emergency Contacts',
          style: AppTypography.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Info Banner
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add trusted contacts who will be notified in case of emergency',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contacts List
                Expanded(
                  child: _contacts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.contacts,
                                size: 80,
                                color: Colors.white24,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No emergency contacts yet',
                                style: AppTypography.body1.copyWith(
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add your first contact',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _contacts.length,
                          itemBuilder: (context, index) {
                            final contact = _contacts[index];
                            return _ContactCard(
                              contact: contact,
                              onEdit: () => _editContact(contact),
                              onDelete: () => _deleteContact(contact),
                              onVerify: () => _verifyContact(contact),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onVerify;

  const _ContactCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                contact.name[0].toUpperCase(),
                style: AppTypography.h4.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    contact.name,
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (contact.isVerified)
                  const Icon(
                    Icons.verified,
                    color: Colors.green,
                    size: 20,
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  contact.phoneNumber,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white70,
                  ),
                ),
                if (contact.email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    contact.email!,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    contact.relationship,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.white54),
              color: AppColors.navbarBackground,
              itemBuilder: (context) => [
                if (!contact.isVerified)
                  PopupMenuItem(
                    onTap: onVerify,
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Verify',
                          style: AppTypography.body2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  onTap: onEdit,
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: AppTypography.body2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: onDelete,
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: AppTypography.body2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddEditContactDialog extends StatefulWidget {
  final EmergencyContact? contact;

  const _AddEditContactDialog({this.contact});

  @override
  State<_AddEditContactDialog> createState() => _AddEditContactDialogState();
}

class _AddEditContactDialogState extends State<_AddEditContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _relationship = 'Family';
  bool _isLoading = false;

  final List<String> _relationships = [
    'Family',
    'Friend',
    'Partner',
    'Colleague',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.contact?.phoneNumber ?? '');
    _emailController =
        TextEditingController(text: widget.contact?.email ?? '');
    _relationship = widget.contact?.relationship ?? 'Family';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = EmergencyContactApiService(
        authService: AuthService(),
      );

      if (widget.contact == null) {
        await apiService.addEmergencyContact(
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          relationship: _relationship,
        );
      } else {
        await apiService.updateEmergencyContact(
          contactId: widget.contact!.id,
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          relationship: _relationship,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.navbarBackground,
      title: Text(
        widget.contact == null ? 'Add Contact' : 'Edit Contact',
        style: AppTypography.h4.copyWith(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                style: AppTypography.body1.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: AppTypography.body2.copyWith(
                    color: Colors.white54,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                style: AppTypography.body1.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: AppTypography.body2.copyWith(
                    color: Colors.white54,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                style: AppTypography.body1.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email (Optional)',
                  labelStyle: AppTypography.body2.copyWith(
                    color: Colors.white54,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _relationship,
                style: AppTypography.body1.copyWith(color: Colors.white),
                dropdownColor: AppColors.navbarBackground,
                decoration: InputDecoration(
                  labelText: 'Relationship',
                  labelStyle: AppTypography.body2.copyWith(
                    color: Colors.white54,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                items: _relationships
                    .map((rel) => DropdownMenuItem(
                          value: rel,
                          child: Text(rel),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _relationship = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTypography.button.copyWith(color: Colors.white54),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Save',
                  style: AppTypography.button.copyWith(
                    color: AppColors.primary,
                  ),
                ),
        ),
      ],
    );
  }
}

class _VerificationDialog extends StatefulWidget {
  final EmergencyContact contact;

  const _VerificationDialog({required this.contact});

  @override
  State<_VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<_VerificationDialog> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.navbarBackground,
      title: Text(
        'Verify Contact',
        style: AppTypography.h4.copyWith(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'A verification code has been sent to ${widget.contact.phoneNumber}',
            style: AppTypography.body2.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            style: AppTypography.body1.copyWith(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Verification Code',
              labelStyle: AppTypography.body2.copyWith(
                color: Colors.white54,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTypography.button.copyWith(color: Colors.white54),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _codeController.text),
          child: Text(
            'Verify',
            style: AppTypography.button.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

