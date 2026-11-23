import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/login_methods.dart';
import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/features/login/widgets/fan_picker.dart';
import 'package:ilm_fan/features/login/widgets/method_list.dart';
import 'package:ilm_fan/features/login/widgets/profile_form.dart';
import 'package:ilm_fan/features/login/widgets/role_picker.dart';
import 'package:ilm_fan/models/user_profile.dart';

class LoginFlowScreen extends StatefulWidget {
  const LoginFlowScreen({super.key, this.onLoggedIn});

  final ValueChanged<UserProfile>? onLoggedIn;

  @override
  State<LoginFlowScreen> createState() => _LoginFlowScreenState();
}

class _LoginFlowScreenState extends State<LoginFlowScreen> {
  RoleId? _roleId;
  bool _pickingLearnerSubRole = false;
  List<String> _fanIds = const [];
  LoginMethodId? _methodId;

  RoleOption? get _role => roleById(_roleId);

  bool get _needsFan => _roleId != null && roleNeedsSubjectAtLogin(_roleId!);

  void _onSaveProfile(UserProfile draft) {
    final profile = UserProfile(
      firstName: draft.firstName,
      lastName: draft.lastName,
      role: _roleId,
      subjectFanId: _fanIds.isNotEmpty ? _fanIds.first : null,
      subjectFanIds: _fanIds,
    );
    widget.onLoggedIn?.call(profile);
  }

  void _backFromProfile() {
    setState(() {
      if (_needsFan) {
        _fanIds = const [];
      } else {
        _roleId = null;
      }
    });
  }

  void _backFromFan() {
    setState(() {
      _pickingLearnerSubRole = isLearnerRole(_roleId);
      _roleId = null;
      _fanIds = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _buildStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    if (_methodId == null) {
      return MethodList(onSelect: (id) => setState(() => _methodId = id));
    }

    if (_role == null && _pickingLearnerSubRole) {
      return LearnerRolePicker(
        onBack: () => setState(() => _pickingLearnerSubRole = false),
        onSelect: (id) => setState(() {
          _roleId = id;
          _pickingLearnerSubRole = false;
          _fanIds = const [];
        }),
      );
    }

    if (_role == null) {
      return RolePicker(
        onSelect: (id) => setState(() {
          _roleId = id;
          _fanIds = const [];
        }),
        onSelectLearner: () => setState(() => _pickingLearnerSubRole = true),
      );
    }

    if (_needsFan && _fanIds.isEmpty) {
      return FanPicker(
        role: _role!,
        onBack: _backFromFan,
        onSelect: (ids) => setState(() => _fanIds = ids),
      );
    }

    return ProfileForm(onBack: _backFromProfile, onSave: _onSaveProfile);
  }
}
