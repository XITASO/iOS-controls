//
//  XIDoubleSlider.h
//
//  Created by Dimitris on 23/06/2010.
//  Modified by Christian Höfle on 30.10.12.
//  Copyright (c) 2012 XITASO GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@class XISliderHandle;


/**
 XIDoubleSlider is a UIControl that replaces one/two regular UISlider controls.
 The XIDoubleSlider has two handles to set minimum/maximum value and a third handle for setting the
 playback point in audio specific contexts.
 @author Christian Höfle
 @date 2012-10-30
 */
@interface XIDoubleSlider : UIControl

@property (nonatomic, strong) XISliderHandle *minHandle;                    /**< The min handle of the double slider */
@property (nonatomic, strong) XISliderHandle *maxHandle;                    /**< The max handle of the double slider */
@property (nonatomic, assign) float minValue;                               /**< The min value that can be selected */
@property (nonatomic, assign) float maxValue;                               /**< The max value that can be selected */
@property (nonatomic, assign) float minSelectedValue;                       /**< The value of the min handle */
@property (nonatomic, assign) float maxSelectedValue;                       /**< The value of the max handle */
@property (nonatomic, assign, readonly) BOOL minHandleTouched;              /**< boolean to know if the min handle is currently touched, private */
@property (nonatomic, assign, readonly) BOOL maxHandleTouched;              /**< boolean to know if the max handle is currently touched, private */        

@property (nonatomic, strong, readonly) UIView *sliderBackgroundLine;       /**< The background line that is visible over the whole min / max area */
@property (nonatomic, strong, readonly) UIView *sliderForegroundLine;       /**< The foreground line, only showing the currently selected area */
@property (nonatomic, assign, readonly) CGRect sliderBarFrame;              /**< The frame that defines the area the handles can be dragged in */

@property (nonatomic, strong) UIColor *foregroundColor;                     /**< The color of the foreground line */
@property (nonatomic, strong) UIColor *backgroundColor;                     /**< The color of the background line */
@property (nonatomic, strong) UIColor *handleColor;                         /**< The color of the min / max handles */


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