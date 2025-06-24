enum Environment { dev, prod }

class AppConfig {
  static Environment _environment = Environment.dev;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get supabaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://hvnoyunycjynvhiapkzs.supabase.co';
      case Environment.prod:
        return 'https://hvnoyunycjynvhiapkzs.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    switch (_environment) {
      case Environment.dev:
        return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2bm95dW55Y2p5bnZoaWFwa3pzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3MzYxNzEsImV4cCI6MjA2NjMxMjE3MX0.8K2PiON7Xm3onbNzdzuc6dRdups57kFdVNrBaPlfsoo';
      case Environment.prod:
        return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2bm95dW55Y2p5bnZoaWFwa3pzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3MzYxNzEsImV4cCI6MjA2NjMxMjE3MX0.8K2PiON7Xm3onbNzdzuc6dRdups57kFdVNrBaPlfsoo';
    }
  }

  static String get appName => 'Todo App';
  static String get version => '1.0.0';
}
