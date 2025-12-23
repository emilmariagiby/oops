import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestSupabasePage extends StatefulWidget {
  const TestSupabasePage({super.key});

  @override
  State<TestSupabasePage> createState() => _TestSupabasePageState();
}

class _TestSupabasePageState extends State<TestSupabasePage> {
  String _result = "Testing connection...";

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      final supabase = Supabase.instance.client;

      // 👇 Try to select first 1 row from your 'employee' table
      final response = await supabase.from('employee').select().limit(1);

      setState(() {
        _result = "✅ Supabase connected!\n\nResponse:\n$response";
      });
    } catch (error) {
      setState(() {
        _result = "❌ Connection failed:\n$error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(_result),
        ),
      ),
    );
  }
}
