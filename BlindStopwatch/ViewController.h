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
#import "ASCView.h"
#import <Parse/Parse.h>
#import "Level.h"

@class RBVolumeButtons;

@interface ViewController : UIViewController <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>
//@interface ViewController : UIViewController <JBLineChartViewDelegate, JBLineChartViewDataSource>

{

    int screenWidth,screenHeight;
    
    float launchVolume;
    IBOutlet UILabel *counterLabel;
    IBOutlet UILabel *counterGoalLabel;
    IBOutlet UILabel *nextLevelLabel;
    
    UILabel *goalPrecision;

    
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
    
    NSMutableArray *levelData;
    int maxLevel;
    int currentLevel;

    MPVolumeView *volumeView;
    
    RBVolumeButtons *_buttonStealer;

    TextArrow* instructions;
    
    ASCView * ascView;
    float resetCounter;
    
    NSArray *dots;
    
    Dots *mainDot;
    NSArray *satellites;
    UIView * blob;
    
    NSArray *levels;
    
    float start;
    CGPoint offset;
    
    int trialSequence;

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
