import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../utils/validation.dart';

// Basic text input field
class ProfileTextInput extends StatelessWidget {
  final String label;
  final String? hint;
  final String? value;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int? minLength;
  final int? maxLines;
  final bool isRequired;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const ProfileTextInput({
    Key? key,
    required this.label,
    this.hint,
    this.value,
    this.keyboardType,
    this.maxLength,
    this.minLength,
    this.maxLines = 1,
    this.isRequired = false,
    this.errorText,
    this.onChanged,
    this.onTap,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          onChanged: onChanged,
          onTap: onTap,
          validator: validator ?? (value) {
            return ValidationUtils.validateField(
              value: value,
              fieldName: label,
              isRequired: isRequired,
              maxLength: maxLength,
              minLength: minLength,
            );
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.greyLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: AppTypography.body2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// Dropdown input field
class ProfileDropdownInput<T extends ReferenceItem> extends StatelessWidget {
  final String label;
  final T? selectedValue;
  final List<T> options;
  final bool isRequired;
  final String? errorText;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? displayText;

  const ProfileDropdownInput({
    Key? key,
    required this.label,
    this.selectedValue,
    required this.options,
    this.isRequired = false,
    this.errorText,
    this.onChanged,
    this.displayText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: selectedValue,
          items: options.map((option) {
            return DropdownMenuItem<T>(
              value: option,
              child: Text(
                displayText?.call(option) ?? option.name,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Select $label',
            hintStyle: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.greyLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          dropdownColor: Colors.white,
          style: AppTypography.body2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// Multi-select dropdown
class ProfileMultiSelectInput<T extends ReferenceItem> extends StatefulWidget {
  final String label;
  final List<T> selectedValues;
  final List<T> options;
  final bool isRequired;
  final String? errorText;
  final ValueChanged<List<T>>? onChanged;
  final String Function(T)? displayText;

  const ProfileMultiSelectInput({
    Key? key,
    required this.label,
    required this.selectedValues,
    required this.options,
    this.isRequired = false,
    this.errorText,
    this.onChanged,
    this.displayText,
  }) : super(key: key);

  @override
  State<ProfileMultiSelectInput<T>> createState() => _ProfileMultiSelectInputState<T>();
}

class _ProfileMultiSelectInputState<T extends ReferenceItem> extends State<ProfileMultiSelectInput<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.isRequired)
              Text(
                ' *',
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Selected items chips
        if (widget.selectedValues.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedValues.map((item) {
              return Chip(
                label: Text(
                  widget.displayText?.call(item) ?? item.name,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: AppColors.primary,
                deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                onDeleted: () {
                  final newList = List<T>.from(widget.selectedValues);
                  newList.remove(item);
                  widget.onChanged?.call(newList);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        
        // Dropdown button
        InkWell(
          onTap: () => _showMultiSelectDialog(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(8),
              border: widget.errorText != null
                  ? Border.all(color: AppColors.error, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selectedValues.isEmpty
                        ? 'Select ${widget.label}'
                        : '${widget.selectedValues.length} selected',
                    style: AppTypography.body2.copyWith(
                      color: widget.selectedValues.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  void _showMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select ${widget.label}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.options.length,
            itemBuilder: (context, index) {
              final option = widget.options[index];
              final isSelected = widget.selectedValues.contains(option);
              
              return CheckboxListTile(
                title: Text(
                  widget.displayText?.call(option) ?? option.name,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                value: isSelected,
                onChanged: (value) {
                  final newList = List<T>.from(widget.selectedValues);
                  if (value == true) {
                    newList.add(option);
                  } else {
                    newList.remove(option);
                  }
                  widget.onChanged?.call(newList);
                },
                activeColor: AppColors.primary,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// Range slider for age/distance
class ProfileRangeSlider extends StatelessWidget {
  final String label;
  final RangeValues value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double)? displayText;
  final ValueChanged<RangeValues>? onChanged;

  const ProfileRangeSlider({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions = 100,
    this.displayText,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        // Range display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayText?.call(value.start) ?? value.start.round().toString(),
              style: AppTypography.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'to',
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              displayText?.call(value.end) ?? value.end.round().toString(),
              style: AppTypography.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Range slider
        RangeSlider(
          values: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.greyMedium,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// Toggle switch
class ProfileToggleSwitch extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ProfileToggleSwitch({
    Key? key,
    required this.label,
    this.description,
    required this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

// Date picker
class ProfileDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final bool isRequired;
  final String? errorText;
  final ValueChanged<DateTime>? onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const ProfileDatePicker({
    Key? key,
    required this.label,
    this.selectedDate,
    this.isRequired = false,
    this.errorText,
    this.onDateSelected,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showDatePicker(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(8),
              border: errorText != null
                  ? Border.all(color: AppColors.error, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'Select date',
                    style: AppTypography.body2.copyWith(
                      color: selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  void _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 36500)), // 100 years ago
      lastDate: lastDate ?? DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && onDateSelected != null) {
      onDateSelected!(picked);
    }
  }
}
