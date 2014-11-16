//
//  RcdFile.h
//  A simple structure for saving references to files.
//  iTunes Play Button Patch
//
//  Created by Farhan Ahmad on 11/12/14.
//  Copyright (c) 2014 thebitguru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RcdFile : NSObject

@property (copy) NSString * name;
@property (copy) NSString * comments;
@property (copy) NSString * md5sum;
@property (copy) NSURL * fileUrl;
@property BOOL isPatched;

- (id) initWithParams:(NSString *)name
             comments:(NSString *)comments
               md5sum:(NSString *)md5sum
            isPatched:(BOOL)isPatched
              fileUrl:(NSURL *)fileUrl;

@end
