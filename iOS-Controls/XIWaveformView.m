//
//  XIWaveformView.m
//  XITASO Open Source Library
//
//  Created by Christian Höfle on 2014-11-13.
//  Copyright (c) 2014 XITASO GmbH. All rights reserved.
//

#import "XIWaveformView.h"


#define absX(x) (x<0?0-x:x)
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define decibel(amplitude) (100.0 * log10(absX(amplitude)/200.0))


@interface XIWaveformView ()

/**
 Method draws the image with the given parameters and some parameters from class variables
 @author Christian Höfle
 @date 2012-11-14
 @param samples The data to draw
 @returns UIImage the drawn UIImage
 */
- (UIImage *)getAudioImageGraphForSamples:(SInt16 *)samples withSize:(int)currentImageSize;

@end


@implementation XIWaveformView


#pragma mark -
#pragma mark Class methods

- (void)buildFromAsset:(AVURLAsset *)songAsset completion:(void(^)(BOOL successful))completionHandler
{
    // do in background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        
        _assetReader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
        _assetTrack = [songAsset.tracks objectAtIndex:0];
        
        // set the values for the track output
        NSDictionary* outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                            [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                            // [NSNumber numberWithInt:44100.0],AVSampleRateKey, /*Not Supported*/
                                            // [NSNumber numberWithInt:1], AVNumberOfChannelsKey, doesn't work
                                            [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                            [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                            [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                            [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                            nil];
        
        AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:_assetTrack outputSettings:outputSettingsDict];
        [_assetReader addOutput:output];
        
        NSArray *audioStreamFormatDescriptions = _assetTrack.formatDescriptions;
        
        for (unsigned int i = 0; i < [audioStreamFormatDescriptions count]; ++i) {
            CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[audioStreamFormatDescriptions objectAtIndex:i];
            const AudioStreamBasicDescription *audioStreamDescription = CMAudioFormatDescriptionGetStreamBasicDescription(item);
            
            if (audioStreamDescription) {
                sampleRate = audioStreamDescription->mSampleRate;
                channelCount = audioStreamDescription->mChannelsPerFrame;
                audioLength = _assetReader.asset.duration;
            }
        }
        
        UInt32 bytesPerSample = 2 * channelCount;
        
        NSMutableData * fullSongData = [[NSMutableData alloc] init]; // the full song data
        [_assetReader startReading];
        
        normalizeMax = 0;
        UInt64 totalBytes = 0;
        SInt64 totalLeft = 0;
        NSInteger sampleTally = 0;
        
        // this is the value responsible for the length of the wave
        NSInteger samplesPerPixel = audioLength.value / self.frame.size.width / 4;
        
        // get the buffer output while the AssetReader is working
        while (_assetReader.status == AVAssetReaderStatusReading) {
            
            AVAssetReaderTrackOutput *trackOutput = (AVAssetReaderTrackOutput *)[_assetReader.outputs objectAtIndex:0];
            CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
            
            if (sampleBufferRef){
                CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
                
                size_t length = CMBlockBufferGetDataLength(blockBufferRef);
                totalBytes += length;
                
                NSMutableData *data = [NSMutableData dataWithLength:length];
                CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
                SInt16 *samples = (SInt16 *)data.mutableBytes;
                
                // the amount of samples needed for the song data
                int sampleCount = (int)(length / bytesPerSample);
                
                for (int i = 0; i < sampleCount ; i ++) {
                    
                    SInt16 left = *samples++;
                    left = decibel(left);
                    
                    totalLeft  += left;
                    
                    sampleTally++;
                    
                    if (sampleTally > samplesPerPixel) {
                        
                        left  = totalLeft / sampleTally;
                        
                        // check if the current value is higher than the max value
                        SInt16 fix = abs(left);
                        
                        if (fix > normalizeMax) {
                            normalizeMax = fix;
                        }
                        
                        [fullSongData appendBytes:&left length:sizeof(left)];
                        
                        totalLeft   = 0;
                        sampleTally = 0;
                    }
                }
                
                CMSampleBufferInvalidate(sampleBufferRef);
                CFRelease(sampleBufferRef);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // set image
            self.image = [self getAudioImageGraphForSamples:(SInt16 *)fullSongData.bytes withSize:(int)totalBytes/(samplesPerPixel*bytesPerSample)+1];
            
            // call completion handler
            completionHandler(YES);
        });
    });
}

- (UIImage *)getAudioImageGraphForSamples:(SInt16 *)samples withSize:(int)currentImageSize
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 4.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetAlpha(context, 1.0);
    CGRect rect;
    rect.size = self.frame.size;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGColorRef leftcolor = self.tintColor.CGColor;
    
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 0.25);
    
    float halfGraphHeight = (self.frame.size.height / 2);
    float centerLeft = halfGraphHeight;
    float sampleAdjustmentFactor = (self.frame.size.height) / normalizeMax / 2;
    
    for (CGFloat intSample = 0 ; intSample < currentImageSize ; intSample += 0.25 ) {
        SInt16 left = *samples++;
        float pixels = (float)left;
        pixels *= sampleAdjustmentFactor;
        CGContextMoveToPoint(context, intSample, centerLeft - pixels);
        CGContextAddLineToPoint(context, intSample, centerLeft + pixels);
        CGContextSetStrokeColorWithColor(context, leftcolor);
        CGContextStrokePath(context);
    }
    
    // Create new image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Tidy up
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)stopBuildingWaveform
{
    if (_assetReader.status == AVAssetReaderStatusReading) {
        [_assetReader cancelReading];
        
        _assetReader = nil;
        _assetTrack = nil;
        
    }
}

@end
