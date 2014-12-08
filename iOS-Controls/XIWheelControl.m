//
//  XIWheelControl.m
//  XITASO Open Source Library
//
//  Created by Christian Höfle on 2014-11-13.
//  Copyright (c) 2014 XITASO GmbH. All rights reserved.
//

#import "XIWheelControl.h"



/**
 XIWheelView creates a view for the XIWheelControl without needing an image
 @author Christian Höfle
 @date 2014-10-30
 */
@interface XIWheelView : UIView

@property (nonatomic, assign, readonly) BOOL touched;               /**< Bool that indicates whether the view should show its touch state or not */
@property (nonatomic, assign, readonly) CGRect originalFrame;       /**< The original frame of the view, important when changing to the touch state */
@property (nonatomic, strong) UIColor *tintColor;                   /**< The tint color for the strokes */

@end


@implementation XIWheelView


static const float XIWheelControlStrokeMargin = 0.5;                /**< The margin the strokes inside has from the frame, needed for rect calculation */
static const float XIWheelControlHandleFactor = 5.0;                /**< The factor the handle is smaller than the whole control */


#pragma mark -
#pragma mark Init methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // setup the view
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // setup the view
        [self setup];
    }
    return self;
}

#pragma mark -
#pragma mark Class methods

- (void)setup
{
    // set background clear
    self.backgroundColor = [UIColor clearColor];
    
    // disable touches
    self.userInteractionEnabled = NO;
    
    // set original frame
    _originalFrame = self.frame;
}

- (void)setTouched:(BOOL)touched
{
    _touched = touched;
    
    // redraw the view
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing mehthods

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set antialiasing
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetShouldAntialias(context, YES);
    
    // make background
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGRect rectangle = _originalFrame;
    CGContextAddEllipseInRect(context, rectangle);
    CGContextDrawPath(context, kCGPathFill);
    
    // make stroke
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, _tintColor.CGColor);
    rectangle = CGRectMake(XIWheelControlStrokeMargin, XIWheelControlStrokeMargin, _originalFrame.size.width - XIWheelControlStrokeMargin*2, _originalFrame.size.height - XIWheelControlStrokeMargin*2);
    CGContextAddEllipseInRect(context, rectangle);
    CGContextStrokePath(context);
    
    // handle background
    if (_touched) {
        CGContextSetFillColorWithColor(context, _tintColor.CGColor);
        
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    
    float width = _originalFrame.size.width / XIWheelControlHandleFactor;
    float verticalMargin = width / 2.0;
    float horizontalMargin = (_originalFrame.size.width - width) / 2.0;
    rectangle = CGRectMake(horizontalMargin, verticalMargin, width, width);
    CGContextAddEllipseInRect(context, rectangle);
    CGContextDrawPath(context, kCGPathFill);
    
    // handle stroke
    CGContextAddEllipseInRect(context, rectangle);
    CGContextStrokePath(context);
}

@end




@interface XIWheelControl ()

/**
 Method calculates the distance of a given point to the center of the wheelImageView
 @author Christian Höfle
 @date 2012-11-19
 @param point The given point
 @returns float The distance to the center
 */
- (float)calculateDistanceFromCenter:(CGPoint)point;

/**
 Method checks if a given touch point is valid and if the tracking should be continued
 @author Christian Höfle
 @date 2012-11-19
 @param touchPoint The touch point to check
 @param tolerance Bool to mark if there should be a tolerance
 @returns BOOL YES if the point is valid, NO if not
 */
- (BOOL)touchPointIsValid:(CGPoint)touchPoint withTolerance:(BOOL)tolerance;

/**
 Method checks if the angle change of the wheel results in a value within the min/max bounds and sends the UIControlEventValueChanged action if so
 @author Christian Höfle
 @date 2012-11-19
 @param angleChange The value of the angle change
 */
- (void)checkForValueChange:(float)angleChange;

@end

@implementation XIWheelControl


#pragma mark -
#pragma mark Statics

static float const XIMarginWheelTouch = 100.0;

static float deltaAngle;
static float deltaAngleTemp;


#pragma mark -
#pragma mark Init method

