import 'package:logger/logger.dart';
import '../config/oauth_config.dart';

/// Structured logging service for authentication operations
/// 
/// Provides log levels (debug, info, warning, error) with automatic
/// context injection and production-safe logging.
class AuthLogger {
  static final Logger _logger = Logger(
    filter: _ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
  
  /// Log levels
  static const debug = 'DEBUG';
  static const info = 'INFO';
  static const warning = 'WARNING';
  static const error = 'ERROR';
  
  /// Logs a debug message (suppressed in production)
  /// 
  /// Debug messages are only shown in debug mode and are suppressed
  /// in production builds.
  /// 
  /// Parameters:
  ///   - message: The log message
  ///   - context: Optional additional context data
  /// 
  /// Example:
  /// ```dart
  /// AuthLogger.d('Starting authentication', context: {'user': 'test@example.com'});
  /// ```
  static void d(String message, {Map<String, dynamic>? context}) {
    final enrichedMessage = _enrichMessage(message, context);
    _logger.d(enrichedMessage);
  }
  
  /// Logs an info message
  /// 
  /// Info messages are shown in all environments and represent
  /// normal operational events.
  /// 
  /// Parameters:
  ///   - message: The log message
  ///   - context: Optional additional context data
  /// 
  /// Example:
  /// ```dart
  /// AuthLogger.i('User authenticated successfully');
  /// ```
  static void i(String message, {Map<String, dynamic>? context}) {
    final enrichedMessage = _enrichMessage(message, context);
    _logger.i(enrichedMessage);
  }
  
  /// Logs a warning
  /// 
  /// Warning messages indicate potential issues that don't prevent
  /// operation but should be investigated.
  /// 
  /// Parameters:
  ///   - message: The log message
  ///   - context: Optional additional context data
  /// 
  /// Example:
  /// ```dart
  /// AuthLogger.w('Session expiring soon', context: {'expiresIn': '1 hour'});
  /// ```
  static void w(String message, {Map<String, dynamic>? context}) {
    final enrichedMessage = _enrichMessage(message, context);
    _logger.w(enrichedMessage);
  }
  
  /// Logs an error with optional exception
  /// 
  /// Error messages indicate failures that prevent normal operation.
  /// 
  /// Parameters:
  ///   - message: The log message
  ///   - error: Optional exception object
  ///   - stackTrace: Optional stack trace
  ///   - context: Optional additional context data
  /// 
  /// Example:
  /// ```dart
  /// AuthLogger.e(
  ///   'Authentication failed',
  ///   error: exception,
  ///   stackTrace: stackTrace,
  ///   context: {'errorType': 'network'},
  /// );
  /// ```
  static void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final enrichedMessage = _enrichMessage(message, context);
    _logger.e(enrichedMessage, error: error, stackTrace: stackTrace);
  }
  
  /// Logs an authentication event for monitoring
  /// 
  /// Authentication events are logged at info level and include
  /// structured data for monitoring and analytics.
  /// 
  /// Parameters:
  ///   - event: The event name (e.g., 'login_success', 'logout')
  ///   - data: Optional event data
  /// 
  /// Example:
  /// ```dart
  /// AuthLogger.authEvent('login_success', data: {
  ///   'method': 'google',
  ///   'duration': '2.5s',
  /// });
  /// ```
  static void authEvent(String event, {Map<String, dynamic>? data}) {
    final context = {
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
      if (data != null) ...data,
    };
    i('AUTH_EVENT: $event', context: context);
  }
  
  /// Enriches a log message with context
  /// 
  /// Adds automatic context like environment and timestamp
  static String _enrichMessage(String message, Map<String, dynamic>? context) {
    if (context == null || context.isEmpty) {
      return message;
    }
    
    final contextStr = context.entries
        .map((e) => '${e.key}=${e.value}')
        .join(', ');
    
    return '$message [$contextStr]';
  }
}

/// Custom log filter that suppresses debug logs in production
class _ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // In production, suppress debug logs
    if (OAuthConfig.isProduction && event.level == Level.debug) {
      return false;
    }
    
    // Allow all other logs
    return true;
  }
}
