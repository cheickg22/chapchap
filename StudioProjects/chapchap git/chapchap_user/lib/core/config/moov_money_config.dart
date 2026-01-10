/// Configuration for restart_tagxi Money API
/// Test credentials provided by restart_tagxi Money
/// 
/// IMPORTANT: These are TEST credentials only
/// Production credentials should be stored securely in environment variables
/// or a secure configuration management system

class restart_tagxiMoneyConfig {
  // Environment configuration
  static const bool isProduction = false; // Set to true for production
  
  // Test Environment Credentials
  static const String testBaseUrl = 'https://testbed.restart_tagximoney.ml:38443/apiaccess';
  static const String testCashInUrl = '$testBaseUrl/IntegratingCashIn';
  static const String testCashOutUrl = '$testBaseUrl/IntegratingCashOut';
  static const String testShortCode = '22300001009';
  static const String testUsername = '00001009';
  static const String testPassword = 'Accounting_2025test';
  
  // Production Environment Credentials (to be filled later)
  static const String prodBaseUrl = ''; // To be provided by restart_tagxi Money
  static const String prodCashInUrl = '';
  static const String prodCashOutUrl = '';
  static const String prodShortCode = '';
  static const String prodUsername = '';
  static const String prodPassword = '';
  
  // Active configuration based on environment
  static String get baseUrl => isProduction ? prodBaseUrl : testBaseUrl;
  static String get cashInUrl => isProduction ? prodCashInUrl : testCashInUrl;
  static String get cashOutUrl => isProduction ? prodCashOutUrl : testCashOutUrl;
  static String get shortCode => isProduction ? prodShortCode : testShortCode;
  static String get username => isProduction ? prodUsername : testUsername;
  static String get password => isProduction ? prodPassword : testPassword;
  
  // API Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Transaction Limits (in XOF)
  static const double minTransactionAmount = 500;
  static const double maxTransactionAmount = 2000000;
  static const double dailyLimit = 5000000;
  
  // Commission Configuration
  static const double commissionPercentage = 0.02; // 2%
  static const double minCommission = 50;
  static const double maxCommission = 10000;
  
  // Security Configuration
  static const String apiKeyHeader = 'X-API-Key';
  static const String authorizationHeader = 'Authorization';
  
  // Response Codes
  static const String successCode = '0';
  static const String pendingCode = '1';
  static const String failedCode = '2';
  
  // Error Messages
  static const Map<String, String> errorMessages = {
    '100': 'Invalid credentials',
    '101': 'Insufficient balance',
    '102': 'Invalid phone number',
    '103': 'Transaction limit exceeded',
    '104': 'Service temporarily unavailable',
    '105': 'Duplicate transaction',
    '106': 'Invalid amount',
    '107': 'Account blocked',
    '108': 'Network error',
    '109': 'Timeout error',
  };
  
  // Validate configuration
  static bool validateConfig() {
    if (isProduction) {
      return prodBaseUrl.isNotEmpty && 
             prodUsername.isNotEmpty && 
             prodPassword.isNotEmpty &&
             prodShortCode.isNotEmpty;
    }
    return testBaseUrl.isNotEmpty && 
           testUsername.isNotEmpty && 
           testPassword.isNotEmpty &&
           testShortCode.isNotEmpty;
  }
  
  // Get current environment name
  static String get environmentName => isProduction ? 'Production' : 'Test';
  
  // Log configuration (for debugging, remove sensitive data in production)
  static Map<String, dynamic> getConfigInfo() {
    return {
      'environment': environmentName,
      'baseUrl': baseUrl,
      'shortCode': shortCode,
      'username': username,
      // Never log passwords in production
      'passwordConfigured': password.isNotEmpty,
      'configValid': validateConfig(),
    };
  }
}
