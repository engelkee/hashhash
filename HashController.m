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
	[progressTextField setHidden:YES];
	[appWindow registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil]];
}


- (IBAction)copyToClipBoard:(id)sender {
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
	if([sender tag] == 0) {
		[pb setString:[hashTextField stringValue] forType:NSStringPboardType];
	} else if([sender tag] == 1) {
		[pb setString:[shaTextField stringValue] forType:NSStringPboardType];
	}
}

- (IBAction)openFile:(id)sender {
	int result;
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setDelegate:self];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setTitle:@"Choose File"];
	result = [openPanel runModalForDirectory:nil file:nil types:nil];
	
	if(result == NSOKButton) {
		filePath = [[openPanel filenames] objectAtIndex:0];
		[appWindow setTitle:[filePath lastPathComponent]];
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
	[progressTextField setHidden:NO];
	
	NSData* data = [NSData dataWithContentsOfFile:filePath];
	
	// MD5 calculation
	unsigned char md5[16];
	CC_MD5([data bytes], [data length], md5);
	NSString *outString = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
						   md5[0],md5[1],md5[2],md5[3],md5[4],md5[5],md5[6],md5[7],md5[8],md5[9],md5[10],md5[11],md5[12],md5[13],md5[14],md5[15]];
	
	// SHA1 calculation
	unsigned char sha1[20];
	CC_SHA1([data bytes], [data length], sha1);
	NSString *sha1String = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
							sha1[0],sha1[1],sha1[2],sha1[3],sha1[4],sha1[5],sha1[6],sha1[7],sha1[8],sha1[9],sha1[10],sha1[11],sha1[12],sha1[13],sha1[14],sha1[15],sha1[16],sha1[17],sha1[18],sha1[19]];

	[shaTextField setStringValue:sha1String];
	[hashTextField setStringValue:outString];
	
	[progressTextField setHidden:YES];
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
