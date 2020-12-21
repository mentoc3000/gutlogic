import 'package:flutter/widgets.dart';
import '../../util/validators.dart';
import '../gl_icons.dart';
import 'gl_text_form_field.dart';

class EmailValidators {
  static String none(String email) => null;
  static String isNotEmpty(String email) => email.isEmpty ? 'Enter email.' : null;
  static String full(String email) => isValidEmail(email) ? null : 'Invalid email address.';
}

class EmailFormField extends StatefulWidget {
  final TextEditingController controller;
  final StringValidator validator;

  const EmailFormField({
    Key key,
    this.controller,
    this.validator = EmailValidators.none,
  }) : super(key: key);

  @override
  _EmailFormFieldState createState() => _EmailFormFieldState();
}

class _EmailFormFieldState extends State<EmailFormField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasHadFocus;
  bool _isDirty;

  @override
  void initState() {
    super.initState();
    _isDirty = false;
    _hasHadFocus = false;
    _focusNode.addListener(() => setState(() {
          _hasHadFocus |= _focusNode.hasFocus;
          _isDirty |= _hasHadFocus && !_focusNode.hasFocus;
        }));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GLTextFormField(
      controller: widget.controller,
      decorationIcon: GLIcons.email,
      labelText: 'Email',
      focusNode: _focusNode,
      keyboardType: TextInputType.emailAddress,
      autovalidate: _isDirty,
      autocorrect: false,
      validator: validateDirty,
    );
  }

  String validateDirty(String s) => _isDirty ? widget.validator(s) : null;
}
