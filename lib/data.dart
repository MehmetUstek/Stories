import 'package:stories/models/user_model.dart';

import 'models/story_model.dart';

final User user = User(
  username: 'ipekayyildiz',
  userIconURL: 'https://wallpapercave.com/wp/AYWg3iu.jpg',
);
final User second_user = User(
    username: 'mehmetustekk',
    userIconURL: 'https://wallpapercave.com/wp/AYWg3iu.jpg');
final List<Story> stories = [
  Story(
    URL:
        'https://images.unsplash.com/photo-1534103362078-d07e750bd0c4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80',
    storyType: StoryType.image,
    duration: const Duration(seconds: 10),
    user: user,
  ),
  Story(
    URL: 'https://media.giphy.com/media/moyzrwjUIkdNe/giphy.gif',
    storyType: StoryType.image,
    user: User(
      username: 'John Doe',
      userIconURL: 'https://wallpapercave.com/wp/AYWg3iu.jpg',
    ),
    duration: const Duration(seconds: 7),
  ),
  Story(
    URL:
        'https://static.videezy.com/system/resources/previews/000/005/529/original/Reaviling_Sjusj%C3%B8en_Ski_Senter.mp4',
    storyType: StoryType.video,
    duration: const Duration(seconds: 0),
    user: user,
  ),
  Story(
    URL:
        'https://images.unsplash.com/photo-1531694611353-d4758f86fa6d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=564&q=80',
    storyType: StoryType.image,
    duration: const Duration(seconds: 5),
    user: user,
  ),
  Story(
    URL:
        'https://static.videezy.com/system/resources/previews/000/007/536/original/rockybeach.mp4',
    storyType: StoryType.video,
    duration: const Duration(seconds: 0),
    user: user,
  ),
  Story(
    URL: 'https://media2.giphy.com/media/M8PxVICV5KlezP1pGE/giphy.gif',
    storyType: StoryType.image,
    duration: const Duration(seconds: 8),
    user: user,
  ),
  Story(
    URL: 'https://media2.giphy.com/media/M8PxVICV5KlezP1pGE/giphy.gif',
    storyType: StoryType.image,
    duration: const Duration(seconds: 8),
    user: second_user,
  ),
];
