//
//  AppDelegate.m
//  iTunes Play Button Patch
//
//  Created by Farhan Ahmad on 11/12/14.
//  Copyright (c) 2014 thebitguru. All rights reserved.
//

#import "AppDelegate.h"
#import "Patcher.h"
#import "RcdFile.h"
#import "AboutWindowController.h"
#import "GradientView.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSTextField *osVersion;
@property (weak) IBOutlet NSButton *restoreFromBackupButton;
@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSImageView *logoImage;
@property (weak) IBOutlet GradientView *topBackground;

- (IBAction)showInFinderMenu:(id)sender;
- (IBAction)aboutMenuItemClicked:(id)sender;
- (IBAction)refreshButtonClicked:(id)sender;
- (IBAction)restoreFromBackupButtonClicked:(id)sender;
- (IBAction)patchButtonClicked:(id)sender;
@end

@implementation AppDelegate {
    Patcher * _patcher;
    AboutWindowController * _aboutWindowController;
    NSFileCoordinator * _fileCoordinator;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _patcher = [[Patcher alloc] init];
    [_osVersion setStringValue:[[NSProcessInfo processInfo] operatingSystemVersionString]];
    [self refreshView];
    
    [_logoImage setImage:[NSImage imageNamed:@"logo.png"]];
    
    [_topBackground setEndingColor:[NSColor colorWithCalibratedRed:38.0/255 green:90.0/255 blue:158.0/255 alpha:1.0]];
    [_topBackground setStartingColor:[NSColor colorWithCalibratedRed:48.0/255 green:118.0/255 blue:209.0/255 alpha:1.0]];
    [_topBackground setAngle:270];
    [_topBackground setNeedsDisplay:YES];
    
    // TODO: Figure out how to hookup the directory watch.
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

// Enables/disables the "Show in Finder" menu.
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if ([_tableView selectedRow] == -1) {
        return NO;
    } else {
        return YES;
    }
}

- (IBAction)showInFinderMenu:(id)sender {
    NSInteger selectedRow = [_tableView selectedRow];
    if (selectedRow == -1) return;
    NSArray * fileURLs = [NSArray arrayWithObjects:[[[_patcher files] objectAtIndex:selectedRow] fileUrl], nil];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
}

- (void) refreshView {
    [_patcher reloadFiles];
    [_tableView reloadData];
    if ([_patcher isMainFilePatched]) {
        [_status setStringValue:@"Patched."];
    } else {
        [_status setStringValue:@"Unpatched."];
    }
    
    [_restoreFromBackupButton setEnabled:[_patcher backupPresent]];
}

- (IBAction)restoreFromBackupButtonClicked:(id)sender {
}

- (IBAction)patchButtonClicked:(id)sender {
    NSAlert * alert = [[NSAlert alloc] init];
    [alert setMessageText:@"You will now be asked for administrator password twice, since rcd file is in a privileged location this access is necessary to apply the patch."];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    if ([alert runModal] == NSAlertSecondButtonReturn) {
        return;
    }

    NSError * error;
    @try {
        [_patcher patchFile:error];
    }
    @catch (NSException *exception) {
        NSAlert * alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Unexpected Error"];
        [alert setInformativeText:[exception description]];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        NSLog(@"Problem running task: %@", [exception description]);
    }
    @finally {
    }

    if (error != NULL) {
        NSLog(@"%@", [error description]);
    }
    [self refreshView];
}

- (IBAction)aboutMenuItemClicked:(id)sender {
    if (!_aboutWindowController) {
        _aboutWindowController = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindow"];
    }
    [[NSApplication sharedApplication] runModalForWindow:[_aboutWindowController window]];
}

- (IBAction)refreshButtonClicked:(id)sender {
    [self refreshView];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[_patcher files] count];
}

- (id)tableView:(NSTableView *)tableView
            objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)rowIndex {
    RcdFile * item = [[_patcher files] objectAtIndex:rowIndex];
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"filename"]) {
        return [[item name] copy];
    } else if ([identifier isEqualToString:@"md5sum"]) {
        return [[item md5sum] copy];
    } else if ([identifier isEqualToString:@"comments"]) {
        return [[item comments] copy];
    } else {
        return @"COLUMN ID NOT FOUND";
    }
}
@end
