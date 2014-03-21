//
//  GraphView.h
//  Calculator
//
//  Created by Krawczyk, Pete on 10/19/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource
-(float)valueForXValue:(float)xValue;
@end

@interface GraphView : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

@end
