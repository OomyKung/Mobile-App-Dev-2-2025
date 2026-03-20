class User {
  final int? id;
  final String username;
  final String email;
  final String pwd;
  final double weight; // kg
  final double height; // cm

  // ==================== CALCULATION (การคำนวณ) ====================
  /// BMI และ BMI Type ถูกคำนวณอัตโนมัติเมื่อ User object ถูกสร้าง
  /// - ข้อมูลพื้นฐาน (weight, height) ถูกรับมาจากผู้ใช้
  /// - BMI คำนวณโดย: weight(kg) / (height(m) * height(m))
  /// - BMI Type ถูกกำหนดตามค่า BMI
  final double bmi;
  final String bmiType;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.pwd,
    required this.weight,
    required this.height,
  }) : bmi = calculateBmi(weight, height),
       bmiType = determineBmiType(calculateBmi(weight, height));

  // ---------- CALCULATION METHOD - BMI ----------
  /// ฟังก์ชันเพื่อคำนวณค่า BMI
  static double calculateBmi(double weightKg, double heightCm) {
    final hMeter = heightCm / 100.0;
    return weightKg / (hMeter * hMeter);
  }

  /// ฟังก์ชันเพื่อกำหนด BMI Type ตามค่า BMI
  static String determineBmiType(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 23.0) return 'Normal';
    if (bmi < 25.0) return 'Risk to Overweight';
    if (bmi < 29.9) return 'Overweight';
    return 'Obese';
  }

  // ---------- Additional Feature - Health Suggestion ----------
  static double _h2(double heightCm) {
    final h = heightCm / 100.0;
    return h * h;
  }

  double get normalMinWeight => 18.5 * _h2(height);
  double get normalMaxWeight => 23.0 * _h2(height);

  double get weightToNormalKg {
    if (bmiType == 'Underweight') {
      final diff = normalMinWeight - weight;
      return diff > 0 ? diff : 0;
    }
    if (bmiType == 'Risk to Overweight' ||
        bmiType == 'Overweight' ||
        bmiType == 'Obese') {
      final diff = weight - normalMaxWeight;
      return diff > 0 ? diff : 0;
    }
    return 0;
  }

  String get healthMessage {
    if (bmiType == 'Normal') return 'Good Health.';
    if (bmiType == 'Underweight') {
      return 'Need to gain ${weightToNormalKg.toStringAsFixed(2)} kg';
    }
    return 'Need to reduce ${weightToNormalKg.toStringAsFixed(2)} kg';
  }

  // ✅ Always return a valid asset path (no text!)
  String get bmiImagePath {
    switch (bmiType) {
      case 'Underweight':
        return 'assets/images/bmi-1.png';
      case 'Normal':
        return 'assets/images/bmi-2.png';
      case 'Risk to Overweight':
        return 'assets/images/bmi-3.png';
      case 'Overweight':
        return 'assets/images/bmi-4.png';
      case 'Obese':
        return 'assets/images/bmi-5.png';
      default:
        return 'assets/images/bmi-2.png'; // fallback
    }
  }

  // ==================== DATA STORAGE (บันทึกข้อมูล) ====================
  /// Convert User object เป็น Map เพื่อบันทึกลงฐานข้อมูล (CRUD - CREATE/UPDATE)
  /// - รวมข้อมูลพื้นฐาน: username, email, pwd, weight, height
  /// - บันทึก BMI และ BMI Type ที่คำนวณไว้ด้วย
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'pwd': pwd,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'bmi_type': bmiType,
    };
  }

  /// Convert Map จากฐานข้อมูลเป็น User object (CRUD - READ)
  /// - อ่านข้อมูลจากฐานข้อมูลและกำหนดให้กับ User properties
  /// - BMI และ BMI Type ไม่จำเป็นต้องรับป้อนใหม่เพราะมีการคำนวณในคอนสตรัคเตอร์
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String,
      pwd: map['pwd'] as String,
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
    );
  }
}
