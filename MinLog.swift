import Foundation

open class MinLog {
  
  enum LoggingType: String {
    case verbose = "VERBOSE"
    case debug = "DEBUG"
    case error = "ERROR"
    case info = "INFORMATION"
    case warn = "WARNING"
  }
  
  
  /// Initialiser
  public init() {}
  
  /// Get File Name
  /// - Parameter filePath: File Path String
  /// - Returns: File Name
  private static func getFileName(filePath: String) -> String {
    return filePath.components(separatedBy: "/").last!
  }
  
  /// Verbose Logging
  /// - Parameter message: Message String
  open class func v(
    _ message: String,
    filePath: String = #file,
    functionName: String = #function,
    lineNumber: Int = #line,
    columnNumber: Int = #column
  ){
    let fileName = MinLog.getFileName(filePath: filePath)
    let loggingType = LoggingType.verbose.rawValue
    debugPrint("👄 \(loggingType): \(fileName) - \(functionName) at line \(lineNumber)[\(columnNumber)]: \(message)")
  }
  
  /// Debug Logging
  /// - Parameter message: Message String
  open class func d(
    _ message: String,
    filePath: String = #file,
    functionName: String = #function,
    lineNumber: Int = #line,
    columnNumber: Int = #column
  ){
    let fileName = MinLog.getFileName(filePath: filePath)
    let loggingType = LoggingType.debug.rawValue
    debugPrint("🧑‍💻 \(loggingType): \(fileName) - \(functionName) at line \(lineNumber)[\(columnNumber)]: \(message)")
  }
  
  /// Info Logging
  /// - Parameter message: Message String
  open class func i(
    _ message: String,
    filePath: String = #file,
    functionName: String = #function,
    lineNumber: Int = #line,
    columnNumber: Int = #column
  ){
    let fileName = MinLog.getFileName(filePath: filePath)
    let loggingType = LoggingType.info.rawValue
    debugPrint("📙 \(loggingType): \(fileName) - \(functionName) at line \(lineNumber)[\(columnNumber)]: \(message)")
  }
  
  /// Warning Logging
  /// - Parameter message: Message String
  open class func w(
    _ message: String,
    filePath: String = #file,
    functionName: String = #function,
    lineNumber: Int = #line,
    columnNumber: Int = #column
  ){
    let fileName = MinLog.getFileName(filePath: filePath)
    let loggingType = LoggingType.warn.rawValue
    debugPrint("🔔 \(loggingType): \(fileName) - \(functionName) at line \(lineNumber)[\(columnNumber)]: \(message)")
  }
  
  /// Error Logging
  /// - Parameter message: Message String
  open class func e(
    _ message: String,
    filePath: String = #file,
    functionName: String = #function,
    lineNumber: Int = #line,
    columnNumber: Int = #column
  ){
    let fileName = MinLog.getFileName(filePath: filePath)
    let loggingType = LoggingType.error.rawValue
    debugPrint("❌ \(loggingType): \(fileName) - \(functionName) at line \(lineNumber)[\(columnNumber)]: \(message)")
  }
}
