import 'package:flutter/material.dart';

import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/profile_subject_builder.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Profile'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ProfileSubjectBuilder(),
      ),
    );
  }
}
