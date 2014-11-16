//
//  Patcher.h
//  iTunes Play Button Patch
//
//  Created by Farhan Ahmad on 11/12/14.
//  Copyright (c) 2014 thebitguru. All rights reserved.
//

#import <Foundation/Foundation.h>

//static NSString * const RCD_PATH = @"/Users/thebitguru/Documents/Development/Projects/iTunes Play Button Patch/rcd";
static NSString * const RCD_PATH = @"/System/Library/CoreServices/rcd.app/Contents/MacOS/";

@interface Patcher : NSObject

@property NSMutableArray* files;
@property BOOL backupPresent;
@property BOOL isMainFilePatched;

- (id) init;
- (BOOL) isFilePatched: (NSString *) filePath;
- (void) reloadFiles;
- (void) patchFile: (NSError *) error;

@end