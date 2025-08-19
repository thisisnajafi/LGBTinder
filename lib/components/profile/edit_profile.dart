import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;

  const EditProfile({
    Key? key,
    required this.initialData,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.initialData);
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        await widget.onSave(_formData);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: AppTypography.titleMediumStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTypography.buttonStyle.copyWith(
                      color: AppColors.primaryLight,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _EditSection(
              title: 'Basic Information',
              children: [
                _EditTextField(
                  label: 'Name',
                  initialValue: _formData['name'] ?? '',
                  onSaved: (value) => _formData['name'] = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                _EditTextField(
                  label: 'Bio',
                  initialValue: _formData['bio'] ?? '',
                  onSaved: (value) => _formData['bio'] = value,
                  maxLines: 3,
                ),
                _EditTextField(
                  label: 'Location',
                  initialValue: _formData['location'] ?? '',
                  onSaved: (value) => _formData['location'] = value,
                  icon: Icons.location_on,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _EditSection(
              title: 'Personal Information',
              children: [
                _EditDropdownField(
                  label: 'Gender',
                  value: _formData['gender'] ?? '',
                  items: const ['Male', 'Female', 'Non-binary', 'Other'],
                  onChanged: (value) {
                    setState(() => _formData['gender'] = value);
                  },
                ),
                _EditDropdownField(
                  label: 'Orientation',
                  value: _formData['orientation'] ?? '',
                  items: const [
                    'Straight',
                    'Gay',
                    'Lesbian',
                    'Bisexual',
                    'Pansexual',
                    'Other'
                  ],
                  onChanged: (value) {
                    setState(() => _formData['orientation'] = value);
                  },
                ),
                _EditDropdownField(
                  label: 'Relationship Status',
                  value: _formData['relationshipStatus'] ?? '',
                  items: const [
                    'Single',
                    'In a relationship',
                    'Married',
                    'Divorced',
                    'Widowed',
                    'Other'
                  ],
                  onChanged: (value) {
                    setState(() => _formData['relationshipStatus'] = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _EditSection(
              title: 'Interests',
              children: [
                _EditChipsField(
                  label: 'Add Interests',
                  initialValues: List<String>.from(_formData['interests'] ?? []),
                  onChanged: (values) {
                    setState(() => _formData['interests'] = values);
                  },
                  suggestions: const [
                    'Music',
                    'Movies',
                    'Books',
                    'Sports',
                    'Travel',
                    'Food',
                    'Art',
                    'Photography',
                    'Gaming',
                    'Fitness',
                    'Dancing',
                    'Cooking',
                    'Fashion',
                    'Technology',
                    'Nature',
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _EditSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleSmallStyle.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _EditTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final Function(String?) onSaved;
  final String? Function(String?)? validator;
  final int? maxLines;
  final IconData? icon;

  const _EditTextField({
    required this.label,
    this.initialValue,
    required this.onSaved,
    this.validator,
    this.maxLines = 1,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextFormField(
        initialValue: initialValue,
        onSaved: onSaved,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _EditDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String?) onChanged;

  const _EditDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _EditChipsField extends StatefulWidget {
  final String label;
  final List<String> initialValues;
  final Function(List<String>) onChanged;
  final List<String> suggestions;

  const _EditChipsField({
    required this.label,
    required this.initialValues,
    required this.onChanged,
    required this.suggestions,
  });

  @override
  State<_EditChipsField> createState() => _EditChipsFieldState();
}

class _EditChipsFieldState extends State<_EditChipsField> {
  late List<String> _selectedValues;
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedValues = List<String>.from(widget.initialValues);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addValue(String value) {
    if (value.isNotEmpty && !_selectedValues.contains(value)) {
      setState(() {
        _selectedValues.add(value);
        widget.onChanged(_selectedValues);
      });
      _textController.clear();
    }
  }

  void _removeValue(String value) {
    setState(() {
      _selectedValues.remove(value);
      widget.onChanged(_selectedValues);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: AppTypography.bodyMediumStyle,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedValues.map((value) {
              return Chip(
                label: Text(value),
                onDeleted: () => _removeValue(value),
                backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                labelStyle: TextStyle(color: AppColors.primaryLight),
                deleteIconColor: AppColors.primaryLight,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Type and press enter',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addValue(_textController.text),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: _addValue,
          ),
          if (_textController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.suggestions
                  .where((suggestion) =>
                      suggestion.toLowerCase().contains(_textController.text.toLowerCase()) &&
                      !_selectedValues.contains(suggestion))
                  .map((suggestion) {
                return ActionChip(
                  label: Text(suggestion),
                  onPressed: () => _addValue(suggestion),
                  backgroundColor: AppColors.primaryLight.withOpacity(0.05),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
} 