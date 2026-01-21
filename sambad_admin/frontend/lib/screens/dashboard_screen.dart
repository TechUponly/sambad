
import 'package:flutter/material.dart';
import 'sidebar_button.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'config_screen.dart';
import 'rights_screen.dart';
import 'audit_screen.dart';
import 'logout_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';

// Helper for persona description (must be after imports, before classes)
String personaDescription(String? persona) {
  switch (persona) {
    case 'Leader':
      return 'Natural leader, inspires others, takes initiative.';
    case 'Connector':
      return 'Brings people together, builds strong relationships.';
    case 'Analyst':
      return 'Data-driven, logical, and detail-oriented.';
    case 'Innovator':
      return 'Creative thinker, always brings new ideas.';
    default:
      return 'No persona description available.';
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  final List<_SidebarItem> _sidebarItems = [
    _SidebarItem('Dashboard', Icons.dashboard),
    _SidebarItem('Users', Icons.people),
    _SidebarItem('Analytics', Icons.analytics),
    _SidebarItem('Profile', Icons.person),
    _SidebarItem('Settings', Icons.settings),
    _SidebarItem('Config', Icons.tune),
    _SidebarItem('Rights', Icons.admin_panel_settings),
    _SidebarItem('Audit', Icons.history),
    _SidebarItem('Logout', Icons.logout),
  ];

  Widget _getSectionWidget(int index) {
    switch (index) {
      case 0:
        return _DashboardContent();
      case 1:
        return _UsersContent();
      case 2:
        return Center(child: Text('Analytics Page', style: Theme.of(context).textTheme.headlineMedium));
      case 3:
        return ProfileScreen();
      case 4:
        return SettingsScreen();
      case 5:
        return ConfigScreen();
      case 6:
        return RightsScreen();
      case 7:
        return AuditScreen();
      default:
        return Center(child: Text('Unknown Section'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sambad Admin Dashboard'),
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: theme.drawerTheme.backgroundColor ?? theme.colorScheme.surface,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      for (int i = 0; i < _sidebarItems.length; i++)
                        SidebarButton(
                          icon: _sidebarItems[i].icon,
                          label: _sidebarItems[i].label,
                          color: i == _selectedIndex ? theme.colorScheme.primary : theme.colorScheme.secondary.withOpacity(0.2),
                          textColor: i == _selectedIndex ? Colors.white : null,
                          onTap: () {
                            if (_sidebarItems[i].label == 'Logout') {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => AdminLoginPage()),
                                (route) => false,
                              );
                            } else {
                              setState(() {
                                _selectedIndex = i;
                              });
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _getSectionWidget(_selectedIndex),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final String label;
  final IconData icon;
  const _SidebarItem(this.label, this.icon);
}

// Dashboard content widget
class _DashboardContent extends StatefulWidget {
  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  late Future<Map<String, dynamic>> _analyticsFuture;
  late Future<List<dynamic>> _activityFuture;
  String selectedCountry = 'India';
  final List<String> countries = ['India', 'USA', 'UK', 'Germany', 'Australia'];

  // Real-time event state
  List<dynamic> _liveActivity = [];
  Map<String, dynamic>? _liveAnalytics;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = ApiService().fetchDashboardAnalytics();
    _activityFuture = ApiService().fetchRecentActivity();
    // Connect to WebSocket for real-time updates
    AdminWebSocket().connect(
      url: 'ws://localhost:4000',
      onEvent: (event) {
        if (event['type'] == 'contact_added') {
          setState(() {
            _liveActivity.insert(0, {
              'description': 'Contact added: ${event['contact']['name']} (${event['contact']['phone']})',
              'time': DateTime.now().toLocal().toString().substring(0, 16),
            });
          });
        } else if (event['type'] == 'message_sent') {
          setState(() {
            _liveActivity.insert(0, {
              'description': 'Message sent from ${event['message']['from']} to ${event['message']['to']}',
              'time': DateTime.now().toLocal().toString().substring(0, 16),
            });
          });
        }
        // Optionally update analytics if event includes new stats
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dashboard, color: theme.colorScheme.primary, size: 36),
                  const SizedBox(width: 14),
                  Text(
                    'Dashboard',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              // Country filter dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: selectedCountry,
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.arrow_drop_down),
                  style: theme.textTheme.titleMedium,
                  dropdownColor: theme.colorScheme.surface,
                  onChanged: (val) => setState(() => selectedCountry = val!),
                  items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.secondary,
                child: Icon(Icons.account_circle, color: theme.colorScheme.primary, size: 36),
              ),
            ],
          ),
          const SizedBox(height: 28),
          FutureBuilder<Map<String, dynamic>>(
            future: _analyticsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Failed to load analytics: \\${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No analytics data.'));
              }
              final data = snapshot.data!;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatCard(
                    icon: Icons.person_add,
                    label: 'New Users',
                    value: data['newUsers']?.toString() ?? '-',
                    color: theme.colorScheme.primary,
                  ),
                  _StatCard(
                    icon: Icons.people,
                    label: 'Total Users',
                    value: data['totalUsers']?.toString() ?? '-',
                    color: theme.colorScheme.secondary,
                  ),
                  _StatCard(
                    icon: Icons.trending_up,
                    label: 'Growth',
                    value: data['growth']?.toString() ?? '-',
                    color: Colors.green,
                  ),
                  _StatCard(
                    icon: Icons.check_circle,
                    label: 'Active',
                    value: data['activeUsers']?.toString() ?? '-',
                    color: Colors.blue,
                  ),
                  _StatCard(
                    icon: Icons.remove_circle,
                    label: 'Inactive',
                    value: data['inactiveUsers']?.toString() ?? '-',
                    color: Colors.redAccent,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Text('Recent Activity', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // Show live activity if available, else fallback to initial fetch
          _liveActivity.isNotEmpty
              ? Column(
                  children: _liveActivity
                      .map((activity) => _ActivityItem(
                            icon: Icons.chat,
                            description: activity['description'] ?? '-',
                            time: activity['time'] ?? '-',
                          ))
                      .toList(),
                )
              : FutureBuilder<List<dynamic>>(
                  future: _activityFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Failed to load activity: \\${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No recent activity.'));
                    }
                    return Column(
                      children: snapshot.data!
                          .map((activity) => _ActivityItem(
                                icon: Icons.chat,
                                description: activity['description'] ?? '-',
                                time: activity['time'] ?? '-',
                              ))
                          .toList(),
                    );
                  },
                ),
          const SizedBox(height: 32),
          // User analytics graph and comparison chart can be similarly updated to use real data if available
          // ...existing code for charts (can be updated in next step)...
        ],
      ),
    );
  }
}



class _UsersContent extends StatefulWidget {
  @override
  State<_UsersContent> createState() => _UsersContentState();
}

class _UsersContentState extends State<_UsersContent> {
  late Future<List<dynamic>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService().fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load users: \\${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found.'));
        }
        return _ExpandableUserList(users: snapshot.data!);
      },
    );
  }
}

