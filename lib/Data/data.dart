import 'package:flutter/material.dart';

/* class Storage{
  static SharedPreferences? pref;
  static String key = "k1";

  static Map store = {
    "accountDetails" : accountDetails,
    "eventList" : fullEventList,
  };

  static void init() async {
    pref ??= await SharedPreferences.getInstance();
  }

  static void setDummyData(){
    accountDetails = dummyAccountDetails;
    fullEventList = dummyEventList;
  }

  static Map? loadData(){
    if(pref != null){
      String? stringData = pref?.getString(key);
      if(stringData == null){
        print("there is no data being saved.");
        return null;
      }
      return jsonDecode(stringData!);
    }else{
      print("pref is null.");
      return null;
    }
  } 

  static void saveData(){
    if(accountDetails == {} || fullEventList == []){
      print("no data can be saved. account details and event list are empty.");
      return;
    }
    String jsonString = jsonEncode(store);
    pref?.setString(key, jsonString);
  }
} */

//account details and event list to be stored
Map? accountDetails; 
List<Map>? fullEventList;

Map dummyAccountDetails = {
  "username" : "Dimas",
  "email" : "dimasrizkyk@gmail.com",
  "passwordHash" : "ah39829he920dh9h89d",
  "totalJoined" : 0,
  "topicsDiscussed" : 0,
  "friendsMade" : 0,
  "pastEvents" : [],
  "upcomingEvents" : [],
  "createdEvents" : [], 
};

