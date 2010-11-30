//
//  ExampleAudioFile.h
//  ExtAudioFileExample
//
//  Created by Lucius Kwok on 11/26/10.
//  Copyright 2010 Felt Tip Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>


@interface ExampleAudioFile : NSObject {
	ExtAudioFileRef extAudioFileRef;
	
	Float64 sampleRate;
	NSUInteger numberChannels;
	
	NSString *filename;
	NSString *info;
}

@property (assign) Float64 sampleRate;
@property (assign) NSUInteger numberChannels;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *info;

- (id)initWithFileToOpen:(NSURL *)aFile;
- (id)initWithFileToCreate:(NSURL *)aFile fileType:(AudioFileTypeID)fileType streamDescription:(AudioStreamBasicDescription *)description;

- (AudioStreamBasicDescription)fileDataFormat;
- (AudioStreamBasicDescription)clientDataFormat;
- (void)setClientDataFormat:(AudioStreamBasicDescription)asbd;
- (AudioStreamBasicDescription)canonicalDataFormat;
- (AudioConverterRef)audioConverter;
- (void)setBitRate:(UInt32)bitRate;

- (NSData *)readDataWithNumberFrames:(UInt32)length;
- (void)writeData:(NSData *)data;

@end
