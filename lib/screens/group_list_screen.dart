import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicksplit/screens/group/create_group_screen.dart';
import 'package:quicksplit/screens/group/expense_list_screen.dart';
import 'package:quicksplit/screens/paywall_screen.dart';
import 'package:quicksplit/screens/quick_split_screen.dart';
import '../../providers/group_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // title: StatefulBuilder(
        //   builder: (context, setState) {
        //     bool isPressed = false;

        //     return GestureDetector(
        //       onLongPressStart: (_) {
        //         setState(() => isPressed = true);
        //         Future.delayed(const Duration(milliseconds: 150), () {
        //           setState(() => isPressed = false);
        //         });
        //       },
        //       onLongPress: () {
        //         showModalBottomSheet(
        //           context: context,
        //           builder: (context) {
        //             return Padding(
        //               padding: const EdgeInsets.all(16),
        //               child: Column(
        //                 mainAxisSize: MainAxisSize.min,
        //                 children: [
        //                   Text(
        //                     '🧪 Developer Tools',
        //                     style: TextStyle(
        //                       fontSize: 18,
        //                       fontWeight: FontWeight.bold,
        //                       color: Theme.of(context).colorScheme.primary,
        //                     ),
        //                   ),
        //                   const SizedBox(height: 12),
        //                   ElevatedButton(
        //                     onPressed: () async {
        //                       final prefs =
        //                           await SharedPreferences.getInstance();
        //                       await prefs.remove('onboardingComplete');
        //                       await prefs.remove('onboardingDate');
        //                       Navigator.pop(context);
        //                       ScaffoldMessenger.of(context).showSnackBar(
        //                         const SnackBar(
        //                           content: Text(
        //                             'Onboarding reset. Restart the app.',
        //                           ),
        //                         ),
        //                       );
        //                     },
        //                     child: const Text('Reset Onboarding'),
        //                   ),
        //                 ],
        //               ),
        //             );
        //           },
        //         );
        //       },
        //       child: AnimatedScale(
        //         scale: isPressed ? 1.1 : 1.0,
        //         duration: const Duration(milliseconds: 100),
        //         child: Text(
        //           'QuickSplit – My Groups',
        //           style: TextStyle(
        //             color: Theme.of(context).colorScheme.primary,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //     );
        //   },
        // ),
        title: Text(
          'QuickSplit – My Groups',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          groupProvider.groups.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No groups yet. Add one!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: groupProvider.groups.length,
                itemBuilder: (context, index) {
                  final group = groupProvider.groups[index];
                  final totalAmount = group.expenses.fold<double>(
                    0,
                    (sum, e) => sum + e.amount,
                  );

                  return Card(
                    elevation: 2,
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title: Text(
                        group.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      subtitle: Text(
                        '${group.type} • ${group.members.length} member${group.members.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: 'Edit Group',
                            onPressed: () async {
                              final provider = Provider.of<GroupProvider>(
                                context,
                                listen: false,
                              );
                              final isProUser = await provider.isProUser;
                              if (!isProUser) {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: const Text('Upgrade Required'),
                                        content: const Text(
                                          'Editing groups is a premium feature. Upgrade to unlock this functionality.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          const PaywallScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text('Upgrade'),
                                          ),
                                        ],
                                      ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => CreateGroupScreen(
                                        existingGroup: group,
                                      ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            tooltip: 'Delete Group',
                            onPressed: () async {
                              final provider = Provider.of<GroupProvider>(
                                context,
                                listen: false,
                              );
                              final isProUser = await provider.isProUser;
                              if (!isProUser && provider.groups.length <= 2) {
                                // Free user with 2 or fewer groups: show dialog and do NOT proceed
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: const Text('Upgrade Required'),
                                        content: const Text(
                                          'Free users must keep at least 2 groups. Upgrade to delete more groups.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          const PaywallScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text('Upgrade'),
                                          ),
                                        ],
                                      ),
                                );
                                return;
                              }

                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: Text(
                                        'Delete Group?',
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to delete this group? This will remove all associated expenses.',
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.color,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.of(ctx).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(ctx).pop(true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirm == true) {
                                final provider = Provider.of<GroupProvider>(
                                  context,
                                  listen: false,
                                );
                                final removedGroup = group;

                                final success = await provider.removeGroup(
                                  removedGroup.id,
                                );
                                if (!success) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text('Upgrade Required'),
                                          content: const Text(
                                            'Free users must keep at least 2 groups. Upgrade to delete more groups.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) =>
                                                            const PaywallScreen(),
                                                  ),
                                                );
                                              },
                                              child: const Text('Upgrade'),
                                            ),
                                          ],
                                        ),
                                  );
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Group deleted'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      textColor:
                                          Theme.of(context).colorScheme.primary,
                                      onPressed: () {
                                        provider.addGroup(removedGroup);
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpenseListScreen(group: group),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'quickSplit',
            icon: Icon(
              Icons.restaurant,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: Text(
              'Quick Split',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuickSplitScreen()),
              ); // or use MaterialPageRoute if needed
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addGroup',
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () async {
              final provider = Provider.of<GroupProvider>(
                context,
                listen: false,
              );
              final isProUser = await provider.isProUser;
              if (!isProUser && provider.groups.length >= 2) {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text('Upgrade Required'),
                        content: const Text(
                          'Free tier allows up to 2 groups only. Upgrade to premium for more.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PaywallScreen(),
                                ),
                              );
                            },
                            child: const Text('Upgrade'),
                          ),
                        ],
                      ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
              );
            },
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
