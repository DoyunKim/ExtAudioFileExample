//
//  ExtAudioFileExampleAppDelegate.m
//  ExtAudioFileExample
//
//  Created by Lucius Kwok on 11/26/10.
//  Copyright 2010 Felt Tip Inc. All rights reserved.
//

#import "ExtAudioFileExampleAppDelegate.h"
#import "ExampleAudioFile.h"
#import "ExampleTableView.h"


@implementation ExtAudioFileExampleAppDelegate

@synthesize window, tableView, bitratePopup;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	files = [[NSMutableArray alloc] init];

	// Enable receiving dragged files in window.
	[self.window registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}

- (BOOL)openURL:(NSURL *)url {
	ExampleAudioFile *file = nil;
	
	NS_DURING
	{
		file = [[[ExampleAudioFile alloc] initWithFileToOpen:url] autorelease];
		if (file != nil) {
			[files addObject:file];
			[tableView reloadData];
		}
	}
	NS_HANDLER
	{
		file = nil;
	}
	NS_ENDHANDLER
	
	return file != nil;
}

- (IBAction)openDocument:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:YES];
	NSInteger result  = [panel runModal];
	if (result == NSFileHandlingPanelOKButton) {
		for (NSURL *url in [panel URLs]) {
			[self openURL:url];
		}
	}
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
	NSURL *url = [NSURL fileURLWithPath:filename];
	return [self openURL:url];
}

- (IBAction)convertToAAC:(id)sender {
	const AudioFileTypeID kOutputFileType = kAudioFileM4AType;
	NSString *kOutputFileExtension = @"m4a";
	NSString *destinationPath = [@"~/Desktop/" stringByStandardizingPath];

	// Save an AAC version of the files to desktop.
	while (files.count > 0) {
		ExampleAudioFile *inputFile = [files objectAtIndex:0];
		NSString *name = [inputFile.filename stringByDeletingPathExtension];
		name = [name stringByAppendingPathExtension:kOutputFileExtension];
		NSString *destinationFile = [destinationPath stringByAppendingPathComponent:name];
		
		// Set up client data format to the "canonical" format
		AudioStreamBasicDescription clientDataFormat = [inputFile canonicalDataFormat];;
		[inputFile setClientDataFormat:clientDataFormat];
		
		// Set up output file data format
		AudioStreamBasicDescription outputDataFormat;
		outputDataFormat.mSampleRate		= inputFile.sampleRate;
		outputDataFormat.mFormatID			= kAudioFormatMPEG4AAC;
		outputDataFormat.mFormatFlags		= 0;
		outputDataFormat.mBytesPerFrame	= 0;
		outputDataFormat.mFramesPerPacket	= 0;
		outputDataFormat.mBytesPerPacket	= 0;
		outputDataFormat.mChannelsPerFrame= inputFile.numberChannels;
		outputDataFormat.mBitsPerChannel	= 0;
		outputDataFormat.mReserved			= 0;
		
		// Create an audio file for writing
		NSURL *outputURL = [NSURL fileURLWithPath:destinationFile];
		ExampleAudioFile *outputFile = [[ExampleAudioFile alloc] initWithFileToCreate:outputURL fileType:kOutputFileType streamDescription:&outputDataFormat];
		[outputFile setClientDataFormat:clientDataFormat];
		
		// Set bit rate.
		NSUInteger bitRate = [bitratePopup selectedTag];
		if (bitRate > 0) {
			[outputFile setBitRate:bitRate];
		}
		
		// Loop
		const NSUInteger kNumFrames = 2048;
		NSData *data = [inputFile readDataWithNumberFrames:kNumFrames];
		while ([data length] > 0) {
			[outputFile writeData:data];
			data = [inputFile readDataWithNumberFrames:kNumFrames];
		}
		
		[outputFile release];
		[files removeObject:inputFile];
	}
	[tableView reloadData];
}

#pragma mark Table View

- (NSInteger) numberOfRowsInTableView:(NSTableView*)view {
	return files.count;
}

- (id) tableView:(NSTableView *)view objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)rowIndex 
{
	ExampleAudioFile *file = [files objectAtIndex:rowIndex];
	return [file valueForKey:[column identifier]];
}

- (void)tableViewDelete:(ExampleTableView *)aView {
	NSIndexSet *selRows = [aView selectedRowIndexes];
	int i = files.count - 1;
	while (i >= 0) {
		if ([selRows containsIndex:i]) {
			[files removeObjectAtIndex:i];
		}
		i--;
	}
	[aView deselectAll:nil];
	[aView reloadData];
}

#pragma mark Dragging

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
	NSPasteboard *pboard;
	NSDragOperation sourceDragMask;
	
	sourceDragMask = [sender draggingSourceOperationMask];
	pboard = [sender draggingPasteboard];
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		return NSDragOperationCopy;
	}
	return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	NSPasteboard *pboard = [sender draggingPasteboard];
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		NSArray *draggedFiles = [pboard propertyListForType:NSFilenamesPboardType];
		for (NSString *file in draggedFiles) {
			NSURL *url = [NSURL fileURLWithPath:file];
			[self openURL:url];
		}
	}
	return YES;
}


@end
