## 🔍 Quick Reference Guide - Common Patterns

สำหรับใช้อ้างอิงเร็ว ๆ ในระหว่างการพัฒนา

---

## 1️⃣ Database Patterns

### Create Database Connection
```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'app.db');
  
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // Create tables here
    },
  );
}
```

### Create Table
```dart
Future<void> _createTable(Database db, int version) async {
  await db.execute('''
    CREATE TABLE items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      price REAL,
      createdAt TEXT NOT NULL
    )
  ''');
}
```

### Insert Data
```dart
Future<int> insertItem(Item item) async {
  final db = await database;
  return await db.insert('items', item.toMap());
}
```

### Read All Data
```dart
Future<List<Item>> getAllItems() async {
  final db = await database;
  final maps = await db.query('items');
  return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
}
```

### Read with Filter
```dart
Future<List<Item>> getItemsByCategory(String category) async {
  final db = await database;
  return await db.query(
    'items',
    where: 'category = ?',
    whereArgs: [category],
    orderBy: 'createdAt DESC',
  );
}
```

### Update Data
```dart
Future<int> updateItem(Item item) async {
  final db = await database;
  return await db.update(
    'items',
    item.toMap(),
    where: 'id = ?',
    whereArgs: [item.id],
  );
}
```

### Delete Data
```dart
Future<int> deleteItem(int id) async {
  final db = await database;
  return await db.delete(
    'items',
    where: 'id = ?',
    whereArgs: [id],
  );
}
```

### Raw Query (COUNT, SUM, AVG)
```dart
Future<int> getItemCount() async {
  final db = await database;
  final result = await db.rawQuery('SELECT COUNT(*) as count FROM items');
  return Sqflite.firstIntValue(result) ?? 0;
}

Future<double> getTotalPrice() async {
  final db = await database;
  final result = await db.rawQuery('SELECT SUM(price) as total FROM items');
  return Sqflite.firstDoubleValue(result) ?? 0;
}
```

---

## 2️⃣ Form Validation Patterns

### Basic Validation
```dart
String? _validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Name is required';
  }
  if (value.length < 3) {
    return 'Name must be at least 3 characters';
  }
  if (value.length > 50) {
    return 'Name must not exceed 50 characters';
  }
  return null;
}
```

### Number Validation
```dart
String? _validatePrice(String? value) {
  if (value == null || value.isEmpty) {
    return 'Price is required';
  }
  final price = double.tryParse(value);
  if (price == null) {
    return 'Please enter a valid number';
  }
  if (price <= 0) {
    return 'Price must be greater than 0';
  }
  if (price > 999999) {
    return 'Price is too high';
  }
  return null;
}
```

### Email Validation
```dart
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}
```

### Phone Number Validation
```dart
String? _validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone number is required';
  }
  if (value.length < 9 || value.length > 12) {
    return 'Phone number must be 9-12 digits';
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    return 'Phone number must contain only digits';
  }
  return null;
}
```

### Date Range Validation
```dart
String? _validateDate(String? fromDate, String? toDate) {
  if (fromDate == null || fromDate.isEmpty) {
    return 'From date is required';
  }
  if (toDate == null || toDate.isEmpty) {
    return 'To date is required';
  }
  
  try {
    final from = DateTime.parse(fromDate);
    final to = DateTime.parse(toDate);
    
    if (from.isAfter(to)) {
      return 'From date must be before to date';
    }
  } catch (e) {
    return 'Invalid date format';
  }
  
  return null;
}
```

---

## 3️⃣ Navigation Patterns

### Simple Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AddScreen()),
);
```

### Navigation with Result
```dart
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AddScreen()),
);

if (result == true) {
  _loadItems(); // Refresh data
}
```

### Pop with Result
```dart
Navigator.pop(context, true); // Return true to indicate success
```

---

## 4️⃣ State Management Patterns

### Load Data on Init
```dart
@override
void initState() {
  super.initState();
  _loadItems();
}

Future<void> _loadItems() async {
  try {
    final items = await dbHelper.getAllItems();
    setState(() {
      this.items = items;
    });
  } catch (e) {
    _showError('Error loading items: $e');
  }
}
```

### Async State with Loading
```dart
bool isLoading = false;

