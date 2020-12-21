import 'package:flutter/widgets.dart';

import '../../util/validators.dart';
import '../gl_icons.dart';
import 'gl_text_form_field.dart';
import 'password_strength_bar.dart';

class PasswordValidators {
  static String none(String password) => null;
  static String isNotEmpty(String password) => password.isEmpty ? 'Enter password.' : null;
  static String length(String password) {
    if (isPasswordTooShort(password)) {
      return 'Password must be at least 10 characters.';
    }
    if (isPasswordTooLong(password)) {
      return 'Password must be fewer than 64 characters.';
    }
    return null;
  }

  static String full(String password) {
    return length(password);
  }
}

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final StringValidator validator;
  final String label;
  final bool showIcon;
  final bool enabled;
  final bool showStrengthBar;

  PasswordFormField({
    Key key,
    this.controller,
    this.validator = PasswordValidators.none,
    this.label = 'Password',
    this.showIcon = true,
    this.enabled = true,
    this.showStrengthBar = false,
  }) : super(key: key);

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasHadFocus;
  bool _isDirty;
  TextEditingController _controller;
  final _defaultController = TextEditingController();
  String _password;

  @override
  void initState() {
    super.initState();
    _isDirty = false;
    _hasHadFocus = false;
    _focusNode.addListener(() => setState(() {
          _hasHadFocus |= _focusNode.hasFocus;
          _isDirty |= _hasHadFocus && !_focusNode.hasFocus;
        }));
    _controller = widget.controller ?? _defaultController;
    _controller.addListener(() => setState(() {
          _password = _controller.text;
        }));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _defaultController.dispose();
    super.dispose();
  }

  Widget buildStrengthBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 10, 0, 0),
      child: PasswordStrengthBar(password: _password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GLTextFormField(
          controller: _controller,
          decorationIcon: widget.showIcon ? GLIcons.password : null,
          labelText: widget.label,
          focusNode: _focusNode,
          obscureText: true,
          autovalidate: _isDirty,
          autocorrect: false,
          validator: validateDirty,
          enabled: widget.enabled,
        ),
        if (widget.showStrengthBar) buildStrengthBar(context)
      ],
    );
  }

  String validateDirty(String s) => _isDirty ? widget.validator(s) : null;
}
