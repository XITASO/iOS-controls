//
//  XIDoubleSlider.m
//
//  Created by Dimitris on 23/06/2010.
//  Modified by Christian Höfle on 30.10.12.
//  Copyright (c) 2012 XITASO GmbH. All rights reserved.
//


#import "XIDoubleSlider.h"


#pragma mark -
#pragma mark - Defines


static const float handleTouchExtensionValue = 20.0;


@interface XISliderHandle : UIView

@property (nonatomic, strong) UIColor *tintColor;

- (id)initWithColor:(UIColor *)color;

@end


@implementation XISliderHandle

- (id)initWithColor:(UIColor *)color
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 32, 32);
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = color;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set antialiasing
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetShouldAntialias(context, YES);
    
    // set shadow
    CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 3, [UIColor colorWithWhite:0.75 alpha:1.0].CGColor);
    
    // make background
    CGContextSetFillColorWithColor(context, _tintColor.CGColor);
    CGContextAddEllipseInRect(context, CGRectMake(2, 0, 28, 28));
    CGContextDrawPath(context, kCGPathFill);

    CGContextSetShadow(context, CGSizeMake(0, 0), 0);
    
    // set border
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(2, 0.5, 28, 28) cornerRadius:14];
    bezierPath.lineWidth = 0.5;
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.5 alpha:0.2].CGColor);
    [bezierPath stroke];
}

@end



#pragma mark -
#pragma mark - Implementation

@implementation XIDoubleSlider


#pragma mark -
#pragma mark Init method

- (id)initWithFrame:(CGRect)frame minValue:(float)minValue maxValue:(float)maxValue
{
    self = [super initWithFrame:frame];
    if (self) {
        // setup
        [self setupWithMinValue:minValue maxValue:maxValue];
    }
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // setup
        [self setupWithMinValue:0 maxValue:100];
    }
    return self;
}

- (void)setupWithMinValue:(float)minValue maxValue:(float)maxValue
{
    if (minValue < maxValue) {
        self.minValue = minValue;
        self.maxValue = maxValue;
        
    } else {
        self.minValue = maxValue;
        self.maxValue = minValue;
    }
    
    // set clear background color
    self.backgroundColor = [UIColor clearColor];
    
    // set slider background line
    _sliderBackgroundLine = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                     self.frame.size.height / 2 - 1,
                                                                     self.frame.size.width,
                                                                     2)];
    _sliderBackgroundLine.backgroundColor = [UIColor lightGrayColor];
    _sliderBackgroundLine.userInteractionEnabled = NO;
    [self addSubview:_sliderBackgroundLine];
    
    _sliderForegroundLine = [[UIView alloc] initWithFrame:CGRectMake(0, _sliderBackgroundLine.frame.origin.y, 100, 2)];
    _sliderForegroundLine.backgroundColor = [UIColor blueColor];
    _sliderForegroundLine.userInteractionEnabled = NO;
    [self addSubview:_sliderForegroundLine];
    
    // set the slider bar frame
    _sliderBarFrame = CGRectMake(0,
                                 self.frame.size.height / 2 - 1,
                                 self.frame.size.width,
                                 2);
    
    // alloc the minHandle and set the frame correctly
    _minHandle = [[XISliderHandle alloc] initWithColor:[UIColor whiteColor]];
    _minHandle.frame = CGRectMake(_sliderBarFrame.origin.x + _minHandle.frame.size.width,
                                  (_sliderBarFrame.origin.y + _sliderBarFrame.size.height) - (_minHandle.frame.size.height / 2) + 1,
                                  _minHandle.frame.size.width,
                                  _minHandle.frame.size.height);
    
    [self addSubview:_minHandle];
    
    // alloc the maxHandle and set the frame correctly
    _maxHandle = [[XISliderHandle alloc] initWithColor:[UIColor whiteColor]];
    _maxHandle.frame = CGRectMake(_sliderBarFrame.size.width - _maxHandle.frame.size.width,
                                  (_sliderBarFrame.origin.y + _sliderBarFrame.size.height) - (_maxHandle.frame.size.height / 2) + 1,
                                  _maxHandle.frame.size.width,
                                  _maxHandle.frame.size.height);
    
    [self addSubview:_maxHandle];
    
    // Init some values
    _minHandleTouched = NO;
    _maxHandleTouched = NO;
    
    [self updateValues];

}


