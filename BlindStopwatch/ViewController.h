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
#import <Parse/Parse.h>
#import "Level.h"
#import "LevelProgressView.h"
#import <GameKit/GameKit.h>

@class RBVolumeButtons;

@interface ViewController : UIViewController <GKGameCenterControllerDelegate, UIAlertViewDelegate>  //<BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>
//@interface ViewController : UIViewController <JBLineChartViewDelegate, JBLineChartViewDataSource>

{
    
    LevelProgressView *progressView;
    
    int screenWidth,screenHeight;
    
    
    UIView *labelContainer;
     UILabel *counterLabel;
     UILabel *counterGoalLabel;
    IBOutlet UILabel *differencelLabel;
    
    TextArrow* instructions;
    TextArrow* levelAlert;
    NSMutableArray * levelArrows;
    UIButton *nextButton;
    
    IBOutlet UILabel *nextLevelLabel;
    
    UILabel *goalPrecision;
    
    UIVisualEffectView *labelContainerBlur;

    
    
    UIVisualEffectView *blobBlur;

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

    
    float bestScore;
    int currentLevel;
    

    RBVolumeButtons *_buttonStealer;
    
    float resetCounter;
    
    Dots *mainDot;
    NSArray *satellites;
    
    Dots * highScoreDot;
    UILabel *highScoreLabel;

    //UIView * blob;
    NSMutableArray *dots;
    NSMutableArray *hearts;
    int life;
    NSArray *levels;
    
    float start;
    CGPoint offset;
    
    int trialSequence;
    
    UIImageView * xView;
    UIImageView * oView;
    
    NSMutableArray * stageLabels;
    
    int resetCountdown;
    UIButton *restartButton;
    UIButton *playButton;

    int lastStage;
    
    BOOL practicing;
    UIView *blob;
    
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

@property BOOL gameCenterEnabled;
@property NSString *leaderboardIdentifier;

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard;

@end
