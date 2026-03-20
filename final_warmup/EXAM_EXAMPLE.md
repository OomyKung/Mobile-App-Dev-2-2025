## Task Manager - Example Exam App

ตัวอย่างแอปพลิเคชัน **Task Manager** สำหรับการเตรียมสอบ Final นักจัดการงาน/To-Do รายการของคุณด้วยฐานข้อมูลท้องถิ่น

### ✅ ตรงตามความต้องการข้อสอบ

| ความต้องการ | การนำไปใช้ |
|------------|----------|
| **Openbook** | โค้ดอ่านง่าย มีความเห็นโดยละเอียด |
| **Multi-Screen Navigation** | Home Screen, Add/Edit Screen |
| **CRUD Operations** | Create, Read, Update, Delete tasks ในฐานข้อมูล |
| **Local Database (SQLite)** | `sqflite` package - ฐานข้อมูล offline |
| **Input Validation** | ตรวจสอบ title (3-100 chars) และ description (5-500 chars) |
| **Offline Ready** | ไม่ต้องมี internet, ฐานข้อมูลเก็บใน device |
| **Data Persistence** | ข้อมูลยังคงอยู่หลังปิดแอป |

---

## 🗂️ โครงสร้าง Project

```
lib/
├── main.dart                          # Application entry point
├── models/
│   └── task.dart                      # Task data model
├── database/
│   └── database_helper.dart           # Database CRUD operations
└── screens/
    ├── home_screen.dart               # Main task list & statistics
    └── add_edit_screen.dart           # Form for add/edit tasks
```

---

## 📱 Features ของแอป

### 1. **Home Screen** - หน้าหลัก
- 📊 Statistics Card: นับจำนวน Total/Completed/Pending tasks
- 📋 Task List: แสดงรายการงานทั้งหมด
- 🔄 Filter: เลือกดู All Tasks หรือ Completed Tasks เท่านั้น
- ✅ Toggle Completion: คลิกเครื่องหมายถูกเพื่อทำเครื่องหมายว่าสำเร็จ
- ✏️ Edit: แก้ไขงานที่มีอยู่
- 🗑️ Delete: ลบผลงานที่เลือก หรือลบทั้งหมดที่สำเร็จแล้ว
- ➕ Add Button: เพิ่มงานใหม่

### 2. **Add/Edit Screen** - เพิ่ม/แก้ไขงาน
- 📝 Title Input:
  - ✓ บังคับกรอก
  - ✓ ความยาว 3-100 ตัวอักษร
  - ✓ ข้อความแสดงข้อกำหนด
  
- 📝 Description Input:
  - ✓ บังคับกรอก
  - ✓ ความยาว 5-500 ตัวอักษร
  - ✓ Multi-line text area
  - ✓ ข้อความแสดงข้อกำหนด

- 📋 Task Info Card (เฉพาะหน้าแก้ไข):
  - แสดงสถานะปัจจุบัน
  - แสดงวันที่สร้างและเสร็จสิ้น

- 💾 Action Buttons:
  - Save/Update button (disabled ขณะบันทึก)
  - Cancel button

### 3. **Database (SQLite)**
ตารางข้อมูลที่จัดเก็บ:
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  isCompleted INTEGER DEFAULT 0,
  createdAt TEXT NOT NULL,
  completedAt TEXT
)
```

---

## 🔧 CRUD Operations ในฐานข้อมูล

### Create (เพิ่มข้อมูล)
```dart
Future<int> insertTask(Task task)
```

### Read (อ่านข้อมูล)
```dart
Future<List<Task>> getAllTasks()           // ดึงทั้งหมด
Future<List<Task>> getTasksByStatus()      // ดึงตามสถานะ
Future<Task?> getTaskById(int id)          // ดึงรายการเดี่ยว
Future<int> getTaskCount()                 // นับจำนวน
```

### Update (อัปเดตข้อมูล)
```dart
Future<int> updateTask(Task task)          // อัปเดตรายการ
Future<int> toggleTaskStatus()             // เปลี่ยนสถานะสำเร็จ/ยังไม่สำเร็จ
```

### Delete (ลบข้อมูล)
```dart
Future<int> deleteTask(int id)             // ลบรายการเดี่ยว
Future<int> deleteCompletedTasks()         // ลบทั้งหมดที่สำเร็จแล้ว
```

---

## 📦 Dependencies ที่ใช้

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.3.0          # SQLite database
  path: ^1.8.3             # File path handling
```

