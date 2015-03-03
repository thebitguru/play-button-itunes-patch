//
//  CustomLogFormatter.m
//  Play Button iTunes Patch
//
// Based on https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Documentation/CustomFormatters.md

#import "CustomLogFormatter.h"
#import "DDLog.h"
#import <Foundation/Foundation.h>

@implementation CustomLogFormatter

- (id)init {
    if((self = [super init]))
    {
        threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
        [threadUnsafeDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS"];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;

    switch (logMessage->_flag)
    {
        case DDLogFlagError   : logLevel = @"ERROR"; break;
        case DDLogFlagWarning : logLevel = @"WARNING"; break;
        case DDLogFlagInfo    : logLevel = @"INFO"; break;
        case DDLogFlagDebug   : logLevel = @"DEBUG"; break;
        default               : logLevel = @"VERBOSE"; break;
    }
    
    NSString *dateAndTime = [threadUnsafeDateFormatter stringFromDate:(logMessage->_timestamp)];
    return [NSString stringWithFormat:@"%@ | %@ | %@:%lu - %@\n", dateAndTime, logLevel, logMessage->_fileName, logMessage->_line, logMessage->_message];
}

- (void)didAddToLogger:(id <DDLogger>)logger {
    loggerCount++;
    NSAssert(loggerCount <= 1, @"This logger isn't thread-safe");
}

- (void)willRemoveFromLogger:(id <DDLogger>)logger {
    loggerCount--;
}

@end
