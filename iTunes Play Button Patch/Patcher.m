//
//  Patcher.m
//  iTunes Play Button Patch
//
//  Created by Farhan Ahmad on 11/12/14.
//  Copyright (c) 2014 thebitguru. All rights reserved.
//

#import "Patcher.h"
#import "RcdFile.h"
#import <CommonCrypto/CommonDigest.h>   // Needed for MD5 sum.

@implementation Patcher {
    NSData * _FIND_COMMAND_DATA;
    NSData * _REPLACE_COMMAND_DATA;
    NSFileManager * _fileManager;
}

- (id) init {
    self = [super init];
    if (self) {
        _FIND_COMMAND_DATA    = [@"tell application id \"com.apple.iTunes\" to launch" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
        _REPLACE_COMMAND_DATA = [@"--ll application id \"com.apple.iTunes\" to launch" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
        
        _fileManager = [NSFileManager defaultManager];
        _files = [[NSMutableArray alloc] init];
        
        _backupPresent = false;
        _isMainFilePatched = false;
        [self reloadFiles];
    }
    return self;
}


- (BOOL) isFilePatched: (NSString *) filePath {
    NSData * fileData = [_fileManager contentsAtPath:filePath];
    return [fileData rangeOfData:_FIND_COMMAND_DATA options:kNilOptions range:NSMakeRange(0, [fileData length])].location == NSNotFound;
}

- (void) reloadFiles {
    [_files removeAllObjects];
    
    _backupPresent = false;
    _isMainFilePatched = false;
    NSError * error;
    NSArray * contents = [_fileManager contentsOfDirectoryAtPath:RCD_PATH error:&error];
//    NSArray * contents = [_fileManager subpathsAtPath:RCD_PATH];   // Show subdirectory contents as well.
    if (contents == NULL) {
        return;
    }
    
    BOOL isPatched = false;
    NSString * comments;
    BOOL isDirectory;
    for (NSString * filename in contents) {
        comments = @"";
        
        // Ignore directories.
        if ([_fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", RCD_PATH, filename]
                               isDirectory:&isDirectory] && isDirectory) {
            continue;
        }
        
        NSURL * fileUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", RCD_PATH, filename]];
        if ([filename rangeOfString:@"rcd_backup_" options:NSAnchoredSearch].location != NSNotFound) {
            comments = [comments stringByAppendingString:@"Backup file. "];
            _backupPresent = true;
        }
        
        if ([filename rangeOfString:@"rcd" options:NSAnchoredSearch].location != NSNotFound) {
            isPatched = [self isFilePatched:[fileUrl path]];
            if (isPatched) {
                comments = [comments stringByAppendingString:@"Patched."];
            } else {
                comments = [comments stringByAppendingString:@"Unpatched."];
            }
            
            if ([filename isEqualToString:@"rcd"]) {
                _isMainFilePatched = isPatched;
            }
        } else {
            comments = [comments stringByAppendingString:@"Unrecognized file."];
        }
        
        // Calculate the md5 sum.
        NSString * md5sum = [self calculateMD5Sum:[_fileManager contentsAtPath:[fileUrl path]]];
        
        [_files addObject:[[RcdFile alloc] initWithParams:filename comments:comments md5sum:md5sum isPatched:isPatched fileUrl:fileUrl]];
    }
}


- (NSString *) calculateMD5Sum: (NSData *)fileData {
    unsigned char md5buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5([fileData bytes], (unsigned int)[fileData length], md5buffer);
    
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", md5buffer[i]];
    return output;
}

- (void) patchFile: (NSError *) error {
    NSString * filePath = [NSString stringWithFormat:@"%@/rcd", RCD_PATH];
    NSData * fileData = [_fileManager contentsAtPath:filePath];
    NSMutableData * mutableData = [fileData mutableCopy];
    NSRange foundAt;
    NSRange nextRange = NSMakeRange(0, [fileData length]);
    int numFound = 0;
    while (true) {
        foundAt = [mutableData rangeOfData:_FIND_COMMAND_DATA options:kNilOptions range:nextRange];
        if (foundAt.location == NSNotFound) {
            break;
        }
        numFound += 1;
        [mutableData replaceBytesInRange:foundAt withBytes:[_REPLACE_COMMAND_DATA bytes] length:[_REPLACE_COMMAND_DATA length]];
        NSUInteger after = foundAt.location + foundAt.length;
        nextRange = NSMakeRange(after, [mutableData length] - after);
    }
    
    // Create authorization reference so we don't have to keep asking for user/password.
    AuthorizationExternalForm authExtForm;
    if (![self getAuthorizationExternalForm:&authExtForm]) {
        return;
    }
    
    // Create backup file and a patched version.
    NSDate * now = [[NSDate alloc] init];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd_HH_mm.ss"];
    [self writeDataToProtectedFile:fileData
                          filePath:[NSString stringWithFormat:@"%@/rcd_backup_%@_%@",
                                    RCD_PATH,
                                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                    [dateFormatter stringFromDate:now]]
                       authExtForm:authExtForm];
    
    // Write the updated file.
    NSString * new_file = [NSString stringWithFormat:@"%@/rcd", RCD_PATH];
    [self writeDataToProtectedFile:mutableData filePath:new_file authExtForm:authExtForm];
    
    // Then run the command to sign the newly created file.
    //    [self writeDataToProtectedFile:mutableData filePath:[NSString stringWithFormat:@"%@/rcd_new_unsigned", RCD_PATH] authExtForm:authExtForm];
    [self selfSignFile:[NSString stringWithFormat:@"%@/rcd", RCD_PATH] authExtForm:authExtForm];
}

/*
 * Get an AuthorizationExternalForm with elevated privileges. Returns false if the user
 * canceled the authorization, otherwise, returns true or raises an exception if
 * something went wrong.
 */
- (BOOL) getAuthorizationExternalForm:(AuthorizationExternalForm *)authExtForm {
    AuthorizationRef authRef;
    OSStatus status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authRef);
    if (status != errAuthorizationSuccess) {
        [NSException raise:@"no_auth_ref" format:@"Could not initialize authorization reference (OSStatus = %d).", status];
    }
    
    AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &right};
    AuthorizationFlags flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
    if (AuthorizationCopyRights(authRef, &rights, NULL, flags, NULL) != errAuthorizationSuccess) {      // User canceled.
        return false;
    }
    
    status = AuthorizationMakeExternalForm(authRef, authExtForm);
    if (status != errAuthorizationSuccess) {
        [NSException raise:@"no_auth_ext_form" format:@"Could not create authorization external form (OSStatus = %d).", status];
    }
    return true;
}

