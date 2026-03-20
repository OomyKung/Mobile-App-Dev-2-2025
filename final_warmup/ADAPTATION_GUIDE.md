## 🎯 Exam Adaptation Guide

แนวทางการดัดแปลงตัวอย่าง Task Manager สำหรับข้อสอบนักการจัดการภาพขนาดใหญ่และกิจกรรมเบิกต้นไม้

---

## 💡 ไอเดีย 1: ระบบจัดการร้านค้า (Store Management)

### เพิ่มเติม Features:
- **Models**: Product, Order, Customer แทน Task
- **Database**: ตาราง products, orders, customers
- **Screens**:
  - Product List (Read)
  - Add/Edit Product (Create/Update)
  - Customer Management (CRUD)
  - Order Dashboard (Statistics)

### CRUD Operations:
- ✅ Add Products to Database
- ✅ View Products with Filtering
- ✅ Update Product Stock/Price
- ✅ Delete Products

---

## 💡 ไอเดีย 2: ระบบจัดการนักเรียน (Student Management)

### เปลี่ยนแปลง:
- **Models**: Student, Course, Grade
- **Database**: students table, courses table, grades table
- **Features**:
  - Add/Edit/Delete Students
  - Manage Courses
  - Track Grades
  - Filter by Status (Active/Inactive)

### Input Validation Examples:
```dart
// Student ID validation
String? _validateStudentId(String? value) {
  if (value == null || value.isEmpty) return 'ID required';
  if (value.length != 10) return 'ID must be 10 digits';
  return null;
}

// Email validation
String? _validateEmail(String? value) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value ?? '')) {
    return 'Invalid email format';
  }
  return null;
}

// GPA validation
String? _validateGPA(String? value) {
  if (value == null || value.isEmpty) return 'GPA required';
  final gpa = double.tryParse(value);
  if (gpa == null || gpa < 0 || gpa > 4) {
    return 'GPA must be between 0 and 4';
  }
  return null;
}
```

---

## 💡 ไอเดีย 3: ระบบจัดการค่าใช้จ่าย (Expense Tracker)

### Model Changes:
```dart
class Expense {
  int? id;
  String category;        // Food, Transport, Entertainment
  double amount;
  String description;
  DateTime date;
  String paymentMethod;  // Cash, Credit Card, etc.
}
```

### Database Schema:
```sql
CREATE TABLE expenses (
  id INTEGER PRIMARY KEY,
  category TEXT NOT NULL,
  amount REAL NOT NULL,
  description TEXT,
  date TEXT NOT NULL,
  paymentMethod TEXT
)
```

### Advanced Features:
- 📊 Statistics by Category
- 📈 Monthly Summary
- 🔍 Filter by Date Range
- 💰 Total Expenses Report

---

## 💡 ไอเดีย 4: ระบบจัดการสินค้าคงคลัง (Inventory System)

### Additional Complexity:
```dart
class Item {
  int? id;
  String name;
  int quantity;
  double unitPrice;
  String supplier;
  DateTime lastRestocked;
  int minStockLevel;
}
```

### Advanced CRUD:
```dart
// Restock item
Future<int> restockItem(int id, int quantity) async {
  final db = await database;
  return await db.update(
    'items',
    {'quantity': quantity, 'lastRestocked': DateTime.now()},
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Get low stock items
Future<List<Item>> getLowStockItems() async {
  final db = await database;
  final maps = await db.query(
    'items',
    where: 'quantity < minStockLevel',
  );
  return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
}

// Calculate total inventory value
Future<double> getTotalInventoryValue() async {
  final db = await database;
  final result = await db.rawQuery(
    'SELECT SUM(quantity * unitPrice) as total FROM items',
  );
  return Sqflite.firstDoubleValue(result) ?? 0;
}
```

---

## 🔧 การปรับแต่ง Key Components

### 1. ขยายการตรวจสอบ Input
```dart
// Numeric validation
String? _validatePositiveNumber(String? value) {
  if (value == null || value.isEmpty) return 'Required';
  final number = double.tryParse(value);
  if (number == null || number <= 0) {
    return 'Must be positive number';
  }
  return null;
}

// Phone number validation
String? _validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) return 'Required';
  if (value.length < 9 || value.length > 12) {
    return 'Invalid phone number';
  }
  return null;
}

// Date range validation
String? _validateDateRange(String? fromDate, String? toDate) {
  final from = DateTime.tryParse(fromDate ?? '');
  final to = DateTime.tryParse(toDate ?? '');
  
  if (from == null || to == null) return 'Invalid dates';
  if (from.isAfter(to)) return 'From date must be before to date';
  return null;
}
```

### 2. เพิ่ม Search/Filter Features
```dart
// Search by name
Future<List<Item>> searchItems(String query) async {
  final db = await database;
  final maps = await db.query(
    'items',
    where: 'name LIKE ?',
    whereArgs: ['%$query%'],
  );
  return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
}

// Filter by date range
Future<List<Expense>> getExpensesByDateRange(
  DateTime startDate,
  DateTime endDate,
) async {
  final db = await database;
  final maps = await db.query(
    'expenses',
    where: 'date BETWEEN ? AND ?',
    whereArgs: [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ],
  );
  return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
}
```

