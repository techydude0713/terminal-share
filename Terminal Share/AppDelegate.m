// AppDelegate.m
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <ScriptingBridge/ScriptingBridge.h>

#import "AppDelegate.h"

static void PrintHelpBanner() {
    NSMutableArray *mutableLines = [NSMutableArray array];
    
    [mutableLines addObjectsFromArray:@[@"airdrop-cli", @"", @"A command-line interface for Airdrop", @""]];
    
    [mutableLines addObjectsFromArray:@[@"Usage:", @"\t$ airdrop-cli /path/to/file1 [/path/to/file2] [/path/to/file3] (etc)", @""]];
    
    [mutableLines addObject:@""];

    [mutableLines addObjectsFromArray:@[@"Original Author:", @"\tMattt Thompson <m@mattt.me>", @""]];
    [mutableLines addObjectsFromArray:@[@"Website:", @"\thttps://github.com/mattt", @""]];
    [mutableLines addObjectsFromArray:@[@"Fork Author:", @"\tJohn Papetti <techydude3@aol.com>", @""]];
    [mutableLines addObjectsFromArray:@[@"Website:", @"\thttps://github.com/jpapetti0713", @""]];

    [mutableLines enumerateObjectsUsingBlock:^(id line, NSUInteger idx, BOOL *stop) {
        printf("%s\n", [line UTF8String]);
    }];
}

static NSArray * NSSharingServiceItemsFromDefaults(NSArray *arguments) {
    NSMutableArray *mutableItems = [NSMutableArray array];
    
    
    for (int i = 1; i < [arguments count]; i++){
        id value = arguments[i];
        if ([[NSFileManager defaultManager]fileExistsAtPath:value]){
            NSURL *fileURL = [NSURL fileURLWithPath:value];
            if (fileURL) {
                [mutableItems addObject:fileURL];
            }

        }
        else{
            NSLog(@"WARNING: \"%@\" is either not valid or found.",value);

        }
    }
    if (mutableItems.count){
        return mutableItems;
    }
    else{
        NSLog(@"ERROR: All files failed to send.");
        exit(EXIT_FAILURE);
    }
    
}

@interface AppDelegate () <NSSharingServiceDelegate>
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    if (arguments.count <= 1) {
        PrintHelpBanner();
        exit(EXIT_FAILURE);
    }
    
    NSSharingService *sharingService = [NSSharingService sharingServiceNamed:NSSharingServiceNameSendViaAirDrop];
    sharingService.delegate = self;
    [sharingService performWithItems:NSSharingServiceItemsFromDefaults(arguments)];
}

#pragma mark - ScriptingBridge

- (BOOL)activateAppWithBundleID:(NSString *)bundleID {
    id app = [SBApplication applicationWithBundleIdentifier:bundleID];
    if (app) {
        [app activate];
        
        return YES;
    } else {
        NSLog(@"Unable to find an application with the specified bundle indentifier.");
        
        return NO;
    }
}

#pragma mark - NSSharingServiceDelegate

- (void)sharingService:(NSSharingService *)sharingService
         didShareItems:(NSArray *)items
{
    exit(EXIT_SUCCESS);
}

- (void)sharingService:(NSSharingService *)sharingService
   didFailToShareItems:(NSArray *)items
                 error:(NSError *)error
{
    exit(EXIT_FAILURE);
}

@end
