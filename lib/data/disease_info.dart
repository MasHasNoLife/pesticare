/// Disease information data for expandable info cards
class DiseaseInfo {
  final String name;
  final String description;
  final List<String> causes;
  final List<String> symptoms;
  final List<String> prevention;

  const DiseaseInfo({
    required this.name,
    required this.description,
    required this.causes,
    required this.symptoms,
    required this.prevention,
  });
}

/// Database of disease information for all crops
class DiseaseDatabase {
  static const Map<String, DiseaseInfo> diseases = {
    // Cotton diseases
    'Bacterial Blight': DiseaseInfo(
      name: 'Bacterial Blight',
      description: 'A bacterial disease causing angular water-soaked lesions on leaves.',
      causes: ['Xanthomonas citri bacteria', 'Warm, humid conditions', 'Rain splash spread'],
      symptoms: ['Angular water-soaked spots', 'Yellowing of leaves', 'Premature leaf drop'],
      prevention: ['Use disease-free seeds', 'Crop rotation', 'Avoid overhead irrigation'],
    ),
    'Curl Virus': DiseaseInfo(
      name: 'Cotton Leaf Curl Virus',
      description: 'A viral disease transmitted by whiteflies causing severe leaf curling.',
      causes: ['Begomovirus', 'Whitefly transmission', 'Infected plant material'],
      symptoms: ['Upward leaf curling', 'Thickened veins', 'Stunted growth'],
      prevention: ['Control whitefly vectors', 'Remove infected plants', 'Use resistant varieties'],
    ),
    'Healthy Leaf': DiseaseInfo(
      name: 'Healthy Plant',
      description: 'The plant shows no signs of disease and appears healthy.',
      causes: [],
      symptoms: ['Vibrant green color', 'Normal leaf shape', 'Good growth'],
      prevention: ['Maintain good practices', 'Regular monitoring', 'Balanced nutrition'],
    ),
    'Herbicide Growth Damage': DiseaseInfo(
      name: 'Herbicide Damage',
      description: 'Plant damage caused by herbicide exposure or drift.',
      causes: ['Herbicide drift', 'Improper application', 'Residue in soil'],
      symptoms: ['Cupped or twisted leaves', 'Stunted growth', 'Yellowing'],
      prevention: ['Careful herbicide application', 'Buffer zones', 'Wind awareness'],
    ),
    'Leaf Hopper Jassids': DiseaseInfo(
      name: 'Jassid Infestation',
      description: 'Damage caused by leaf hopper insects feeding on plant sap.',
      causes: ['Jassid insects', 'Hot dry weather', 'Lack of natural predators'],
      symptoms: ['Yellowing leaf margins', 'Curling edges', 'Hopper burn'],
      prevention: ['Spray systemic insecticides', 'Maintain field hygiene', 'Natural predators'],
    ),
    'Leaf Redding': DiseaseInfo(
      name: 'Leaf Reddening',
      description: 'Physiological disorder causing red discoloration of leaves.',
      causes: ['Magnesium deficiency', 'Low temperatures', 'Waterlogging'],
      symptoms: ['Reddish-purple leaves', 'Starts from lower leaves', 'Premature aging'],
      prevention: ['Apply magnesium sulfate', 'Proper drainage', 'Balanced fertilization'],
    ),
    'Leaf Variegation': DiseaseInfo(
      name: 'Leaf Variegation',
      description: 'Irregular patterns of discoloration on leaves.',
      causes: ['Nutrient deficiency', 'Viral infection', 'Genetic factors'],
      symptoms: ['Mottled leaves', 'Light and dark patches', 'Irregular patterns'],
      prevention: ['Soil testing', 'Micronutrient application', 'Use certified seeds'],
    ),

    // Rice diseases
    'Bacterial Leaf Blight': DiseaseInfo(
      name: 'Bacterial Leaf Blight',
      description: 'A serious bacterial disease causing yellowing and wilting of rice leaves.',
      causes: ['Xanthomonas oryzae bacteria', 'Flood water spread', 'Warm humid weather'],
      symptoms: ['Yellow-orange lesions', 'Wilting from tip', 'Milky bacterial ooze'],
      prevention: ['Use resistant varieties', 'Balanced nitrogen', 'Drain fields properly'],
    ),
    'Brown Spot': DiseaseInfo(
      name: 'Brown Spot',
      description: 'A fungal disease causing brown lesions with gray centers.',
      causes: ['Cochliobolus miyabeanus fungus', 'Poor soil nutrition', 'Drought stress'],
      symptoms: ['Oval brown spots', 'Gray center', 'Premature ripening'],
      prevention: ['Balanced fertilization', 'Use treated seeds', 'Adequate irrigation'],
    ),
    'Healthy Rice Leaf': DiseaseInfo(
      name: 'Healthy Rice',
      description: 'The rice plant shows no signs of disease.',
      causes: [],
      symptoms: ['Vibrant green color', 'Upright leaves', 'Normal growth'],
      prevention: ['Continue good practices', 'Regular monitoring'],
    ),
    'Leaf Blast': DiseaseInfo(
      name: 'Rice Blast',
      description: 'A devastating fungal disease causing diamond-shaped lesions.',
      causes: ['Magnaporthe oryzae fungus', 'Cool nights', 'High nitrogen'],
      symptoms: ['Diamond-shaped spots', 'Grayish center', 'Neck rot'],
      prevention: ['Resistant varieties', 'Avoid excess nitrogen', 'Fungicide spray'],
    ),
    'Leaf scald': DiseaseInfo(
      name: 'Leaf Scald',
      description: 'A fungal disease causing large zonate lesions on leaves.',
      causes: ['Microdochium oryzae fungus', 'High humidity', 'Dense planting'],
      symptoms: ['Zonate lesions', 'Light brown color', 'Starting from tip'],
      prevention: ['Proper spacing', 'Avoid excess nitrogen', 'Fungicide treatment'],
    ),
    'Sheath Blight': DiseaseInfo(
      name: 'Sheath Blight',
      description: 'A fungal disease affecting the leaf sheath and stem.',
      causes: ['Rhizoctonia solani fungus', 'Dense canopy', 'High humidity'],
      symptoms: ['Irregular lesions', 'Green-gray color', 'Lodging'],
      prevention: ['Wider spacing', 'Lower nitrogen', 'Fungicide at boot stage'],
    ),

    // Wheat diseases
    'Healthy Wheat': DiseaseInfo(
      name: 'Healthy Wheat',
      description: 'The wheat plant shows no signs of disease.',
      causes: [],
      symptoms: ['Green leaves', 'Strong stems', 'Normal growth'],
      prevention: ['Maintain good practices', 'Regular field scouting'],
    ),
    'Wheat Brown leaf Rust': DiseaseInfo(
      name: 'Brown Leaf Rust',
      description: 'A fungal disease causing orange-brown pustules on leaves.',
      causes: ['Puccinia triticina fungus', 'Mild temperatures', 'High humidity'],
      symptoms: ['Orange-brown pustules', 'Random distribution', 'Early senescence'],
      prevention: ['Resistant varieties', 'Early sowing', 'Fungicide spray'],
    ),
    'Wheat Yellow Rust': DiseaseInfo(
      name: 'Yellow Stripe Rust',
      description: 'A serious fungal disease causing yellow stripes on leaves.',
      causes: ['Puccinia striiformis fungus', 'Cool weather', 'Morning dew'],
      symptoms: ['Yellow stripes', 'Parallel to veins', 'Severe yield loss'],
      prevention: ['Resistant varieties', 'Seed treatment', 'Timely fungicide'],
    ),
    'Wheat black rust': DiseaseInfo(
      name: 'Black Stem Rust',
      description: 'A highly destructive rust disease affecting stems and leaves.',
      causes: ['Puccinia graminis fungus', 'Warm humid weather', 'Wind spread'],
      symptoms: ['Reddish-brown pustules', 'Black stem', 'Lodging'],
      prevention: ['Resistant varieties', 'Early detection', 'Fungicide application'],
    ),
    'Wheat leaf blight': DiseaseInfo(
      name: 'Leaf Blight',
      description: 'A fungal disease causing brown blighting of leaves.',
      causes: ['Bipolaris sorokiniana fungus', 'Warm humid weather', 'Stressed plants'],
      symptoms: ['Brown lesions', 'Blighted appearance', 'Reduced grain fill'],
      prevention: ['Crop rotation', 'Resistant varieties', 'Fungicide spray'],
    ),
    'Wheat aphid': DiseaseInfo(
      name: 'Aphid Infestation',
      description: 'Damage caused by aphid insects sucking plant sap.',
      causes: ['Aphid insects', 'Dry conditions', 'Lack of predators'],
      symptoms: ['Yellowing leaves', 'Honeydew deposits', 'Stunted growth'],
      prevention: ['Natural predators', 'Spray insecticides', 'Early detection'],
    ),
    'Wheat mite': DiseaseInfo(
      name: 'Mite Damage',
      description: 'Damage caused by mites feeding on plant tissue.',
      causes: ['Spider mites', 'Hot dry weather', 'Water stress'],
      symptoms: ['Silvery stippling', 'Webbing', 'Leaf drying'],
      prevention: ['Adequate irrigation', 'Miticide application', 'Avoid drought stress'],
    ),
    'Wheat Stem fly': DiseaseInfo(
      name: 'Stem Fly Damage',
      description: 'Damage caused by stem fly larvae boring into stems.',
      causes: ['Atherigona species', 'Late sowing', 'Dry conditions'],
      symptoms: ['Dead heart', 'Dried central shoot', 'Tunneling in stem'],
      prevention: ['Timely sowing', 'Seed treatment', 'Soil application'],
    ),
    'Wheat powdery mildew': DiseaseInfo(
      name: 'Powdery Mildew',
      description: 'A fungal disease causing white powdery growth on leaves.',
      causes: ['Blumeria graminis fungus', 'Moderate temperatures', 'High humidity'],
      symptoms: ['White powder', 'Yellow patches', 'Reduced photosynthesis'],
      prevention: ['Resistant varieties', 'Avoid excess nitrogen', 'Sulfur spray'],
    ),
    'Wheat scab': DiseaseInfo(
      name: 'Fusarium Head Blight',
      description: 'A fungal disease affecting wheat heads at flowering.',
      causes: ['Fusarium species', 'Warm wet flowering', 'Crop residue'],
      symptoms: ['Bleached spikelets', 'Pink fungal growth', 'Shriveled grain'],
      prevention: ['Resistant varieties', 'Crop rotation', 'Fungicide at flowering'],
    ),
  };

  /// Get disease info by name
  static DiseaseInfo? getInfo(String diseaseName) {
    return diseases[diseaseName];
  }
}
