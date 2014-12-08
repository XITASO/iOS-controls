//
//  XIWheelControl.h
//  XITASO Open Source Library
//
//  Created by Christian Höfle on 2014-11-13.
//  Copyright (c) 2014 XITASO GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XIWheelView;

/**
 XIWheelControl represents a control that is used like the wheel on the classic iPods for incrementing/decrementing values very accurately
 @author Christian Höfle
 @date 2012-11-19
 */
@interface XIWheelControl : UIControl

@property (nonatomic, strong, readonly) XIWheelView *wheelView;                     /**< The wheelview that is drawn on top of the control */
@property (nonatomic, assign, readonly) CGAffineTransform wheelAffineTransform;     /**< The affine transform object */
@property (nonatomic, assign, readonly) float value;                                /**< The current value fo the wheel control */
@property (nonatomic, assign, readonly) float minDistanceCenter;                    /**< The minimum distance from the center of the control the initial touch must have */

@property (nonatomic, assign) float minValue;                                       /**< The min value of the control */
@property (nonatomic, assign) float maxValue;                                       /**< The max value of the control */
@property (nonatomic, assign) float multiplicator;                                  /**< The multiplicator, important to increment/decrement exponentially */
@property (nonatomic, strong) UIColor *tintColor;                                   /**< The tint color of the view */

/**
 Init method overwriting initWithFrame with minValue and maxValue initialization
 @author Christian Höfle
 @date 2012-11-19
 @param frame The CGRect for the control
 @param minValue The min value the value must have
 @param maxValue The max value the value must have
 @returns id Itself
 */
- (id)initWithFrame:(CGRect)frame minValue:(float)minValue maxValue:(float)maxValue;

@end
