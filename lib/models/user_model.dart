import 'package:stories/models/story_model.dart';

class User {
  final String username;
  final String userIconURL;
  final List<Story>? userStories;

  User({required this.username, required this.userIconURL, this.userStories});
}