List<Map<String, dynamic>> dummyEventList = [
  {
    "id": 0,
    "title": "Morning Jogging",
    "author": "Alice",
    "topics": ["STRESS", "FASHION", "WELLNESS"],
    "type": "JOGGING",
    "maxNumOfPeople": 20,
    "currentNumOfPeople": 9,
    "description": "Join us for a refreshing morning jog along the scenic routes of Singapore's East Coast Park. Experience the invigorating sea breeze and start your day on the right foot!",
    "location": [[1.3007, 103.9127]], // East Coast Park location
    "start": "15-04-2024 07:00",
    "end": "15-04-2024 08:00"
  },
  {
    "id": 1,
    "title": "Trail Running Adventure",
    "author": "Bob",
    "topics": ["SCHOOL", "EXAMS", "CHALLENGE", "FITNESS"],
    "type": "RUNNING",
    "maxNumOfPeople": 15,
    "currentNumOfPeople": 3,
    "description": "Embark on an adrenaline-pumping trail running adventure through Singapore's lush green trails in MacRitchie Reservoir. Challenge yourself and conquer nature's obstacles!",
    "location": [[1.3440, 103.8223]], // MacRitchie Reservoir location
    "start": "16-04-2024 08:00",
    "end": "16-04-2024 10:00"
  },
  {
    "id": 2,
    "title": "Cycling for Finance",
    "author": "Charlie",
    "topics": ["FINANCE", "CRYPTO", "CHALLENGE", "LEISURE"],
    "type": "CYCLING",
    "maxNumOfPeople": 25,
    "currentNumOfPeople": 7,
    "description": "Join our cycling expedition through Singapore's financial district and discover the city's bustling financial hub while enjoying the thrill of cycling through urban landscapes.",
    "location": [[1.2804, 103.8500]], // Singapore Financial District location
    "start": "17-04-2024 09:00",
    "end": "17-04-2024 11:00"
  },
  {
    "id": 3,
    "title": "Nature Hiking Expedition",
    "author": "David",
    "topics": ["NATURE", "WELLNESS", "ENVIRONMENT"],
    "type": "HIKING",
    "maxNumOfPeople": 15,
    "currentNumOfPeople": 12,
    "description": "Escape the hustle and bustle of the city with our nature hiking expedition. Traverse through Singapore's verdant rainforests and immerse yourself in the beauty of nature.",
    "location": [[1.3250, 103.8140]], // Bukit Timah Nature Reserve location
    "start": "18-01-2024 10:00",
    "end": "18-01-2024 12:00"
  },
  {
    "id": 4,
    "title": "Outdoor Gaming Challenge",
    "author": "Eve",
    "topics": ["GAMING", "ENTERTAINMENT", "CHALLENGE"],
    "type": "WALKING",
    "maxNumOfPeople": 30,
    "currentNumOfPeople": 22,
    "description": "Join us for an exhilarating outdoor gaming challenge at Sentosa Island, Singapore. Test your skills and strategic thinking in various thrilling games amidst scenic surroundings.",
    "location": [[1.2494, 103.8303]], // Sentosa Island location
    "start": "19-01-2024 14:00",
    "end": "19-01-2024 16:00"
  },
  {
    "id": 5,
    "title": "Yoga in the Park",
    "author": "Frank",
    "topics": ["SCIENCE", "TECHNOLOGY", "WELLNESS"],
    "type": "YOGA",
    "maxNumOfPeople": 20,
    "currentNumOfPeople": 14,
    "description": "Relax your body and mind with our rejuvenating yoga session in the tranquil setting of Singapore's Botanic Gardens. Experience inner peace amidst lush greenery.",
    "location": [[1.3136, 103.8153]], // Singapore Botanic Gardens location
    "start": "20-04-2024 07:30",
    "end": "20-04-2024 09:00"
  },
  {
    "id": 6,
    "title": "Swimming Workout",
    "author": "Grace",
    "topics": ["FASHION", "DESIGN", "FITNESS"],
    "type": "SWIMMING",
    "maxNumOfPeople": 30,
    "currentNumOfPeople": 17,
    "description": "Dive into fitness with our swimming workout session at Singapore's iconic Marina Bay Sands infinity pool. Tone your muscles while enjoying breathtaking city views.",
    "location": [[1.2836, 103.8607]], // Marina Bay Sands location
    "start": "21-04-2024 08:00",
    "end": "21-04-2024 09:30"
  },
  {
    "id": 7,
    "title": "CrossFit in Nature",
    "author": "Henry",
    "topics": ["SPORTS", "WELLNESS", "FITNESS"],
    "type": "CROSSFIT",
    "maxNumOfPeople": 15,
    "currentNumOfPeople": 7,
    "description": "Experience the ultimate workout amidst nature with our CrossFit session at Singapore's East Coast Park. Strengthen your body while breathing in the fresh sea air.",
    "location": [[1.3017, 103.9129]], // East Coast Park location
    "start": "22-04-2024 09:00",
    "end": "22-04-2024 10:30"
  },
  {
    "id": 8,
    "title": "Outdoor HIIT Session",
    "author": "Ivy",
    "topics": ["WELLNESS", "MENTAL HEALTH", "FITNESS"],
    "type": "HIIT",
    "maxNumOfPeople": 20,
    "currentNumOfPeople": 11,
    "description": "Revitalize your body and mind with our high-intensity interval training (HIIT) session in the heart of Singapore's lush greenery. Get fit while enjoying nature's beauty!",
    "location": [[1.3136, 103.8153]], // Singapore Botanic Gardens location
    "start": "23-04-2024 10:30",
    "end": "23-04-2024 12:00"
  },
  {
    "id": 9,
    "title": "Hiking Adventure",
    "author": "Jack",
    "topics": ["ADVENTURE", "FITNESS", "NATURE"],
    "type": "HIKING",
    "maxNumOfPeople": 20,
    "currentNumOfPeople": 20,
    "description": "Embark on an exciting hiking adventure through the Southern Ridges of Singapore. Discover hidden gems and panoramic views while staying active and fit.",
    "location": [[1.2833, 103.7895]], // Southern Ridges location
    "start": "24-04-2024 11:00",
    "end": "24-04-2024 13:00"
  },
  {
    "id": 10,
    "title": "Walking Meditation",
    "author": "Kate",
    "topics": ["TRAVEL", "ADVENTURE", "WELLNESS"],
    "type": "WALKING",
    "maxNumOfPeople": 25,
    "currentNumOfPeople": 19,
    "description": "Join our walking meditation session amidst the serene surroundings of Singapore's Gardens by the Bay. Connect with nature and find inner peace through mindful walking.",
    "location": [[1.2815, 103.8636]], // Gardens by the Bay location
    "start": "25-04-2024 07:00",
    "end": "25-04-2024 08:30"
  },
  {
    "id": 11,
    "title": "Trail Biking",
    "author": "Liam",
    "topics": ["PHOTOGRAPHY", "NATURE", "LEISURE"],
    "type": "CYCLING",
    "maxNumOfPeople": 20,
    "currentNumOfPeople": 12,
    "description": "Experience the thrill of trail biking through Singapore's lush green trails in Pulau Ubin. Discover hidden gems and capture stunning nature photographs along the way.",
    "location": [[1.4043, 103.9637]], // Pulau Ubin location
    "start": "26-04-2024 08:30",
    "end": "26-04-2024 10:30"
  },
  {
    "id": 12,
    "title": "Outdoor Yoga Retreat",
    "author": "Mia",
    "topics": ["ENVIRONMENT", "COMMUNITY", "WELLNESS"],
    "type": "YOGA",
    "maxNumOfPeople": 15,
    "currentNumOfPeople": 10,
    "description": "Escape the urban chaos and join us for an outdoor yoga retreat at Singapore's tranquil Labrador Nature Reserve. Rejuvenate your body and soul amidst nature's embrace.",
    "location": [[1.2720, 103.8037]], // Labrador Nature Reserve location
    "start": "27-04-2024 09:00",
    "end": "27-04-2024 11:00"
  },
  {
    "id": 13,
    "title": "Sunrise Photography",
    "author": "Nina",
    "topics": ["PHOTOGRAPHY", "ART", "NATURE"],
    "type": "PHOTOGRAPHY",
    "maxNumOfPeople": 10,
    "currentNumOfPeople": 6,
    "description": "Capture the breathtaking beauty of sunrise at Singapore's iconic Merlion Park. Join fellow photography enthusiasts and immortalize the first light of the day.",
    "location": [[1.2868, 103.8545]], // Merlion Park location
    "start": "28-04-2024 06:00",
    "end": "28-04-2024 08:00"
  },
  {
    "id": 14,
    "title": "Beach Cleanup",
    "author": "Oliver",
    "topics": ["ENVIRONMENT", "COMMUNITY", "SUSTAINABILITY"],
    "type": "VOLUNTEERING",
    "maxNumOfPeople": 30,
    "currentNumOfPeople": 25,
    "description": "Join us for a meaningful beach cleanup initiative at Singapore's East Coast Park. Contribute to environmental sustainability while enjoying the beach vibes!",
    "location": [[1.3007, 103.9127]], // East Coast Park location
    "start": "29-04-2024 09:30",
    "end": "29-04-2024 11:30"
  },
  {
    "id": 15,
    "title": "Outdoor Painting Session",
    "author": "Peter",
    "topics": ["ART", "CREATIVITY", "NATURE"],
    "type": "PAINTING",
    "maxNumOfPeople": 15,
    "currentNumOfPeople": 12,
    "description": "Unleash your creativity amidst the inspiring landscapes of Singapore's Marina Barrage. Join our outdoor painting session and let nature be your muse.",
    "location": [[1.2799, 103.8660]], // Marina Barrage location
    "start": "30-04-2024 09:00",
    "end": "30-04-2024 11:00"
  },
  {
    "id": 16,
    "title": "Dog Walking Group",
    "author": "Quinn",
    "topics": ["PETS", "COMMUNITY", "WELLNESS"],
    "type": "WALKING",
    "maxNumOfPeople": 20,
    "currentNumOfPeople": 11,
    "description": "Join our dog walking group for a fun-filled stroll along Singapore's picturesque East Coast Park. Meet fellow dog lovers and enjoy quality time with your furry friends.",
    "location": [[1.3007, 103.9127]], // East Coast Park location
    "start": "01-05-2024 08:00",
    "end": "01-05-2024 09:30"
  },
  {
    "id": 17,
    "title": "Bird Watching Expedition",
    "author": "Rachel",
    "topics": ["NATURE", "WILDLIFE", "ADVENTURE"],
    "type": "HIKING",
    "maxNumOfPeople": 15,
    "currentNumOfPeople": 9,
    "description": "Discover Singapore's diverse bird species with our bird watching expedition at Sungei Buloh Wetland Reserve. Observe majestic birds in their natural habitat.",
    "location": [[1.4467, 103.7302]], // Sungei Buloh Wetland Reserve location
    "start": "02-05-2024 07:30",
    "end": "02-05-2024 09:00"
  },
  {
    "id": 18,
    "title": "Rock Climbing Adventure",
    "author": "Sam",
    "topics": ["ADVENTURE", "CHALLENGE", "FITNESS"],
    "type": "ROCK CLIMBING",
    "maxNumOfPeople": 10,
    "currentNumOfPeople": 7,
    "description": "Challenge yourself with our rock climbing adventure at Dairy Farm Quarry, one of Singapore's premier climbing spots. Scale limestone cliffs and conquer new heights!",
    "location": [[1.3907, 103.7727]], // Dairy Farm Quarry location
    "start": "03-05-2024 08:00",
    "end": "03-05-2024 10:00"
  },
  {
    "id": 19,
    "title": "Outdoor Cooking Workshop",
    "author": "Tom",
    "topics": ["COOKING", "FOOD", "NATURE"],
    "type": "COOKING",
    "maxNumOfPeople": 12,
    "currentNumOfPeople": 4,
    "description": "Join our outdoor cooking workshop amidst the lush greenery of Singapore's Pasir Ris Park. Learn to prepare delicious meals using natural ingredients.",
    "location": [[1.3720, 103.9474]], // Pasir Ris Park location
    "start": "04-05-2024 09:30",
    "end": "04-05-2024 11:30"
  },
  {
    "id": 20,
    "title": "Botanical Garden Tour",
    "author": "Ursula",
    "topics": ["NATURE", "GARDENING", "COMMUNITY"],
    "type": "WALKING",
    "maxNumOfPeople": 20,
    "currentNumOfPeople": 13,
    "description": "Explore the botanical wonders of Singapore with our guided tour of Singapore Botanic Gardens. Discover rare plant species and learn about conservation efforts.",
    "location": [[1.3136, 103.8153]], // Singapore Botanic Gardens location
    "start": "05-05-2024 10:00",
    "end": "05-05-2024 12:00"
  },
  {
    "id": 21,
    "title": "Sunset Kayaking",
    "author": "Victoria",
    "topics": ["NATURE", "WATER SPORTS", "ADVENTURE"],
    "type": "KAYAKING",
    "maxNumOfPeople": 10,
    "currentNumOfPeople": 5,
    "description": "Paddle into the sunset with our kayaking adventure along the tranquil waters of Singapore's Kallang Basin. Witness breathtaking views as the sun dips below the horizon.",
    "location": [[1.3062, 103.8636]], // Kallang Basin location
    "start": "06-05-2024 17:00",
    "end": "06-05-2024 19:00"
  },
  {
    "id": 22,
    "title": "Beach Volleyball Tournament",
    "author": "William",
    "topics": ["SPORTS", "COMMUNITY", "LEISURE"],
    "type": "VOLLEYBALL",
    "maxNumOfPeople": 16,
    "currentNumOfPeople": 13,
    "description": "Join our beach volleyball tournament at Siloso Beach, Sentosa Island. Gather your team and compete for glory in a fun-filled day of sun, sand, and sports!",
    "location": [[1.2524, 103.8120]], // Siloso Beach location
    "start": "07-05-2024 10:00",
    "end": "07-05-2024 14:00"
  },
  {
    "id": 23,
    "title": "Tai Chi by the Lake",
    "author": "Xavier",
    "topics": ["WELLNESS", "MEDITATION", "COMMUNITY"],
    "type": "TAI CHI",
    "maxNumOfPeople": 25,
    "currentNumOfPeople": 7,
    "description": "Experience the harmony of mind and body with our Tai Chi session by the serene lakeside of Singapore's Chinese Garden. Rejuvenate your spirit amidst tranquil surroundings.",
    "location": [[1.3429, 103.7318]], // Chinese Garden location
    "start": "08-05-2024 08:30",
    "end": "08-05-2024 10:00"
  },
  {
    "id": 24,
    "title": "Outdoor Photography Workshop",
    "author": "Yvonne",
    "topics": ["PHOTOGRAPHY", "ART", "LEARNING"],
    "type": "PHOTOGRAPHY",
    "maxNumOfPeople": 15,
    "currentNumOfPeople": 4,
    "description": "Unleash your creativity with our outdoor photography workshop at Singapore's picturesque Gardens by the Bay. Capture stunning landscapes and master the art of photography.",
    "location": [[1.2816, 103.8635]], // Gardens by the Bay location
    "start": "09-05-2024 09:00",
    "end": "09-05-2024 11:00"
  },
  {
    "id": 25,
    "title": "Forest Bathing Experience",
    "author": "Zara",
    "topics": ["WELLNESS", "NATURE", "MEDITATION"],
    "type": "WALKING",
    "maxNumOfPeople": 20,
    "currentNumOfPeople": 12,
    "description": "Immerse yourself in the therapeutic embrace of nature with our forest bathing experience at Singapore's Chestnut Nature Park. Reconnect with yourself and find inner peace.",
    "location": [[1.3895, 103.7722]], // Chestnut Nature Park location
    "start": "10-05-2024 10:30",
    "end": "10-05-2024 12:00"
  },
  {
    "id": 26,
    "title": "Outdoor Fitness Bootcamp",
    "author": "Aaron",
    "topics": ["FITNESS", "HEALTH", "CHALLENGE"],
    "type": "FITNESS",
    "maxNumOfPeople": 20,
    "currentNumOfPeople": 15,
    "description": "Join our outdoor fitness bootcamp and push your limits in a high-intensity workout session at Singapore's Bedok Reservoir Park. Get motivated and achieve your fitness goals!",
    "location": [[1.3386, 103.9419]], // Bedok Reservoir Park location
    "start": "11-05-2024 09:00",
    "end": "11-05-2024 10:30"
  },
  {
    "id": 27,
    "title": "Nature Photography Walk",
    "author": "Bella",
    "topics": ["PHOTOGRAPHY", "NATURE", "LEISURE"],
    "type": "PHOTOGRAPHY",
    "maxNumOfPeople": 15,
    "currentNumOfPeople": 10,
    "description": "Explore the beauty of Singapore's nature reserves with our guided photography walk. Capture stunning landscapes and unique flora and fauna under expert guidance.",
    "location": [[1.3444, 103.6850]], // Various Nature Reserves location
    "start": "12-05-2024 08:00",
    "end": "12-05-2024 10:00"
  },
  {
    "id": 28,
    "title": "Adventure Trail Running",
    "author": "Cameron",
    "topics": ["RUNNING", "ADVENTURE", "FITNESS"],
    "type": "RUNNING",
    "maxNumOfPeople": 15,
    "currentNumOfPeople": 8,
    "description": "Embark on an adrenaline-pumping adventure trail run through Singapore's rugged terrain. Challenge yourself and conquer nature's obstacles while enjoying breathtaking views!",
    "location": [[1.3521, 103.8198]], // Various Trails location
    "start": "13-05-2024 07:30",
    "end": "13-05-2024 09:30"
  },
  {
    "id": 29,
    "title": "Outdoor Mindfulness Meditation",
    "author": "Daniel",
    "topics": ["MEDITATION", "WELLNESS", "HEALTH"],
    "type": "MEDITATION",
    "maxNumOfPeople": 20,
    "currentNumOfPeople": 16,
    "description": "Experience inner peace and tranquility with our outdoor mindfulness meditation session in the serene surroundings of Singapore's Fort Canning Park. Let go of stress and find balance.",
    "location": [[1.2958, 103.8456]], // Fort Canning Park location
    "start": "14-05-2024 07:00",
    "end": "14-05-2024 08:30"
  },
  {
    "id": 30,
    "title": "Kayaking Expedition",
    "author": "Ethan",
    "topics": ["WATER SPORTS", "ADVENTURE", "NATURE"],
    "type": "KAYAKING",
    "maxNumOfPeople": 12,
    "currentNumOfPeople": 6,
    "description": "Embark on a thrilling kayaking expedition and explore the hidden gems of Singapore's Southern Islands. Paddle through mangroves and discover secluded beaches.",
    "location": [[1.2258, 103.9200]], // Southern Islands location
    "start": "15-05-2024 09:00",
    "end": "15-05-2024 12:00"
  },
  {
    "id": 31,
    "title": "Nature Sketching Workshop",
    "author": "Fiona",
    "topics": ["ART", "NATURE", "LEARNING"],
    "type": "SKETCHING",
    "maxNumOfPeople": 15,
    "currentNumOfPeople": 11,
    "description": "Unleash your creativity with our nature sketching workshop amidst the inspiring landscapes of Singapore's MacRitchie Reservoir Park. Capture the beauty of nature on paper.",
    "location": [[1.3431, 103.8359]], // MacRitchie Reservoir Park location
    "start": "16-05-2024 10:30",
    "end": "16-05-2024 12:30"
  }
];

