import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huoo/bloc/auth_bloc.dart';
import 'package:huoo/repositories/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  UserProfile? _apiUserProfile;
  bool _isLoadingApiProfile = false;
  String _apiError = '';
  bool _isApiConnected = false;

  @override
  void initState() {
    super.initState();
    _loadApiProfile();
    _checkApiHealth();
  }

  Future<void> _loadApiProfile() async {
    setState(() {
      _isLoadingApiProfile = true;
      _apiError = '';
    });

    try {
      final profile = await _userRepository.getUserProfile();
      setState(() {
        _apiUserProfile = profile;
        _isLoadingApiProfile = false;
      });
    } catch (e) {
      setState(() {
        _apiError = 'Failed to load profile from API: $e';
        _isLoadingApiProfile = false;
      });
    }
  }

  Future<void> _checkApiHealth() async {
    final isHealthy = await _userRepository.checkApiHealth();
    setState(() {
      _isApiConnected = isHealthy;
    });
  }

  Future<void> _testApiConnection() async {
    final isConnected = await _userRepository.testApiConnection();
    setState(() {
      _isApiConnected = isConnected;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isConnected
                ? 'API connection successful!'
                : 'API connection failed. Check your backend.',
          ),
          backgroundColor: isConnected ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // API Status Indicator
          IconButton(
            icon: Icon(
              _isApiConnected ? Icons.cloud_done : Icons.cloud_off,
              color: _isApiConnected ? Colors.green : Colors.red,
            ),
            onPressed: _testApiConnection,
            tooltip: _isApiConnected ? 'API Connected' : 'API Disconnected',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(SignOutEvent());
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is Authenticated) {
            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Profile avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child:
                        user.photoURL != null
                            ? ClipOval(
                              child: Image.network(
                                user.photoURL!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.person,
                                      size: 60,
                                      color: theme.colorScheme.primary,
                                    ),
                              ),
                            )
                            : Icon(
                              Icons.person,
                              size: 60,
                              color: theme.colorScheme.primary,
                            ),
                  ),

                  const SizedBox(height: 24),

                  // Name
                  Text(
                    user.displayName ?? 'User',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Email
                  Text(
                    user.email ?? 'No email provided',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // API Status Section
                  _buildApiStatusCard(theme),

                  const SizedBox(height: 24),

                  // Account info section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Information',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // User ID
                        _buildInfoRow(
                          context,
                          'User ID',
                          user.uid,
                          Icons.fingerprint,
                        ),

                        const Divider(height: 32),

                        // Email verified status
                        _buildInfoRow(
                          context,
                          'Email Verified',
                          user.emailVerified ? 'Yes' : 'No',
                          Icons.verified,
                          valueColor:
                              user.emailVerified ? Colors.green : Colors.orange,
                        ),

                        const Divider(height: 32),

                        // Auth provider
                        _buildInfoRow(
                          context,
                          'Sign-in Method',
                          user.providerData.isNotEmpty
                              ? _getProviderName(
                                user.providerData.first.providerId,
                              )
                              : 'Email/Password',
                          Icons.login,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (state is AuthenticatedAsGuest) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 80,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'You are signed in as a guest',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account to save your preferences',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to sign up screen
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Create Account'),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  const Text('Not signed in'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Go to Sign In'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildApiStatusCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            _isApiConnected
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isApiConnected ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isApiConnected ? Icons.cloud_done : Icons.cloud_off,
                color: _isApiConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                'API Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _testApiConnection,
                child: const Text('Test Connection'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isApiConnected
                ? 'Connected to backend API'
                : 'Cannot connect to backend API',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _isApiConnected ? Colors.green : Colors.red,
            ),
          ),
          if (_isLoadingApiProfile) ...[
            const SizedBox(height: 12),
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Loading API profile...'),
              ],
            ),
          ],
          if (_apiUserProfile != null) ...[
            const SizedBox(height: 12),
            Text(
              'API Profile: ${_apiUserProfile!.displayName ?? _apiUserProfile!.email ?? 'Unknown'}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
            ),
          ],
          if (_apiError.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _apiError,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadApiProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh API Profile'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
            ),
          ),
        ],
      ),
    );
  }

  String _getProviderName(String providerId) {
    switch (providerId) {
      case 'google.com':
        return 'Google';
      case 'apple.com':
        return 'Apple';
      case 'password':
        return 'Email/Password';
      case 'phone':
        return 'Phone Number';
      default:
        return 'Unknown';
    }
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
