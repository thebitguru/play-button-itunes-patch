//
//  AppDelegate.m
//  iTunes Play Button Patch
//
//  Created by Farhan Ahmad on 11/12/14.
//  Copyright (c) 2014 Farhan Ahmad. All rights reserved.
//

#import "AppDelegate.h"
#import "Patcher.h"
#import "RcdFile.h"
#import "AboutWindowController.h"
#import "GradientView.h"
@import QuartzCore;

@interface AppDelegate ()

@property (weak) IBOutlet NSTextField *osVersion;
@property (weak) IBOutlet NSButton *restoreFromBackupButton;
@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSImageView *logoImage;
@property (weak) IBOutlet GradientView *topBackground;
@property (weak) IBOutlet NSTextField *commandLineToolsStatus;
@property (weak) IBOutlet NSButton *installXcodeCommandLineToolsButton;

- (IBAction)installXcodeCommandLineToolsButtonClicked:(id)sender;
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
    NSDateFormatter * _dateFormatter;
    BOOL _lastCommandLineToolStatus;
    BOOL _loadedOnce;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _dateFormatter = [[NSDateFormatter alloc] init];
//    [_dateFormatter setDateFormat:@"MM/dd/Y h:mm:ss a"];
    [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    _lastCommandLineToolStatus = false;
    _loadedOnce = false;
    _patcher = [[Patcher alloc] init];
    [_osVersion setStringValue:[[NSProcessInfo processInfo] operatingSystemVersionString]];
    [_logoImage setImage:[NSImage imageNamed:@"logo.png"]];
    
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [_window setTitle:[NSString stringWithFormat:@"%@ - %@", [_window title], version]];
    [_titleTextField setStringValue:[NSString stringWithFormat:@"%@ - %@", [_titleTextField stringValue], version]];
    
    [_topBackground setEndingColor:[NSColor colorWithCalibratedRed:38.0/255 green:90.0/255 blue:158.0/255 alpha:1.0]];
    [_topBackground setStartingColor:[NSColor colorWithCalibratedRed:48.0/255 green:118.0/255 blue:209.0/255 alpha:1.0]];
    [_topBackground setAngle:270];
    [_topBackground setNeedsDisplay:YES];
    
    // TODO: Figure out how to hookup the directory watch.
    
    
    // Yosemite+ styling.
    if ([NSVisualEffectView class]) {
        [_window setStyleMask:[_window styleMask] | NSFullSizeContentViewWindowMask];
        [_window setTitleVisibility:NSWindowTitleHidden];
        [_window setTitlebarAppearsTransparent:YES];
    }
    
    [self refreshView];
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

- (IBAction)installXcodeCommandLineToolsButtonClicked:(id)sender {
    [self installXcodeCommandLineTools];
}

- (void) installXcodeCommandLineTools {
    NSAlert * alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Xcode command line tools are required for signing the modified rcd file.  Without signing OS X will keep complaining that the signature is invalid.\n\nKicking off Xcode command line tools install, please follow the instructions and click the Refresh button in this app once the install has finished."];
    [alert addButtonWithTitle:@"OK, kick it off..."];
    [alert addButtonWithTitle:@"No, don't install"];
    if ([alert runModal] == NSAlertSecondButtonReturn) {
        return;
    }
    
    // Kickoff the install.
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/xcode-select" arguments:@[@"--install"]];
}

- (IBAction)showInFinderMenu:(id)sender {
    NSInteger selectedRow = [_tableView selectedRow];
    if (selectedRow == -1) return;
    // TODO:
//    [[NSWorkspace sharedWorkspace]
//     selectFile:[[[[_patcher files] objectAtIndex:selectedRow] fileUrl] absoluteString]
//     inFileViewerRootedAtPath:@""];
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
    
    if ([[_patcher backupFiles] count] > 0) {
        [_restoreFromBackupButton setEnabled:true];
        [_restoreFromBackupButton setToolTip:@"Backups found, ready to restore."];
    } else {
        [_restoreFromBackupButton setToolTip:@"No backup found."];
        [_restoreFromBackupButton setEnabled:false];
    }
    
    
    // Animate the updated status label.
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D forward = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D back = CATransform3DMakeScale(0.8, 0.8, 1);
    CATransform3D forward2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D back2 = CATransform3DMakeScale(0.9, 0.9, 1);
    [animation setValues:[NSArray arrayWithObjects:
                       [NSValue valueWithCATransform3D:CATransform3DIdentity],
                       [NSValue valueWithCATransform3D:forward],
                       [NSValue valueWithCATransform3D:back],
                       [NSValue valueWithCATransform3D:forward2],
                       [NSValue valueWithCATransform3D:back2],
                       [NSValue valueWithCATransform3D:CATransform3DIdentity],
                       nil]];
    [animation setDuration:0.5];
    [[_status layer] addAnimation:animation forKey:@"updateAnimation"];
    
    // Animate the command line tools status only if it has changed.
    if ((_lastCommandLineToolStatus != [_patcher areCommandLineToolsInstalled]) || !_loadedOnce) {
        [[_commandLineToolsStatus layer] addAnimation:animation forKey:@"updateAnimation"];
    }
    _loadedOnce = true;
    _lastCommandLineToolStatus = [_patcher areCommandLineToolsInstalled];
    [_installXcodeCommandLineToolsButton setEnabled:!_lastCommandLineToolStatus];
    
    if ([_patcher areCommandLineToolsInstalled]) {
        [_commandLineToolsStatus setStringValue:@"Installed."];
        [_installXcodeCommandLineToolsButton setToolTip:@"Already installed."];
    } else {
        [_commandLineToolsStatus setStringValue:@"Not installed."];
        [_installXcodeCommandLineToolsButton setToolTip:@"Click to install..."];
    }
    
//    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//    [animation setDuration:0.25];
//    [animation setFromValue:[NSNumber numberWithFloat:0]];
//    [animation setToValue:[NSNumber numberWithFloat:2 * M_PI]];
//    [[_status layer] addAnimation:animation forKey:animation.keyPath];
    
    
//    CALayer *layer = [_status layer];
//    CATransform3D transform = CATransform3DIdentity;
//    transform.m34 = 1.0 / -50;
//    layer.transform = transform;
//    
//    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
//    animation.values = [NSArray arrayWithObjects:
//                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 0 * M_PI / 2, 100, 1, 100)],
//                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 1 * M_PI / 2, 100, 1, 100)],
//                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 1 * M_PI / 2, 100, 1, 100)],
//                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 1 * M_PI / 2, 100, 1, 100)],
//                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 4 * M_PI / 2, 100, 1, 100)],
//                        nil];
//    animation.duration = 1;
//    [layer addAnimation:animation forKey:animation.keyPath];
    
//    [[_status layer] setTransform:transform];
    
}

- (IBAction)restoreFromBackupButtonClicked:(id)sender {
    RcdFile * fileToRestore = nil;
    
    // If there are multiple backup files then decide which one to use.
    if ([[_patcher backupFiles] count] > 1) {
        NSAlert * alert = [[NSAlert alloc] init];
        
        // Find latest backup file.
        RcdFile * latestFile = nil;
        for (RcdFile * file in [_patcher backupFiles]) {
            if (latestFile == nil) {
                latestFile = file;
                continue;
            }
            
            if ([[file dateModified] isGreaterThan:[latestFile dateModified]]) {
                latestFile = file;
            }
        }
        
        if ([_tableView selectedRow] != -1) {
            RcdFile * selectedFile = [[_patcher files] objectAtIndex:[_tableView selectedRow]];
            // If the user has already selected a backup file then we confirm a few things.
            if ([selectedFile isBackupFile]) {
                // If the selected file is older than the *latest* backup file then confirm.
                if ([[selectedFile fileUrl] isEqualTo:[latestFile fileUrl]] == false) {
                    [alert setMessageText:[NSString
                                           stringWithFormat:@"The backup file that you have selected (%@) is not the latest backup file (%@), are you sure you want to restore from an older backup file?",
                                           [[selectedFile fileUrl] lastPathComponent],
                                           [[latestFile fileUrl] lastPathComponent]]];
                    [alert addButtonWithTitle:@"Yes, restore from the older version"];
                    [alert addButtonWithTitle:@"No, stop, I am going to select a different file"];
                    if ([alert runModal] == NSAlertSecondButtonReturn) {
                        return;
                    } else {
                        fileToRestore = selectedFile;
                    }
                } else {
                    // Otherwise, this is the latest file so we don't need to check anything.
                    fileToRestore = selectedFile;
                }
            }
        }
        
        if (fileToRestore == nil) {
            // Otherwise, they haven't selected a specific file so confirm that they would like to restore from
            // the latest file.
            alert = [[NSAlert alloc] init];
            [alert setMessageText:[NSString
                                   stringWithFormat:@"There are multiple backup files, would you like to restore the latest one (%@)?",
                                   [[latestFile fileUrl] lastPathComponent]]];
            [alert addButtonWithTitle:@"Yes"];
            [alert addButtonWithTitle:@"No, stop"];
            if ([alert runModal] == NSAlertSecondButtonReturn) {
                alert = [[NSAlert alloc] init];
                [alert setMessageText:@"In that case select a specific backup file from the list and click the restore button again."];
                [alert addButtonWithTitle:@"OK"];
                [alert runModal];
                return;
            } else {
                fileToRestore = latestFile;
            }
        }
    } else {
        fileToRestore = [[_patcher backupFiles] objectAtIndex:0];
    }
    
    // Finally restore from the decided backup file.
    @try {
        [_patcher restoreFromBackupFile:fileToRestore];
    }
    @catch (NSException *exception) {
        NSAlert * alert = [[NSAlert alloc] init];
        [alert setInformativeText:[exception description]];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        NSLog(@"Problem restoring from backup: %@", [exception description]);
    }
    [self refreshView];
}

- (IBAction)patchButtonClicked:(id)sender {
    NSAlert * alert = [[NSAlert alloc] init];
    // Only do this if not already installed.
    if (![_patcher areCommandLineToolsInstalled]) {
        [alert setMessageText:@"Xcode command line tools are required for signing the modified rcd file.  Without signing OS X will keep complaining that the signature is invalid.\n\nWould you like to install Xcode command line tools?"];
        [alert addButtonWithTitle:@"Yes, install Xcode command line tools"];
        [alert addButtonWithTitle:@"No, I don't want to patch"];
        if ([alert runModal] == NSAlertSecondButtonReturn) {
            return;
        } else {
            [self installXcodeCommandLineTools];
            return;
        }
    }
    
    [alert setMessageText:@"You will now be asked for administrator password **twice**, since rcd file is in a privileged location this access is necessary to apply the patch."];
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
        [self refreshView];
        return;
    }

    if (error != NULL) {
        NSLog(@"%@", [error description]);
        [self refreshView];
        return;
    }
    
    // File was patched successfully.
    [self refreshView];
    alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Patch Applied"];
    [alert setInformativeText:@"The patch was applied successfully.\n\nYou only have to do this once per Mac OS X upgrade."];
    [alert addButtonWithTitle:@"Excellent, take me to the project website now!"];
    [alert addButtonWithTitle:@"Excellent, I am all set!"];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.thebitguru.com/projects/iTunesPatch?utm_source=guiapp&utm_medium=guiapp&utm_campaign=successful-patch"]];
    }
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
    } else if ([identifier isEqualToString:@"dateModified"]) {
        return [_dateFormatter stringFromDate:[item dateModified]];
    } else {
        return @"COLUMN ID NOT FOUND";
    }
}
@end
