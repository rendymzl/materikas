import 'package:supabase_flutter/supabase_flutter.dart';

loadSupabase() async {
  await Supabase.initialize(
    url: 'https://fohbzceowdszhuamwief.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvaGJ6Y2Vvd2Rzemh1YW13aWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjUyMzc2MzEsImV4cCI6MjA0MDgxMzYzMX0.hBbSXniRlT2X7zQPBJ7PF8JZuQteu9tzPkGYE8pxlmQ',
  );
}
