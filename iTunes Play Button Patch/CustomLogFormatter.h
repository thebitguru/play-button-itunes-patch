//
//  CustomLogFormatter.h
//  Play Button iTunes Patch
//
// Based on https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Documentation/CustomFormatters.md

#import <Cocoa/Cocoa.h>

@interface CustomLogFormatter : NSObject <DDLogFormatter>
{
    int loggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}
@end
