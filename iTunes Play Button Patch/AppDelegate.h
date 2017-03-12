//
//  AppDelegate.h
//  iTunes Play Button Patch
//
//  Created by Farhan Ahmad on 11/12/14.
//  Copyright (c) 2014 Farhan Ahmad. All rights reserved.
//

#import <Cocoa/Cocoa.h>

static NSString * const URL_SIP_INFO = @"http://thebitguru.com/projects/itunes-patch#sip-info";


@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSWindowDelegate, NSMenuDelegate>

@end

