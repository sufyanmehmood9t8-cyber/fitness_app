import '../models/exercise.dart';

abstract final class SeedData {
  static const String basePath = 'assets/images';

  static const List<String> categoryNames = <String>[
    'Yoga Stretch',
    'Upper Back',
    'Lower Back',
    'Split Training',
    'Neck Exercise',
    'Shoulder',
    'Chest',
    'Arms',
    'Core',
    'Hip',
    'Glutes',
    'Quads',
    'Hamstrings',
    'Calves',
    'Ankles',
    'Morning Routine',
  ];

  static const Map<String, String> categoryImages = <String, String>{
    'Yoga Stretch': '$basePath/yoga.webp',
    'Upper Back': '$basePath/upper-back.webp',
    'Lower Back': '$basePath/lower-back.webp',
    'Split Training': '$basePath/split.webp',
    'Neck Exercise': '$basePath/Neck.webp',
    'Shoulder': '$basePath/shoulder.webp',
    'Chest': '$basePath/chest.webp',
    'Arms': '$basePath/arms.webp',
    'Core': '$basePath/core.webp',
    'Hip': '$basePath/hip.webp',
    'Glutes': '$basePath/glutes.webp',
    'Quads': '$basePath/quads.webp',
    'Hamstrings': '$basePath/Hamstring.webp',
    'Calves': '$basePath/calves.webp',
    'Ankles': '$basePath/ankles.webp',
    'Morning Routine': '$basePath/morning.webp',
  };

  static const String todayFlowImage = '$basePath/today-flow.webp';

  static const List<String> todayFlowIds = <String>[
    'split-training',
    'half-split',
    'front-split-prep',
  ];

  static const List<String> programIds = <String>[
    'neck-tilt',
    'shoulder-rolls',
    'hip-mobility',
    'hamstring-stretch',
    'lower-back-release',
  ];

