
#import "MarsLogger.h"
#import <xlog/appender.h>
#import <xlog/xloggerbase.h>


static NSUInteger g_processID = 0;

static uint64_t kMaxXLogFileSize = 1024 * 1024 * 1; // 2017-11-21 改为 1 MB

@interface MarsLogger()
@property (strong, nonatomic) NSDictionary *levelStringDict;
@property (strong, nonatomic) NSString *logParentPath;
@property (strong, nonatomic) NSString *appPrefix;
@end


@implementation MarsLogger


+ (instancetype)sharedLogger {
    static MarsLogger *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MarsLogger alloc] init];
    });
    return manager;
}


/// 启动日志
/// - Parameters:
///   - showConsole: 是否控制台输出日志
///   - appPrefix: app前缀
///   - logParentPath: log父目录，如果传nil则默认存到/Library/Cache下
///   - logFileByteSize: 文件大小，单位是 Byte
- (void)prepareLoggerWithShowConsole:(BOOL)showConsole appPrefix:(NSString *)appPrefix logParentPath:(NSString *)logParentPath logFileByteSize:(uint64_t)logFileByteSize
{
    self.appPrefix = appPrefix;
    self.levelStringDict = @{
        @(MarsLogLevelDefault)    : @"Default",
        @(MarsLogLevelDebug)   : @"Debug",
        @(MarsLogLevelInfo)   : @"Info",
        @(MarsLogLevelError)    : @"Error",
    };
    
    if ([logParentPath length]) {
        _logParentPath = logParentPath;
    }
    
    if (showConsole) {
        xlogger_SetLevel(kLevelDebug);
        mars::xlog::appender_set_console_log(true);
    } else {
        xlogger_SetLevel(kLevelInfo);
        mars::xlog::appender_set_console_log(false);
    }
    
    mars::xlog::appender_set_max_file_size(logFileByteSize ? : kMaxXLogFileSize);
    
    NSString *logPath = [self logFolderPath];
    mars::xlog::XLogConfig config;
    config.mode_ = mars::xlog::kAppenderAsync;
    config.logdir_ = [logPath UTF8String];
    config.nameprefix_ = [self.appPrefix UTF8String];
    mars::xlog::appender_open(config);
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self cleanLogFiles];
    });
}

- (void)cleanLogFiles
{
    NSError* error= nil;
    NSString* logFolder = [self logFolderPath];
    NSArray* logFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logFolder error:&error];
    if (logFiles == nil || [logFiles count] == 0) {
        NSLog(@"Error happened when clearnLogFiles:%@", error);
        return;
    }
    
#ifdef DEBUG
    NSDate* date = [[NSDate date] dateByAddingTimeInterval:-10*24*60*60];
#else
    NSDate* date = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
#endif
    
    for (NSString *logFile in logFiles) {
        
        NSString *logFilePath = [logFolder stringByAppendingPathComponent:logFile];
        NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:logFilePath error:&error];
        if (fileAttr) {
            NSDate *creationDate = [fileAttr valueForKey:NSFileCreationDate];
            if ([creationDate compare:date] == NSOrderedAscending) {
                NSLog(@"[Kiwi:LogExt] cleanLogFiles: %@ will be deleted", logFile);
                [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:&error];
                NSLog(@"[Kiwi:LogExt] cleanLogFiles: %@ was deleted, error number is %ld", logFilePath, (long)error.code);
            }
        }
    }
}

- (void)unloadLog
{
    mars::xlog::appender_close();
}

- (NSString *)logFolderPath
{
    NSString* path = [self getLogPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

- (NSString *)lastLogFilePathName
{
    NSArray *logFileList = [self logFilePathListByReverse];
    return [logFileList lastObject];
}

- (NSArray *)logFilePathListByReverse
{
    NSString *logFolderPath = [self logFolderPath];
    NSError *error = nil;
    NSArray *logFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logFolderPath error:&error];
    if (logFileList == nil || [logFileList count] == 0){
        return nil;
    }
    NSMutableArray *tmpLogFileList = [NSMutableArray new];
    [logFileList enumerateObjectsUsingBlock:^(NSString * logFilePath, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[logFilePath pathExtension] isEqualToString:@"xlog"]) {
            [tmpLogFileList addObject:[logFolderPath stringByAppendingPathComponent:logFilePath]];
        }
    }];
    
    NSArray *array = [tmpLogFileList sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        NSDictionary *firstProperties = [[NSFileManager defaultManager] attributesOfItemAtPath:obj1 error:nil];
        NSDate *firstDate = [firstProperties  objectForKey:NSFileModificationDate];
        NSDictionary *secondProperties = [[NSFileManager defaultManager] attributesOfItemAtPath:obj2 error:nil];
        NSDate *secondDate = [secondProperties objectForKey:NSFileModificationDate];
        return [secondDate compare:firstDate];
    }];
    
    return array;
}

