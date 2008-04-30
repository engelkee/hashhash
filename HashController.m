//
//  HashController.m
//  HashHash
//
//  Created by Dominik Gwosdek on 11.04.08.
//  Copyright 2008 Dominik Gwosdek. All rights reserved.
//

#import "HashController.h"
//#include <openssl/md5.h>

@implementation HashController

- (id)init
{
	self = [super init];
	if (self != nil) {
		NSLog(@"Init");
	}
	return self;
}

- (void)awakeFromNib {
	[appWindow registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil]];
}


- (IBAction)copyToClipBoard:(id)sender {
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
	[pb setString:[hashTextField stringValue] forType:NSStringPboardType];
	NSLog(@"TF Value: %@", [hashTextField stringValue]);
}

- (void)generateHash {
	NSLog(@"generate hash with file: %@", filePath);
	[progress startAnimation:self];
	NSData *data;
	NSTask *task = [[NSTask alloc] init];
	NSPipe *pipe = [[NSPipe alloc] init];
	[task setLaunchPath:@"/sbin/md5"];
	[task setArguments:[NSArray arrayWithObjects:@"-q", filePath, nil]];
	[task setStandardOutput:pipe];
	NSFileHandle *fh = [pipe fileHandleForReading];
	NSLog(@"launchpath: %@", [task launchPath]);
	[task launch];
	
	while ((data = [fh availableData]) && [data length]) {
		NSLog(@"data: %@", data);
		NSString *outString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSLog(@"String: %@", outString);
		[hashTextField setStringValue:outString];
	}
	
	[task waitUntilExit];
//	NSLog(@"Data: %@", data);
//	NSString *outString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[progress stopAnimation:self];
	[pipe release];
	[task release];
}

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
	NSLog(@"dragging entered");
	if ([sender draggingSource] != self) {
		return NSDragOperationCopy;
	}
	return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSLog(@"perform drag operation");
	NSPasteboard *pb = [sender draggingPasteboard];
	if ( [[pb types] containsObject:NSFilenamesPboardType] ) {
		filePath = [[pb propertyListForType:NSFilenamesPboardType] objectAtIndex:0];
		[appWindow setTitle:[filePath lastPathComponent]];
		//[self generateHash:[[pb propertyListForType:NSFilenamesPboardType] objectAtIndex:0]];
		[NSThread detachNewThreadSelector:@selector(generateHash) toTarget:self withObject:nil];
	}
	
    return YES;
}


- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	NSLog(@"dragging exited");
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	NSLog(@"conclude drag operation");
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed {
    return YES;
}

@end
