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
      title: 'Algeria Post WMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthCheckScreen(),
    );
  }
}

/// شاشة التحقق من وجود كلمة سر أو طلب إنشائها / إدخالها
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _isLoading = true;
  bool _hasPin = false;

  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('app_pin');
    setState(() {
      _hasPin = savedPin != null && savedPin.isNotEmpty;
      _isLoading = false;
    });
  }

  Future<void> _savePin() async {
    if (_pinController.text.length < 4) {
      setState(() {
        _errorMessage = 'كلمة السر يجب أن تتكون من 4 أرقام على الأقل';
      });
      return;
    }
    if (_pinController.text != _confirmPinController.text) {
      setState(() {
        _errorMessage = 'كلمتا السر غير متطابقتين';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_pin', _pinController.text);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainHomeScreen()),
      );
    }
  }

  Future<void> _verifyPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('app_pin');

    if (_pinController.text == savedPin) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainHomeScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'كلمة السر غير صحيحة!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                      const Icon(Icons.lock_person, size: 70, color: Colors.blueAccent),
                      const SizedBox(height: 15),
                      Text(
                        _hasPin ? 'تأمين المخزن - بريد الجزائر' : 'إنشاء كلمة سر جديدة',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _hasPin
                            ? 'أدخل كلمة السر الخاصة بك للدخول للتطبيق'
                            : 'قم بإنشاء كلمة سر لحماية بيانات المخزن والحصص',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: _hasPin ? 'كلمة السر' : 'كلمة السر الجديدة',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.key),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!_hasPin)
                        TextField(
                          controller: _confirmPinController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            labelText: 'تأكيد كلمة السر',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.key_outlined),
                            counterText: '',
                          ),
                        ),
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _hasPin ? _verifyPin : _savePin,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          _hasPin ? 'دخول للتطبيق' : 'حفظ وإنشاء كلمة السر',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
    const QuotaTableScreen(),
    const PalletCalculatorScreen(),
    const BonDeCommandeCheckScreen(),
    const RegistreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'جدول الحصص',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'حاسبة الباليطة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'مطابقة الطلب',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'السجل',
          ),
        ],
      ),
    );
  }
}

/// 1. شاشة حاسبة الباليطة الشبكية + التعامل مع النقص
class PalletCalculatorScreen extends StatefulWidget {
  const PalletCalculatorScreen({super.key});

  @override
  State<PalletCalculatorScreen> createState() => _PalletCalculatorScreenState();
}

class _PalletCalculatorScreenState extends State<PalletCalculatorScreen> {
  final TextEditingController _horizontalController = TextEditingController();
  final TextEditingController _verticalController = TextEditingController();
  final TextEditingController _missingBoxesController = TextEditingController();

  int _selectedPackSize = 1000;
  int _totalCartons = 0;
  int _missingCartons = 0;
  int _netCartons = 0;
  int _totalPapers = 0;