---

## 🚀 วิธีใช้งาน

### 1. **ได้รับแอป** (ไม่ต้อง `flutter pub get` ใหม่)
```bash
cd final_warmup
flutter run
```

### 2. **สร้างงานใหม่**
- กด ➕ button
- กรอก Title (3-100 chars)
- กรอก Description (5-500 chars)
- กด "Create Task"

### 3. **แก้ไขงาน**
- คลิก "⋮" ที่งาน → Edit
- แก้ไขข้อมูล
- กด "Update Task"

### 4. **ทำเครื่องหมายสำเร็จ**
- คลิก checkbox ทางซ้ายของงาน

### 5. **ลบงาน**
- คลิก "⋮" ที่งาน → Delete
- หรือกด "Clear" เพื่อลบทั้งหมดที่สำเร็จแล้ว

---

## 🎓 แนวคิดที่เรียนรู้

| หัวข้อ | คำอธิบาย |
|------|---------|
| **StatefulWidget** | Home Screen และ Add/Edit Screen ใช้ State Management |
| **Forms & Validation** | Input validation ด้วย `FormField` และ `TextFormField` |
| **Database Operations** | CRUD ด้วย SQLite ผ่าน `sqflite` package |
| **Navigation** | `Navigator.push()` สำหรับไปหน้าอื่น |
| **Error Handling** | Try-catch และข้อการแสดงข้อผิดพลาด |
| **Async/Await** | Future-based database operations |
| **Data Models** | Serialization/Deserialization ด้วย `toMap()` และ `fromMap()` |
| **UI/UX** | Cards, ListTile, AppBar, FloatingActionButton, Dialogs |

---

## 💡 ข้อเสนอแนะสำหรับสอบ

1. ✅ **ตรวจสอบการตรวจสอบ Input**
   - กรอก title ที่สั้นเกินไป
   - กรอก description ที่ยาวเกินไป
   - เว้นว่างข้างบน

2. ✅ **ทดสอบ CRUD Operations**
   - สร้างงาน → ดูในรายการ
   - แก้ไขงาน → ตรวจสอบการเปลี่ยนแปลง
   - ลบงาน → ตรวจสอบการถูกลบออก

3. ✅ **ทดสอบ Data Persistence**
   - สร้างงานบางอย่าง
   - ปิดแอป (hot restart)
   - เปิดแอปอีกครั้ง → ข้อมูลยังอยู่

4. ✅ **ทดสอบ Offline**
   - ปิด WiFi/Mobile Data
   - แอปควรทำงานได้ปกติ

---

## 🔍 File Structure Explanation

### `main.dart`
- Entry point ของแอป
- ตั้ง MaterialApp theme
- กำหนด Home Screen

### `models/task.dart`
- คลาส Task ที่ใช้เก็บข้อมูลงาน
- Method `toMap()` - แปลงเป็น Map สำหรับบันทึกในฐานข้อมูล
- Method `fromMap()` - แปลงจาก Map เป็นออบเจกต์ Task

### `database/database_helper.dart`
- Singleton pattern (DatabaseHelper._instance)
- ทั้งหมด CRUD methods
- Database initialization และ table creation

### `screens/home_screen.dart`
- แสดงรายการงาน
- Statistics ของงาน
- Navigation ไปยังหน้า Add/Edit

### `screens/add_edit_screen.dart`
- Form สำหรับสร้าง/แก้ไขงาน
- Input validation
- Error handling

---

## 📝 สรุป

แอป Task Manager นี้เป็นตัวอย่างที่สมบูรณ์ของ:
- ✅ การใช้ SQLite database แบบ offline
- ✅ CRUD operations ที่สมบูรณ์
- ✅ Input validation ตามที่กำหนด
- ✅ Multi-screen navigation
- ✅ State management
- ✅ Error handling
- ✅ Data persistence

คุณสามารถใช้นี้เป็นแบบภาพสำหรับการออกแบบแอป exam ของคุณเอง! 🎉
