//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Krawczyk, Pete on 9/7/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

-(void)pushOperand:(double)operand;
-(id)performOperation:(NSString *)operation;
-(id)performOperation:(NSString *)operation
            withVariables:(NSDictionary *)variables;
-(void)clearStack;
-(void)undoLastOperation;

@property (readonly) id program;

+(id)runProgram:(id)program;
+(id)runProgram:(id)program
      withVariables:(NSDictionary *)variables;
+(NSSet *)variablesUsedInProgram:(id)program;
+(NSString *)descriptionOfProgram:(id)program;

@end
