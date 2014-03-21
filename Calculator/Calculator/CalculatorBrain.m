//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Krawczyk, Pete on 9/7/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

+(BOOL)isOperation:(NSString *)operationOrVariable;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

-(NSMutableArray *)programStack {
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

-(void)pushOperand:(double)operand {
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

-(void)clearStack {
    [self.programStack removeAllObjects];
}

-(void)undoLastOperation {
    [self.programStack removeLastObject];
}

-(id)performOperation:(NSString *)operation {
    return [self performOperation:operation withVariables:nil];
}

-(id)performOperation:(NSString *)operation
        withVariables:(NSDictionary *)variables {
    [self.programStack addObject:operation];
    id result = [CalculatorBrain runProgram:self.program withVariables:variables];
    if ([result isKindOfClass:[NSString class]]) {
        [self.programStack removeLastObject];
    }
    return result;
}

-(id)program {
    return [self.programStack copy];
}

+(NSNumber *)operationOperands:(NSString *)operation {
    NSDictionary *operandsRequired = @{
        @"+" : @2,
        @"-" : @2,
        @"*" : @2,
        @"/" : @2,
        @"sqrt" : @1,
        @"sin" : @1,
        @"cos" : @1,
        @"pi" : @0,
        @"+/-" : @1
    };
    return [operandsRequired objectForKey:operation];
}

+(BOOL)isOperation:(NSString *)operationOrVariable {
    NSNumber *operandsRequired = [self operationOperands:operationOrVariable];
    BOOL result = (operandsRequired != nil);
    return result;
}

+(NSString *)descriptionOfProgram:(id)program {
    NSMutableArray *restOfProgram;
    BOOL isTop = FALSE;
    if ([program isKindOfClass:[NSMutableArray class]]) {
        restOfProgram = program;
    }
    else if ([program isKindOfClass:[NSArray class]]) {
        restOfProgram = [program mutableCopy];
        isTop = true;
    }
    else {
        return @"";
    }
    
    id operand = [restOfProgram lastObject];
    if (!operand) {
        return @"";
    }
    [restOfProgram removeLastObject];
    
    NSString *result = @"";
    if ([operand isKindOfClass:[NSNumber class] ]) {
        result = [NSString stringWithFormat:@"%.12g", [operand doubleValue]];
    }
    else if ([operand isKindOfClass:[NSString class]]) {
        if ([self isOperation:operand]) {
            int operandsRequired = [[self operationOperands:operand] integerValue];
            if (operandsRequired == 0) {
                result = operand;
            }
            else if (operandsRequired == 1) {
                result = [NSString stringWithFormat:@"%@(%@)", operand, [self descriptionOfProgram:restOfProgram]];
            }
            else {
                NSString *rightSide = [self descriptionOfProgram:restOfProgram];
                NSString *leftSide = [self descriptionOfProgram:restOfProgram];                
                if ([leftSide rangeOfString:@" "].location != NSNotFound || [leftSide rangeOfString:@" "].location != NSNotFound) {
                    leftSide = [NSString stringWithFormat:@"(%@)", leftSide];
                }
                if ([rightSide rangeOfString:@" "].location != NSNotFound || [rightSide rangeOfString:@" "].location != NSNotFound) {
                    rightSide = [NSString stringWithFormat:@"(%@)", rightSide];
                }
                result = [NSString stringWithFormat:@"%@ %@ %@", leftSide, operand, rightSide];
            }
        }
        else {
            result = operand;
        }
    }
    
    if (isTop && [restOfProgram count] > 0) {
        return [NSString stringWithFormat:@"%@, %@", result, [self descriptionOfProgram:[restOfProgram copy]] ];
    }
    return result;
}

+(id)runProgram:(id)program {
    return [self runProgram:program withVariables:nil];
}

+(id)runProgram:(id)program
  withVariables:(NSDictionary *)variables {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    if ([stack count] == 0) {
        return [NSNumber numberWithInt:0];
    }
    
    return [self popOperandOffStack:stack withVariables:variables];
}

+(NSSet *)variablesUsedInProgram:(id)program {
    NSMutableSet *programVariables = [[NSMutableSet alloc] init];
    if ([program isKindOfClass:[NSArray class]]) {
        for (NSString *operand in program) {
            if ([operand isKindOfClass:[NSString class]]) {
                if (![self isOperation:operand]) {
                    [programVariables addObject:[operand copy]];
                }
            }
        }
    }
    
    if ([[programVariables allObjects] count] > 0) {
        return [programVariables copy];
    }
    return nil;
}

+(id)popOperandOffStack:(NSMutableArray *)stack
          withVariables:(NSDictionary *)variables {
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    }
    
    if (!topOfStack) {
        return @"Insufficient operands present";
    }
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        if (![self isOperation:topOfStack]) {
            if ([variables objectForKey:topOfStack]) {
                result = [[variables objectForKey:topOfStack] doubleValue];
            }
        }
        else {
            double firstOperand = 0;
            double secondOperand = 0;
            
            NSNumber *requiredOperands = [self operationOperands:topOfStack];
            if ([requiredOperands integerValue] >= 1) {
                id popResult = [self popOperandOffStack:stack withVariables:variables];
                if ([popResult isKindOfClass:[NSString class]]) {
                    return popResult;
                }
                firstOperand = [popResult doubleValue];
                
                if ([requiredOperands integerValue] == 2) {
                    popResult = [self popOperandOffStack:stack withVariables:variables];
                    if ([popResult isKindOfClass:[NSString class]]) {
                        return popResult;
                    }
                    secondOperand = [popResult doubleValue];
                }
            }
            
            if ([topOfStack isEqualToString:@"pi"]) {
                result = M_PI;
            }
            else if ([topOfStack isEqualToString:@"sqrt"]) {
                if (firstOperand >= 0) {
                    result = sqrt(firstOperand);
                }
                else {
                    return @"Attempted to take the square root of a negative number";
                }
            }
            else if ([topOfStack isEqualToString:@"sin"]) {
                result = sin(firstOperand);
            }
            else if ([topOfStack isEqualToString:@"cos"]) {
                result = cos(firstOperand);
            }
            else if ([topOfStack isEqualToString:@"+/-"]) {
                result = (-1) * firstOperand;
            }
            else  if ([topOfStack isEqualToString:@"+"]) {
                result = secondOperand + firstOperand;
            }
            else if ([topOfStack isEqualToString:@"-"]) {
                result = secondOperand - firstOperand;
            }
            else if ([topOfStack isEqualToString:@"*"]) {
                result = secondOperand * firstOperand;
            }
            else if ([topOfStack isEqualToString:@"/"]) {
                if (firstOperand != 0) {
                    result = secondOperand / firstOperand;
                }
                else {
                    return @"Attempted to divide by zero.";
                }
            }
            else {
                return [NSString stringWithFormat:@"Unknown operation attempted: %@", topOfStack];
            }
        }
    }
    
    
    return [NSNumber numberWithDouble:result];
}

@end
