//
//  ViewController.h
//  VolumeSnap
//
//  Created by Randall Brown on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
//#import "BEMSimpleLineGraphView.h"
#import "Dots.h"
#import "TextArrow.h"
#import <Parse/Parse.h>
#import "Level.h"
#import "LevelProgressView.h"
#import <GameKit/GameKit.h>
#import "BFPaperButton.h"

@class RBVolumeButtons;

@interface ViewController : UIViewController <GKGameCenterControllerDelegate, UIAlertViewDelegate>  //<BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>
//@interface ViewController : UIViewController <JBLineChartViewDelegate, JBLineChartViewDataSource>

{
    int screenWidth,screenHeight;
    RBVolumeButtons *_buttonStealer;
    int trialSequence;
    int lastStage;

    
    //timing
    NSTimeInterval startTime;
    NSTimeInterval elapsed;
    NSTimeInterval timerGoal;
    NSString *timeValuesFile;
    
    NSInteger nPointsVisible;
    
    
    //points
    float best;
    float experiencePoints;
    int currentLevel;
    
    int life;
    float start;
    CGPoint offset;
    BOOL practicing;
    
    
    //progressView
    LevelProgressView *progressView;
    
    UILabel *bestLabel;
    UILabel *highScoreLabel;
    NSMutableArray *dots;
    
    BFPaperButton *restartExpandButton;
    UIButton *restartButton;
    UIButton *playButton;
    UIButton *trophyButton;
    UIButton *medalButton;
    
    NSMutableArray * stageLabels;
    int resetCountdown;

    
    //self.view
    UIView *labelContainer;
     UILabel *counterLabel;
     UILabel *counterGoalLabel;
    UILabel *goalPrecision;
    NSMutableArray *hearts;

    IBOutlet UILabel *differencelLabel;
    
    TextArrow* instructions;
    TextArrow* levelAlert;
    NSMutableArray * levelArrows;
    UIButton *nextButton;
    UIButton *shareButton;
    UIView *blob;

    Dots *mainDot;
    NSArray *satellites;
    
    UIImageView * xView;
    UIImageView * oView;
    
    IBOutlet UILabel *nextLevelLabel;

    
    UIVisualEffectView *labelContainerBlur;
    
    UIVisualEffectView *blobBlur;

//    IBOutlet UIView *stats;
//    UILabel *lastResults;
//    UILabel *accuracy;
//    UILabel *precision;
    

    
    
}


void drawLine(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color);
@property (weak, nonatomic) IBOutlet UILabel *screenLabel;
@property (assign, nonatomic) NSInteger indexNumber;
@property (retain) RBVolumeButtons *buttonStealer;
//@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *myGraph;
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
