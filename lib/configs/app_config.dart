enum Environment { dev, prod }

class AppConfig {
  static Environment _environment = Environment.dev;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get supabaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://wmfswgcrudvdqcgcnbxf.supabase.co';
      case Environment.prod:
        return 'https://wmfswgcrudvdqcgcnbxf.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    switch (_environment) {
      case Environment.dev:
        return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndtZnN3Z2NydWR2ZHFjZ2NuYnhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0MTMzMzcsImV4cCI6MjA2NTk4OTMzN30.qnXLhP_Is-88aChJns67muMjhShCYQ-Qp2MPf2Iv9g8';
      case Environment.prod:
        return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndtZnN3Z2NydWR2ZHFjZ2NuYnhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0MTMzMzcsImV4cCI6MjA2NTk4OTMzN30.qnXLhP_Is-88aChJns67muMjhShCYQ-Qp2MPf2Iv9g8';
    }
  }

  static String get appName => 'Todo App';
  static String get version => '1.0.0';
}
