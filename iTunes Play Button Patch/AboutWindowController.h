//
//  AboutWindowController.h
//  iTunes Play Button Patch
//
//  Created by Farhan Ahmad on 11/13/14.
//  Copyright (c) 2014 thebitguru. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutWindowController : NSWindowController <NSWindowDelegate>

- (void)windowWillClose:(NSNotification *)notification;

@end
