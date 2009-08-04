//
//  HashController.h
//  HashHash
//
//  Created by Dominik Gwosdek on 11.04.08.
//  Copyright 2008 Dominik Gwosdek. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HashController : NSObject {
	IBOutlet NSTextField *hashTextField;
	IBOutlet NSTextField *shaTextField;
	IBOutlet NSWindow *appWindow;
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSTextField *progressTextField;
	NSString *filePath;
}

- (IBAction)copyToClipBoard:(id)sender;
- (IBAction)openFile:(id)sender;
- (void)generateHash;
@end
