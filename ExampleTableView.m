//
//  ExampleTableView.m
//  ExtAudioFileExample
//
//  Created by Lucius Kwok on 11/16/10.
//  Copyright 2010 Felt Tip Inc. All rights reserved.
//

#import "ExampleTableView.h"

@implementation ExampleTableView

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
	}
	return self;
}

#pragma mark Actions

- (IBAction)delete:(id)sender {
	if ([self numberOfSelectedRows] > 0) 
		[(id <SoundTableViewDelegate>) [self delegate] tableViewDelete:self];
}

- (void)deleteBackward:(id)sender {
	[self delete:nil];
}

- (void)deleteForward:(id)sender {
	[self delete:nil];
}

- (void)keyDown:(NSEvent *)event {
	NSString* chars = [event charactersIgnoringModifiers];
	if ([chars length] == 1) {
		unichar c = [chars characterAtIndex:0];
		if (c == NSDeleteCharacter || c == NSDeleteFunctionKey) {
			[self delete:nil];
		}
	}
}	

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem {
	BOOL result = NO;
	
	if ([anItem action] == @selector(delete:)) {
		result = ([self numberOfSelectedRows] > 0);
	} else {
		result = [super validateUserInterfaceItem:anItem];
	}
	return result;
}

@end