- (BOOL) writeDataToProtectedFile:(NSData *)data
                         filePath:(NSString *)filePath
                      authExtForm:(AuthorizationExternalForm)authExtForm {
    NSPipe * writePipe = [[NSPipe alloc] init];
    NSFileHandle * writeHandle = [writePipe fileHandleForWriting];
    NSTask * task = [[NSTask alloc] init];
    
    [task setLaunchPath:@"/usr/libexec/authopen"];
    [task setArguments:@[@"-c", @"-w", @"-extauth", @"-m", @"0755", filePath]];
    [task setStandardInput:writePipe];
    [task launch];
    [writeHandle writeData:[NSData dataWithBytes:authExtForm.bytes length:32]];
    [writeHandle writeData:data];
    [writeHandle closeFile];
    
    return true;
}

// Uses the codesign utility to self sign the given file.
- (BOOL) selfSignFile:(NSString *)filePath
          authExtForm:(AuthorizationExternalForm)authExtForm {
    NSString * output;
    NSString * processErrorDescription;
    BOOL success = [self runProcessAsAdministrator:@"/usr/bin/codesign"
                                     withArguments:@[@"-f", @"-s", @"-", filePath]
                                            output:&output
                                  errorDescription:&processErrorDescription];
    if (!success) {
        [NSException raise:@"no_codesign" format:@"Could not codesign the modified binary."];
    }
    return success;
}


// Used only for signing the file.
// Copied from http://stackoverflow.com/questions/6841937/authorizationexecutewithprivileges-is-deprecated
- (BOOL) runProcessAsAdministrator:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription {
    
    NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"'%@' %@", scriptPath, allArgs];
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    
    // Check errorInfo
    if (! eventResult)
    {
        // Describe common errors
        *errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
        {
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
            *errorDescription = @"The administrator password is required to do this.";
        }
        
        // Set error message from provided message
        if (*errorDescription == nil)
        {
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
            *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }
        
        return NO;
    }
    else
    {
        // Set output to the AppleScript's output
        *output = [eventResult stringValue];
        
        return YES;
    }
}

@end
