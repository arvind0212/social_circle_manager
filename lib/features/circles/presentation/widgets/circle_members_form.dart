import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/circle_creation_model.dart';
import '../providers/circle_creation_provider.dart';
import '../../../../core/theme/app_theme.dart';

/// Form for adding members to the circle (Step 2)
class CircleMembersForm extends StatefulWidget {
  const CircleMembersForm({Key? key}) : super(key: key);

  @override
  State<CircleMembersForm> createState() => _CircleMembersFormState();
}

class _CircleMembersFormState extends State<CircleMembersForm> {
  final TextEditingController _memberController = TextEditingController();
  final GlobalKey<ShadFormState> _formKey = GlobalKey<ShadFormState>();
  
  @override
  void dispose() {
    _memberController.dispose();
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
          // Availability explanation card
          _buildAvailabilityExplanationCard(),
          
          const SizedBox(height: 24),
          
          // Member input form
          ShadForm(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ShadInputFormField(
                    controller: _memberController,
                    id: 'add-member',
                    label: const Text('Add Member'),
                    placeholder: const Text('Enter email or phone number...'),
                  ),
                ),
                const SizedBox(width: 12),
                ShadButton(
                  onPressed: _addMember,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Or add from contacts
          _buildContactsButton(),
          
          const SizedBox(height: 20),
          
          // Members list
          _buildMembersList(),
        ],
      ),
    );
  }
  
  Widget _buildAvailabilityExplanationCard() {
    final theme = ShadTheme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.lerp(
          theme.colorScheme.accent.withOpacity(0.1),
          theme.colorScheme.primary.withOpacity(0.05),
          0.5,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Member Availability',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Added members will share their availability status (free/busy) for event planning. Their detailed calendar events will remain private.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }
  
  Widget _buildContactsButton() {
    final theme = ShadTheme.of(context);
    
    return Center(
      child: ShadButton.outline(
        onPressed: _handleContactsAccess,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.contacts_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Add from Contacts'),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }
  
  Widget _buildMembersList() {
    final provider = Provider.of<CircleCreationProvider>(context);
    final theme = ShadTheme.of(context);
    
    if (provider.data.members.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.person_add_alt_1_outlined,
                size: 48,
                color: theme.colorScheme.mutedForeground.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No members added yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Add members by email or phone, or import from your contacts',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.mutedForeground.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'Added Members (${provider.data.members.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.foreground,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.border,
              width: 1,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.data.members.length,
            separatorBuilder: (context, index) => Divider(
              color: theme.colorScheme.border,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final member = provider.data.members[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.accent.withOpacity(0.2),
                  radius: 20,
                  child: member.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            member.photoUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          member.name != null && member.name!.isNotEmpty
                              ? member.name![0].toUpperCase()
                              : member.identifier[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                ),
                title: Text(
                  member.name ?? member.identifier,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.foreground,
                  ),
                ),
                subtitle: member.name != null
                    ? Text(
                        member.identifier,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      )
                    : null,
                trailing: IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: theme.colorScheme.destructive,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    provider.removeMember(member.id);
                  },
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }
  
  void _addMember() {
    final theme = ShadTheme.of(context);
    final email = _memberController.text.trim();
    
    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address.'),
          backgroundColor: theme.colorScheme.destructive,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    final provider = Provider.of<CircleCreationProvider>(context, listen: false);
    
    // Check if member already exists
    if (provider.data.members.any((m) => m.identifier.toLowerCase() == email.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This member is already added.'),
          backgroundColor: theme.colorScheme.destructive,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Add new member
    provider.addMember(
      CircleMember(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Just for demo
        identifier: email,
      ),
    );
    
    // Clear the field
    _memberController.clear();
    
    HapticFeedback.lightImpact();
  }
  
  void _handleContactsAccess() {
    final theme = ShadTheme.of(context);
    
    // In a real app, this would request contacts permission and show contacts picker
    // For this demo, we'll show a dialog with mock contacts
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Select Contacts'),
        description: const Text('Choose contacts to add to your circle.'),
        child: SizedBox(
          width: double.infinity,
          height: 300,
          child: _buildMockContactsList(),
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMockContactsList() {
    final theme = ShadTheme.of(context);
    final provider = Provider.of<CircleCreationProvider>(context, listen: false);
    
    // Mock contacts data
    final List<Map<String, String>> mockContacts = [
      {'name': 'John Smith', 'email': 'john.smith@example.com'},
      {'name': 'Sarah Johnson', 'email': 'sarah.j@example.com'},
      {'name': 'Michael Brown', 'email': 'michael.brown@example.com'},
      {'name': 'Emily Davis', 'email': 'emily.davis@example.com'},
      {'name': 'David Wilson', 'email': 'david.wilson@example.com'},
      {'name': 'Olivia Miller', 'email': 'olivia.m@example.com'},
      {'name': 'James Taylor', 'email': 'james.t@example.com'},
      {'name': 'Sophia White', 'email': 'sophia.white@example.com'},
    ];
    
    return ListView.builder(
      itemCount: mockContacts.length,
      itemBuilder: (context, index) {
        final contact = mockContacts[index];
        final name = contact['name']!;
        final email = contact['email']!;
        final isAdded = provider.data.members.any((m) => m.identifier.toLowerCase() == email.toLowerCase());
        
        return CheckboxListTile(
          value: isAdded,
          onChanged: (selected) {
            HapticFeedback.lightImpact();
            if (selected == true && !isAdded) {
              provider.addMember(
                CircleMember(
                  id: DateTime.now().millisecondsSinceEpoch.toString() + index.toString(),
                  identifier: email,
                  name: name,
                  status: MemberStatus.pending,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('$name added to circle'),
                  backgroundColor: theme.colorScheme.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            } else if (selected == false && isAdded) {
              final memberId = provider.data.members
                  .firstWhere((m) => m.identifier.toLowerCase() == email.toLowerCase())
                  .id;
              provider.removeMember(memberId);
            }
          },
          title: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.foreground,
            ),
          ),
          subtitle: Text(
            email,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          secondary: CircleAvatar(
            backgroundColor: theme.colorScheme.accent.withOpacity(0.2),
            child: Text(
              name[0],
              style: TextStyle(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
} 