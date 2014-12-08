//
//  XIDoubleSlider.h
//
//  Created by Dimitris on 23/06/2010.
//  Modified by Christian Höfle on 30.10.12.
//  Copyright (c) 2012 XITASO GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LastTouchedHandle) {
    LastTouchedHandleNoHandle = 0,
    LastTouchedHandleMinHandle,
    LastTouchedHandleMaxHandle
};


@class XISliderHandle;


@protocol XIDoubleSliderProtocol <NSObject>

/**
 Method 
 @author Christian Höfle
 @date 2012-11-20
 @param lastTouchedHandle
 */
- (void)sliderDidEndChangingWithHandle:(LastTouchedHandle)lastTouchedHandle;

@end


/**
 XIDoubleSlider is a UIControl that replaces one/two regular UISlider controls.
 The XIDoubleSlider has two handles to set minimum/maximum value and a third handle for setting the
 playback point in audio specific contexts.
 @author Christian Höfle
 @date 2012-10-30
 */
@interface XIDoubleSlider : UIControl

@property (nonatomic, strong) XISliderHandle *minHandle;
@property (nonatomic, strong) XISliderHandle *maxHandle;
@property (nonatomic, assign) float minValue;
@property (nonatomic, assign) float maxValue;
@property (nonatomic, assign) BOOL handlesEnabled;
@property (nonatomic, assign) float minSelectedValue;
@property (nonatomic, assign) float maxSelectedValue;
@property (nonatomic, assign, readonly) BOOL minHandleTouched;
@property (nonatomic, assign, readonly) BOOL maxHandleTouched;
@property (nonatomic, readonly) LastTouchedHandle lastTouchedHandle;

@property (nonatomic, strong, readonly) UIView *sliderBackgroundLine;
@property (nonatomic, strong, readonly) UIView *sliderForegroundLine;
@property (nonatomic, assign, readonly) CGRect sliderBarFrame;

@property (nonatomic, strong) UIColor *foregroundColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *handleColor;

@property (weak) id <XIDoubleSliderProtocol> delegate;


/**
 Init method of the slider
 @author Christian Höfle
 @date 2012-10-31
 @param aFrame The CGRect frame for the slider
 @param minValue The value at the lower end of the slider
 @param maxValue The value at the upper end of the slider
 @param height The visible height of the slider bar in the background
 @returns id The slider object itself
 */
- (id)initWithFrame:(CGRect)frame minValue:(float)minValue maxValue:(float)maxValue;

/**
 Method updates the values of the handles to the position they are dragged to
 @author Christian Höfle
 @date 2012-10-30
 */
- (void)updateValues;

/**
 Method updates the frames of the handles to the current values
 @author Christian Höfle
 @date 2012-11-08
 */
- (void)updateHandleFrames;

@end