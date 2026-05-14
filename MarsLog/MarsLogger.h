
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MarsLogLevel) {
    MarsLogLevelDefault = 0,  // 默认信息
    MarsLogLevelDebug   = 1,  // 调试日志
    MarsLogLevelInfo    = 2,  // 重要信息日志
    MarsLogLevelError   = 3   // 错误日志
};

NS_ASSUME_NONNULL_BEGIN

@interface MarsLogger : NSObject

+ (instancetype)sharedLogger;


/// 启动日志
/// - Parameters:
///   - showConsole: 是否控制台输出日志
///   - appPrefix: app前缀
///   - logParentPath: log父目录，如果传nil则默认存到/Library/Cache下
///   - logFileByteSize: 文件大小，单位是 Byte
- (void)prepareLoggerWithShowConsole:(BOOL)showConsole appPrefix:(NSString * _Nonnull)appPrefix logParentPath:(NSString * __nullable)logParentPath logFileByteSize:(uint64_t)logFileByteSize;

/// 关闭日志系统
- (void)unloadLog;


/// 日志路径
- (NSString *)logFolderPath;

/// 返回最新的log文件的完整路径
/// @return 文件的完整路径
- (NSString *)lastLogFilePathName;

/// 倒序返回log文件列表
/// @return 文件列表
- (NSArray *)logFilePathListByReverse;


/// 在异步队列里写 log（Swift调用）
- (void)logWithLevel:(MarsLogLevel)logLevel moduleName:(NSString * _Nonnull)moduleName fileName:(NSString * _Nonnull)fileName lineNumber:(int)lineNumber funcName:(NSString * _Nonnull)funcName message:(NSString * _Nonnull)message;
/// 在异步队列里写 log（OC调用）
- (void)logWithLevel:(MarsLogLevel)logLevel moduleName:(NSString * _Nonnull)moduleName fileName:(const char * _Nonnull)fileName lineNumber:(int)lineNumber funcName:(const char * _Nonnull)funcName format:(NSString * _Nonnull)format, ... NS_FORMAT_FUNCTION(6,7);

/// 立即写 log（Swift调用）
- (void)logImmediatelyWithLevel:(MarsLogLevel)logLevel moduleName:(NSString * _Nonnull)moduleName fileName:(NSString * _Nonnull)fileName lineNumber:(int)lineNumber funcName:(NSString * _Nonnull)funcName message:(NSString * _Nonnull)message;
/// 立即写 log（OC调用）
- (void)logImmediatelyWithLevel:(MarsLogLevel)logLevel moduleName:(NSString * _Nonnull)moduleName fileName:(const char * _Nonnull)fileName lineNumber:(int)lineNumber funcName:(const char * _Nonnull)funcName format:(NSString * _Nonnull)format, ... NS_FORMAT_FUNCTION(6,7);


/// 立即刷新日志保存本地
- (void)flush;


/// 查找符合服务器下发日期日志路徑
- (NSMutableArray *)searchXLogFilesWithStart:(NSTimeInterval)logStartTime endTime:(NSTimeInterval)logEndTime;

@end

NS_ASSUME_NONNULL_END