  void _calculate() {
    int horizontal = int.tryParse(_horizontalController.text) ?? 0;
    int vertical = int.tryParse(_verticalController.text) ?? 0;
    _missingCartons = int.tryParse(_missingBoxesController.text) ?? 0;

    setState(() {
      _totalCartons = horizontal * vertical;
      _netCartons = _totalCartons - _missingCartons;
      if (_netCartons < 0) _netCartons = 0;
      _totalPapers = _netCartons * _selectedPackSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة الباليطة والمخزون'),
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
                    'الحساب الشبكي: (أفقي × عمودي) - الكراتين الناقصة',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _horizontalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'العدد الأفقي (مثال: 11)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _calculate(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('×', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _verticalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'العدد العمودي (مثال: 9)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _calculate(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _missingBoxesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد الكراتين الناقصة / المأخوذة (إن وجد)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.remove_circle_outline, color: Colors.red),
                ),
                onChanged: (_) => _calculate(),
              ),
              const SizedBox(height: 16),
              const Text('نوع السلعة / سعة الكرتونة:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              DropdownButtonFormField<int>(
                value: _selectedPackSize,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 1000, child: Text('أوراق عادية (1000 ورقة)')),
                  DropdownMenuItem(value: 500, child: Text('كراتين (500 ورقة)')),
                  DropdownMenuItem(value: 250, child: Text('أظرفة F3 / F4 (250 وحدة)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedPackSize = val;
                      _calculate();
                    });
                  }
                },
              ),
              const SizedBox(height: 25),
              Card(
                elevation: 4,
                color: _missingCartons > 0 ? Colors.orange.shade50 : Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: _missingCartons > 0 ? Colors.orange : Colors.green,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text('إجمالي الكراتين الصافي: $_netCartons كرتونة',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (_missingCartons > 0)
                        Text('(تم خصم $_missingCartons كرتونة ناقصة)',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      const Divider(),
                      const Text('إجمالي الأوراق / الوحدات:', style: TextStyle(fontSize: 15)),
                      Text('$_totalPapers',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: _missingCartons > 0 ? Colors.orange.shade900 : Colors.green.shade900,
                          )),
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

/// 2. شاشة مطابقة Bon de Commande والتنبيه من النقص
class BonDeCommandeCheckScreen extends StatefulWidget {
  const BonDeCommandeCheckScreen({super.key});

  @override
  State<BonDeCommandeCheckScreen> createState() => _BonDeCommandeCheckScreenState();
}

class _BonDeCommandeCheckScreenState extends State<BonDeCommandeCheckScreen> {
  final TextEditingController _targetQuantityController = TextEditingController();
  final TextEditingController _palletCountController = TextEditingController();
  final TextEditingController _missingBoxesController = TextEditingController();

  int _packSize = 1000;
  int _calculatedTotal = 0;
  int _targetQuantity = 0;
  String _statusMessage = 'أدخل البيانات للتحقق من المطابقة';
  Color _statusColor = Colors.grey;

  void _checkMatching() {
    _targetQuantity = int.tryParse(_targetQuantityController.text) ?? 0;
    int totalCartons = int.tryParse(_palletCountController.text) ?? 0;
    int missingCartons = int.tryParse(_missingBoxesController.text) ?? 0;

    int actualCartons = totalCartons - missingCartons;
    _calculatedTotal = actualCartons * _packSize;

    setState(() {
      if (_targetQuantity == 0 || totalCartons == 0) {
        _statusMessage = 'رجاءً أدخل الكمية المطلوبة وعدد الكراتين';
        _statusColor = Colors.grey;
      } else if (_calculatedTotal == _targetQuantity) {
        _statusMessage = '✅ مطابقة تامة! الكمية كاملة ومكافئة للطلب.';
        _statusColor = Colors.green;
      } else if (_calculatedTotal < _targetQuantity) {
        int diff = _targetQuantity - _calculatedTotal;
        _statusMessage = '⚠️ تنبيه: وجود نقص! الناقص: $diff وحدة (${diff ~/ _packSize} كرتونة). يُوصى بإرجاع الشحنة لتفادي المشاكل المحاسبية.';
        _statusColor = Colors.red;
      } else {
        int diff = _calculatedTotal - _targetQuantity;
        _statusMessage = 'ℹ️ تنبيه: الكمية الواردة أكبر من المطلوب بـ: $diff وحدة.';
        _statusColor = Colors.orange;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق من Bon de Commande'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _targetQuantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الكمية المكتوبة في Bon de Commande',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment),
                ),
                onChanged: (_) => _checkMatching(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _packSize,
                decoration: const InputDecoration(
                  labelText: 'نوع السلعة / سعة الكرتونة',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1000, child: Text('أوراق عادية (1000 ورقة)')),
                  DropdownMenuItem(value: 500, child: Text('كراتين (500 ورقة)')),
                  DropdownMenuItem(value: 250, child: Text('أظرفة F3/F4 (250 وحدة)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    _packSize = val;
                    _checkMatching();
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _palletCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'عدد الكراتين المفترضة',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _checkMatching(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _missingBoxesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'عدد الناقص منها',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _checkMatching(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Card(
                color: _statusColor.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: _statusColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'الكمية الفعلية المحسوبة: $_calculatedTotal',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: _statusColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 3. شاشة جدول حصص الولايات والتشطيب الرقمي
class QuotaTableScreen extends StatefulWidget {
  const QuotaTableScreen({super.key});

  @override
  State<QuotaTableScreen> createState() => _QuotaTableScreenState();
}

class _QuotaTableScreenState extends State<QuotaTableScreen> {
  final List<Map<String, dynamic>> _provinces = [
    {'code': '01', 'name': 'أدرار', 'received': false, 'date': ''},
    {'code': '02', 'name': 'الشلف', 'received': false, 'date': ''},
    {'code': '16', 'name': 'الجزائر', 'received': true, 'date': '2026-10-18'},
    {'code': '25', 'name': 'قسنطينة', 'received': false, 'date': ''},
    {'code': '31', 'name': 'وهران', 'received': false, 'date': ''},
  ];

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
        title: const Text('جدول الحصص (الباب الرقمي)'),
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
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              subtitle: Text(isDone ? 'تم الاستلام بتاريخ: ${prov['date']}' : 'لم تستلم الحصة بعد'),
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

/// 4. شاشة السجل الرقمي (Registre Virtuel)
class RegistreScreen extends StatelessWidget {
  const RegistreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السجل الرقمي (Registre)'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'هنا يتم تنظيم البيانات كجدول السجل الورقي لتسهيل تدوينها يدوياً في كراس الريجيست حمايةً من انقطاع الكهرباء.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
