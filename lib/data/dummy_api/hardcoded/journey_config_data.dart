/// Initial "knobs" of the dummy API: circles per status and how many are
/// unlocked. Starts with only the first circle unlocked; finishing a circle
/// unlocks the next one.
const journeyConfigJson = r'''
{
  "userName": "Pravesh",
  "unlockedCircles": 1,
  "statuses": [
    {
      "id": "beginner",
      "title": "Beginner",
      "level": 1,
      "subtitle": "Psychology of weight",
      "icon": "eco",
      "color": "#F9E3C7",
      "circleCount": 5
    },
    {
      "id": "insider",
      "title": "Insider",
      "level": 2,
      "subtitle": "Handle your food triggers",
      "icon": "insights",
      "color": "#DCEBFA",
      "circleCount": 6
    }
  ]
}
''';
