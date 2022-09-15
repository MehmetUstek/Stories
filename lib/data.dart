import 'package:stories/models/user_model.dart';

import 'models/story_model.dart';

const imageDuration = 5;
final User user = User(
    username: 'mehmetustekk',
    userIconURL: 'https://wallpapercave.com/wp/AYWg3iu.jpg',
    userStories: [
      Story(
        url:
            'https://images.unsplash.com/photo-1534103362078-d07e750bd0c4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80',
        storyType: StoryType.image,
      ),
      Story(
        url:
            'https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        storyType: StoryType.image,
      ),
      Story(
        url:
            'https://static.videezy.com/system/resources/previews/000/005/529/original/Reaviling_Sjusj%C3%B8en_Ski_Senter.mp4',
        storyType: StoryType.video,
      ),
    ]);
final User secondUser = User(
    username: 'mehmetustekk1',
    userIconURL: 'https://wallpapercave.com/wp/AYWg3iu.jpg',
    userStories: [
      Story(
        url:
            'https://images.unsplash.com/photo-1531694611353-d4758f86fa6d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=564&q=80',
        storyType: StoryType.image,
      ),
      Story(
        url:
            'https://static.videezy.com/system/resources/previews/000/007/536/original/rockybeach.mp4',
        storyType: StoryType.video,
      ),
      Story(
        url:
            'https://images.pexels.com/photos/905485/pexels-photo-905485.jpeg?auto=compress&cs=tinysrgb&w=1200',
        storyType: StoryType.image,
      ),
      Story(
        url:
            'https://images.pexels.com/photos/1695052/pexels-photo-1695052.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
        storyType: StoryType.image,
      ),
    ]);
final List<User> users = [user, secondUser];
