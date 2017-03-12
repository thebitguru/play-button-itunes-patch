//
//  PatchedWindowController.m
//  Play Button iTunes Patch
//
//  Created by Farhan Ahmad on 3/5/17.
//  Copyright © 2017 thebitguru. All rights reserved.
//

#import "PatchedWindowController.h"

@interface PatchedWindowController ()

- (IBAction)showWebsiteButtonClicked:(id)sender;
- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)moreAboutBECMClicked:(id)sender;

@end

@implementation PatchedWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)showWebsiteButtonClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:URL_AFTER_INSTALL]];
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (IBAction)moreAboutBECMClicked:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:URL_BECM_DONATE]];
//    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}


- (IBAction)closeButtonClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}

@end