  static const List<Exercise> exercises = <Exercise>[
    // Yoga Stretch
    Exercise(
      id: 'cat-cow-flow',
      name: 'Cat-Cow Flow',
      category: 'Yoga Stretch',
      bodyParts: <String>['Spine', 'Core', 'Lower Back'],
      durationSec: 50,
      imageAsset: '$basePath/yoga.webp',
      steps: <String>[
        'Start on all fours with your wrists under your shoulders and knees under your hips.',
        'Inhale, drop your belly and lift your chest and tailbone into Cow.',
        'Exhale, round your spine and tuck your chin toward your chest into Cat.',
        'Move slowly between both shapes for the full duration, following your breath.',
      ],
    ),
    Exercise(
      id: 'downward-dog',
      name: 'Downward Dog',
      category: 'Yoga Stretch',
      bodyParts: <String>['Shoulders', 'Hamstrings', 'Calves'],
      durationSec: 55,
      imageAsset: '$basePath/yoga.webp',
      steps: <String>[
        'From all fours, tuck your toes and lift your hips up and back.',
        'Press your palms into the floor and lengthen your spine.',
        'Keep a soft bend in the knees and send your heels toward the ground.',
        'Breathe deeply and gently pedal your feet to release the calves.',
      ],
    ),
    Exercise(
      id: 'childs-pose',
      name: "Child's Pose",
      category: 'Yoga Stretch',
      bodyParts: <String>['Lower Back', 'Hips', 'Shoulders'],
      durationSec: 60,
      imageAsset: '$basePath/yoga.png',
      steps: <String>[
        'Kneel with your big toes together and knees comfortably apart.',
        'Sit your hips back toward your heels and fold your torso forward.',
        'Reach your arms long in front of you and rest your forehead down.',
        'Let your shoulders soften and take slow breaths into your lower back.',
      ],
    ),

    // Upper Back
    Exercise(
      id: 'thoracic-opener',
      name: 'Thoracic Opener',
      category: 'Upper Back',
      bodyParts: <String>['Upper Back', 'Chest', 'Shoulders'],
      durationSec: 50,
      imageAsset: '$basePath/upper-back.webp',
      steps: <String>[
        'Kneel and place a chair or block in front of you at chest height.',
        'Rest your elbows on the support with your hands together.',
        'Sink your chest below your shoulders and lengthen through the upper back.',
        'Hold while breathing slowly, then gently press back up.',
      ],
    ),
    Exercise(
      id: 'thread-needle',
      name: 'Thread the Needle',
      category: 'Upper Back',
      bodyParts: <String>['Upper Back', 'Shoulders', 'Spine'],
      durationSec: 45,
      imageAsset: '$basePath/upper-back.webp',
      steps: <String>[
        'Begin on all fours with a tall, neutral spine.',
        'Slide your right arm underneath your left arm, palm facing up.',
        'Lower your right shoulder and temple toward the mat.',
        'Breathe into your upper back, then switch sides halfway through.',
      ],
    ),
    Exercise(
      id: 'wall-angels',
      name: 'Wall Angels',
      category: 'Upper Back',
      bodyParts: <String>['Upper Back', 'Shoulders', 'Chest'],
      durationSec: 50,
      imageAsset: '$basePath/upper-back.webp',
      steps: <String>[
        'Stand with your back against a wall and knees slightly bent.',
        'Bring your arms into a goalpost shape with elbows against the wall.',
        'Slowly slide your arms overhead while keeping contact with the wall.',
        'Lower back to the start with control and repeat.',
      ],
    ),

    // Lower Back
    Exercise(
      id: 'pelvic-tilt',
      name: 'Pelvic Tilt',
      category: 'Lower Back',
      bodyParts: <String>['Lower Back', 'Core'],
      durationSec: 45,
      imageAsset: '$basePath/lower-back.webp',
      steps: <String>[
        'Lie on your back with your knees bent and feet flat on the floor.',
        'Gently flatten your lower back into the mat by tilting your pelvis.',
        'Hold for three slow breaths, then release back to a neutral spine.',
        'Repeat gently without pushing through pain.',
      ],
    ),
    Exercise(
      id: 'knee-to-chest',
      name: 'Knee-to-Chest',
      category: 'Lower Back',
      bodyParts: <String>['Lower Back', 'Glutes', 'Hips'],
      durationSec: 50,
      imageAsset: '$basePath/lower-back.webp',
      steps: <String>[
        'Lie on your back and draw your right knee toward your chest.',
        'Clasp your hands below the knee if that feels comfortable.',
        'Keep your left leg long and your lower back relaxed.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'lower-back-release',
      name: 'Supine Twist',
      category: 'Lower Back',
      bodyParts: <String>['Lower Back', 'Hips', 'Spine'],
      durationSec: 45,
      imageAsset: '$basePath/lower-back.webp',
      steps: <String>[
        'Lie on your back and hug both knees toward your chest.',
        'Let both knees fall to the right while keeping shoulders grounded.',
        'Turn your head gently to the left and soften your jaw.',
        'Return through center and repeat on the other side.',
      ],
    ),

    // Split Training
    Exercise(
      id: 'split-training',
      name: 'Split Training',
      category: 'Split Training',
      bodyParts: <String>['Hips', 'Lower Back', 'Glutes'],
      durationSec: 45,
      imageAsset: '$basePath/split.webp',
      steps: <String>[
        'Start in a low lunge with your right foot forward and left knee down.',
        'Keep your hips square and gently sink forward until you feel a stretch.',
        'Reach your arms overhead and lengthen through the front of your hip.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'half-split',
      name: 'Half Split',
      category: 'Split Training',
      bodyParts: <String>['Hamstrings', 'Hips', 'Calves'],
      durationSec: 45,
      imageAsset: '$basePath/split.webp',
      steps: <String>[
        'From a low lunge, shift your hips back over the rear knee.',
        'Straighten your front leg and flex your front foot toward you.',
        'Hinge forward with a long spine until you feel the hamstring stretch.',
        'Hold, then switch legs halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'front-split-prep',
      name: 'Front Split Prep',
      category: 'Split Training',
      bodyParts: <String>['Hips', 'Hamstrings', 'Quads'],
      durationSec: 45,
      imageAsset: '$basePath/split.webp',
      steps: <String>[
        'Kneel with one foot forward and place blocks beside your hips.',
        'Slide your front foot forward and your back knee backward with control.',
        'Keep your hips square and only go as far as feels safe.',
        'Breathe, hold, then switch sides halfway through the timer.',
      ],
    ),

    // Neck Exercise
    Exercise(
      id: 'neck-tilt',
      name: 'Neck Tilt',
      category: 'Neck Exercise',
      bodyParts: <String>['Neck', 'Shoulders'],
      durationSec: 40,
      imageAsset: '$basePath/Neck.webp',
      steps: <String>[
        'Sit or stand tall with your shoulders relaxed.',
        'Tilt your right ear gently toward your right shoulder.',
        'Rest your right hand lightly on your head for a deeper stretch.',
        'Breathe, then switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'chin-tuck',
      name: 'Chin Tuck',
      category: 'Neck Exercise',
      bodyParts: <String>['Neck', 'Upper Back'],
      durationSec: 40,
      imageAsset: '$basePath/Neck.webp',
      steps: <String>[
        'Sit tall and look straight ahead.',
        'Gently glide your chin straight back, making a double chin.',
        'Hold for two breaths without lifting or lowering your chin.',
        'Release slowly and repeat.',
      ],
    ),
    Exercise(
      id: 'neck-rotation',
      name: 'Neck Rotation',
      category: 'Neck Exercise',
      bodyParts: <String>['Neck', 'Shoulders'],
      durationSec: 40,
      imageAsset: '$basePath/Neck.webp',
      steps: <String>[
        'Sit with a long spine and relaxed shoulders.',
        'Turn your head slowly to look over your right shoulder.',
        'Hold at a comfortable end range and breathe.',
        'Return through center and repeat to the left.',
      ],
    ),

    // Shoulder
    Exercise(
      id: 'shoulder-rolls',
      name: 'Shoulder Rolls',
      category: 'Shoulder',
      bodyParts: <String>['Shoulders', 'Upper Back', 'Neck'],
      durationSec: 40,
      imageAsset: '$basePath/shoulder.webp',
      steps: <String>[
        'Stand tall with your arms relaxed at your sides.',
        'Lift your shoulders up toward your ears and roll them back.',
        'Squeeze your shoulder blades together at the bottom of the roll.',
        'Continue slowly, then reverse direction halfway through.',
      ],
    ),
    Exercise(
      id: 'cross-body',
      name: 'Cross-Body Stretch',
      category: 'Shoulder',
      bodyParts: <String>['Shoulders', 'Arms'],
      durationSec: 40,
      imageAsset: '$basePath/shoulder.webp',
      steps: <String>[
        'Bring your right arm across your chest at shoulder height.',
        'Use your left hand to gently draw it closer.',
        'Keep the shoulder down and away from your ear.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'doorway-shoulder',
      name: 'Doorway Shoulder Opener',
      category: 'Shoulder',
      bodyParts: <String>['Shoulders', 'Chest'],
      durationSec: 45,
      imageAsset: '$basePath/shoulder.webp',
      steps: <String>[
        'Place your forearm on a doorframe with your elbow at shoulder height.',
        'Step your opposite foot forward and turn your chest away.',
        'Keep your shoulder relaxed and your ribs down.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),

    // Chest
    Exercise(
      id: 'doorway-chest',
      name: 'Doorway Chest Opener',
      category: 'Chest',
      bodyParts: <String>['Chest', 'Shoulders'],
      durationSec: 45,
      imageAsset: '$basePath/chest.webp',
      steps: <String>[
        'Place both forearms on the sides of a doorframe.',
        'Step one foot through the doorway and lean your chest forward.',
        'Keep your chin level and shoulders down.',
        'Breathe into the stretch, then step back and reset.',
      ],
    ),
    Exercise(
      id: 'cobra',
      name: 'Cobra Stretch',
      category: 'Chest',
      bodyParts: <String>['Chest', 'Spine', 'Lower Back'],
      durationSec: 45,
      imageAsset: '$basePath/chest.webp',
      steps: <String>[
        'Lie face down with your hands beside your ribs.',
        'Press gently into your hands and lift your chest.',
        'Keep your elbows close to your body and shoulders away from your ears.',
        'Breathe, lower with control, and repeat.',
      ],
    ),
    Exercise(
      id: 'clasped-lift',
      name: 'Clasped Hands Lift',
      category: 'Chest',
      bodyParts: <String>['Chest', 'Shoulders'],
      durationSec: 40,
      imageAsset: '$basePath/chest.webp',
      steps: <String>[
        'Clasp your hands behind your back and straighten your arms.',
        'Lift your hands away from your body and open your chest.',
        'Keep your ribs connected and avoid over-arching your lower back.',
        'Hold, breathing slowly, then release.',
      ],
    ),

    // Arms
    Exercise(
      id: 'triceps-stretch',
      name: 'Overhead Triceps Stretch',
      category: 'Arms',
      bodyParts: <String>['Arms', 'Shoulders'],
      durationSec: 40,
      imageAsset: '$basePath/arms.webp',
      steps: <String>[
        'Reach your right arm overhead and bend your elbow.',
        'Rest your right hand between your shoulder blades.',
        'Use your left hand to gently guide the elbow back.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'wrist-flexor',
      name: 'Wrist Flexor Stretch',
      category: 'Arms',
      bodyParts: <String>['Arms', 'Wrists'],
      durationSec: 40,
      imageAsset: '$basePath/arms.webp',
      steps: <String>[
        'Extend your right arm forward with your palm facing up.',
        'Use your left hand to gently pull your fingers down.',
        'Keep your elbow straight and shoulder relaxed.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'forearm-rotation',
      name: 'Forearm Rotation',
      category: 'Arms',
      bodyParts: <String>['Arms', 'Wrists'],
      durationSec: 40,
      imageAsset: '$basePath/arms.webp',
      steps: <String>[
        'Extend both arms forward with your palms facing the floor.',
        'Slowly rotate your palms upward, then back down.',
        'Move through a comfortable range without forcing your wrists.',
        'Continue at a slow, controlled pace.',
      ],
    ),

    // Core
    Exercise(
      id: 'dead-bug',
      name: 'Dead Bug',
      category: 'Core',
      bodyParts: <String>['Core', 'Lower Back'],
      durationSec: 50,
      imageAsset: '$basePath/core.webp',
      steps: <String>[
        'Lie on your back with arms toward the ceiling and knees over hips.',
        'Lower your right arm and left leg toward the floor.',
        'Keep your lower back gently pressed into the mat.',
        'Return to center and alternate sides.',
      ],
    ),
    Exercise(
      id: 'plank-hold',
      name: 'Plank Hold',
      category: 'Core',
      bodyParts: <String>['Core', 'Shoulders'],
      durationSec: 45,
      imageAsset: '$basePath/core.webp',
      steps: <String>[
        'Set up on your forearms with elbows under your shoulders.',
        'Step your feet back and form a straight line from head to heels.',
        'Brace your core and gently pull your belly button in.',
        'Breathe steadily and lower your knees if you need to reset.',
      ],
    ),
    Exercise(
      id: 'bird-dog',
      name: 'Bird Dog',
      category: 'Core',
      bodyParts: <String>['Core', 'Lower Back', 'Glutes'],
      durationSec: 50,
      imageAsset: '$basePath/core.webp',
      steps: <String>[
        'Start on all fours with a neutral spine.',
        'Reach your right arm forward and left leg back at the same time.',
        'Keep your hips level and reach long from heel to fingertip.',
        'Return to center and switch sides.',
      ],
    ),

    // Hip
    Exercise(
      id: 'hip-mobility',
      name: 'Hip Mobility',
      category: 'Hip',
      bodyParts: <String>['Hips', 'Glutes', 'Lower Back'],
      durationSec: 45,
      imageAsset: '$basePath/hip.png',
      steps: <String>[
        'Stand with feet wider than hip-width and bend your knees.',
        'Shift your weight into your right hip and sink into a gentle squat.',
        'Reach your left arm across and lengthen the left side of your body.',
        'Flow side to side with slow, steady breaths.',
      ],
    ),
    Exercise(
      id: 'pigeon-pose',
      name: 'Pigeon Pose',
      category: 'Hip',
      bodyParts: <String>['Hips', 'Glutes'],
      durationSec: 55,
      imageAsset: '$basePath/hip.png',
      steps: <String>[
        'From all fours, bring your right knee toward your right wrist.',
        'Angle your right foot toward your left hip and slide your left leg back.',
        'Keep your hips level and fold forward as far as feels comfortable.',
        'Breathe, then switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'butterfly',
      name: 'Butterfly Stretch',
      category: 'Hip',
      bodyParts: <String>['Hips', 'Inner Thighs'],
      durationSec: 50,
      imageAsset: '$basePath/hip.png',
      steps: <String>[
        'Sit tall with the soles of your feet together and knees open.',
        'Hold your feet and lengthen your spine.',
        'Hinge forward from your hips without rounding your back.',
        'Breathe and let your knees soften toward the floor.',
      ],
    ),

    // Glutes
    Exercise(
      id: 'figure-four',
      name: 'Figure Four',
      category: 'Glutes',
      bodyParts: <String>['Glutes', 'Hips'],
      durationSec: 50,
      imageAsset: '$basePath/glutes.png',
      steps: <String>[
        'Lie on your back with knees bent and feet flat.',
        'Place your right ankle over your left thigh, forming a figure four.',
        'Reach through and clasp your left thigh, drawing it toward you.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'glute-bridge',
      name: 'Glute Bridge',
      category: 'Glutes',
      bodyParts: <String>['Glutes', 'Core', 'Lower Back'],
      durationSec: 45,
      imageAsset: '$basePath/glutes.png',
      steps: <String>[
        'Lie on your back with knees bent and feet hip-width apart.',
        'Press through your heels and lift your hips toward the ceiling.',
        'Squeeze your glutes at the top without arching your lower back.',
        'Lower slowly and repeat.',
      ],
    ),
    Exercise(
      id: 'standing-glute',
      name: 'Standing Glute Stretch',
      category: 'Glutes',
      bodyParts: <String>['Glutes', 'Hips'],
      durationSec: 45,
      imageAsset: '$basePath/glutes.png',
      steps: <String>[
        'Stand tall and cross your right ankle over your left knee.',
        'Bend your standing knee and sit your hips back and down.',
        'Keep your chest lifted and lean forward slightly.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),

    // Quads
    Exercise(
      id: 'standing-quad',
      name: 'Standing Quad Stretch',
      category: 'Quads',
      bodyParts: <String>['Quads', 'Hips'],
      durationSec: 45,
      imageAsset: '$basePath/quads.png',
      steps: <String>[
        'Stand tall and hold a wall for balance if needed.',
        'Bend your right knee and hold your ankle behind you.',
        'Keep your knees close together and gently push your hip forward.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'kneeling-lunge',
      name: 'Kneeling Lunge',
      category: 'Quads',
      bodyParts: <String>['Quads', 'Hips'],
      durationSec: 50,
      imageAsset: '$basePath/quads.png',
      steps: <String>[
        'Kneel on your right knee with your left foot forward.',
        'Tuck your pelvis slightly and shift your weight forward.',
        'Reach one arm up and lengthen through the front of your right hip.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'couch-stretch',
      name: 'Couch Stretch',
      category: 'Quads',
      bodyParts: <String>['Quads', 'Hip Flexors'],
      durationSec: 55,
      imageAsset: '$basePath/quads.png',
      steps: <String>[
        'Kneel close to a wall or couch with your back foot up against it.',
        'Slide your back knee toward the wall and keep your torso upright.',
        'Squeeze your glutes and gently push your hips forward.',
        'Breathe, then switch sides halfway through the timer.',
      ],
    ),

    // Hamstrings
    Exercise(
      id: 'hamstring-stretch',
      name: 'Hamstring Stretch',
      category: 'Hamstrings',
      bodyParts: <String>['Hamstrings', 'Hips', 'Calves'],
      durationSec: 45,
      imageAsset: '$basePath/Hamstring.png',
      steps: <String>[
        'Sit with your right leg extended and left knee bent.',
        'Sit tall and hinge forward from your hips over the straight leg.',
        'Keep your foot flexed and your spine long.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'seated-fold',
      name: 'Seated Forward Fold',
      category: 'Hamstrings',
      bodyParts: <String>['Hamstrings', 'Lower Back', 'Calves'],
      durationSec: 55,
      imageAsset: '$basePath/Hamstring.png',
      steps: <String>[
        'Sit with both legs extended in front of you.',
        'Flex your feet and sit tall on your sitting bones.',
        'Hinge forward from your hips, reaching toward your feet.',
        'Relax your neck and breathe into the back of your legs.',
      ],
    ),
    Exercise(
      id: 'toe-touch',
      name: 'Standing Toe Touch',
      category: 'Hamstrings',
      bodyParts: <String>['Hamstrings', 'Calves', 'Lower Back'],
      durationSec: 45,
      imageAsset: '$basePath/Hamstring.png',
      steps: <String>[
        'Stand with your feet hip-width apart and knees soft.',
        'Hinge forward from your hips and let your arms hang down.',
        'Keep your spine long rather than rounding aggressively.',
        'Breathe and slowly roll back up to standing.',
      ],
    ),

    // Calves
    Exercise(
      id: 'wall-calf',
      name: 'Wall Calf Stretch',
      category: 'Calves',
      bodyParts: <String>['Calves', 'Ankles', 'Hamstrings'],
      durationSec: 45,
      imageAsset: '$basePath/calves.png',
      steps: <String>[
        'Place both hands on a wall and step your right foot back.',
        'Keep your right heel on the floor and your back leg straight.',
        'Lean into the wall until you feel a stretch through your calf.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'downward-pedal',
      name: 'Downward Dog Pedal',
      category: 'Calves',
      bodyParts: <String>['Calves', 'Hamstrings'],
      durationSec: 45,
      imageAsset: '$basePath/calves.png',
      steps: <String>[
        'Come into downward dog with your hips lifted.',
        'Bend your right knee and press your left heel toward the floor.',
        'Alternate slowly, pedaling your feet like riding a bike.',
        'Keep your hands pressing firmly into the mat.',
      ],
    ),
    Exercise(
      id: 'seated-calf',
      name: 'Seated Calf Stretch',
      category: 'Calves',
      bodyParts: <String>['Calves', 'Ankles'],
      durationSec: 40,
      imageAsset: '$basePath/calves.png',
      steps: <String>[
        'Sit on the floor with your right leg extended.',
        'Loop a towel around the ball of your right foot.',
        'Gently pull your toes toward you until you feel the calf stretch.',
        'Hold, then switch sides halfway through the timer.',
      ],
    ),

    // Ankles
    Exercise(
      id: 'ankle-circles',
      name: 'Ankle Circles',
      category: 'Ankles',
      bodyParts: <String>['Ankles', 'Calves'],
      durationSec: 40,
      imageAsset: '$basePath/ankles.png',
      steps: <String>[
        'Sit or stand with one foot lifted slightly off the floor.',
        'Draw slow, controlled circles with your ankle.',
        'Make ten circles in each direction without moving your knee.',
        'Switch ankles halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'knee-to-wall',
      name: 'Knee-to-Wall',
      category: 'Ankles',
      bodyParts: <String>['Ankles', 'Calves'],
      durationSec: 45,
      imageAsset: '$basePath/ankles.png',
      steps: <String>[
        'Face a wall with your toes a few inches away.',
        'Drive your right knee forward toward the wall while keeping your heel down.',
        'Hold for a breath, then step back and reset.',
        'Switch sides halfway through the timer.',
      ],
    ),
    Exercise(
      id: 'ankle-rock',
      name: 'Ankle Rock',
      category: 'Ankles',
      bodyParts: <String>['Ankles', 'Calves', 'Quads'],
      durationSec: 45,
      imageAsset: '$basePath/ankles.png',
      steps: <String>[
        'Kneel with one foot forward and your heel planted.',
        'Shift your weight forward over your toes, keeping your heel down.',
        'Pause at the end range, then shift back with control.',
        'Repeat slowly, then switch sides halfway through.',
      ],
    ),

    // Morning Routine
    Exercise(
      id: 'morning-reach',
      name: 'Morning Reach',
      category: 'Morning Routine',
      bodyParts: <String>['Shoulders', 'Spine', 'Arms'],
      durationSec: 45,
      imageAsset: '$basePath/morning.png',
      steps: <String>[
        'Stand tall with your feet hip-width apart.',
        'Inhale and reach both arms overhead, interlacing your fingers.',
        'Lengthen through your sides and slightly back.',
        'Exhale and lower your arms slowly.',
      ],
    ),
    Exercise(
      id: 'spine-wake',
      name: 'Spine Awakening',
      category: 'Morning Routine',
      bodyParts: <String>['Spine', 'Core', 'Lower Back'],
      durationSec: 50,
      imageAsset: '$basePath/morning.png',
      steps: <String>[
        'Stand with your knees soft and arms relaxed.',
        'Slowly roll down through your spine, letting your head hang.',
        'Pause at the bottom and take one deep breath.',
        'Roll up one vertebra at a time.',
      ],
    ),
    Exercise(
      id: 'sunrise-side',
      name: 'Sunrise Side Bend',
      category: 'Morning Routine',
      bodyParts: <String>['Spine', 'Obliques', 'Shoulders'],
      durationSec: 45,
      imageAsset: '$basePath/morning.png',
      steps: <String>[
        'Stand tall and reach your right arm overhead.',
        'Lean gently to the left, lengthening your right side.',
        'Keep your hips centered and your chest open.',
        'Breathe, return to center, then switch sides.',
      ],
    ),
  ];

  static String categorySlug(String name) =>
      name.toLowerCase().replaceAll(' ', '-');

  static List<Exercise> exercisesForCategory(String category) =>
      exercises.where((exercise) => exercise.category == category).toList();

  static List<Exercise> exercisesForBodyPart(String bodyPart) {
    final normalized = bodyPart.toLowerCase().trim();
    return exercises.where((exercise) {
      return exercise.bodyParts.any((part) {
        final value = part.toLowerCase();
        return value == normalized ||
            value.contains(normalized) ||
            normalized.contains(value);
      });
    }).toList();
  }

  static Exercise? byId(String id) {
    for (final exercise in exercises) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }

  static List<String> categoriesForBodyPart(String bodyPart) {
    final result = <String>[];
    for (final exercise in exercisesForBodyPart(bodyPart)) {
      if (!result.contains(exercise.category)) result.add(exercise.category);
    }
    return result;
  }

  static String imageForCategory(String category) =>
      categoryImages[category] ?? '$basePath/yoga.png';
}