Future<void> _saveItem() async {
  setState(() => isLoading = true);
  
  try {
    await dbHelper.insertItem(item);
    _showSuccess('Item saved');
  } catch (e) {
    _showError('Error: $e');
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}
```

---

## 5️⃣ Widgets and UI Patterns

### TextField with Validation
```dart
TextFormField(
  controller: controller,
  decoration: InputDecoration(
    hintText: 'Enter name',
    labelText: 'Name',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.person),
    errorMaxLines: 2,
  ),
  validator: _validateName,
  textInputAction: TextInputAction.next,
)
```

### List View with Items
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ListTile(
      title: Text(item.name),
      subtitle: Text(item.description),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Text('Edit'),
            onTap: () => _editItem(item),
          ),
          PopupMenuItem(
            child: Text('Delete'),
            onTap: () => _deleteItem(item.id),
          ),
        ],
      ),
    );
  },
)
```

### Empty State
```dart
items.isEmpty
  ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No items found'),
        ],
      ),
    )
  : ListView.builder(...)
```

### Action Buttons
```dart
Column(
  children: [
    ElevatedButton(
      onPressed: () => _save(),
      child: Text('Save'),
    ),
    SizedBox(height: 12),
    OutlinedButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Cancel'),
    ),
  ],
)
```

### Dialogs
```dart
// Confirmation Dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Delete Item?'),
    content: Text('This action cannot be undone'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          _delete();
        },
        child: Text('Delete'),
      ),
    ],
  ),
);
```

### SnackBar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Item saved!'),
    duration: Duration(seconds: 2),
  ),
);
```

---

## 6️⃣ Model Patterns

### Model with toMap/fromMap
```dart
class Item {
  int? id;
  String name;
  String description;
  double price;
  DateTime createdAt;

  Item({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
```

---

## 7️⃣ Error Handling Pattern

### Try-Catch with User Feedback
```dart
try {
  // Database operation
  await dbHelper.insertItem(item);
  
  // Show success
  _showSuccess('Item added successfully');
  
  // Navigate back
  Navigator.pop(context, true);
  
} on DatabaseException catch (e) {
  _showError('Database error: ${e.toString()}');
  
} on FormatException catch (e) {
  _showError('Invalid data format: ${e.toString()}');
  
} catch (e) {
  _showError('Unexpected error: ${e.toString()}');
}
```

---

## 8️⃣ Search/Filter Pattern

### Search Implementation
```dart
Future<List<Item>> _searchItems(String query) async {
  if (query.isEmpty) {
    return await dbHelper.getAllItems();
  }
  
  final db = await dbHelper.database;
  final maps = await db.query(
    'items',
    where: 'name LIKE ? OR description LIKE ?',
    whereArgs: ['%$query%', '%$query%'],
  );
  
  return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
}

// In UI
TextField(
  onChanged: (query) {
    _searchItems(query);
  },
)
```

---

## 9️⃣ Date/Time Patterns

### Format DateTime
```dart
String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}

// Usage
Text(_formatDate(item.createdAt))
```

### Date Picker
```dart
void _selectDate() async {
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

## 🔟 Statistics Pattern

### Calculate Stats
```dart
Future<Map<String, dynamic>> getStats() async {
  final db = await database;
  
  final total = await db.rawQuery(
    'SELECT COUNT(*) as count FROM items'
  );
  
  final completed = await db.rawQuery(
    'SELECT COUNT(*) as count FROM items WHERE status = "completed"'
  );
  
  final totalCount = Sqflite.firstIntValue(total) ?? 0;
  final completedCount = Sqflite.firstIntValue(completed) ?? 0;
  
  return {
    'total': totalCount,
    'completed': completedCount,
    'pending': totalCount - completedCount,
  };
}
```

---

## 📝 Quick Checklist for New App

When creating a new domain app, follow this:

- [ ] Create Model class with `toMap()` and `fromMap()`
- [ ] Create `DatabaseHelper` with CRUD methods
- [ ] Create `HomeScreen` with list and statistics
- [ ] Create `AddEditScreen` with form and validation
- [ ] Update `main.dart` to use new screens
- [ ] Add necessary dependencies in `pubspec.yaml`
- [ ] Test all CRUD operations
- [ ] Test validation
- [ ] Test offline functionality
- [ ] Test data persistence (close and reopen app)

---

**Use these patterns as templates for your exam app!** 🚀
