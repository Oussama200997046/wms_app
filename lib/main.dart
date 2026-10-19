import 'package:flutter/material.dart';

void main() {
  runApp(const WmsApp());
}

class WmsApp extends StatelessWidget {
  const WmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'إدارة مخازن بريد الجزائر',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xF2F4F7FF),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// 1. شاشة تسجيل الدخول
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(text: "Oussama");
  final _passwordController = TextEditingController(text: "123456");
  bool _isLoading = false;

  void _login() {
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال البيانات المطلوبة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[700],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.markunread_mailbox, size: 70, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'بريد الجزائر',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const Text(
                  'نظام إدارة المخازن والشحنات (WMS)',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'اسم المستخدم / الرقم الوظيفي',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 2. الواجهة الرئيسية والتنقل
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Map<String, String>> _shipments = [
    {'code': 'DZ-982341-SFP', 'type': 'طرد بريدي وارد', 'status': 'مكتمل', 'date': '2026-10-19'},
    {'code': 'DZ-104928-EXP', 'type': 'شحنة عاجلة Express', 'status': 'قيد المعالجة', 'date': '2026-10-19'},
    {'code': 'DZ-550192-SFP', 'type': 'مواد مخزنية', 'status': 'مكتمل', 'date': '2026-10-18'},
  ];

  final TextEditingController _shipmentController = TextEditingController();

  void _addShipment(String code, String type) {
    setState(() {
      _shipments.insert(0, {
        'code': code,
        'type': type,
        'status': 'قيد المعالجة',
        'date': DateTime.now().toString().substring(0, 10),
      });
    });
  }

  void _openScannerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_scanner, size: 60, color: Colors.amber),
              const SizedBox(height: 10),
              const Text(
                'مسح الباركود / QR',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('قم بتوجيه الكاميرا نحو الرمز الخاص بالشحنة'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('محاكاة مسح شحنة جديدة', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                  final randomCode = 'DZ-${100000 + DateTime.now().millisecond % 899999}-WMS';
                  _addShipment(randomCode, 'طرد جديد مسجل بالكاميرا');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تمت إضافة الشحنة: $randomCode')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة مخازن بريد الجزائر', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardHome(),
          _buildShipmentsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[700],
        onPressed: _openScannerDialog,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'المخزن بالشحنات'),
        ],
      ),
    );
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مرحباً بك، أسامة 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text('ملخص نشاط المخزن اليوم', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('إجمالي الشحنات', '${_shipments.length}', Colors.blue, Icons.archive),
              const SizedBox(width: 10),
              _buildStatCard('قيد المعالجة', '${_shipments.where((s) => s['status'] == 'قيد المعالجة').length}', Colors.orange, Icons.pending_actions),
            ],
          ),
          const SizedBox(height: 20),
          const Text('عمليات سريعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.add_a_photo, color: Colors.amber),
              title: const Text('مسح باركود شحنة جديدة'),
              subtitle: const Text('إدخال مباشر عبر كاميرا الهاتف'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _openScannerDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _shipmentController,
                  decoration: const InputDecoration(
                    hintText: 'إدخال رمز الشحنة يدوياً',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_shipmentController.text.isNotEmpty) {
                    _addShipment(_shipmentController.text, 'إدخال يدوي');
                    _shipmentController.clear();
                  }
                },
                child: const Text('إضافة', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _shipments.length,
              itemBuilder: (context, index) {
                final item = _shipments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping, color: Colors.amber),
                    title: Text(item['code']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['type']} • ${item['date']}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item['status'] == 'مكتمل' ? Colors.green[100] : Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['status']!,
                        style: TextStyle(
                          color: item['status'] == 'مكتمل' ? Colors.green[800] : Colors.orange[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
