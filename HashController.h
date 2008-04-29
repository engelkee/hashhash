//
//  HashController.h
//  HashHash
//
//  Created by Dominik Gwosdek on 11.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HashController : NSObject {
	IBOutlet NSTextField *hashTextField;
	IBOutlet NSWindow *appWindow;
	IBOutlet NSProgressIndicator *progress;
	NSString *filePath;
}

- (IBAction)copyToClipBoard:(id)sender;
- (void)generateHash;
@end
