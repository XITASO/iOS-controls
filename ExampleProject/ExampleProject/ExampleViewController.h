//
//  ExampleViewController.h
//  XITASO Open Source Library
//
//  Created by Christian Höfle on 2014-10-30.
//  Copyright (c) 2014 XITASO GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XIWheelControl.h"
#import "XIWaveformView.h"
#import "XIDoubleSlider.h"

@interface ExampleViewController : UIViewController

@property (nonatomic, strong) IBOutlet XIWheelControl *wheelControl;
@property (nonatomic, strong) IBOutlet XIWaveformView *waveformView;
@property (nonatomic, strong) IBOutlet XIDoubleSlider *doubleSlider;

@end

