import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../resources/profile_repository.dart';
import '../../../widgets/utility/subject_value_builder.dart';
import '../../loading_page.dart';
import 'profile_form.dart';

class ProfileSubjectBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SubjectValueBuilder(
      subject: context.read<ProfileRepository>().stream,
      builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
        return snapshot.data == null ? LoadingPage() : ProfileForm(profile: snapshot.data);
      },
    );
  }
}