#pragma mark -
#pragma mark Touch tracking methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.enabled) {
        CGPoint touchPoint = [touch locationInView:self];
        
        // check if the min or max slider got touched and if so set one of the booleans to YES; make the frames bigger by 20 to each side
        if (CGRectContainsPoint(CGRectMake(_minHandle.frame.origin.x - handleTouchExtensionValue,
                                           _minHandle.frame.origin.y - handleTouchExtensionValue,
                                           _minHandle.frame.size.width + handleTouchExtensionValue,
                                           _minHandle.frame.size.height + handleTouchExtensionValue*2),
                                touchPoint)) {
            _minHandleTouched = YES;
            
        } else if (CGRectContainsPoint(CGRectMake(_maxHandle.frame.origin.x,
                                                  _maxHandle.frame.origin.y - handleTouchExtensionValue,
                                                  _maxHandle.frame.size.width+handleTouchExtensionValue,
                                                  _maxHandle.frame.size.height+handleTouchExtensionValue*2),
                                       touchPoint)) {
            _maxHandleTouched = YES;
        }
    
        return YES;
    } else {
        return NO;
    
    }
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchPoint = [touch locationInView:self];
    
    // Get the new values of the handle, depending on which one got touched
	if (_minHandleTouched) {
        // Min handle
		if (touchPoint.x + (_minHandle.frame.size.width / 2) < _maxHandle.frame.origin.x &&
            touchPoint.x >= (_sliderBarFrame.origin.x + (_minHandle.frame.size.width / 2))) {
            // min handle is below max handle and above min limit
			_minHandle.center = CGPointMake(touchPoint.x, _minHandle.center.y);
		
        } else if (touchPoint.x < (_sliderBarFrame.origin.x + (_minHandle.frame.size.width / 2))) {
            // min handle is below or equal to the min limit, set to min limit
            _minHandle.center = CGPointMake((_sliderBarFrame.origin.x + (_minHandle.frame.size.width / 2)), _minHandle.center.y);
        
        } else if (touchPoint.x + (_minHandle.frame.size.width / 2) > _maxHandle.frame.origin.x) {
            // min handle is above or equal to the max handle, set to max limit
            _minHandle.center = CGPointMake(_maxHandle.frame.origin.x - (_minHandle.frame.size.width / 2), _minHandle.center.y);
        }
        
	} else if (_maxHandleTouched) {
        // Max handle
		if (touchPoint.x - (_maxHandle.frame.size.width / 2) > (_minHandle.frame.origin.x + _minHandle.frame.size.width) &&
            touchPoint.x <= (_sliderBarFrame.origin.x + _sliderBarFrame.size.width - (_maxHandle.frame.size.width / 2))) {
            // max handle is above min handle and below max limit
			_maxHandle.center = CGPointMake(touchPoint.x, _maxHandle.center.y);
		
        } else if (touchPoint.x > (_sliderBarFrame.origin.x + _sliderBarFrame.size.width - (_maxHandle.frame.size.width / 2))) {
            _maxHandle.center = CGPointMake(_sliderBarFrame.origin.x + _sliderBarFrame.size.width - (_maxHandle.frame.size.width / 2), _maxHandle.center.y);
        }
    }
    
    // update the min/max values
    [self updateValues];
    
	// Send value changed alert
	[self sendActionsForControlEvents:UIControlEventValueChanged];
    
	return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _minHandleTouched = NO;
    _maxHandleTouched = NO;
    
    // send editing ended
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}


#pragma mark -
#pragma mark Setter methods

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    _minHandle.userInteractionEnabled = enabled;
    _maxHandle.userInteractionEnabled = enabled;
}

- (void)setMinValue:(float)minValue
{
    _minValue = minValue;
    
    if (_minSelectedValue < _minValue) {
        self.minSelectedValue = _minValue;
    }
    
    [self updateHandleFrames];
    [self updateValues];
}

- (void)setMaxValue:(float)maxValue
{
    _maxValue = maxValue;
    
    if (_maxSelectedValue > _maxValue) {
        self.maxSelectedValue = _maxValue;
    }
    
    [self updateHandleFrames];
    [self updateValues];
}

- (void)setMinSelectedValue:(float)minSelectedValue
{
    if (minSelectedValue >= _minValue && minSelectedValue < _maxSelectedValue) {
        _minSelectedValue = minSelectedValue;
    }
    
    [self updateHandleFrames];
    [self updateValues];
}

- (void)setMaxSelectedValue:(float)maxSelectedValue
{
    if (maxSelectedValue <= _maxValue && maxSelectedValue > _minSelectedValue) {
        _maxSelectedValue = maxSelectedValue;
    }
    
    [self updateHandleFrames];
    [self updateValues];
}

- (void)setForegroundColor:(UIColor *)foregroundColor
{
    _sliderForegroundLine.backgroundColor = _foregroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _sliderBackgroundLine.backgroundColor = backgroundColor;
}

- (void)setHandleColor:(UIColor *)handleColor
{
    _minHandle.tintColor = handleColor;
    _maxHandle.tintColor = handleColor;
}


#pragma mark -
#pragma mark Helper methods

- (void)updateValues
{
    // update view
    _sliderForegroundLine.frame = CGRectMake(_minHandle.center.x,
                                             _sliderForegroundLine.frame.origin.y,
                                             _maxHandle.center.x - _minHandle.center.x,
                                             _sliderForegroundLine.frame.size.height);
    
    _minSelectedValue = _minValue + (((_minHandle.center.x - (_minHandle.frame.size.width / 2)) / (_sliderBarFrame.size.width - _minHandle.frame.size.width)) * (_maxValue - _minValue));
    
    // snap to min value
    if (_minSelectedValue < _minValue) {
        _minSelectedValue = _minValue;
    }
    
    _maxSelectedValue = _minValue + (((_maxHandle.center.x - (_maxHandle.frame.size.width / 2)) / (_sliderBarFrame.size.width - _maxHandle.frame.size.width)) * (_maxValue - _minValue));
    
    // snap to max value
    if (_maxSelectedValue > _maxValue) {
        _maxSelectedValue = _maxValue;
    }
}

- (void)updateHandleFrames
{
    _minHandle.center = CGPointMake((2 * _minSelectedValue * _minHandle.frame.size.width - _minValue * _minHandle.frame.size.width - 2 * _minSelectedValue * _sliderBarFrame.size.width + 2 * _minValue * _sliderBarFrame.size.width - _minHandle.frame.size.width * _maxValue)/(2 * (_minValue - _maxValue)), _minHandle.center.y);
    _maxHandle.center = CGPointMake((2 * _maxSelectedValue * _maxHandle.frame.size.width - _minValue * _maxHandle.frame.size.width - 2 * _maxSelectedValue * _sliderBarFrame.size.width + 2 * _minValue * _sliderBarFrame.size.width - _maxHandle.frame.size.width * _maxValue)/(2 * (_minValue - _maxValue)), _maxHandle.center.y);
}


#pragma mark -
#pragma mark Dealloc method

- (void)dealloc
{
    // free all the objects
    _minHandle = nil;
    _maxHandle = nil;
}



@end