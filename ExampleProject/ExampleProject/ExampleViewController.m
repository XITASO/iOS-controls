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
    _wheelControl.minValue = 0;
    _wheelControl.maxValue = 100;
    _wheelControl.tintColor = [UIColor blueColor];
    
    _waveformView.tintColor = [UIColor blueColor];
    [_waveformView buildFromAsset:[AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ExampleAudio" ofType:@"m4a"]]] completion:^(BOOL successful) {
        
    }];
    
    _doubleSlider.minSelectedValue = 10;
    _doubleSlider.maxSelectedValue = 90;
    _doubleSlider.delegate = self;
    [_doubleSlider addTarget:self action:@selector(doubleSliderValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)didChangeValue:(XIWheelControl *)wheel
{
    
}

- (void)doubleSliderValueChanged
{
    
}

- (void)sliderDidEndChangingWithHandle:(LastTouchedHandle)lastTouchedHandle
{
    
}

@end