Map weatherReport = {
  "weather" : "Loading weather...",
  "tempLow" : 0,
  "tempHigh" : 0,
  "humidLow" : 0,
  "humidHigh" : 0,
};

List<Map> eventJoinedList = [];
Map? currentEvent;

List<String> activities = [
  "ARCHERY", "BADMINTON", "BASKETBALL", "BIRD WATCHING", "BOATING",
  "BOXING", "CAMPING", "CANOEING", "CLIMBING", "CRICKET",
  "CROSSFIT", "CYCLING", "DANCING", "FENCING", "FISHING",
  "FOOTBALL", "FRISBEE", "GARDENING", "GEOCACHING", "GOLF",
  "HIIT", "HIKING", "HORSEBACK RIDING", "ICE SKATING", "JOGGING",
  "KAYAKING", "MARTIAL ARTS", "PAINTBALL", "PAINTING", "PARKOUR",
  "PING PONG", "ROLLER SKATING", "RUNNING", "SAILING", "SKATEBOARDING",
  "SKIING", "SKYDIVING", "SNOWBOARDING", "SOCCER", "STARGAZING",
  "SURFING", "SWIMMING", "TENNIS", "TRAIL RUNNING", "VOLLEYBALL",
  "WALKING", "WATER SKIING", "WEIGHTLIFTING", "WILDLIFE VIEWING",
  "YOGA"
];

