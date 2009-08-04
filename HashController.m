//
//  HashController.m
//  HashHash
//
//  Created by Dominik Gwosdek on 11.04.08.
//  Copyright 2008 Dominik Gwosdek. All rights reserved.
//

#import "HashController.h"
#include <CommonCrypto/CommonDigest.h>

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

- (IBAction)openFile:(id)sender {
	int result;
//	NSArray *fileTypes = [NSArray arrayWithObject:@"txt"];
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setDelegate:self];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setTitle:@"Choose File"];
	result = [openPanel runModalForDirectory:nil file:nil types:nil];
	
	if(result == NSOKButton) {
		filePath = [[openPanel filenames] objectAtIndex:0];
		[appWindow setTitle:[filePath lastPathComponent]];
		//[self generateHash:[[pb propertyListForType:NSFilenamesPboardType] objectAtIndex:0]];
		[NSThread detachNewThreadSelector:@selector(generateHash) toTarget:self withObject:nil];
	}
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename {
	NSString *ext = [filename pathExtension];
	NSLog(@"%@", ext);
	if([ext isEqualToString:@"app"]) {
		return NO;
	}
	return YES;
}

- (void)generateHash {
	NSLog(@"generate hash with file: %@", filePath);
	[progress startAnimation:self];
	
	unsigned char md5[16];
	
	NSData* data = [NSData dataWithContentsOfFile:filePath];
	CC_MD5([data bytes], [data length], md5);
	NSString *outString = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",md5[0],md5[1],md5[2],md5[3],md5[4],md5[5],md5[6],md5[7],md5[8],md5[9],md5[10],md5[11],md5[12],md5[13],md5[14],md5[15]];
	NSLog(@"hash: %@", outString);
	[hashTextField setStringValue:outString];
	[progress stopAnimation:self];
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
