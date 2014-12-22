//
//  RcdFile.h
//  A simple structure for saving references to files.
//  iTunes Play Button Patch
//
//  Created by Farhan Ahmad on 11/12/14.
//  Copyright (c) 2014 Farhan Ahmad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RcdFile : NSObject

@property (copy) NSString * name;
@property (copy) NSString * comments;
@property (copy) NSString * md5sum;
@property (copy) NSURL * fileUrl;
@property (copy) NSDate * dateModified;
@property BOOL isPatched;
@property BOOL isBackupFile;

- (id) initWithParams:(NSString *)name
             comments:(NSString *)comments
               md5sum:(NSString *)md5sum
            isPatched:(BOOL)isPatched
         dateModified:(NSDate *) dateModified
              fileUrl:(NSURL *)fileUrl;

@end
