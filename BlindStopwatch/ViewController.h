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
#import "Dots.h"
#import "TextArrow.h"

@class RBVolumeButtons;

@interface ViewController : UIViewController <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate, UIGestureRecognizerDelegate>
//@interface ViewController : UIViewController <JBLineChartViewDelegate, JBLineChartViewDataSource>

{

    float launchVolume;
    IBOutlet UILabel *counterLabel;
    IBOutlet UILabel *counterGoalLabel;
    IBOutlet UILabel *nextLevelLabel;
    IBOutlet UILabel *instructionLabel;

    
    IBOutlet UIView *stats;
    UILabel *lastResults;
    UILabel *accuracy;
    UILabel *precision;
    
    IBOutlet UIView *morestats;

    bool running, reset;
    
    NSTimeInterval startTime;
    NSTimeInterval elapsed;
    NSTimeInterval timerGoal;
    NSString *timeValuesFile;
    
    NSInteger nPointsVisible;
    NSArray *dots;
    
    NSMutableArray *levelProgress;
    int maxLevel;
    int currentLevel;

    MPVolumeView *volumeView;
    
    RBVolumeButtons *_buttonStealer;

    TextArrow* instructions;
    
}


void drawLine(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color);
@property (weak, nonatomic) IBOutlet UILabel *screenLabel;

@property (assign, nonatomic) NSInteger indexNumber;

@property (retain) RBVolumeButtons *buttonStealer;


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
