import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/circle_creation_provider.dart';
import '../../../../core/theme/app_theme.dart';

/// Form for entering basic circle details (Step 1)
class CircleDetailsForm extends StatefulWidget {
  const CircleDetailsForm({Key? key}) : super(key: key);

  @override
  State<CircleDetailsForm> createState() => _CircleDetailsFormState();
}

class _CircleDetailsFormState extends State<CircleDetailsForm> {
  final GlobalKey<ShadFormState> _formKey = GlobalKey<ShadFormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Default icons for selection
  final List<IconData> _defaultIcons = [
    Icons.groups_rounded,
    Icons.family_restroom_rounded,
    Icons.sports_basketball_rounded,
    Icons.restaurant_rounded,
    Icons.school_rounded,
    Icons.movie_rounded,
    Icons.work_rounded,
    Icons.celebration_rounded,
    Icons.hiking_rounded,
    Icons.music_note_rounded,
    Icons.book_rounded,
    Icons.favorite_rounded,
  ];
  
  // Currently selected icon
  IconData? _selectedIcon;
  
  @override
  void initState() {
    super.initState();
    // Initialize form with current data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CircleCreationProvider>(context, listen: false);
      _nameController.text = provider.data.name;
      _descriptionController.text = provider.data.description;
      setState(() {
        _selectedIcon = provider.data.selectedIcon ?? _defaultIcons[0];
      });
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview of circle avatar
          _buildCirclePreview(),
          
          const SizedBox(height: 24),
          
          // Form fields
          ShadForm(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadInputFormField(
                  controller: _nameController,
                  id: 'circle-name',
                  label: const Text('Circle Name'),
                  placeholder: const Text('Enter circle name...'),
                  onChanged: (value) {
                    Provider.of<CircleCreationProvider>(context, listen: false)
                        .updateBasicDetails(name: value);
                  },
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  'Circle Icon',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.foreground,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                _buildIconSelector(),
                
                const SizedBox(height: 20),
                
                ShadInputFormField(
                  controller: _descriptionController,
                  id: 'circle-description',
                  label: const Text('Description'),
                  placeholder: const Text('What is this circle for? (optional)'),
                  maxLength: 200,
                  minLines: 3,
                  maxLines: 5,
                  onChanged: (value) {
                    Provider.of<CircleCreationProvider>(context, listen: false)
                        .updateBasicDetails(description: value);
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
        ],
      ),
    );
  }
  
  Widget _buildCirclePreview() {
    final theme = ShadTheme.of(context);
    final provider = Provider.of<CircleCreationProvider>(context);
    
    // Get initials if name exists
    String initials = '';
    if (_nameController.text.isNotEmpty) {
      initials = _nameController.text.split(' ')
          .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
          .join('')
          .substring(0, _nameController.text.split(' ').length > 1 ? 2 : 1);
    }
    
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.accent.withOpacity(0.2),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipOval(
          child: provider.data.isUsingCustomImage && provider.data.customIconImage != null
              ? Image.file(
                  provider.data.customIconImage!,
                  fit: BoxFit.cover,
                )
              : Center(
                  child: _nameController.text.isEmpty
                      ? Icon(
                          _selectedIcon ?? Icons.groups_rounded,
                          size: 50,
                          color: theme.colorScheme.primary,
                        )
                      : _selectedIcon != null
                          ? Icon(
                              _selectedIcon!,
                              size: 50,
                              color: theme.colorScheme.primary,
                            )
                          : Text(
                              initials,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                ),
        ),
      ).animate().scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: 600.ms,
        curve: Curves.elasticOut,
      ),
    );
  }
  
  Widget _buildIconSelector() {
    final theme = ShadTheme.of(context);
    final provider = Provider.of<CircleCreationProvider>(context);
    
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: theme.colorScheme.card.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.border,
          width: 1,
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: _defaultIcons.length + 1, // +1 for custom upload option
        itemBuilder: (context, index) {
          if (index == _defaultIcons.length) {
            // Custom upload option
            return InkWell(
              onTap: () {
                // In a real app, this would open image picker
                _showImageSourceDialog();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.border,
                    width: 1,
                  ),
                  color: theme.colorScheme.background,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Custom',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Icon selection option
          final icon = _defaultIcons[index];
          final isSelected = _selectedIcon == icon && !provider.data.isUsingCustomImage;
          
          return InkWell(
            onTap: () {
              setState(() {
                _selectedIcon = icon;
              });
              provider.updateBasicDetails(
                selectedIcon: icon,
                isUsingCustomImage: false,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.border,
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.background,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.mutedForeground,
                size: 24,
              ),
            ),
          ).animate().scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 400.ms,
            delay: (50 * index).ms,
            curve: Curves.easeOutBack,
          );
        },
      ),
    );
  }
  
  void _showImageSourceDialog() {
    final theme = ShadTheme.of(context);
    
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Choose Image Source'),
        description: const Text('Select where you want to get your circle image from.'),
        actions: [
          ShadButton.outline(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, this would launch camera
              _showImageUnavailableMessage('Camera');
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text('Camera'),
              ],
            ),
          ),
          ShadButton.outline(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, this would launch gallery
              _showImageUnavailableMessage('Gallery');
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text('Gallery'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showImageUnavailableMessage(String source) {
    final theme = ShadTheme.of(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.primary,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$source access is not available in this demo.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 