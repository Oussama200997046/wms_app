import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AlgeriaPostWMSApp());
}

class AlgeriaPostWMSApp extends StatelessWidget {
  const AlgeriaPostWMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام إدارة المستودعات - بريد الجزائر',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthCheckScreen(),
    );
  }
}

/// شاشة تسجيل الدخول
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  Future<void> _login() async {
    if (_pinController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _usernameController.text.isEmpty ? 'أمناء المخزن' : _usernameController.text);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainHomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inventory_2, size: 70, color: Colors.blueAccent),
                      const SizedBox(height: 15),
                      const Text(
                        'مرفق إدارة المستودعات - بريد الجزائر',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم الموظف / أمين المخزن',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'رمز الدخول / كلمة السر',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const UpwPendingScreen(), 
    const QuotaTableScreen(),
    const PalletCalculatorScreen(),
    const BonDeCommandeCheckScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pending_actions), label: 'حصص UPW'),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: 'جدول الحصص'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'حاسبة الباليطة'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: 'مطابقة الطلب'),
        ],
      ),
    );
  }
}

/// 1. قائمة حصص UPW المتبقية
class UpwPendingScreen extends StatefulWidget {
  const UpwPendingScreen({super.key});

  @override
  State<UpwPendingScreen> createState() => _UpwPendingScreenState();
}

class _UpwPendingScreenState extends State<UpwPendingScreen> {
  final List<Map<String, dynamic>> _pendingOrders = [];