class _ExpandableUserList extends StatefulWidget {
  final List<dynamic> users;
  const _ExpandableUserList({required this.users});
  @override
  State<_ExpandableUserList> createState() => _ExpandableUserListState();
}

class _ExpandableUserListState extends State<_ExpandableUserList> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Users', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: widget.users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final user = widget.users[i];
                final isExpanded = expandedIndex == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: Card(
                    elevation: isExpanded ? 10 : 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    color: isExpanded ? theme.colorScheme.primary.withOpacity(0.08) : theme.cardColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() => expandedIndex = isExpanded ? null : i);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: user['active'] ? theme.colorScheme.primary : Colors.grey[400],
                                  child: Icon(Icons.person, color: Colors.white, size: 32),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user['name'], style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                      Text(user['location'], style: theme.textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: theme.colorScheme.primary),
                              ],
                            ),
                            if (isExpanded) ...[
                              const SizedBox(height: 14),
                              Divider(color: theme.dividerColor, height: 1),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.badge, color: theme.colorScheme.secondary),
                                  const SizedBox(width: 8),
                                  Text('Persona:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 6),
                                  Text(user['persona'], style: theme.textTheme.bodyMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.email, color: theme.colorScheme.secondary),
                                  const SizedBox(width: 8),
                                  Text('Email:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 6),
                                  Text(user['email'], style: theme.textTheme.bodyMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, color: theme.colorScheme.secondary),
                                  const SizedBox(width: 8),
                                  Text('Joined:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 6),
                                  Text(user['joined'], style: theme.textTheme.bodyMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.verified_user, color: user['active'] ? Colors.teal : Colors.redAccent),
                                  const SizedBox(width: 8),
                                  Text('Account Status:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: user['active'] ? Colors.green[100] : Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      user['active'] ? 'Active' : 'Inactive',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: user['active'] ? Colors.green[800] : Colors.red[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Persona features row
                              Row(
                                children: [
                                  Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary),
                                  const SizedBox(width: 10),
                                  Icon(Icons.mic_none, color: theme.colorScheme.primary),
                                  const SizedBox(width: 10),
                                  Icon(Icons.videocam_outlined, color: theme.colorScheme.primary),
                                  const SizedBox(width: 10),
                                  Icon(Icons.location_on_outlined, color: theme.colorScheme.primary),
                                  const SizedBox(width: 10),
                                  Text('Persona Features', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Smart persona analytics
                              Card(
                                margin: const EdgeInsets.only(top: 10, bottom: 4),
                                color: theme.colorScheme.secondary.withOpacity(0.08),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.insights, color: theme.colorScheme.primary),
                                          const SizedBox(width: 8),
                                          Text('Persona Analytics', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.timeline, color: Colors.blueAccent, size: 18),
                                          const SizedBox(width: 6),
                                          Text('Activity Score: ', style: theme.textTheme.bodySmall),
                                          Text('${(user['active'] ? 87 : 42)}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 18),
                                          Icon(Icons.group, color: Colors.green, size: 18),
                                          const SizedBox(width: 6),
                                          Text('Connections: ', style: theme.textTheme.bodySmall),
                                          Text('${user['active'] ? 24 : 7}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.chat_bubble, color: Colors.deepPurple, size: 18),
                                          const SizedBox(width: 6),
                                          Text('Chats: ', style: theme.textTheme.bodySmall),
                                          Text('${user['active'] ? 132 : 12}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 18),
                                          Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                                          const SizedBox(width: 6),
                                          Text('Last Location: ', style: theme.textTheme.bodySmall),
                                          Text(user['location'], style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text('Persona Type: ${user['persona']}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text(personaDescription(user['persona']), style: theme.textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// Stat card widget for dashboard quick stats
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withOpacity(0.12),
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 15, color: color)),
          ],
        ),
      ),
    );
  }
}

// Recent activity item widget
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String description;
  final String time;
  const _ActivityItem({required this.icon, required this.description, required this.time});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(description, style: theme.textTheme.bodyMedium)),
          Text(time, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

// Comparison chart widget with toggle and growth/degrowth highlight
class _ComparisonChart extends StatefulWidget {
  final ThemeData theme;
  const _ComparisonChart({required this.theme});

  @override
  State<_ComparisonChart> createState() => _ComparisonChartState();
}

class _ComparisonChartState extends State<_ComparisonChart> {
  String _selected = 'Day';

  static const List<String> _modes = ['Day', 'Month', 'Year'];

  // Dummy data for each mode
  static const Map<String, List<double>> _data = {
    'Day':    [10, 12, 11, 13, 12, 15, 14],
    'Month':  [120, 130, 110, 140, 135, 150, 145],
    'Year':   [1200, 1350, 1280, 1400, 1380, 1500, 1470],
  };
  static const Map<String, List<String>> _labels = {
    'Day':    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'Month':  ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
    'Year':   ['2019', '2020', '2021', '2022', '2023', '2024', '2025'],
  };

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final data = _data[_selected]!;
    final labels = _labels[_selected]!;
    // Calculate growth/degrowth for each point
    List<bool?> growth = List.generate(data.length, (i) {
      if (i == 0) return null;
      return data[i] > data[i-1] ? true : data[i] < data[i-1] ? false : null;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (final mode in _modes)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(mode),
                  selected: _selected == mode,
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: _selected == mode ? Colors.white : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selected = mode);
                  },
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(labels[value.toInt()], style: theme.textTheme.bodySmall),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    interval: 1,
                    reservedSize: 32,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: theme.dividerColor)),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 4,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      if (index == 0) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: theme.colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      }
                      final isGrowth = growth[index];
                      return FlDotCirclePainter(
                        radius: 6,
                        color: isGrowth == true
                            ? Colors.green
                            : isGrowth == false
                                ? Colors.red
                                : theme.colorScheme.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              gridData: FlGridData(show: true),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.arrow_upward, color: Colors.green, size: 18),
            const SizedBox(width: 4),
            Text('Growth', style: theme.textTheme.bodySmall?.copyWith(color: Colors.green)),
            const SizedBox(width: 16),
            Icon(Icons.arrow_downward, color: Colors.red, size: 18),
            const SizedBox(width: 4),
            Text('Degrowth', style: theme.textTheme.bodySmall?.copyWith(color: Colors.red)),
          ],
        ),
      ],
    );
  }
}
