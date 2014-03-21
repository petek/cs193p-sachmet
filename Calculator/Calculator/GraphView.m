//
//  GraphView.m
//  Calculator
//
//  Created by Krawczyk, Pete on 10/19/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"
#import "CalculatorBrain.h"

@interface GraphView()
@property (nonatomic) BOOL hasOriginBeenInitialized;
@end

@implementation GraphView

@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize dataSource = _dataSource;
@synthesize hasOriginBeenInitialized = _hasOriginBeenInitialized;

-(CGFloat) scale {
    if (!_scale) {
        return 25.0;
    }
    return _scale;
}

-(void)setScale:(CGFloat)scale {
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay];
    }
}

-(CGPoint) origin {
    return _origin;
}

-(void)setOrigin:(CGPoint)origin {
    _origin = origin;
    [self setNeedsDisplay];
}

-(void)setDataSource:(id<GraphViewDataSource>)dataSource {
    _dataSource = dataSource;
}

-(void)setup {
    self.contentMode = UIViewContentModeRedraw;
}

-(void)awakeFromNib {
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (!self.hasOriginBeenInitialized) {
        CGPoint midPoint;
        midPoint.x = self.bounds.origin.x + self.bounds.size.width/2;
        midPoint.y = self.bounds.origin.y + self.bounds.size.height/2;
        
        [self setOrigin:midPoint];
    }
    
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];

    CGContextSetLineWidth(context, 1.0);
    [[UIColor blueColor] setStroke];
    
    CGContextBeginPath(context);
    int startPixel = self.bounds.origin.x;
    int endPixel = startPixel + self.bounds.size.width;
    BOOL lastPixelWasNaN = TRUE;
    for (int drawAtPixel = startPixel; drawAtPixel <= endPixel; drawAtPixel++) {
        float xValueAtPixel = (drawAtPixel - self.origin.x) / self.scale;
        float yValue = [self.dataSource valueForXValue:xValueAtPixel];
        if (yValue != NAN) {
            float yPixel = self.origin.y - yValue * self.scale;
            if (lastPixelWasNaN) {
                CGContextMoveToPoint(context, drawAtPixel, yPixel);
            }
            else {
                CGContextAddLineToPoint(context, drawAtPixel, yPixel);
            }
            lastPixelWasNaN = FALSE;
        }
        else {
            lastPixelWasNaN = TRUE;
        }
    }
    CGContextStrokePath(context);
}

@end