Map<List<String>, Color> topicsToColors = {
  ["school", "exams", 'clubs', 'study', 'cca'] : Colors.blue.shade300, // academics
  ["finance", "crypto", "trading", 'business', 'money', ] : Colors.yellow.shade300, // finance
  ["nature", "environment", "news", 'wellness', 'community', 'wildlife', 'gardening', 'sustainability', 'parenting'] : Colors.green.shade300, // nature/community
  ["gaming", "movies", "music", 'entertainment'] : Colors.orange.shade300, // entertainment
  ["science", "technology", "photography", 'blockchain', 'ai', 'computers'] : Colors.purple.shade200, // technology
  ["fashion", "design", "art", 'food', 'creativity', 'cooking'] : Colors.pink.shade300, // creativity
  ['challenge', 'leisure', 'adventure', 'relaxed', 'meditation', 'fitness', 'mental health', 'learning', 'health', 'sports'] : Colors.teal.shade300, // mode/mindset/lifestyle
  ["stress", "fear", 'sickness', 'disease', 'worry', 'anxiety'] : Colors.red.shade300, // concerns
};

Color getColorFromTopic(String topic){
  topic = topic.toLowerCase();
  for (var entry in topicsToColors.entries) {
    if (entry.key.contains(topic)) {
      return entry.value;
    }
  }
  return Colors.white; 
}