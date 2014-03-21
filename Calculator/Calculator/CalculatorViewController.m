//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Krawczyk, Pete on 9/7/12. Yay!
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSMutableDictionary *variableValues;

@end

@implementation CalculatorViewController

@synthesize brain = _brain;
@synthesize display = _display;
@synthesize history = _history;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize variableValues = _variableValues;

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DrawGraph"]) {
        if (self.userIsInTheMiddleOfEnteringANumber) {
            [self enterPressed];
        }
        [segue.destinationViewController setProgram:self.brain.program];
    }
}

-(CalculatorBrain *)brain {
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

-(NSMutableDictionary *)variableValues {
    if (!_variableValues) {
        _variableValues = [[NSMutableDictionary alloc] init];
    }
    return _variableValues;
}

-(void)clearEnterFromHistory {
    NSRange foundEnter = [self.history.text rangeOfString:@"="];
    if (foundEnter.location != NSNotFound) {
        NSUInteger newHistoryLength = foundEnter.location - 1;
        self.history.text = [self.history.text substringToIndex:newHistoryLength];
    }
    return;
}

-(void)updateProgramViewState:(id)result {
    self.userIsInTheMiddleOfEnteringANumber = NO;
    if ([result isKindOfClass:[NSString class]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calculation Error"
                                                        message:result
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        self.display.text = @"E";
    }
    else if ([result isKindOfClass:[NSNumber class]]) {
        self.display.text = [NSString stringWithFormat:@"%.12g", [result doubleValue]];
    }
    self.history.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    return;
}


- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber && !(
        [self.display.text rangeOfString:@"."].location == NSNotFound &&
        [self.display.text doubleValue] == 0
    )) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    }
    else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
        [self clearEnterFromHistory];
    }
    return;
}

-(IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    [self updateProgramViewState:[self.brain performOperation:sender.currentTitle withVariables:[self.variableValues copy]]];
    return;
}

- (IBAction)enterPressed {
    [self clearEnterFromHistory];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self.brain pushOperand:[self.display.text doubleValue]];
    [self updateProgramViewState:[CalculatorBrain runProgram:self.brain.program withVariables:[self.variableValues copy]]];
    return;
}

- (IBAction)periodPressed {
    if (!self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = @"0";
        self.userIsInTheMiddleOfEnteringANumber = YES;
        [self clearEnterFromHistory];
    }
    if ([self.display.text rangeOfString:@"."].location == NSNotFound) {
        self.display.text = [self.display.text stringByAppendingString:@"."];
    }
    return;
}

- (IBAction)clearPressed {
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self.brain clearStack];
    [self.variableValues removeAllObjects];
    [self updateProgramViewState:[NSNumber numberWithInt:0]];
    return;
}

- (IBAction)backspacePressed {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        NSInteger lengthShowing = [self.display.text length];
        if (lengthShowing > 0) {
            lengthShowing = lengthShowing - 1;
            self.display.text = [self.display.text substringToIndex:lengthShowing];
            if ([self.display.text isEqualToString:@"-"]) {
                lengthShowing = 0;
            }
        }
        if (lengthShowing == 0) {
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    }
    else {
        [self.brain undoLastOperation];
        [self updateProgramViewState:[CalculatorBrain runProgram:self.brain.program withVariables:[self.variableValues copy]]];
    }
    return;
}

- (IBAction)signChangePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text rangeOfString:@"-"].location == NSNotFound) {
            self.display.text = [@"-" stringByAppendingString:self.display.text];
        }
        else {
            self.display.text = [self.display.text substringFromIndex:1];
        }
    }
    else {
        [self operationPressed:sender];
    }
    return;
}

- (IBAction)variablePressed:(UIButton *)sender {
    [self operationPressed:sender];
}

-(void)viewDidLoad {
    [super viewDidLoad];
}

@end
