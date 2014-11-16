//
//  AboutWindowController.m
//  iTunes Play Button Patch
//
//  Created by Farhan Ahmad on 11/13/14.
//  Copyright (c) 2014 thebitguru. All rights reserved.
//

#import "AboutWindowController.h"

@interface AboutWindowController ()

@end

@implementation AboutWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] stopModal];
}

@end