  void _addPendingOrder() {
    TextEditingController boxNameController = TextEditingController();
    TextEditingController upwProvinceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة حظيرة/حصة متبقية لولايات UPW'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: boxNameController,
              decoration: const InputDecoration(
                labelText: 'اسم السلعة / العلبة (مثال: أظرفة F4)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: upwProvinceController,
              decoration: const InputDecoration(
                labelText: 'اسم الولاية (مثال: الجزائر أو 16)',
                hintText: 'سيتم تحويلها تلقائياً إلى UPW',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (boxNameController.text.isNotEmpty && upwProvinceController.text.isNotEmpty) {
                setState(() {
                  String provInput = upwProvinceController.text.trim();
                  String upwFormat = provInput.toUpperCase().startsWith('UPW')
                      ? provInput.toUpperCase()
                      : 'UPW $provInput';

                  _pendingOrders.add({
                    'item_name': boxNameController.text,
                    'upw_province': upwFormat,
                    'date_added': DateTime.now().toString().split(' ')[0],
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ في القائمة'),
          ),
        ],
      ),
    );
  }

  void _removeOrder(int index) {
    setState(() {
      _pendingOrders.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة حصص UPW المتبقية'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPendingOrder,
        icon: const Icon(Icons.add),
        label: const Text('إضافة سلعة لم تُستلم'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _pendingOrders.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'لا توجد حصص متبقية حالياً.\nاضغط على زر (+) لإضافة السلع والولايات (UPW) التي لم تستلم بعد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              itemCount: _pendingOrders.length,
              itemBuilder: (context, index) {
                final item = _pendingOrders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    ),
                    title: Text(
                      item['upw_province'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('السلعة المتبقية: ${item['item_name']}\nتاريخ التسجيل: ${item['date_added']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                      tooltip: 'تم التسليم (حذف من المتبقي)',
                      onPressed: () => _removeOrder(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// 2. حاسبة الباليطة والتلبة مع السلع المزدوجة والكتب
class PalletCalculatorScreen extends StatefulWidget {
  const PalletCalculatorScreen({super.key});

  @override
  State<PalletCalculatorScreen> createState() => _PalletCalculatorScreenState();
}

class _PalletCalculatorScreenState extends State<PalletCalculatorScreen> {
  final TextEditingController _horizontalController = TextEditingController();
  final TextEditingController _verticalController = TextEditingController();
  final TextEditingController _topExtraController = TextEditingController();
  final TextEditingController _missingBoxesController = TextEditingController();
  final TextEditingController _customBookCapacityController = TextEditingController();

  int _selectedPackSize = 1000;
  bool _isCustomBook = false;
  int _netCartons = 0;
  int _totalUnits = 0;

  void _calculate() {
    int horizontal = int.tryParse(_horizontalController.text) ?? 0;
    int vertical = int.tryParse(_verticalController.text) ?? 0;
    int topExtra = int.tryParse(_topExtraController.text) ?? 0;
    int missing = int.tryParse(_missingBoxesController.text) ?? 0;

    int packCapacity = _selectedPackSize;
    if (_isCustomBook) {
      packCapacity = int.tryParse(_customBookCapacityController.text) ?? 0;
    }

    setState(() {
      int gridTotal = horizontal * vertical;
      _netCartons = (gridTotal + topExtra) - missing;
      if (_netCartons < 0) _netCartons = 0;
      _totalUnits = _netCartons * packCapacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة الباليطة والتلبة'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.blue.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'المعادلة: (أفقي × عمودي) + التلبة العلوية - الكراتين الناقصة',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _horizontalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'العدد الأفقي', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('×')),
                  Expanded(
                    child: TextField(
                      controller: _verticalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'العدد العمودي', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _topExtraController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'التلبة (فوق الباليطة)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.add_box, color: Colors.green),
                      ),
                      onChanged: (_) => _calculate(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _missingBoxesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الكراتين الناقصة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.indeterminate_check_box, color: Colors.red),
                      ),
                      onChanged: (_) => _calculate(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<int>(
                value: _isCustomBook ? -1 : _selectedPackSize,
                decoration: const InputDecoration(labelText: 'سعة الكرتونة / نوع السلعة', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 2000, child: Text('سلع مزدوجة (2000 وحدة)')),
                  DropdownMenuItem(value: 1000, child: Text('أوراق عادية (1000 ورقة)')),
                  DropdownMenuItem(value: 500, child: Text('كراتين (500 ورقة)')),
                  DropdownMenuItem(value: 250, child: Text('أظرفة F3/F4 (250 وحدة)')),
                  DropdownMenuItem(value: -1, child: Text('علب كتب / كراريس (سعة مخصصة)')),
                ],
                onChanged: (val) {
                  setState(() {
                    if (val == -1) {
                      _isCustomBook = true;
                    } else if (val != null) {
                      _isCustomBook = false;
                      _selectedPackSize = val;
                    }
                    _calculate();
                  });
                },
              ),
              if (_isCustomBook) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _customBookCapacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'أدخل عدد الكتب/الكراريس في الكرتونة',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.menu_book),
                  ),
                  onChanged: (_) => _calculate(),
                ),
              ],
              const SizedBox(height: 20),
              Card(
                color: Colors.green.shade50,
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('إجمالي عدد الكراتين: $_netCartons كرتونة', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(),
                      Text('$_totalUnits', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                      const Text('إجمالي الوحدات/الأوراق/الكتب'),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// 3. جدول الـ 69 ولاية بصيغة UPW
class QuotaTableScreen extends StatefulWidget {
  const QuotaTableScreen({super.key});

  @override
  State<QuotaTableScreen> createState() => _QuotaTableScreenState();
}

class _QuotaTableScreenState extends State<QuotaTableScreen> {
  final List<Map<String, dynamic>> _provinces = List.generate(69, (index) {
    int code = index + 1;
    String codeStr = code < 10 ? '0$code' : '$code';
    return {
      'code': codeStr,
      'name': 'UPW $codeStr',
      'received': false,
      'date': ''
    };
  });

  void _toggleStatus(int index) {
    setState(() {
      _provinces[index]['received'] = !_provinces[index]['received'];
      if (_provinces[index]['received']) {
        _provinces[index]['date'] = DateTime.now().toString().split(' ')[0];
      } else {
        _provinces[index]['date'] = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جدول الحصص العامة (${_provinces.length} ولاية/مركز UPW)'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _provinces.length,
        itemBuilder: (context, index) {
          final prov = _provinces[index];
          final bool isDone = prov['received'];
          return Card(
            color: isDone ? Colors.green.shade50 : Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isDone ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                child: Text(prov['code']),
              ),
              title: Text(
                prov['name'],
                style: TextStyle(
                  decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(isDone ? 'تم التسليم: ${prov['date']}' : 'لم يتم التسليم بعد'),
              trailing: Checkbox(
                value: isDone,
                onChanged: (_) => _toggleStatus(index),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 4. شاشة مطابقة Bon de Commande
class BonDeCommandeCheckScreen extends StatelessWidget {
  const BonDeCommandeCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مطابقة أذونات الطلب'), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
      body: const Center(child: Text('شاشة مطابقة الـ Bon de Commande')),
    );
  }
}
