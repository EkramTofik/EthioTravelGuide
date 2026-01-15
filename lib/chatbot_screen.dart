import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = <_Message>[];
  late final Map<String, String> _faq = _buildFaq();
  late final Map<String, PlaceDetail> _places = _buildPlaceDatabase();

  // Stylish Blue Color Palette
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color lightBlue = Color(0xFFDBEAFE);
  static const Color darkBlue = Color(0xFF1E40AF);
  static const Color chatBackground = Color(0xFFF0F9FF);
  static const Color userBubbleBlue = Color(0xFF2563EB);
  static const Color botBubbleLight = Color(0xFFFFFFFF);

  static const Gradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
  );

  static const Gradient userBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =================== PLACE DATABASE ===================
  Map<String, PlaceDetail> _buildPlaceDatabase() {
    return {
      'lalibela': PlaceDetail(
        name: 'Lalibela',
        description:
            'Lalibela is a town in northern Ethiopia famous for its rock-cut monolithic churches. Built in the 12th-13th centuries by King Lalibela, these 11 medieval churches are carved out of solid volcanic rock and are a UNESCO World Heritage Site. Often called the "Eighth Wonder of the World".',
        location: 'Amhara Region, northern Ethiopia',
        coordinates: '12.0317° N, 39.0417° E',
        altitude: '2,500 meters',
        distanceFromAddis: '640 km (10-12 hours drive, 1 hour flight)',
        languages: ['Amharic', 'Tigrinya'],
        bestTimeToVisit: 'October to March',
        entranceFee: '\$50-70 for foreigners',
        unesco: true,
        category: 'Historical/Religious',
      ),
      'axum': PlaceDetail(
        name: 'Axum (Aksum)',
        description:
            'Axum was the capital of the ancient Aksumite Empire, one of the great civilizations of the ancient world. It\'s known for its giant obelisks (stelae), ancient tombs, and the Church of St. Mary of Zion which supposedly houses the Ark of the Covenant.',
        location: 'Tigray Region, northern Ethiopia',
        coordinates: '14.1206° N, 38.7264° E',
        altitude: '2,131 meters',
        distanceFromAddis: '1,020 km (15-18 hours drive, limited flights)',
        languages: ['Tigrinya', 'Amharic'],
        bestTimeToVisit: 'October to April',
        entranceFee: '\$30-50 for foreigners',
        unesco: true,
        category: 'Historical/Archaeological',
      ),
      'gondar': PlaceDetail(
        name: 'Gondar',
        description:
            'Gondar was the capital of the Ethiopian Empire from the 17th to 19th centuries. Known as the "Camelot of Africa" for its medieval castles and palaces in the Royal Enclosure (Fasil Ghebbi). Also features the beautiful Debre Berhan Selassie Church with its famous angel ceiling.',
        location: 'Amhara Region, northern Ethiopia',
        coordinates: '12.6100° N, 37.4600° E',
        altitude: '2,133 meters',
        distanceFromAddis: '720 km (10-12 hours drive, 1 hour flight)',
        languages: ['Amharic'],
        bestTimeToVisit: 'October to March',
        entranceFee: '\$20-30 for foreigners',
        unesco: true,
        category: 'Historical',
      ),
      'simien mountains': PlaceDetail(
        name: 'Simien Mountains National Park',
        description:
            'A UNESCO World Heritage Site known as the "Roof of Africa" with dramatic mountain scenery, deep valleys, and sharp precipices dropping 1,500 meters. Home to rare species like the Gelada baboon, Ethiopian wolf, and Walia ibex. Ras Dashen at 4,550m is Ethiopia\'s highest peak.',
        location: 'Amhara Region, northern Ethiopia',
        coordinates: '13.2333° N, 38.3833° E',
        altitude: '1,900 to 4,550 meters',
        distanceFromAddis:
            '820 km via Gondar (fly to Gondar then 3-4 hour drive)',
        languages: ['Amharic'],
        bestTimeToVisit: 'October to March (dry season)',
        entranceFee: '\$20 per day + guide/scout fees',
        unesco: true,
        category: 'Natural/Adventure',
      ),
      'harar': PlaceDetail(
        name: 'Harar Jugol',
        description:
            'A fortified historic town with 368 alleys, 82 mosques, and traditional Harari houses. A UNESCO World Heritage Site and the fourth holiest city in Islam. Famous for its hyena feeding ritual, colorful markets, and unique Harari culture.',
        location: 'Harari Region, eastern Ethiopia',
        coordinates: '9.3100° N, 42.1300° E',
        altitude: '1,885 meters',
        distanceFromAddis:
            '525 km (7-8 hours drive, fly to Dire Dawa then 1 hour drive)',
        languages: ['Harari', 'Oromo', 'Amharic'],
        bestTimeToVisit: 'October to March',
        entranceFee: '\$10-20 for foreigners',
        unesco: true,
        category: 'Cultural/Historical',
      ),
      'danakil depression': PlaceDetail(
        name: 'Danakil Depression',
        description:
            'One of the hottest places on Earth and lowest points in Africa at 125 meters below sea level. Features otherworldly landscapes including the Erta Ale active volcano with a permanent lava lake, Dallol sulfur springs (rainbow-colored), and salt lakes. Extreme adventure destination.',
        location: 'Afar Region, northeastern Ethiopia',
        coordinates: '14.2417° N, 40.3000° E',
        altitude: '-125 meters below sea level',
        distanceFromAddis: '780 km (2 days driving via Mekele)',
        languages: ['Afar', 'Amharic'],
        bestTimeToVisit: 'November to March (cooler months)',
        entranceFee: 'Tour packages \$300-500+ (requires organized tour)',
        unesco: false,
        category: 'Natural/Adventure',
      ),
      'omo valley': PlaceDetail(
        name: 'Omo Valley',
        description:
            'A cultural melting pot with over 16 indigenous tribes living traditional lifestyles. Home to the Mursi (lip plates), Hamar (bull jumping), Karo (body painting), and other tribes. One of the best places in Africa for cultural anthropology and photography.',
        location: 'Southern Nations Region, southwestern Ethiopia',
        coordinates: '5.3167° N, 36.5667° E',
        altitude: '500 to 1,000 meters',
        distanceFromAddis:
            '720 km (11-13 hours drive, fly to Arba Minch or Jinka)',
        languages: ['Over 16 tribal languages including Mursi, Hamar, Karo'],
        bestTimeToVisit: 'June to September or December to February',
        entranceFee: 'Tribal visit fees \$5-20 per person',
        unesco: true,
        category: 'Cultural/Anthropological',
      ),
      'bahir dar': PlaceDetail(
        name: 'Bahir Dar',
        description:
            'A beautiful city on the shores of Lake Tana, source of the Blue Nile. Known for its monasteries on lake islands and the spectacular Blue Nile Falls (Tis Abay). Pleasant climate, palm-lined avenues, and vibrant markets.',
        location: 'Amhara Region, northwest Ethiopia',
        coordinates: '11.6000° N, 37.3833° E',
        altitude: '1,800 meters',
        distanceFromAddis: '565 km (9-11 hours drive, 1 hour flight)',
        languages: ['Amharic'],
        bestTimeToVisit: 'October to March',
        entranceFee: 'Lake boat tour \$20-40, Falls \$5',
        unesco: false,
        category: 'Natural/Cultural',
      ),
      'addis ababa': PlaceDetail(
        name: 'Addis Ababa',
        description:
            'The capital and largest city of Ethiopia, founded in 1886. Nicknamed "the political capital of Africa" as headquarters of the African Union. Mix of modern skyscrapers and traditional markets. Home to the National Museum (Lucy skeleton), Holy Trinity Cathedral, and Entoto Mountain.',
        location: 'Central Ethiopia, at the foot of Mount Entoto',
        coordinates: '9.0300° N, 38.7400° E',
        altitude: '2,355 meters',
        distanceFromAddis: 'Capital city - central hub',
        languages: ['Amharic (official)', 'English', 'Oromo', 'many others'],
        bestTimeToVisit: 'Year-round, but best October to March',
        entranceFee: 'Most attractions \$5-20',
        unesco: false,
        category: 'Urban/Cultural',
      ),
      'bale mountains': PlaceDetail(
        name: 'Bale Mountains National Park',
        description:
            'A high-altitude plateau with the largest area of Afro-alpine habitat in Africa. Home to the endangered Ethiopian wolf and mountain nyala. Features the Sanetti Plateau (over 4,000m), Harenna Forest, and Sof Omar caves.',
        location: 'Oromia Region, southeast Ethiopia',
        coordinates: '6.8333° N, 39.8333° E',
        altitude: '1,500 to 4,377 meters',
        distanceFromAddis: '400 km (7-8 hours drive)',
        languages: ['Oromo', 'Amharic'],
        bestTimeToVisit: 'October to May',
        entranceFee: '\$20 per day + guide fees',
        unesco: false,
        category: 'Natural/Wildlife',
      ),
    };
  }

  Map<String, String> _buildFaq() {
    final map = <String, String>{};

    // =================== GENERAL ETHIOPIA INFO ===================
    map.addAll({
      // Multiple ways to ask about EthioTravel Guide
      'what is ethiotravel guide':
          '🌟 **EthioTravel Guide** is your intelligent travel companion for Ethiopia! \n\n✨ **Features**:\n• 📍 Interactive maps & navigation\n• 🏛️ 500+ attractions database\n• 🍽️ Restaurant & food guides\n• 🏨 Accommodation booking\n• 🗺️ Offline access to key info\n• 💬 Real-time chat assistance\n\n🎯 **Perfect for**: First-time visitors, cultural explorers, adventure seekers, and food lovers!',
      'tell me about ethiotravel guide':
          '🌟 **EthioTravel Guide** is your intelligent travel companion for Ethiopia! \n\n✨ **Features**:\n• 📍 Interactive maps & navigation\n• 🏛️ 500+ attractions database\n• 🍽️ Restaurant & food guides\n• 🏨 Accommodation booking\n• 🗺️ Offline access to key info\n• 💬 Real-time chat assistance\n\n🎯 **Perfect for**: First-time visitors, cultural explorers, adventure seekers, and food lovers!',
      'describe ethiotravel guide':
          '🌟 **EthioTravel Guide** is your intelligent travel companion for Ethiopia! \n\n✨ **Features**:\n• 📍 Interactive maps & navigation\n• 🏛️ 500+ attractions database\n• 🍽️ Restaurant & food guides\n• 🏨 Accommodation booking\n• 🗺️ Offline access to key info\n• 💬 Real-time chat assistance\n\n🎯 **Perfect for**: First-time visitors, cultural explorers, adventure seekers, and food lovers!',
      'what does ethiotravel guide do':
          '🌟 **EthioTravel Guide** is your intelligent travel companion for Ethiopia! \n\n✨ **Features**:\n• 📍 Interactive maps & navigation\n• 🏛️ 500+ attractions database\n• 🍽️ Restaurant & food guides\n• 🏨 Accommodation booking\n• 🗺️ Offline access to key info\n• 💬 Real-time chat assistance\n\n🎯 **Perfect for**: First-time visitors, cultural explorers, adventure seekers, and food lovers!',

      // Multiple ways to ask about Ethiopia
      'about ethiopia':
          '🌍 **Ethiopia - Land of Origins**\n\n**Quick Facts:**\n• **Capital**: Addis Ababa\n• **Population**: 120+ million\n• **Area**: 1.1 million km²\n• **Language**: Amharic (official), 80+ local languages\n• **Currency**: Ethiopian Birr (ETB)\n• **Time Zone**: GMT+3\n• **Calling Code**: +251\n\n**Unique Features:**\n✓ Only African country never colonized\n✓ Origin of coffee\n✓ 13-month calendar\n✓ 3,000+ years of history\n✓ 9 UNESCO World Heritage Sites',
      'tell me about ethiopia':
          '🇪🇹 **Ethiopia - The Cradle of Humanity**\n\n**Geography:**\n• Located in Horn of Africa\n• Landlocked (ports via Djibouti)\n• Varied terrain: mountains, deserts, lakes\n• Great Rift Valley runs through\n\n**History:**\n• Ancient Axumite Empire (1st century AD)\n• Solomonic dynasty legends\n• Only African country never colonized\n• Oldest independent African nation\n\n**Culture:**\n• 13-month calendar (7-8 years behind)\n• Unique time system (sunrise = 1:00)\n• Orthodox Christian traditions\n• Coffee ceremony rituals\n\n**Economy:**\n• Fastest growing in Africa\n• Agriculture-based (coffee exports)\n• Emerging technology sector',
      'describe ethiopia':
          '📝 **Ethiopia Description:**\n\nA land of dramatic contrasts - from the highest peaks of the Simien Mountains to the lowest depths of the Danakil Depression. Ethiopia is where ancient traditions meet modern aspirations.\n\n**Key Characteristics:**\n• **Historical**: Ancient kingdoms, rock churches\n• **Cultural**: Diverse tribes, unique customs\n• **Natural**: Spectacular landscapes, unique wildlife\n• **Spiritual**: Ancient Christianity, Islam coexistence\n• **Agricultural**: Coffee origin, diverse crops\n\n**Climate:** Tropical monsoon with wide variation due to altitude (highlands cool, lowlands hot).',
      'information about ethiopia':
          '📊 **Ethiopia at a Glance:**\n\n**Basic Info:**\n• **Full Name**: Federal Democratic Republic of Ethiopia\n• **Government**: Federal parliamentary republic\n• **President**: Sahle-Work Zewde\n• **Prime Minister**: Abiy Ahmed\n• **Independence**: Never colonized\n• **UN Membership**: Founding member\n\n**Demographics:**\n• **Population**: ~120 million (2nd in Africa)\n• **Median Age**: 19.5 years\n• **Urbanization**: 21% (growing rapidly)\n• **Literacy Rate**: ~52%\n\n**Religion:**\n• Ethiopian Orthodox ~44%\n• Islam ~34%\n• Protestant ~19%\n• Traditional ~3%',
      'what is ethiopia':
          '🇪🇹 **Ethiopia** is a landlocked country in the Horn of Africa known as the "Cradle of Humanity" where some of the oldest human fossils were found. It\'s the only African country that was never colonized and has a rich history dating back over 3,000 years.',
      'can you describe ethiopia':
          '🇪🇹 **Ethiopia - A Land of Contrasts:**\n• **History**: Ancient civilizations like Axum\n• **Culture**: Over 80 ethnic groups\n• **Religion**: Orthodox Christian heritage\n• **Nature**: From Simien peaks to Danakil desert\n• **Food**: Unique cuisine like injera\n• **Coffee**: Birthplace of coffee cultivation',

      // Multiple ways to ask about visiting Ethiopia
      'why visit ethiopia':
          '🎯 **Top 10 Reasons to Visit Ethiopia:**\n\n1. **Ancient History**: Rock-hewn churches of Lalibela\n2. **Unique Culture**: Over 80 ethnic groups\n3. **Spectacular Nature**: Simien & Bale Mountains\n4. **Birthplace of Coffee**: Authentic coffee ceremonies\n5. **Friendly People**: Known for hospitality\n6. **Affordable Travel**: Good value for money\n7. **Delicious Food**: Unique cuisine (injera, wot)\n8. **Adventure**: Trekking, wildlife, hot springs\n9. **Festivals**: Colorful religious celebrations\n10. **Climate**: Year-round spring in highlands',
      'why should i visit ethiopia':
          '🎯 **Top Reasons to Visit Ethiopia:**\n\n• **Unique History**: Only uncolonized African country\n• **UNESCO Sites**: 9 World Heritage Sites\n• **Cultural Diversity**: 80+ ethnic groups\n• **Natural Beauty**: Mountains, lakes, waterfalls\n• **Affordable**: Great value for travelers\n• **Hospitality**: Welcoming local people\n• **Adventure**: Trekking, safaris, cultural tours',
      'reasons to visit ethiopia':
          '🎯 **Why Ethiopia Should Be Your Next Destination:**\n\n✓ Ancient rock churches of Lalibela\n✓ Tribal cultures of Omo Valley\n✓ Spectacular Simien Mountains\n✓ Historic castles of Gondar\n✓ Vibrant capital Addis Ababa\n✓ Unique Ethiopian cuisine\n✓ Birthplace of coffee\n✓ Year-round pleasant climate',
      'what makes ethiopia special':
          '🌟 **What Makes Ethiopia Unique:**\n\n• **Historical**: Never colonized, ancient civilization\n• **Cultural**: 13-month calendar, unique alphabet\n• **Religious**: Ancient Christian traditions\n• **Natural**: Diverse landscapes & wildlife\n• **Archaeological**: "Lucy" fossil discovery site\n• **Spiritual**: Holy sites for Christians & Muslims\n• **Agricultural**: Origin of coffee cultivation',

      // Multiple ways to ask about languages
      'how many languages in ethiopia':
          '🗣️ **Languages of Ethiopia:**\n\n**Official Language:** Amharic\n\n**Major Regional Languages:**\n1. Oromo (~34% of population)\n2. Amharic (~30%)\n3. Somali (~6%)\n4. Tigrinya (~6%)\n5. Sidamo (~4%)\n6. Wolaytta (~2%)\n7. Gurage (~2%)\n8. Afar (~1.7%)\n9. Hadiyya (~1.7%)\n10. Gamo (~1.5%)\n\n**Total:** Over 80 languages spoken!\n\n**English** is widely taught in schools and used in business/tourism.',
      'what languages are spoken in ethiopia':
          '🗣️ **Ethiopia\'s Linguistic Diversity:**\n\n**Official**: Amharic (written in Ge\'ez script)\n\n**Working Languages**: Amharic, English, Arabic\n\n**Major Language Families:**\n• **Semitic**: Amharic, Tigrinya, Gurage\n• **Cushitic**: Oromo, Somali, Afar, Sidamo\n• **Omotic**: Wolaytta, Gamo, Dorze\n• **Nilo-Saharan**: Nuer, Anuak\n\n**Tourism Areas**: English widely spoken\n**Rural Areas**: Local languages dominant',
      'languages in ethiopia':
          '🗣️ **Ethiopia has over 80 languages!**\n\n**Most Spoken:**\n1. Oromo (34%)\n2. Amharic (30%)\n3. Somali (6%)\n4. Tigrinya (6%)\n5. Sidamo (4%)\n\n**Official**: Amharic\n**Tourism**: English widely understood\n**Writing**: Ge\'ez script for Amharic',
      'what language do they speak in ethiopia':
          '🗣️ **Main Languages in Ethiopia:**\n\n**Official**: Amharic\n**Most Common**: Oromo\n**Tourism Areas**: English\n**Total Languages**: 80+\n\nAmharic uses the unique Ge\'ez script, one of the oldest alphabets still in use.',
      'ethiopian languages':
          '🗣️ **Ethiopian Languages Overview:**\n\n• **Total**: 80+ distinct languages\n• **Official**: Amharic\n• **Script**: Ge\'ez (one of oldest alphabets)\n• **English**: Widely taught and used in tourism\n• **Arabic**: Used in Muslim communities\n• **Local**: Each region has dominant languages',

      // Multiple ways to ask about WH-questions
      'where is':
          '📍 **I can help you find locations!** Try:\n• "Where is Lalibela?"\n• "Location of Simien Mountains"\n• "Where is [place name] located?"\n• "Can you show me where [place] is?"\n• "Find [place] on map"\n\nI\'ll provide coordinates, region, and distance from Addis.',
      'how far is':
          '📏 **I can check distances!** Try:\n• "How far is Lalibela from Addis?"\n• "Distance from Gondar to Simien"\n• "How far is [place A] from [place B]?"\n• "What\'s the distance to [place]?"\n• "Travel time to [destination]"\n\nI\'ll provide road distances and travel times.',
      'what is':
          '📖 **I can describe places!** Try:\n• "What is Lalibela?"\n• "Describe Simien Mountains"\n• "Tell me about [place name]"\n• "Can you explain what [place] is?"\n• "Give me information about [place]"\n\nI\'ll provide detailed descriptions.',
      'how many':
          '🔢 **I can provide statistics!** Try:\n• "How many languages in Ethiopia?"\n• "How many UNESCO sites?"\n• "How many tribes in Omo Valley?"\n• "What\'s the count of [things]?"\n• "Number of [items] in Ethiopia"\n\nI\'ll give you accurate numbers.',
      'when is':
          '📅 **I know dates and seasons!** Try:\n• "When is best time to visit?"\n• "When is Timket festival?"\n• "When to visit [place]?"\n• "What season for [activity]?"\n• "Best months for [destination]"\n\nI\'ll provide seasonal advice.',
      'why is':
          '🤔 **I can explain significance!** Try:\n• "Why is Lalibela important?"\n• "Why visit Ethiopia?"\n• "Why is [place] famous?"\n• "What makes [place] special?"\n• "Significance of [place/thing]"\n\nI\'ll explain historical/cultural significance.',
      'who built':
          '👷 **I know historical builders!** Try:\n• "Who built Lalibela?"\n• "Who constructed Gondar castles?"\n• "Who founded [place]?"\n• "Creator of [monument]"\n• "Architect of [building]"\n\nI\'ll provide historical context.',
      'which is':
          '🏆 **I can recommend!** Try:\n• "Which is better, Simien or Bale?"\n• "Which places to visit first?"\n• "Which season is best?"\n• "What should I choose between [options]?"\n• "Recommend [type of place]"\n\nI\'ll help you choose.',
      'how to':
          '📝 **I can guide you!** Try:\n• "How to get to Lalibela?"\n• "How to book tours?"\n• "How to travel in Ethiopia?"\n• "How do I [action]?"\n• "Steps for [process]"\n\nI\'ll provide step-by-step guidance.',
    });

    return map;
  }

  String _titleCase(String input) {
    return input
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  List<String> _tokens(String input) =>
      input.split(RegExp(r'[^a-z0-9]+')).where((t) => t.isNotEmpty).toList();

  // =================== ENHANCED NATURAL LANGUAGE UNDERSTANDING ===================
  String? _findBestMatch(String userText) {
    final q = userText.toLowerCase();
    final qTokens = _tokens(q);
    MapEntry<String, String>? best;
    var bestScore = 0;

    // First check for direct matches and synonyms
    for (final entry in _faq.entries) {
      final key = entry.key.toLowerCase();
      final keyTokens = _tokens(key);
      var score = 0;

      // Direct match
      if (q == key) {
        score += 100;
      }

      // Contains match
      if (q.contains(key)) {
        score += keyTokens.length * 3;
      }

      // Check for synonyms and variations
      score += _calculateSimilarityScore(q, key);

      // Token overlap
      for (final t in qTokens) {
        if (keyTokens.contains(t)) {
          score += 2;
        } else if (t.length > 3 && key.contains(t)) {
          score += 1;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        best = entry;
      }
    }

    return bestScore > 2 ? best!.value : null;
  }

  int _calculateSimilarityScore(String query, String key) {
    var score = 0;

    // Synonym mapping for common terms
    final synonymMap = {
      'what': [
        'what is',
        'what are',
        'what does',
        'explain',
        'describe',
        'tell me about',
      ],
      'where': ['where is', 'location of', 'find', 'locate', 'position of'],
      'how': ['how to', 'how do', 'how can', 'way to', 'method for'],
      'when': ['when is', 'time for', 'date of', 'season for'],
      'why': ['why is', 'reason for', 'cause of', 'purpose of'],
      'who': ['who is', 'who are', 'person who', 'creator of'],
      'which': ['which one', 'choose between', 'select from', 'option'],
      'best': ['top', 'recommended', 'excellent', 'great', 'good'],
      'visit': ['go to', 'travel to', 'see', 'tour', 'explore'],
      'place': ['location', 'site', 'destination', 'attraction', 'spot'],
      'information': ['details', 'facts', 'data', 'info', 'knowledge'],
      'hotel': ['accommodation', 'lodging', 'stay', 'inn', 'guesthouse'],
      'food': ['restaurant', 'cuisine', 'meal', 'dish', 'eat'],
      'travel': ['journey', 'trip', 'voyage', 'tour', 'excursion'],
    };

    // Check for synonyms in query
    for (final synonymEntry in synonymMap.entries) {
      final baseWord = synonymEntry.key;
      final synonyms = synonymEntry.value;

      if (key.contains(baseWord)) {
        for (final synonym in synonyms) {
          if (query.contains(synonym)) {
            score += 3;
          }
        }
      }
    }

    return score;
  }

  // =================== ENHANCED ANSWER FUNCTION ===================
  String _answer(String userText) {
    final query = userText.toLowerCase();

    // Enhanced place detection with variations
    for (final placeEntry in _places.entries) {
      final placeName = placeEntry.key;
      final placeDetail = placeEntry.value;

      // Multiple ways to ask about a place
      final placePatterns = [
        placeName,
        placeName.split(' ')[0], // First word
        placeDetail.name.toLowerCase(),
        ...placeDetail.name.split(' ').map((w) => w.toLowerCase()),
      ];

      bool isPlaceQuery = false;
      for (final pattern in placePatterns) {
        if (pattern.length > 3 && query.contains(pattern)) {
          isPlaceQuery = true;
          break;
        }
      }

      if (isPlaceQuery) {
        // Handle different question types about this place with multiple phrasings
        if (_containsAny(query, [
              'what',
              'describe',
              'tell me about',
              'information about',
              'explain',
              'can you describe',
              'what can you tell me about',
              'details about',
              'tell me something about',
            ]) &&
            _containsAny(query, [
              placeName,
              ...placeDetail.name.split(' ').map((w) => w.toLowerCase()),
            ])) {
          return _getPlaceDescription(placeDetail);
        }

        if (_containsAny(query, [
              'where is',
              'location of',
              'find',
              'locate',
              'where can i find',
              'where\'s',
              'where does',
              'place of',
              'situated',
            ]) &&
            _containsAny(query, [
              placeName,
              ...placeDetail.name.split(' ').map((w) => w.toLowerCase()),
            ])) {
          return _getPlaceLocation(placeDetail);
        }

        if (_containsAny(query, [
              'how far',
              'distance',
              'from addis',
              'travel time',
              'how long to get',
              'journey time',
              'drive time',
              'flight time',
              'how to get to',
            ]) &&
            _containsAny(query, [
              placeName,
              ...placeDetail.name.split(' ').map((w) => w.toLowerCase()),
            ])) {
          return _getPlaceDistance(placeDetail);
        }

        if (_containsAny(query, [
              'when to visit',
              'best time',
              'season for',
              'when should i go',
              'good time',
              'right time',
              'ideal time',
              'weather',
            ]) &&
            _containsAny(query, [
              placeName,
              ...placeDetail.name.split(' ').map((w) => w.toLowerCase()),
            ])) {
          return '''
📅 **Best Time to Visit ${placeDetail.name}:**
${placeDetail.bestTimeToVisit}

${_getWeatherAdvice(placeName)}
''';
        }

        if (_containsAny(query, [
              'language',
              'speak',
              'tongue',
              'dialect',
              'local language',
            ]) &&
            _containsAny(query, [
              placeName,
              ...placeDetail.name.split(' ').map((w) => w.toLowerCase()),
            ])) {
          return _getPlaceLanguages(placeDetail);
        }

        if (_containsAny(query, [
              'cost',
              'price',
              'fee',
              'entrance',
              'ticket',
              'how much',
              'charge',
            ]) &&
            _containsAny(query, [
              placeName,
              ...placeDetail.name.split(' ').map((w) => w.toLowerCase()),
            ])) {
          return '''
💰 **Costs for ${placeDetail.name}:**

**Entrance Fee:** ${placeDetail.entranceFee}
${_getAdditionalCosts(placeName)}
${_getBudgetAdvice(placeName)}
''';
        }

        // Default: return full place info
        return _getPlaceFullInfo(placeDetail);
      }
    }

    // Check for WH-questions with multiple phrasings
    if (_isQuestion(query)) {
      return _handleQuestion(query);
    }

    // Check FAQ with enhanced matching
    final best = _findBestMatch(query);
    if (best != null) return best;

    // Enhanced fallback responses with better understanding
    if (_containsAny(query, [
      'tour',
      'book',
      'package',
      'guided tour',
      'tour operator',
      'arrange tour',
      'organize trip',
    ])) {
      return '🏢 **Tour Operators:** For tours, I recommend licensed operators in Addis. Popular ones: Ethiopian Quadrants, Grand Holidays, Tesfa Tours. Book in advance for peak season.\n\n💡 **Tip:** Always check reviews and ensure your operator is licensed by the Ethiopian Tourism Bureau.';
    }

    if (_containsAny(query, [
      'hotel',
      'stay',
      'accommodation',
      'lodging',
      'guesthouse',
      'where to stay',
      'place to sleep',
      'reservation',
    ])) {
      return '🏨 **Accommodation:** Ranges from budget guesthouses (\$10-30) to luxury lodges (\$150-300+).\n\n• **Addis:** Bole area (modern) or Piazza (historic)\n• **Lalibela:** Near churches\n• **Gondar:** Near castles\n• **Simien:** Debark or park lodges\n\n📱 **Booking:** Use Booking.com or contact hotels directly.';
    }

    if (_containsAny(query, [
      'food',
      'eat',
      'restaurant',
      'cuisine',
      'meal',
      'dish',
      'what to eat',
      'local food',
      'ethiopian food',
      'injera',
    ])) {
      return '🍽️ **Food Guide:**\n\n**Must try:** injera with doro wot (chicken stew), tibs, kitfo (minced beef), shiro, beyaynetu (vegetable platter).\n\n🌱 **Vegetarian options excellent** - many traditional dishes are plant-based.\n\n🍴 **Where to eat:** Local restaurants for authentic experience.';
    }

    if (_containsAny(query, [
      'flight',
      'airport',
      'fly',
      'air travel',
      'plane',
      'how to fly',
      'domestic flight',
      'ethiopian airlines',
    ])) {
      return '✈️ **Flights:** Ethiopian Airlines has extensive domestic network.\n\n**Tips:**\n• Book early as flights fill quickly\n• Popular routes: Addis to Bahir Dar, Gondar, Lalibela, Axum\n• Check baggage allowance\n• Arrive 2 hours early for domestic flights';
    }

    if (_containsAny(query, [
      'visa',
      'entry',
      'passport',
      'immigration',
      'border',
      'entry requirements',
      'travel documents',
    ])) {
      return '🛂 **Visa Info:**\n\n• **E-visa recommended:** www.evisa.gov.et\n• **Process:** 1-3 days\n• **Requirements:** passport scan, photo, flight details, accommodation\n• **Some nationalities:** visa on arrival at Bole Airport\n• **Validity:** Usually 30-90 days';
    }

    if (_containsAny(query, [
      'place',
      'visit',
      'attraction',
      'site',
      'destination',
      'things to see',
      'sights',
      'tourist spot',
      'must see',
    ])) {
      return '🏛️ **Top Attractions:**\n\n**Historical:**\n• Lalibela (rock churches)\n• Axum (ancient obelisks)\n• Gondar (medieval castles)\n\n**Natural:**\n• Simien Mountains (dramatic cliffs)\n• Danakil Depression (volcanic)\n• Blue Nile Falls\n\n**Cultural:**\n• Omo Valley (tribal cultures)\n• Harar (walled city)\n• Lake Tana monasteries\n\n💡 **Ask about any specific place by name!**';
    }

    if (_containsAny(query, [
      'direction',
      'navigate',
      'map',
      'route',
      'way',
      'how to get',
      'transportation',
      'road',
      'drive',
    ])) {
      return '🗺️ **Navigation Help:**\n\n• Use Google Maps for turn-by-turn directions\n• I can provide coordinates and best routes\n• Local guides recommended for remote areas\n• 4x4 needed for Omo Valley & Danakil\n• **Tip:** Download offline maps before traveling';
    }

    if (_containsAny(query, [
      'weather',
      'climate',
      'temperature',
      'rain',
      'sunny',
      'what to wear',
      'packing',
      'clothes',
    ])) {
      return '🌤️ **Ethiopia Weather Guide:**\n\n• **Highlands (Addis, Gondar):** Cool, 10-25°C\n• **Lowlands (Danakil):** Very hot, 30-50°C\n• **Rainy season:** June-September\n• **Dry season:** October-May\n• **Pack layers:** Warm clothes for highlands, light for lowlands';
    }

    if (_containsAny(query, [
      'safety',
      'secure',
      'danger',
      'risk',
      'crime',
      'is it safe',
      'travel safety',
      'security',
    ])) {
      return '🛡️ **Safety Tips:**\n\n• Generally safe for tourists\n• Avoid political demonstrations\n• Use licensed guides for remote areas\n• Keep valuables secure\n• Register with your embassy\n• Get travel insurance\n• Emergency number: 911';
    }

    if (_containsAny(query, [
      'money',
      'currency',
      'cash',
      'credit card',
      'atm',
      'exchange',
      'birr',
      'payment',
      'budget',
    ])) {
      return '💵 **Money Matters:**\n\n• **Currency:** Ethiopian Birr (ETB)\n• **Cash is king** - carry enough\n• ATMs in cities only\n• Credit cards in major hotels only\n• Exchange at banks or Bole Airport\n• **Budget:** \$30-100/day depending on style';
    }

    if (_containsAny(query, [
      'culture',
      'custom',
      'tradition',
      'etiquette',
      'manners',
      'do\'s and don\'ts',
      'local customs',
    ])) {
      return '🎭 **Cultural Etiquette:**\n\n• **Greeting:** Handshake with right hand\n• **Respect elders:** Important\n• **Shoes off:** In churches/homes\n• **Eating:** Right hand only for traditional meals\n• **Photos:** Ask permission, especially of people\n• **Dress modestly:** Especially in religious sites';
    }

    // Enhanced general response
    return '''
🌟 **Welcome to EthioTravel Guide!** 🌟

I understand you asked: "${userText}"

I can help you with many travel questions about Ethiopia:

📍 **Location Questions:**
• "Where is Lalibela located?"
• "Can you find Simien Mountains for me?"
• "Show me the location of Axum"

📏 **Distance & Travel Questions:**
• "How far is Gondar from Addis?"
• "Travel time to Danakil Depression"
• "Best way to get to Omo Valley"

📖 **Information Questions:**
• "What is the history of Lalibela?"
• "Tell me about Ethiopian culture"
• "Describe the Simien Mountains"

🗣️ **Language & Culture:**
• "How many languages in Ethiopia?"
• "What languages are spoken in Harar?"
• "Ethiopian customs and traditions"

💰 **Practical Information:**
• "Cost of visiting Gondar"
• "Best hotels in Addis"
• "Ethiopian visa requirements"

📅 **Planning Questions:**
• "When to visit Ethiopia?"
• "Best season for Simien Mountains"
• "Weather in Ethiopia by month"

💡 **Try asking about any place or topic!** Examples:
• "Tell me about Lalibela"
• "How to get to Gondar"
• "Best time to visit Omo Valley"
• "Cost of Simien Mountains trek"
• "Languages spoken in Ethiopia"
''';
  }

  // Helper methods for natural language processing
  bool _containsAny(String query, List<String> terms) {
    for (final term in terms) {
      if (query.contains(term)) return true;
    }
    return false;
  }

  bool _isQuestion(String query) {
    final questionWords = [
      'what',
      'where',
      'how',
      'when',
      'why',
      'who',
      'which',
      'can you',
      'could you',
      'would you',
      'do you',
      'does',
      'is there',
      'are there',
      'tell me',
      'explain',
      'describe',
    ];

    // Check if starts with question word or contains question mark
    if (query.contains('?')) return true;

    for (final word in questionWords) {
      if (query.startsWith(word) || query.contains(' $word ')) {
        return true;
      }
    }

    return false;
  }

  String _handleQuestion(String query) {
    // Enhanced question handling with multiple phrasings
    if (_containsAny(query, [
      'where is',
      'location of',
      'find',
      'locate',
      'where can i find',
      'where\'s',
      'place of',
      'situated',
      'position of',
    ])) {
      return '''
📍 **I can help you find locations in Ethiopia!**

**Try these formats:**
• "Where is Lalibela?"
• "Location of Simien Mountains"
• "Can you show me where Gondar is?"
• "Find Axum on the map"
• "Where exactly is Harar?"

**Or be specific:**
• "Where is [place name] located in Ethiopia?"
• "Show me the location of [place]"
• "Map coordinates for [destination]"

I'll provide region, coordinates, and distance from Addis Ababa.
''';
    }

    if (_containsAny(query, [
      'how far',
      'distance',
      'from addis',
      'travel time',
      'how long',
      'journey time',
      'drive time',
      'flight duration',
    ])) {
      return '''
📏 **I can check distances and travel times!**

**Try these formats:**
• "How far is Lalibela from Addis?"
• "Distance from Gondar to Simien Mountains"
• "Travel time to Bahir Dar"
• "How long to get to Omo Valley?"
• "Flight time from Addis to Axum"

**Or compare:**
• "Which is farther, Lalibela or Gondar?"
• "How far is [place A] from [place B]?"
• "Best route to [destination]"

I'll provide road distances, travel times, and transportation options.
''';
    }

    if (_containsAny(query, [
      'what is',
      'describe',
      'tell me about',
      'information about',
      'explain',
      'can you describe',
      'what can you tell me about',
      'details about',
    ])) {
      return '''
📖 **I can describe places and provide information!**

**Try these formats:**
• "What is Lalibela?"
• "Describe Simien Mountains"
• "Tell me about Axum"
• "Information about Gondar"
• "Can you explain what Danakil Depression is?"

**Or ask specific questions:**
• "What makes Lalibela special?"
• "Historical significance of Axum"
• "Features of Simien Mountains"
• "Cultural importance of Omo Valley"

I'll provide detailed descriptions, history, and significance.
''';
    }

    if (_containsAny(query, [
      'how many',
      'number of',
      'count of',
      'total',
      'how much',
      'quantity',
      'amount',
    ])) {
      return '''
🔢 **I can provide statistics and numbers!**

**Try these formats:**
• "How many languages in Ethiopia?"
• "Number of UNESCO sites in Ethiopia"
• "How many tribes in Omo Valley?"
• "Count of rock churches in Lalibela"
• "Total population of Ethiopia"

**Common statistics I know:**
• Languages: 80+
• UNESCO Sites: 9
• Ethnic groups: 80+
• Population: 120+ million
• Altitude range: -125m to 4,550m

Ask me for specific numbers!
''';
    }

    if (_containsAny(query, [
      'when',
      'best time',
      'season',
      'time to visit',
      'good time',
      'right time',
      'ideal time',
      'weather',
    ])) {
      return '''
📅 **I can advise on timing and seasons!**

**Try these formats:**
• "When is the best time to visit Ethiopia?"
• "Best season for Simien Mountains"
• "When to visit Lalibela?"
• "Weather in Ethiopia by month"
• "Rainy season in Ethiopia"

**Seasonal advice for:**
• Trekking in mountains
• Cultural festivals
• Wildlife viewing
• Desert exploration
• City tours

I'll provide month-by-month recommendations.
''';
    }

    if (_containsAny(query, [
      'why',
      'reason',
      'cause',
      'purpose',
      'significance',
      'important',
      'special',
      'famous',
    ])) {
      return '''
🤔 **I can explain significance and reasons!**

**Try these formats:**
• "Why is Lalibela important?"
• "Why should I visit Ethiopia?"
• "Significance of Axum"
• "What makes Omo Valley special?"
• "Why is Simien Mountains famous?"

**Topics I can explain:**
• Historical significance
• Cultural importance
• Natural wonders
• UNESCO designation reasons
• Unique features

I'll provide detailed explanations.
''';
    }

    return '''
🤔 **I can answer many types of questions!**

**Common question patterns I understand:**

📍 **Location Questions:**
• "Where is [place]?"
• "Location of [destination]"
• "Find [place name]"

📏 **Distance Questions:**
• "How far is [place A] from [place B]?"
• "Distance to [destination]"
• "Travel time to [place]"

📖 **Information Questions:**
• "What is [place/thing]?"
• "Tell me about [topic]"
• "Describe [subject]"

🗣️ **Language Questions:**
• "How many [things] in Ethiopia?"
• "Languages spoken in [place]"
• "Statistics about [topic]"

📅 **Timing Questions:**
• "When to visit [place]?"
• "Best time for [activity]"
• "Season for [destination]"

💰 **Practical Questions:**
• "Cost of [thing]"
• "How to [do something]"
• "Requirements for [process]"

💡 **Try asking about any place or topic in Ethiopia!**
''';
  }

  // Helper methods for place information
  String _getPlaceFullInfo(PlaceDetail place) {
    return '''
🏛️ **${place.name}**

📖 **Description:**
${place.description}

📍 **Location:**
• Region: ${place.location}
• Coordinates: ${place.coordinates}
• Altitude: ${place.altitude}

📏 **Distance from Addis Ababa:**
${place.distanceFromAddis}

🗣️ **Languages Spoken:**
${place.languages.join(', ')}

📅 **Best Time to Visit:**
${place.bestTimeToVisit}

💰 **Entrance Fee:**
${place.entranceFee}

🏷️ **Category:** ${place.category}
${place.unesco ? '✅ **UNESCO World Heritage Site**' : ''}

${_getAdditionalInfo(place.name)}
''';
  }

  String _getPlaceDescription(PlaceDetail place) {
    return '''
📖 **${place.name} - Description**

${place.description}

${place.unesco ? '✅ **UNESCO World Heritage Site**' : ''}
🏷️ **Category:** ${place.category}
📍 **Located in:** ${place.location}
📏 **Altitude:** ${place.altitude}

${_getKeyFeatures(place.name)}
''';
  }

  String _getPlaceLocation(PlaceDetail place) {
    return '''
📍 **${place.name} - Location Details**

**Region:** ${place.location}
**Coordinates:** ${place.coordinates}
**Altitude:** ${place.altitude}

**Distance from Addis Ababa:**
${place.distanceFromAddis}

**Nearest city/town:** ${_getNearestCity(place.name)}
**Access method:** ${_getAccessMethod(place.name)}
**Transport options:** ${_getTransportOptions(place.name)}
''';
  }

  String _getPlaceDistance(PlaceDetail place) {
    return '''
📏 **${place.name} - Distance & Travel Information**

**From Addis Ababa:** ${place.distanceFromAddis}

**Travel Options:**
${_getTravelOptions(place.name)}

**Recommended Route:**
${_getRecommendedRoute(place.name)}

**Approximate Travel Times:**
${_getTravelTimes(place.name)}

**Best Transport Method:** ${_getBestTransport(place.name)}
''';
  }

  String _getPlaceLanguages(PlaceDetail place) {
    return '''
🗣️ **Languages in ${place.name}**

**Primary Languages:**
${place.languages.map((lang) => '• $lang').join('\n')}

**Language Context:**
${_getLanguageContext(place.name)}

**Tourist Communication:**
• English widely understood in tourist areas
• Local guides available for translation
• Basic Amharic phrases appreciated
• Sign language varies by region
''';
  }

  // New helper methods for enhanced responses
  String _getWeatherAdvice(String placeName) {
    final advice = {
      'lalibela':
          '**Weather:** Cool year-round due to high altitude. Nights can be cold. Pack warm clothing.',
      'axum':
          '**Weather:** Mild temperatures. Rainy season (June-September) can make roads difficult.',
      'gondar':
          '**Weather:** Pleasant climate. Best visited in dry season (Oct-Mar) for clear views.',
      'simien mountains':
          '**Weather:** Highly variable. Can be cold at high altitudes. Rain likely June-September.',
      'harar':
          '**Weather:** Warm and dry. Evenings pleasant. Light clothing recommended.',
      'danakil depression':
          '**Weather:** Extremely hot (40-50°C). Visit Nov-Mar when cooler. Hydration essential.',
      'omo valley':
          '**Weather:** Hot and humid. Light, breathable clothing recommended. Dry season preferred.',
      'bahir dar':
          '**Weather:** Tropical climate. Warm year-round. Evenings can be cool.',
      'addis ababa':
          '**Weather:** "Eternal spring" - mild year-round. Rainy afternoons June-September.',
      'bale mountains':
          '**Weather:** Cold at high altitudes. Rainy season June-September. Pack warm layers.',
    };
    return advice[placeName] ??
        'Check local weather forecasts before visiting.';
  }

  String _getAdditionalCosts(String placeName) {
    final costs = {
      'lalibela':
          '**Additional Costs:** Guide (\$20-30/day), transportation to churches (\$10-20), accommodation (\$30-100/night)',
      'axum':
          '**Additional Costs:** Guide (\$15-25/day), museum fees (\$5-10), accommodation (\$25-80/night)',
      'gondar':
          '**Additional Costs:** Royal enclosure guide (\$15-20), church entrance (\$5), accommodation (\$20-70/night)',
      'simien mountains':
          '**Additional Costs:** Scout (\$5/day), guide (\$25-40/day), mule rental (\$10-15/day), park fees (\$20/day)',
      'harar':
          '**Additional Costs:** Hyena man show (\$5-10), guide (\$15-25/day), accommodation (\$20-60/night)',
      'danakil depression':
          '**Additional Costs:** Must book tour package (\$300-500+/person). Includes transport, guide, food, permits.',
      'omo valley':
          '**Additional Costs:** Tribal visit fees (\$5-20/tribe), guide (\$30-50/day), photography permits (\$2-5), accommodation (\$15-40/night)',
      'bahir dar':
          '**Additional Costs:** Lake Tana boat tour (\$20-40/person), Blue Nile Falls (\$5), guide (\$15-25/day), accommodation (\$25-80/night)',
      'addis ababa':
          '**Additional Costs:** Museum entries (\$5-10), guide (\$20-30/day), taxi fares (\$5-20/day), accommodation (\$30-150/night)',
      'bale mountains':
          '**Additional Costs:** Guide (\$25-40/day), scout (\$5/day), vehicle rental (\$80-150/day), accommodation (\$20-100/night)',
    };
    return costs[placeName] ??
        'Additional costs vary based on activities and services required.';
  }

  String _getBudgetAdvice(String placeName) {
    final budget = {
      'lalibela':
          '**Budget Tip:** Visit churches early to avoid crowds. Local guesthouses offer good value.',
      'axum':
          '**Budget Tip:** Combine with nearby sites. Local restaurants are affordable.',
      'gondar':
          '**Budget Tip:** Royal enclosure ticket is valid for multiple days. Walk between sites.',
      'simien mountains':
          '**Budget Tip:** Multi-day treks offer best value. Camp to save on accommodation.',
      'harar':
          '**Budget Tip:** Explore the old city on foot. Eat at local establishments.',
      'danakil depression':
          '**Budget Tip:** Join group tours to reduce costs. Book well in advance.',
      'omo valley':
          '**Budget Tip:** Hire a guide with vehicle. Respect local customs for better experience.',
      'bahir dar':
          '**Budget Tip:** Boat tours can be shared. Local transport is inexpensive.',
      'addis ababa':
          '**Budget Tip:** Use ride-sharing apps. Eat at traditional restaurants for authentic food.',
      'bale mountains':
          '**Budget Tip:** Camping reduces costs. Share guide expenses with other travelers.',
    };
    return budget[placeName] ??
        'Plan your budget considering accommodation, food, transportation, and activities.';
  }

  String _getAdditionalInfo(String placeName) {
    final info = {
      'lalibela':
          '**Tips:**\n• Wear comfortable shoes for walking\n• Respect religious sites\n• Hire local guide for better understanding\n• Photography may have restrictions',
      'axum':
          '**Tips:**\n• Visit St. Mary of Zion (women not allowed in old church)\n• See the obelisks at different times of day\n• Local museums provide context\n• Combine with Yeha temple',
      'gondar':
          '**Tips:**\n• Royal enclosure takes 2-3 hours\n• Visit Debre Berhan Selassie church\n• Fasilidas\' Bath used for Timket festival\n• Explore the old city',
      'simien mountains':
          '**Tips:**\n• Acclimatize to altitude\n• Pack for all weather conditions\n• Multi-day treks recommended\n• Watch for gelada baboons',
      'harar':
          '**Tips:**\n• Explore the 5 gates\n• Evening hyena feeding experience\n• Visit Rimbaud House\n• Try local Harari coffee',
      'danakil depression':
          '**Tips:**\n• Physical fitness required\n• Follow safety instructions\n• Photograph sulfur springs morning/evening\n• Stay hydrated',
      'omo valley':
          '**Tips:**\n• Ask permission before photographs\n• Respect tribal customs\n• Market days best for cultural immersion\n• Learn basic greetings',
      'bahir dar':
          '**Tips:**\n• Boat tours to monasteries\n• Blue Nile Falls best after rainy season\n• Lakeside restaurants\n• Sunset views over Lake Tana',
      'addis ababa':
          '**Tips:**\n• Visit National Museum for Lucy\n• Entoto Mountain for city views\n• Merkato for shopping\n• Coffee ceremony experience',
      'bale mountains':
          '**Tips:**\n• See Ethiopian wolves early morning\n• Harenna Forest exploration\n• Sanetti Plateau for altitude\n• Local guide essential',
    };
    return info[placeName] ??
        'Enjoy your visit and respect local customs and environment.';
  }

  String _getKeyFeatures(String placeName) {
    final features = {
      'lalibela':
          '**Key Features:**\n• 11 rock-hewn churches\n• Bete Giyorgis (cross-shaped)\n• UNESCO World Heritage\n• Active pilgrimage site',
      'axum':
          '**Key Features:**\n• Ancient stelae (obelisks)\n• Church of St. Mary of Zion\n• Tombs of Kings\n• Queen of Sheba\'s Palace',
      'gondar':
          '**Key Features:**\n• Royal Enclosure castles\n• Debre Berhan Selassie church\n• Fasilidas\' Bath\n• Queen Mentewab\'s castle',
      'simien mountains':
          '**Key Features:**\n• Ras Dashen (highest peak)\n• Gelada baboon troops\n• Dramatic escarpments\n• Ethiopian wolf habitat',
      'harar':
          '**Key Features:**\n• Walled city with 368 alleys\n• Hyena feeding tradition\n• Arthur Rimbaud house\n• Colorful markets',
      'danakil depression':
          '**Key Features:**\n• Erta Ale lava lake\n• Dallol sulfur springs\n• Salt lakes and formations\n• Extreme environment',
      'omo valley':
          '**Key Features:**\n• Mursi tribe (lip plates)\n• Hamar tribe (bull jumping)\n• Karo body painting\n• Weekly markets',
      'bahir dar':
          '**Key Features:**\n• Lake Tana (source of Blue Nile)\n• Blue Nile Falls\n• Island monasteries\n• Bird watching',
      'addis ababa':
          '**Key Features:**\n• National Museum (Lucy)\n• Holy Trinity Cathedral\n• Ethnological Museum\n• Mercato market',
      'bale mountains':
          '**Key Features:**\n• Ethiopian wolf sightings\n• Sanetti Plateau\n• Harenna Forest\n• Sof Omar caves',
    };
    return features[placeName] ?? 'Unique cultural and natural attractions.';
  }

  String _getTransportOptions(String placeName) {
    final options = {
      'lalibela':
          '**Transport:** Flight from Addis, shared taxis in town, walking between churches',
      'axum':
          '**Transport:** Flight or long drive, walking between sites, local tuk-tuks',
      'gondar':
          '**Transport:** Flight from Addis, taxis in city, walking in Royal Enclosure',
      'simien mountains':
          '**Transport:** 4x4 vehicle required, trekking on foot, mules available',
      'harar':
          '**Transport:** Flight to Dire Dawa then taxi, walking in old city, tuk-tuks',
      'danakil depression':
          '**Transport:** 4x4 convoy only, walking on volcanic terrain',
      'omo valley':
          '**Transport:** 4x4 essential, walking in villages, boat crossings',
      'bahir dar':
          '**Transport:** Flight from Addis, boat tours, taxis, walking along lake',
      'addis ababa':
          '**Transport:** Taxis, ride-sharing, minibuses, walking in central areas',
      'bale mountains':
          '**Transport:** 4x4 vehicle, trekking, local guides with vehicles',
    };
    return options[placeName] ?? 'Various transport options available.';
  }

  String _getTravelTimes(String placeName) {
    final times = {
      'lalibela':
          '• By air: 1 hour flight + 30min drive\n• By road: 10-12 hours (2 days recommended)\n• Bus: 12-14 hours',
      'axum':
          '• By air: 1.5 hours flight\n• By road: 15-18 hours (2-3 days)\n• Bus: 16-20 hours',
      'gondar':
          '• By air: 1 hour flight\n• By road: 10-12 hours\n• Bus: 11-13 hours',
      'simien mountains':
          '• From Gondar: 3-4 hour drive\n• Trekking: 1-12 days depending on route',
      'harar':
          '• Fly to Dire Dawa: 1 hour + 1 hour drive\n• Direct drive: 7-8 hours\n• Bus: 8-10 hours',
      'danakil depression':
          '• From Mekele: 5-6 hours to sites\n• Tour packages: 3-5 days total',
      'omo valley':
          '• From Arba Minch: 5-6 hours\n• From Jinka: Varies by tribe\n• Multi-day tours recommended',
      'bahir dar':
          '• By air: 1 hour flight\n• By road: 9-11 hours\n• Bus: 10-12 hours',
      'addis ababa':
          '• International flights arrive at Bole\n• Domestic flights to all major cities\n• Road connections nationwide',
      'bale mountains':
          '• From Addis: 7-8 hour drive\n• Trekking: 2-7 days depending on route',
    };
    return times[placeName] ??
        'Travel times vary based on route and transportation.';
  }

  // Existing helper methods (unchanged but included for completeness)
  String _getNearestCity(String placeName) {
    final nearestCities = {
      'lalibela': 'Gashena (market town)',
      'axum': 'Shire (larger town nearby)',
      'gondar': 'Gondar city itself',
      'simien mountains': 'Debark (park HQ)',
      'harar': 'Dire Dawa (50km away)',
      'danakil depression': 'Mekele (base for tours)',
      'omo valley': 'Jinka or Arba Minch',
      'bahir dar': 'Bahir Dar city itself',
      'addis ababa': 'Capital city',
      'bale mountains': 'Goba or Robe towns',
    };
    return nearestCities[placeName] ?? 'Check with local guides';
  }

  String _getAccessMethod(String placeName) {
    final access = {
      'lalibela': 'Flight or 2-day drive from Addis',
      'axum': 'Flight (limited) or long drive',
      'gondar': 'Flight (1hr) or drive from Bahir Dar',
      'simien mountains': 'Drive from Gondar (3-4 hours)',
      'harar': 'Fly to Dire Dawa then drive (1hr)',
      'danakil depression': 'Organized 4x4 tour from Mekele only',
      'omo valley': '4x4 vehicle required, guide essential',
      'bahir dar': 'Flight (1hr) or drive from Addis',
      'addis ababa': 'International flights to Bole Airport',
      'bale mountains': 'Drive from Addis or Shashamane',
    };
    return access[placeName] ?? 'Various transport options';
  }

  String _getTravelOptions(String placeName) {
    final options = {
      'lalibela':
          '• ✈️ Flight: 1 hour from Addis\n• 🚗 Drive: 2 days via Dessie\n• 🚌 Bus: Available but long',
      'axum':
          '• ✈️ Flight: Limited schedule\n• 🚗 Drive: 2-3 days\n• 🚌 Bus: Long journey (15+ hours)',
      'gondar':
          '• ✈️ Flight: 1 hour from Addis\n• 🚗 Drive: 10-12 hours\n• 🚌 Bus: Comfortable options available',
      'simien mountains':
          '• 🚗 Drive from Gondar: 3-4 hours\n• 4x4 needed for park interior\n• No direct flights',
      'harar':
          '• ✈️ Fly to Dire Dawa: 1 hour\n• 🚗 Drive from Dire Dawa: 1 hour\n• 🚗 Direct from Addis: 7-8 hours',
      'danakil depression':
          '• 🚙 Organized 4x4 tour only\n• Armed escort required\n• Start from Mekele',
      'omo valley':
          '• 🚙 4x4 vehicle essential\n• 🛩️ Fly to Arba Minch or Jinka\n• 🚗 Long drive from Addis',
      'bahir dar':
          '• ✈️ Flight: 1 hour from Addis\n• 🚗 Drive: 9-11 hours\n• 🚌 Luxury buses available',
      'addis ababa':
          '• ✈️ International flights\n• Domestic flights hub\n• Major bus terminal',
      'bale mountains':
          '• 🚗 Drive: 7-8 hours from Addis\n• Limited flights to Robe\n• 4x4 recommended',
    };
    return options[placeName] ?? 'Multiple options available';
  }

  String _getRecommendedRoute(String placeName) {
    final routes = {
      'lalibela': 'Addis → (fly) → Lalibela Airport → 30min drive to town',
      'axum':
          'Addis → (fly) → Axum Airport → Short drive to sites\nOR\nAddis → Gondar → Axum (scenic but long)',
      'gondar':
          'Addis → (fly) → Gondar Airport → 15min to city\nOR\nAddis → Bahir Dar → Gondar (3-4 hours)',
      'simien mountains':
          'Addis → (fly) → Gondar → Drive to Debark (2 hours) → Park entry',
      'harar': 'Addis → (fly) → Dire Dawa → Drive to Harar (1 hour)',
      'danakil depression':
          'Addis → (fly) → Mekele → Join organized tour → 4x4 to sites',
      'omo valley':
          'Addis → (fly) → Arba Minch → 4x4 to Omo Valley\nOR\nAddis → (fly) → Jinka → Tribal areas',
      'bahir dar': 'Addis → (fly) → Bahir Dar Airport → Short drive to city',
      'addis ababa': 'International arrival at Bole Airport',
      'bale mountains': 'Addis → Drive to Goba/Robe → Park entry',
    };
    return routes[placeName] ?? 'Consult with tour operator';
  }

  String _getBestTransport(String placeName) {
    final transport = {
      'lalibela': 'Flight (saves 2 days)',
      'axum': 'Flight if available, otherwise drive',
      'gondar': 'Flight',
      'simien mountains': 'Fly to Gondar, then drive',
      'harar': 'Fly to Dire Dawa, then drive',
      'danakil depression': 'Organized tour (only option)',
      'omo valley': 'Fly + 4x4 with guide',
      'bahir dar': 'Flight',
      'addis ababa': 'Flight to Bole Airport',
      'bale mountains': 'Drive or fly+drive',
    };
    return transport[placeName] ?? 'Depends on budget/time';
  }

  String _getLanguageContext(String placeName) {
    final contexts = {
      'lalibela': 'Amharic dominant, English spoken in tourism',
      'axum': 'Tigrinya main language, Amharic/English in tourism',
      'gondar': 'Amharic, English in hotels/restaurants',
      'simien mountains': 'Amharic, local guides speak English',
      'harar': 'Harari, Oromo, Amharic, some English',
      'danakil depression': 'Afar language, guides translate',
      'omo valley': 'Tribal languages, guides essential for translation',
      'bahir dar': 'Amharic, English in tourism sector',
      'addis ababa': 'Amharic official, English widely spoken',
      'bale mountains': 'Oromo dominant, Amharic/English in tourism',
    };
    return contexts[placeName] ?? 'Local languages + English for tourism';
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(role: 'You', text: text));
      _messages.add(_Message(role: 'EthioTravel Guide', text: _answer(text)));
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🌍 EthioTravel Guide',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [chatBackground, Color(0xFFE0F2FE)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: false,
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final m = _messages[i];
                  final isUser = m.role == 'You';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: blueGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.travel_explore,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        if (!isUser) const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (!isUser)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 6,
                                    left: 8,
                                  ),
                                  child: Text(
                                    m.role,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: darkBlue,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: isUser
                                      ? userBubbleGradient
                                      : const LinearGradient(
                                          colors: [
                                            botBubbleLight,
                                            Color(0xFFF8FAFC),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: Radius.circular(
                                      isUser ? 20 : 6,
                                    ),
                                    bottomRight: Radius.circular(
                                      isUser ? 6 : 20,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(
                                        isUser ? 0.2 : 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isUser
                                        ? accentBlue.withOpacity(0.4)
                                        : Colors.blue.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  m.text,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isUser
                                        ? Colors.white
                                        : Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUser) const SizedBox(width: 12),
                        if (isUser)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: userBubbleBlue.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, -10),
                  ),
                ],
                border: Border.all(color: lightBlue.withOpacity(0.8), width: 1),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: accentBlue.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText:
                            'Ask about places, distances, descriptions...',
                        hintStyle: TextStyle(
                          color: Colors.blueGrey[500],
                          fontSize: 15,
                        ),
                        filled: true,
                        fillColor: lightBlue.withOpacity(0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(color: accentBlue, width: 2.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: accentBlue,
                          size: 24,
                        ),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: blueGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: _send,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                      maxLines: 3,
                      minLines: 1,
                      style: const TextStyle(fontSize: 15, color: darkBlue),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickButton(
                          '📍 Where is...',
                          'Where is Lalibela located?',
                        ),
                        _buildQuickButton(
                          '📏 How far...',
                          'How far is Gondar from Addis?',
                        ),
                        _buildQuickButton('📖 Describe...', 'What is Axum?'),
                        _buildQuickButton(
                          '🗣️ Languages',
                          'How many languages in Ethiopia?',
                        ),
                        _buildQuickButton(
                          '🏛️ About Ethiopia',
                          'Tell me about Ethiopia',
                        ),
                        _buildQuickButton(
                          '🎯 Top Sites',
                          'Best places to visit in Ethiopia',
                        ),
                        _buildQuickButton(
                          '💰 Costs',
                          'How much does it cost to visit Lalibela?',
                        ),
                        _buildQuickButton(
                          '📅 When to go',
                          'When is the best time to visit Ethiopia?',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(String text, String query) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: () {
          _controller.text = query;
          _send();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDBEAFE), Color(0xFFE0F2FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accentBlue.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primaryBlue,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// =================== PLACE DETAIL CLASS ===================
class PlaceDetail {
  PlaceDetail({
    required this.name,
    required this.description,
    required this.location,
    required this.coordinates,
    required this.altitude,
    required this.distanceFromAddis,
    required this.languages,
    required this.bestTimeToVisit,
    required this.entranceFee,
    required this.unesco,
    required this.category,
  });

  final String name;
  final String description;
  final String location;
  final String coordinates;
  final String altitude;
  final String distanceFromAddis;
  final List<String> languages;
  final String bestTimeToVisit;
  final String entranceFee;
  final bool unesco;
  final String category;
}

class _Message {
  _Message({required this.role, required this.text});
  final String role;
  final String text;
}
