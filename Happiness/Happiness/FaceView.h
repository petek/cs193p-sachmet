//
//  FaceView.h
//  Happiness
//
//  Created by Krawczyk, Pete on 9/28/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FaceView;

@protocol FaceViewDataSource
-(float)smileForFaceView:(FaceView *)sender;
@end

@interface FaceView : UIView

@property (nonatomic) CGFloat scale;

-(void)pinch:(UIPinchGestureRecognizer *)gesture;

@property (nonatomic, weak) IBOutlet id <FaceViewDataSource> dataSource;

@end
