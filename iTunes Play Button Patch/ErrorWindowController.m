//
//  ErrorWindowController.m
//  Play Button iTunes Patch
//
//  Created by Farhan Ahmad on 3/12/17.
//  Copyright © 2017 thebitguru. All rights reserved.
//

#import "ErrorWindowController.h"
#import "Constants.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "CustomLogFormatter.h"

@interface ErrorWindowController ()

@property IBOutlet NSTextView *errorTextView;

- (IBAction)installCommandLineToolsClicked:(id)sender;
- (IBAction)reportIssueClicked:(id)sender;

@end

@implementation ErrorWindowController {
    NSString * _errorMessage;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    if (_errorMessage) {
        [_errorTextView setString:_errorMessage];
    }
}

- (void) setErrorMessage:(NSString *)errorMessage {
    _errorMessage = errorMessage;
    [_errorTextView setString:_errorMessage];
}


- (IBAction)installCommandLineToolsClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:TriggerCommandLineToolsInstall];
}

- (IBAction)reportIssueClicked:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:TriggerReportIssue];
}

@end
