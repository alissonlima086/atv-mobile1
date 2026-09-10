class Warframe {
  final String name;
  final int health;
  final int shield;
  final int armor;
  final int power;
  final String imageName;
  final String description;
  final bool isPrime;
  final String sex;

  const Warframe({
    required this.name,
    required this.health,
    required this.shield,
    required this.armor,
    required this.power,
    required this.imageName,
    this.description = '',
    this.isPrime = false,
    this.sex = 'Desconhecido',
  });

  factory Warframe.fromJson(Map<String, dynamic> json) => Warframe(
        name: json['name'] as String? ?? 'Desconhecido',
        health: (json['health'] as num?)?.toInt() ?? 0,
        shield: (json['shield'] as num?)?.toInt() ?? 0,
        armor: (json['armor'] as num?)?.toInt() ?? 0,
        power: (json['power'] as num?)?.toInt() ?? 0,
        imageName: json['imageName'] as String? ?? '',
        description: json['description'] as String? ?? '',
        isPrime: json['isPrime'] as bool? ?? false,
        sex: json['sex'] as String? ?? 'Desconhecido',
      );

  String get imageFileName {
    final target = imageName.trim().isNotEmpty ? imageName.trim() : '$name.png';
    return target.startsWith('/') ? target.substring(1) : target;
  }

  String get assetPath => 'assets/images/$imageFileName';

  String get imageUrl {
    if (imageName.startsWith('http://') || imageName.startsWith('https://')) {
      return imageName;
    }
    return 'https://cdn.warframestat.us/img/$imageFileName';
  }

  List<String> get tags {
    final list = <String>[];
    list.add(isPrime ? 'Prime' : 'Padrao');
    if (sex.isNotEmpty && sex != 'Desconhecido') {
      list.add(sex);
    }
    list.add(armor >= 300 || health >= 400 ? 'Tanque' : 'Agil');
    list.add(power >= 150 ? 'Caster' : 'Tatico');
    return list;
  }
}
