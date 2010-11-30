//
//  ExampleTableView.h
//  ExtAudioFileExample
//
//  Created by Lucius Kwok on 11/16/10.
//  Copyright 2010 Felt Tip Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ExampleTableView : NSTableView {

}

@end

@protocol SoundTableViewDelegate
- (void)tableViewDelete:(ExampleTableView *)aView;
@end