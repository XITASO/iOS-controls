//
//  ExampleViewController.m
//  XITASO Open Source Library
//
//  Created by Christian Höfle on 2014-10-30.
//  Copyright (c) 2014 XITASO GmbH. All rights reserved.
//

#import "ExampleViewController.h"

@interface ExampleViewController ()

@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    // setup wheel control
    _wheelControl.minValue = 0;
    _wheelControl.maxValue = 100;
    _wheelControl.tintColor = [UIColor blueColor];
    [_wheelControl addTarget:self action:@selector(wheelDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    // setup waveform
    _waveformView.tintColor = [UIColor blueColor];
    [_waveformView buildFromAsset:[AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ExampleAudio" ofType:@"m4a"]]] completion:^(BOOL successful) {
        
    }];
    
    // setup double slider
    _doubleSlider.minSelectedValue = 10;
    _doubleSlider.maxSelectedValue = 90;
    [_doubleSlider addTarget:self action:@selector(doubleSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_doubleSlider addTarget:self action:@selector(doubleSliderDidEndChangingValue:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -
#pragma mark Wheel value changing

- (void)wheelDidChangeValue:(XIWheelControl *)wheel
{
    NSLog(@"Wheel did change value: %f", wheel.value);
}

#pragma mark -
#pragma mark Double slider value changing

- (void)doubleSliderValueChanged:(XIDoubleSlider *)doubleSlider
{
    NSLog(@"Double slider values: min: %f, max: %f", doubleSlider.minSelectedValue, doubleSlider.maxSelectedValue);
}

- (void)doubleSliderDidEndChangingValue:(XIDoubleSlider *)doubleSlider
{
    NSLog(@"Double slider values: min: %f, max: %f", doubleSlider.minSelectedValue, doubleSlider.maxSelectedValue);
}

@end