### 3. เพิ่ม Statistics/Reports
```dart
// Get summary data
Future<Map<String, dynamic>> getTaskStats() async {
  final db = await database;
  
  final totalResult = await db.rawQuery(
    'SELECT COUNT(*) as total FROM tasks'
  );
  
  final completedResult = await db.rawQuery(
    'SELECT COUNT(*) as completed FROM tasks WHERE isCompleted = 1'
  );
  
  final completionRate = total > 0 
    ? (completed / total * 100).toStringAsFixed(1)
    : '0';
  
  return {
    'total': total,
    'completed': completed,
    'pending': total - completed,
    'completionRate': completionRate,
  };
}
```

---

## 📋 Exam Checklist

### ✅ ความต้องการที่ต้องทำ

- [ ] **Multi-screen navigation** (อย่างน้อย 2 screens)
  - [ ] List/Dashboard screen
  - [ ] Add/Edit screen
  
- [ ] **Database (SQLite)**
  - [ ] Create table(s) ที่เหมาะสม
  - [ ] Database initialization
  
- [ ] **CRUD Operations**
  - [ ] CREATE: Add new record
  - [ ] READ: Retrieve records (all, filtered, single)
  - [ ] UPDATE: Modify existing record
  - [ ] DELETE: Remove record(s)
  
- [ ] **Input Validation**
  - [ ] Title/Name validation
  - [ ] Length constraints
  - [ ] Format validation (if applicable)
  - [ ] Error messages
  
- [ ] **Data Persistence**
  - [ ] Data saves to database
  - [ ] Data loads on app restart
  
- [ ] **User Experience**
  - [ ] Clear buttons/navigation
  - [ ] Feedback messages (SnackBar/Dialog)
  - [ ] Error handling
  - [ ] Loading states (if needed)

---

## 🎨 UI/UX Improvements

ปรับปรุงตัวอย่างด้วย:

### 1. Better Statistics Display
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    _buildStatCard('Total', totalCount, Icons.list, Colors.blue),
    _buildStatCard('Completed', completedCount, Icons.check_circle, Colors.green),
    _buildStatCard('Pending', pendingCount, Icons.hourglass_empty, Colors.orange),
  ],
)
```

### 2. Search Bar
```dart
TextField(
  controller: searchController,
  decoration: InputDecoration(
    hintText: 'Search...',
    prefixIcon: Icon(Icons.search),
    suffixIcon: IconButton(
      icon: Icon(Icons.clear),
      onPressed: () {
        searchController.clear();
        _loadItems();
      },
    ),
  ),
  onChanged: (query) {
    if (query.isNotEmpty) {
      _searchItems(query);
    } else {
      _loadItems();
    }
  },
)
```

### 3. Date Picker
```dart
Future<void> _selectDate() async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );
  
  if (pickedDate != null) {
    setState(() {
      selectedDate = pickedDate;
    });
  }
}
```

---

## 📚 สิ่งที่ต้องเรียน

สำหรับสอบ ตรวจสอบให้แน่ใจว่าเข้าใจ:

1. **SQLite Basics**
   - Table creation
   - Data types (INTEGER, TEXT, REAL)
   - Constraints (PRIMARY KEY, NOT NULL)

2. **CRUD Operations**
   - INSERT statement
   - SELECT query (WHERE, ORDER BY)
   - UPDATE with WHERE clause
   - DELETE with WHERE clause

3. **Dart/Flutter Concepts**
   - StatefulWidget vs StatelessWidget
   - Form validation
   - Navigator
   - Future/async-await
   - try-catch

4. **TextFormField Validation**
   - Required field check
   - Length validation
   - Custom validation patterns

5. **Database Connection**
   - Singleton pattern
   - Database initialization
   - Query execution

---

## 🚀 Tips สำหรับสอบ

1. **ฝึก CRUD Operations**
   - Create: เพิ่มข้อมูล 3-5 รายการ
   - Read: ดูรายการทั้งหมด
   - Update: แก้ไขรายการ
   - Delete: ลบรายการ

2. **ทดสอบ Validation**
   - ลองเว้นว่าง
   - ลองกรอกข้อมูลไม่ถูกต้อง
   - ตรวจสอบข้อความแสดงข้อผิดพลาด

3. **ทดสอบ Offline**
   - ปิด WiFi
   - แอปควรทำงานได้ปกติ

4. **Code Organization**
   - ใส่ code ไว้ใน function ที่เหมาะสม
   - เพิ่ม comments
   - Use meaningful variable names

5. **Error Handling**
   - ใช้ try-catch
   - Show error messages to user
   - ให้ user เลือก action อื่น

---

Good luck with the exam! 💪
