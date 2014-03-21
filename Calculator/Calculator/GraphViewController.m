//
//  GraphViewController.m
//  Calculator
//
//  Created by Krawczyk, Pete on 10/19/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "GraphViewController.h"
#import "AxesDrawer.h"
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, weak) IBOutlet UILabel *formula;
@property (nonatomic) NSString *formulaText;
@end

@implementation GraphViewController

@synthesize program = _program;
@synthesize graphView = _graphView;
@synthesize formula = _formula;

-(void)setProgram:(id)program {
    _program = program;
    
    NSString *newFormula = [CalculatorBrain descriptionOfProgram:program];
    NSRange formulaRange = [newFormula rangeOfString:@","];
    if (formulaRange.location != NSNotFound) {
        newFormula = [newFormula substringToIndex:formulaRange.location];
    }
    self.formulaText = [newFormula copy];
    [self.graphView setNeedsDisplay];
}

-(void)setGraphView:(GraphView *)graphView {
    _graphView = graphView;
    self.graphView.dataSource = self;
}

-(float)valueForXValue:(float)xValue {
    id result = [CalculatorBrain runProgram:self.program withVariables:@{@"x":[NSNumber numberWithFloat:xValue]}];
    if ([result isKindOfClass:[NSNumber class]]) {
        return [result floatValue];
    }
    return NAN;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // can't do this in setProgram because the IBOutlet has not yet
    // been created...
    self.formula.text = self.formulaText;
}

- (void)viewDidUnload {
    [self setFormula:nil];
    [super viewDidUnload];
}
@end
