import 'package:health_tick_demo/domain/entities/journey.dart';
import 'package:health_tick_demo/domain/entities/lesson.dart';

Map<String, dynamic> journeyJson({int beginnerDays = 3, int unlocked = 1}) => {
  'user': {'name': 'Pravesh', 'healthPoints': 12},
  'unlockedCircles': unlocked,
  'currentDayId': unlocked > 0 ? 'beginner-d1' : null,
  'statuses': [
    {
      'id': 'beginner',
      'title': 'Beginner',
      'level': 1,
      'subtitle': 'Psychology of weight',
      'icon': 'eco',
      'color': '#F9E3C7',
      'isUnlocked': unlocked > 0,
      'days': [
        for (var i = 1; i <= beginnerDays; i++)
          {
            'id': 'beginner-d$i',
            'dayNumber': i,
            'emoji': '🧠',
            'state': i <= unlocked ? 'inProgress' : 'locked',
            'lessons': [
              {
                'id': 'beginner-d$i-l1',
                'title': 'Welcome to Health Tick!',
                'state': i <= unlocked ? 'completed' : 'locked',
              },
              {
                'id': 'beginner-d$i-l2',
                'title': 'The 9 Keystone Habits',
                'state': i <= unlocked ? 'available' : 'locked',
              },
            ],
          },
      ],
    },
    {
      'id': 'insider',
      'title': 'Insider',
      'level': 2,
      'subtitle': 'Handle your food triggers',
      'icon': 'insights',
      'color': '#DCEBFA',
      'isUnlocked': false,
      'days': <Map<String, dynamic>>[],
    },
  ],
};

Journey journeyFixture({int beginnerDays = 3, int unlocked = 1}) {
  final days = [
    for (var i = 1; i <= beginnerDays; i++)
      JourneyDay(
        id: 'beginner-d$i',
        dayNumber: i,
        emoji: '🧠',
        state: i <= unlocked ? DayState.inProgress : DayState.locked,
        lessons: [
          LessonSummary(
            id: 'beginner-d$i-l1',
            title: 'Welcome to Health Tick!',
            state: i <= unlocked ? LessonState.completed : LessonState.locked,
          ),
          LessonSummary(
            id: 'beginner-d$i-l2',
            title: 'The 9 Keystone Habits',
            state: i <= unlocked ? LessonState.available : LessonState.locked,
          ),
        ],
      ),
  ];
  return Journey(
    user: const UserSummary(name: 'Pravesh', healthPoints: 12),
    unlockedCircles: unlocked,
    currentDayId: unlocked > 0 ? 'beginner-d1' : null,
    statuses: [
      JourneyStatus(
        id: 'beginner',
        title: 'Beginner',
        level: 1,
        subtitle: 'Psychology of weight',
        icon: 'eco',
        colorHex: '#F9E3C7',
        isUnlocked: unlocked > 0,
        days: days,
      ),
    ],
  );
}

const lessonFixture = Lesson(
  id: 'beginner-d1-l2',
  title: 'The 9 Keystone Habits',
  dayNumber: 1,
  nextLessonId: 'beginner-d1-l3',
  pages: [
    TextLessonPage(emoji: '🁢', body: 'Welcome to **keystone habits**.', cta: "THAT'S AMAZING"),
    QuestionLessonPage(
      prompt: 'Why do you think we humans eat?',
      options: ['Hunger', 'Thirst', 'All of the above'],
      correctOptionIndex: 2,
      explanation: "It's - **All of the above**",
      cta: 'SUBMIT',
    ),
  ],
);
