//
//  PsychologistViewController.m
//  Psychologist
//
//  Created by Krawczyk, Pete on 10/19/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "PsychologistViewController.h"
#import "HappinessViewController.h"

@interface PsychologistViewController ()

@property (nonatomic) int diagnosis;

@end

@implementation PsychologistViewController

@synthesize diagnosis = _diagnosis;

-(void)setAndShowDiagnosis:(int)diagnosis {
    self.diagnosis = diagnosis;
    [self performSegueWithIdentifier:@"ShowDiagnosis" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowDiagnosis"]) {
        [segue.destinationViewController setHappiness:self.diagnosis];
    }
    else if ([segue.identifier isEqualToString:@"CelebritySegue"]) {
        [segue.destinationViewController setHappiness:100];
    }
    else if ([segue.identifier isEqualToString:@"SeriousSegue"]) {
        [segue.destinationViewController setHappiness:20];
    }
    else if ([segue.identifier isEqualToString:@"TV Kook"]) {
        [segue.destinationViewController setHappiness:50];
    }
}

- (IBAction)flying:(id)sender {
    [self setAndShowDiagnosis:85];
}
- (IBAction)apple:(id)sender {
    [self setAndShowDiagnosis:100];
}
- (IBAction)dragons:(id)sender {
    [self setAndShowDiagnosis:20];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
