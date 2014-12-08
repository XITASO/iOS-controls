//
//  XIWaveformView.h
//  XITASO Open Source Library
//
//  Created by Christian Höfle on 2014-11-13.
//  Copyright (c) 2014 XITASO GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>


/**
 WaveformCreator creates a waveform image in a background thread out of a given AVURLAsset and reloads the current image in the owner via delegate; Therefore it's important to set the delegate of the WaveformCreator
 @author Christian Höfle
 @date 2012-11-19
 */
@interface XIWaveformView : UIImageView {
    
@private    
    UInt32 sampleRate;                  /**< The sample rate of the track, usually 44100Hz */
    unsigned int channelCount;          /**< The channel count of the track, currently not used */
    CGSize __imageSize;                 /**< The sample count to be shown, every sample stands for one 1px line */
    UInt32 normalizeMax;                /**< The max value of the amplitude to normalize the shown graph */
    CMTime audioLength;                 /**< The length of the track in samples */
}

@property (nonatomic, strong, readonly) AVAssetReader *assetReader;     /**< The asset reader object needed to parse the given audio file */
@property (nonatomic, strong, readonly) AVAssetTrack *assetTrack;       /**< The asset track from the given song asset */
@property (nonatomic, strong) UIColor *tintColor;                       /**< The color the waveform should be drawn with */


/**
 Method gets the data from an audio asset to show the wave form
 @author Christian Höfle
 @date 2012-11-14
 @param songAsset The AVURLAsset object to read the data from
 @param completionHandler The completion handler thath is called when the building is finished
 */
- (void)buildFromAsset:(AVURLAsset *)songAsset completion:(void(^)(BOOL successful))completionHandler;

@end
