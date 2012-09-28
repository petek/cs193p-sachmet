//
//  HappinessViewController.m
//  Happiness
//
//  Created by Krawczyk, Pete on 9/28/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "HappinessViewController.h"
#import "FaceView.h"

@interface HappinessViewController ()
@property (nonatomic, weak) IBOutlet FaceView *faceView;
@end

@implementation HappinessViewController

@synthesize happiness = _happiness;
@synthesize faceView = _faceView;

-(void)setHappiness:(int)happiness {
    _happiness = happiness;
    [self.faceView setNeedsDisplay];    
}

@end
