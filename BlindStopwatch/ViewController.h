//
//  ViewController.h
//  VolumeSnap
//
//  Created by Randall Brown on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BEMSimpleLineGraphView.h"


@class RBVolumeButtons;

@interface ViewController : UIViewController <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate, UIGestureRecognizerDelegate>
//@interface ViewController : UIViewController <JBLineChartViewDelegate, JBLineChartViewDataSource>

{
   float launchVolume;
   IBOutlet UILabel *counterLabel;
   
   RBVolumeButtons *_buttonStealer;
    bool running, reset;
    NSTimeInterval startTime;
    NSTimeInterval elapsed;
    NSTimeInterval timerGoal;
    NSString *timeValuesFile;
    
    UILabel *instructionLabel;
    NSInteger nPointsVisible;
    
}



@property (strong) RBVolumeButtons *buttonStealer;
//- (IBAction)startStealing:(id)sender;
//- (IBAction)stopStealing:(id)sender;




@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *myGraph;

@property (strong, nonatomic) NSMutableArray *ArrayOfValues;
@property (strong, nonatomic) NSMutableArray *ArrayOfDates;
@property (strong, nonatomic) NSMutableDictionary *TimeData;

@property (strong, nonatomic) IBOutlet UILabel *labelValues;
@property (strong, nonatomic) IBOutlet UILabel *labelDates;

//- (IBAction)refresh:(id)sender;
//- (IBAction)addOrRemoveLineFromGraph:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *graphColorChoice;
@property (weak, nonatomic) IBOutlet UIStepper *graphObjectIncrement;

//- (IBAction)displayStatistics:(id)sender;




@end
