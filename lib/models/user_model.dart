import 'package:stories/models/story_model.dart';

class User {
  final String username;
  final String userIconURL;
  //TODO: Create new model: StoryGroup
  final List<Story>? userStories;
  int currentStoryGroupIndex = 0;

  User({
    required this.username,
    required this.userIconURL,
    this.userStories,
  });
}
