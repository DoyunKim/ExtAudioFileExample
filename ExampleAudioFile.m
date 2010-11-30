//
//  ExampleAudioFile.m
//  ExtAudioFileExample
//
//  Created by Lucius Kwok on 11/26/10.
//  Copyright 2010 Felt Tip Inc. All rights reserved.
//

#import "ExampleAudioFile.h"


@implementation ExampleAudioFile
@synthesize sampleRate, numberChannels, filename, info;

- (id)initWithFileToOpen:(NSURL *)aFile {
	self = [super init];
	if (self) {
		OSStatus err;
		CFURLRef url = (CFURLRef) aFile;
		err = ExtAudioFileOpenURL ((CFURLRef) url, &extAudioFileRef);
		NSAssert1 (err == noErr, @"ExtAudioFileOpenURL() error %d", err);
		
		// Get file info.
		AudioStreamBasicDescription fileDataFormat = [self fileDataFormat];
		sampleRate = fileDataFormat.mSampleRate;
		numberChannels = fileDataFormat.mChannelsPerFrame;
		
		self.filename = [aFile lastPathComponent];
		self.info = [NSString localizedStringWithFormat:@"%1.0f Hz, %d channels", sampleRate, numberChannels];
	}
	return self;
}

- (id)initWithFileToCreate:(NSURL *)aFile fileType:(AudioFileTypeID)fileType streamDescription:(AudioStreamBasicDescription *)description {
	self = [super init];
	if (self) {
		OSStatus err;
		CFURLRef url = (CFURLRef) aFile;
		err = ExtAudioFileCreateWithURL(url, fileType, description, nil, kAudioFileFlags_EraseFile, &extAudioFileRef);
		NSAssert1 (err == noErr, @"ExtAudioFileCreateWithURL() error %d", err);

		sampleRate = description->mSampleRate;
		numberChannels = description->mChannelsPerFrame;

		self.filename = [aFile lastPathComponent];
		self.info = @"";
	}
	return self;
}

- (void)dealloc {
	ExtAudioFileDispose (extAudioFileRef);
	[filename release];
	[info release];
	[super dealloc];
}

#pragma mark ExtAudioFile Properties

- (AudioStreamBasicDescription)fileDataFormat {
	OSStatus err;
	AudioStreamBasicDescription asbd;
	UInt32 size = sizeof(AudioStreamBasicDescription);
	err = ExtAudioFileGetProperty (extAudioFileRef, kExtAudioFileProperty_FileDataFormat, &size, &asbd);
	NSAssert1 (err == noErr, @"ExtAudioFileGetProperty (kExtAudioFileProperty_FileDataFormat) error %d", err);
	return asbd;
}

- (AudioStreamBasicDescription)clientDataFormat {
	OSStatus err;
	AudioStreamBasicDescription asbd;
	UInt32 size = sizeof(AudioStreamBasicDescription);
	err = ExtAudioFileGetProperty (extAudioFileRef, kExtAudioFileProperty_ClientDataFormat, &size, &asbd);
	NSAssert1 (err == noErr, @"ExtAudioFileGetProperty (kExtAudioFileProperty_ClientDataFormat) error %d", err);
	return asbd;
}

- (void)setClientDataFormat:(AudioStreamBasicDescription)asbd {
	OSStatus err = ExtAudioFileSetProperty (extAudioFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof (AudioStreamBasicDescription), &asbd);
	NSAssert1 (err == noErr, @"ExtAudioFileSetProperty (kExtAudioFileProperty_ClientDataFormat) error %d", err);
}

- (AudioStreamBasicDescription)canonicalDataFormat {
	AudioStreamBasicDescription asbd;
	asbd.mSampleRate = sampleRate;
	asbd.mFormatID = kAudioFormatLinearPCM;
	asbd.mFormatFlags = kLinearPCMFormatFlagIsFloat | kAudioFormatFlagsNativeEndian;
	asbd.mBytesPerFrame = sizeof(Float32) * numberChannels;
	asbd.mFramesPerPacket = 1;
	asbd.mBytesPerPacket = asbd.mBytesPerFrame;
	asbd.mChannelsPerFrame = numberChannels;
	asbd.mBitsPerChannel = 32;
	asbd.mReserved = 0;
	return asbd;
}

- (AudioConverterRef)audioConverter {
	AudioConverterRef aConverter;
	UInt32 size = sizeof(AudioConverterRef);
	OSStatus err = ExtAudioFileGetProperty (extAudioFileRef, kExtAudioFileProperty_AudioConverter, &size, &aConverter);
	NSAssert1 (err == noErr, @"ExtAudioFileGetProperty (kExtAudioFileProperty_AudioConverter) error %d", err);
	return aConverter;
}

- (void)setBitRate:(UInt32)bitRate {
	AudioConverterRef audioConverter = [self audioConverter];
	UInt32 size = sizeof (UInt32);
	OSStatus err = AudioConverterSetProperty(audioConverter, kAudioConverterEncodeBitRate, size, &bitRate);
	NSAssert1 (err == noErr, @"ExtAudioFileSetProperty (kAudioConverterEncodeBitRate) error %d", err);
}

#pragma mark File I/O

- (NSData *)readDataWithNumberFrames:(UInt32)length {
	UInt32 numberFrames = length;
	NSMutableData *data = [NSMutableData dataWithLength:length * numberChannels * sizeof(Float32)];
						   
	AudioBufferList list;
	list.mNumberBuffers = 1;
	list.mBuffers[0].mData = [data mutableBytes];
	list.mBuffers[0].mDataByteSize = [data length];
	list.mBuffers[0].mNumberChannels = numberChannels;
	
	OSStatus err = ExtAudioFileRead (extAudioFileRef, &numberFrames, &list);
	NSAssert1 (err == noErr, @"ExtAudioFileRead () error %d", err);
	
	data.length = numberFrames * numberChannels * sizeof(Float32);
	return data;
}

- (void)writeData:(NSData *)data {
	UInt32 numberFrames = data.length / (numberChannels * sizeof(Float32));
	
	AudioBufferList list;
	list.mNumberBuffers = 1;
	list.mBuffers[0].mData = (void *) [data bytes];
	list.mBuffers[0].mDataByteSize = data.length;
	list.mBuffers[0].mNumberChannels = numberChannels;
	
	OSStatus err = ExtAudioFileWrite (extAudioFileRef, numberFrames, &list);
	NSAssert1 (err == noErr, @"ExtAudioFileWrite () error %d", err);
}


@end