- (id)initWithFrame:(CGRect)frame minValue:(float)minValue maxValue:(float)maxValue
{
    self = [super initWithFrame:frame];
    if (self) {        
        // set min/max values
        _minValue = minValue;
        self.maxValue = maxValue;
        
        // add wheel view
        _wheelView = [[XIWheelView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:_wheelView];
        
        // general setup
        [self setup];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // set default min/max values
        _minValue = 0;
        self.maxValue = 100;
        
        // add wheel view
        float widthAndHeightValue = 0;
        
        if (self.frame.size.width > self.frame.size.height) {
            widthAndHeightValue = self.frame.size.height;
        
        } else {
            widthAndHeightValue = self.frame.size.width;
        }
        
        _wheelView = [[XIWheelView alloc] initWithFrame:CGRectMake(0, 0, widthAndHeightValue, widthAndHeightValue)];
        [self addSubview:_wheelView];
        
        // general setup
        [self setup];
    }
    return self;
}


#pragma mark -
#pragma mark UIControl touch methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    if ([self touchPointIsValid:touchPoint withTolerance:NO]) {
        float dx = touchPoint.x - _wheelView.center.x;
        float dy = touchPoint.y - _wheelView.center.y;
        
        // get the angle values
        deltaAngle = atan2(dy,dx);
        deltaAngleTemp = atan2(dy,dx);
        
        _wheelAffineTransform = _wheelView.transform;
        
        // set the touched state
        [_wheelView setTouched:YES];
        
        return YES;
        
    } else return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    float dx = touchPoint.x - _wheelView.center.x;
    float dy = touchPoint.y - _wheelView.center.y;
    
    // get the angle difference from the the touch starting point, set in beginTrackingWithTouch
    float currentAngle = atan2(dy,dx);
    float angleDifference = deltaAngle - currentAngle;
    
    // get the current difference between the last step and the current step
    float angleDifferenceTemp = deltaAngleTemp - currentAngle;
    deltaAngleTemp = currentAngle;
    
    // make the wheel rotate around the center
    _wheelView.transform = CGAffineTransformRotate(_wheelAffineTransform, -angleDifference);
    
    // now check the value
    [self checkForValueChange:angleDifferenceTemp];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    // unset touched state
    [_wheelView setTouched:NO];
}


#pragma mark -
#pragma mark Custom setter methods

- (void)setMinValue:(float)minValue
{
    _minValue = minValue;
    
    [self checkMinMaxValuesAndCalculateMultiplicator];
}

- (void)setMaxValue:(float)maxValue
{
    _maxValue = maxValue;
    
    [self checkMinMaxValuesAndCalculateMultiplicator];
}

- (void)setTintColor:(UIColor *)tintColor
{
    if (_wheelView) {
        _wheelView.tintColor = tintColor;
    }
}


#pragma mark -
#pragma mark Class methods

- (void)setup
{
    _minDistanceCenter = _wheelView.frame.size.width / 7;
}

- (void)checkMinMaxValuesAndCalculateMultiplicator
{
    // check if minvalue < maxvalue
    if (_minValue > _maxValue) {
        // swap the values
        float tempMaxValue = _maxValue;
        _maxValue = _minValue;
        _minValue = tempMaxValue;
        
    } else if (_minValue == _maxValue) {
        // set max value higher than min value
        _maxValue = _minValue + 100;
    }
    
    // calculate multiplicator
    _multiplicator = sqrt((_maxValue - _minValue) / 5);
}

- (float)calculateDistanceFromCenter:(CGPoint)point
{
    CGPoint center = _wheelView.center;
    float dx = point.x - center.x;
    float dy = point.y - center.y;
    return sqrt(dx*dx + dy*dy);
}

- (BOOL)touchPointIsValid:(CGPoint)touchPoint withTolerance:(BOOL)tolerance
{
    CGRect rectToCheck;
    
    if (tolerance) {
        rectToCheck = CGRectMake(_wheelView.frame.origin.x - XIMarginWheelTouch,
                                 _wheelView.frame.origin.y - XIMarginWheelTouch,
                                 _wheelView.frame.size.width + XIMarginWheelTouch,
                                 _wheelView.frame.size.height + XIMarginWheelTouch);
        
    } else rectToCheck = _wheelView.frame;
    
    // touch point is within the wheel rect
    if (CGRectContainsPoint(rectToCheck, touchPoint) && [self calculateDistanceFromCenter:touchPoint] > _minDistanceCenter) {
        return YES;
    
    } else {
        return NO;
    }
}

- (void)checkForValueChange:(float)angleChange
{    
    // don't change if the jump is too big
    if (abs(angleChange) > 2) {
        angleChange = 0;
    }
    
    // increment/decrement the value exponentially
    float tempNewValue;
    float valueChange = (angleChange * _multiplicator) * (angleChange * _multiplicator);
    
    if (angleChange > 0) {
        valueChange = -valueChange;
    }
    
    tempNewValue = _value + valueChange;
    
    // snap to min/max value if out of bounds
    if (tempNewValue < _minValue) {
        tempNewValue = _minValue;
        
    } else if (tempNewValue > _maxValue) {
        tempNewValue = _maxValue;
        
    }
    
    // set the new value and send the action to inform the controller about the change
    _value = tempNewValue;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


@end
