//
//  ExtAudioFileExampleAppDelegate.h
//  ExtAudioFileExample
//
//  Created by Lucius Kwok on 11/26/10.
//  Copyright 2010 Felt Tip Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ExtAudioFileExampleAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
	NSTableView *tableView;
	NSPopUpButton *bitratePopup;
	
	NSMutableArray *files;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet NSPopUpButton *bitratePopup;

- (IBAction)openDocument:(id)sender;
- (IBAction)convertToAAC:(id)sender;

@end