- (void)logWithLevel:(MarsLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(const char *)fileName lineNumber:(int)lineNumber funcName:(const char *)funcName format:(NSString *)format, ... NS_FORMAT_FUNCTION(6,7) {
    if (format == nil || ![format isKindOfClass:[NSString class]]) {
        NSAssert(format, @"参数不能为空");
        format = @"";
    }
    NSString *message = @"";
    if (format.length > 0) {
        va_list argList;
        va_start(argList, format);
        message = [[NSString alloc] initWithFormat:format arguments:argList];
        va_end(argList);
    }
    [self logWithLevel:logLevel moduleName:moduleName fileName:[NSString stringWithUTF8String:fileName] lineNumber:lineNumber funcName:[NSString stringWithUTF8String:funcName] message:message];
}

- (void)logWithLevel:(MarsLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(NSString *)fileName lineNumber:(int)lineNumber funcName:(NSString *)funcName message:(NSString *)message
{
    struct timeval time;
    gettimeofday(&time, NULL);
    
    uintptr_t tid = (uintptr_t)[NSThread currentThread];
    
    // 质量监控中心检测到大量调用 xlog 可能会导致卡顿，用异步队列避免阻塞主线程
    dispatch_async([self loggerQueue], ^{
        [self writeLogWithLevel:logLevel moduleName:moduleName fileName:fileName lineNumber:lineNumber funcName:funcName message:message time:time tid:tid];
    });
}

- (void)logImmediatelyWithLevel:(MarsLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(const char *)fileName lineNumber:(int)lineNumber funcName:(const char *)funcName format:(NSString *)format, ... NS_FORMAT_FUNCTION(6,7) {
    if (format == nil || ![format isKindOfClass:[NSString class]]) {
        NSAssert(format, @"参数不能为空");
        format = @"";
    }
    NSString *message = @"";
    if (format.length > 0) {
        va_list argList;
        va_start(argList, format);
        message = [[NSString alloc] initWithFormat:format arguments:argList];
        va_end(argList);
    }
    [self logImmediatelyWithLevel:logLevel moduleName:moduleName fileName:[NSString stringWithUTF8String:fileName] lineNumber:lineNumber funcName:[NSString stringWithUTF8String:funcName] message:message];
}

- (void)logImmediatelyWithLevel:(MarsLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(NSString *)fileName lineNumber:(int)lineNumber funcName:(NSString *)funcName message:(NSString *)message
{
    struct timeval time;
    gettimeofday(&time, NULL);
    
    uintptr_t tid = (uintptr_t)[NSThread currentThread];
    
    [self writeLogWithLevel:logLevel moduleName:moduleName fileName:fileName lineNumber:lineNumber funcName:funcName message:message time:time tid:tid];
}

- (BOOL)shouldLog:(MarsLogLevel)level
{
    if (level >= (MarsLogLevel)xlogger_Level()) {
        return YES;
    }
    return NO;
}

- (void)flush
{
    mars::xlog::appender_flush();
}

#pragma mark - private

- (void)writeLogWithLevel:(MarsLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(NSString *)fileName lineNumber:(int)lineNumber funcName:(NSString *)funcName message:(NSString *)message time:(struct timeval)time tid:(uintptr_t)tid
{
    NSString *tag = [NSString stringWithFormat:@"<%@>%@",[self levelStringWithLevel:logLevel], moduleName ? [NSString stringWithFormat:@"<%@>", moduleName] : @""];
    
    XLoggerInfo info;
    info.level = (TLogLevel)logLevel;
    info.tag = tag.UTF8String;
    info.filename = fileName.UTF8String;
    info.func_name = funcName.UTF8String;
    info.line = lineNumber;
    info.timeval = time;
    info.tid = tid;
    info.maintid = (uintptr_t)[NSThread mainThread];
    info.pid = g_processID;
    
    xlogger_Write(&info, message.UTF8String);
}

- (NSString *)levelStringWithLevel:(MarsLogLevel)level
{
    NSString *str = self.levelStringDict[@(level)];
    return str ? : @"UNKNOWN";
}

- (dispatch_queue_t)loggerQueue
{
    static dispatch_queue_t queue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.yy.mobile.huya.xlogger", DISPATCH_QUEUE_SERIAL);
    });
    
    return queue;
}

/// 查找符合服务器下发日期日志路徑
- (NSMutableArray *)searchXLogFilesWithStart:(NSTimeInterval)logStartTime endTime:(NSTimeInterval)logEndTime {
    // check source
    if (logStartTime <= 0 || logEndTime <= 0) return [NSMutableArray array];
    NSArray *logFilePathList = [self logFilePathListByReverse];
    if (!logFilePathList || logFilePathList.count <= 0) return [NSMutableArray array];
    NSMutableArray *logFilePathMArr = [NSMutableArray new];
    NSInteger PushLogsMaxCount = 5;
    // search
    for (NSString *sourceFilePath in logFilePathList) {
        NSDictionary *fileAttrisDict = [[NSFileManager defaultManager] attributesOfItemAtPath:sourceFilePath error:nil];
        NSDate *fileCreationDate = [fileAttrisDict objectForKey:NSFileCreationDate];
        int64_t fileCreateTime = fileCreationDate.timeIntervalSince1970;
        BOOL isAfterEqualStart = logStartTime - fileCreateTime <= 0;
        BOOL isBeforeEqualEnd = fileCreateTime - logEndTime <= 0;
        if (!isAfterEqualStart || !isBeforeEqualEnd) continue;
        if (logFilePathMArr.count == PushLogsMaxCount) break;
        [logFilePathMArr addObject:sourceFilePath];
    }
    return logFilePathMArr.mutableCopy;
}

#pragma mark - log File Path

- (NSString *)getCacheDirectory
{
    do {
        if (_logParentPath)
            break;
        
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if ([directories count] < 1)
            break;
        
        _logParentPath = [directories objectAtIndex:0];
        
        NSUInteger length = [_logParentPath length];
        if (length < 1) {
            _logParentPath = nil;
            break;
        }
        
        if ('/' == [_logParentPath characterAtIndex:length - 1])
            break;
        
        _logParentPath = [_logParentPath stringByAppendingString:@"/"];
    } while (false);
    
    return _logParentPath;
}

- (NSString *)getLogPath
{
    static NSString * kLogDir = @"logs/";
    NSString *cacheDir = [self getCacheDirectory];
    if (cacheDir == nil){
        return nil;
    }
    return [cacheDir stringByAppendingPathComponent:kLogDir];
}


@end
