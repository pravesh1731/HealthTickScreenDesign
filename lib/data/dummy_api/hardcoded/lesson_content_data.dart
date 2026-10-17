/// Hard-coded lesson library served by the dummy API.
///
/// Only Level 1 (Beginner) days 1 and 2 have lessons. Every other circle
/// is still drawn, but has no lessons yet ("coming soon").
const lessonContentJson = r'''
{
  "days": {
    "beginner": [
      {
        "emoji": "🧠",
        "lessons": [
          "welcome",
          "keystone-habits",
          "hunger-levels",
          "secret-part-1",
          "initial-goals"
        ]
      },
      {
        "emoji": "💧",
        "lessons": [
          "water-first",
          "secret-part-2",
          "hunger-quiz"
        ]
      }
    ],
    "insider": []
  },
  "lessons": {
    "welcome": {
      "title": "Welcome to Health Tick!",
      "pages": [
        {
          "type": "text",
          "emoji": "👋",
          "body": "Welcome to **Health Tick**!\n\nThis is your journey. Every circle on the path is a day, and every day has a few short lessons.\n\n*Small steps, every single day.*",
          "cta": "LET'S GO"
        },
        {
          "type": "text",
          "emoji": "🏅",
          "body": "Every page you read earns you **health points**.\n\nAnswer the questions honestly - there are no wrong answers here, only learning.",
          "cta": "GOT IT"
        }
      ]
    },
    "keystone-habits": {
      "title": "The 9 Keystone Habits",
      "pages": [
        {
          "type": "text",
          "emoji": "🁢",
          "body": "Welcome to your first mini module - **The 9 Keystone Habits**.\n\nThese are the most powerful habits for lasting health changes.\n\nResearch in behavioural science shows that *keystone habits* often trigger many other good habits—often without you even realising it.\n\n*(Like drinking water automatically reduces food cravings, without you knowing it)*",
          "cta": "THAT'S AMAZING"
        },
        {
          "type": "text",
          "emoji": "🗺️",
          "body": "Over the next few days, you will:\n\n1. Learn how to truly **recognise your body's hunger signals** — and eat when your body actually needs food.\n2. Understand **\"Food Zones\"** and how to balance them step-by-step\n3. **Manage portions** effortlessly — without ever starving yourself.\n4. **Be active** — even when you are busy.\n5. **Handle food cravings** without relying on \"willpower\".\n\nLet's start today with your first keystone habit: **Recognising your body's hunger signals.**",
          "cta": "LET'S BEGIN"
        },
        {
          "type": "question",
          "prompt": "But before we do that, we have a question for you - *Why do you think we humans eat?*",
          "options": [
            "Hunger",
            "Thirst",
            "Stress",
            "Boredom",
            "Cravings",
            "All of the above"
          ],
          "correctOptionIndex": 5,
          "explanation": "It's - **All of the above**.\n\nWe eat for many reasons, and only one of them is true hunger.",
          "cta": "SUBMIT"
        }
      ]
    },
    "hunger-levels": {
      "title": "Keystone Habit #1: Identify your hunger levels",
      "pages": [
        {
          "type": "text",
          "emoji": "🤔",
          "body": "Most people struggle to tell the difference between true hunger, desire to eat and cravings.\n\nLet's look at them one by one.\n\n- **True Hunger** — Your body genuinely needs food.\n- **Desire to Eat** — You're not really hungry, but food is available or it's \"mealtime\".\n- **Cravings** — An intense urge to eat driven by emotions, stress or boredom.",
          "cta": "I'M ATTENTIVE NOW"
        },
        {
          "type": "question",
          "prompt": "\"You should eat when the clock says it's time to eat.\"\n\n*Is this statement true or false?*",
          "options": [
            "True",
            "False"
          ],
          "correctOptionIndex": 1,
          "explanation": "It's **False**.\n\nYou should not eat according to the clock. You should only eat when you are truly hungry.",
          "cta": "DONE"
        }
      ]
    },
    "secret-part-1": {
      "title": "The little secret to weight loss- Part 1",
      "pages": [
        {
          "type": "text",
          "emoji": "🤫",
          "body": "Here's the little secret: weight loss isn't about eating *less*.\n\nIt's about eating **when your body asks for it** — and stopping when it's satisfied.",
          "cta": "TELL ME MORE"
        },
        {
          "type": "text",
          "emoji": "📉",
          "body": "Eating when you're not truly hungry can lead to **weight gain and unnecessary glucose spikes**.\n\nOn the other hand, eating *only* when you're truly hungry can help you:\n\n- **Lose weight** naturally and keep it off\n- Prevent and even **reverse lifestyle diseases**",
          "cta": "THAT MAKES SENSE"
        }
      ]
    },
    "initial-goals": {
      "title": "Set your initial goals",
      "pages": [
        {
          "type": "text",
          "emoji": "🎯",
          "body": "Goals give your journey a direction.\n\nStart small: **one** habit you'll practice this week is better than ten you'll forget.",
          "cta": "OKAY"
        },
        {
          "type": "question",
          "prompt": "Which goal would you like to focus on first?",
          "options": [
            "Drink more water",
            "Eat only when truly hungry",
            "Sleep 7+ hours",
            "Walk after meals"
          ],
          "correctOptionIndex": null,
          "explanation": "Great choice! Every goal on this list is a **keystone habit**.",
          "cta": "SET MY GOAL"
        }
      ]
    },
    "water-first": {
      "title": "Water before food",
      "pages": [
        {
          "type": "text",
          "emoji": "💧",
          "body": "Thirst is often mistaken for hunger.\n\nNext time you feel like snacking, **drink a glass of water** and wait 10 minutes.",
          "cta": "I'LL TRY IT"
        },
        {
          "type": "question",
          "prompt": "How long should you wait after drinking water before deciding whether you're hungry?",
          "options": [
            "1 minute",
            "10 minutes",
            "1 hour"
          ],
          "correctOptionIndex": 1,
          "explanation": "It's **10 minutes** — enough time for your body to tell thirst and hunger apart.",
          "cta": "SUBMIT"
        }
      ]
    },
    "secret-part-2": {
      "title": "The little secret to weight loss- Part 2",
      "pages": [
        {
          "type": "text",
          "emoji": "🍎",
          "body": "We divided hunger into **4 levels**:\n\n1. **Starving** — shaky, irritable, can't focus\n2. **Hungry** — stomach growling, ready for a meal\n3. **Satisfied** — comfortable, energetic\n4. **Stuffed** — heavy, sleepy\n\nAim to eat at level **2** and stop at level **3**.",
          "cta": "WHAT'S NEXT?"
        }
      ]
    },
    "hunger-quiz": {
      "title": "Quick check: hunger levels",
      "pages": [
        {
          "type": "question",
          "prompt": "You feel heavy and sleepy after lunch. Which hunger level did you stop at?",
          "options": [
            "Hungry",
            "Satisfied",
            "Stuffed"
          ],
          "correctOptionIndex": 2,
          "explanation": "It's **Stuffed**. Next time, pause halfway through your plate and check in with yourself.",
          "cta": "SUBMIT"
        }
      ]
    }
  }
}
''';
