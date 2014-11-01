#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
//#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )
#import "RBVolumeButtons.h"

//#include <assert.h>
//#include <mach/mach.h>
//#include <mach/mach_time.h>
//#include <unistd.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

#define NUMLEVELARROWS 5

#define TRIALSINSTAGE 5
#define NUMHEARTS 3
#define SHOWNEXTRASTAGES 3

@interface ViewController () {
    
}
@end

@implementation ViewController


@synthesize buttonStealer = _buttonStealer;
@synthesize screenLabel,indexNumber; 

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
   [super viewDidLoad];
    
    screenHeight=self.view.frame.size.height;
    screenWidth=self.view.frame.size.width;

    trialSequence=-1;

    
    int vbuttonY=137;//5s
    if(IS_IPAD)vbuttonY=237;
    else if(IS_IPHONE_6)vbuttonY=145;
    else if(IS_IPHONE_6_PLUS)vbuttonY=155;
    else if(IS_IPHONE_5)vbuttonY=128;
    else if(IS_IPHONE)vbuttonY=95;

    //instructions
    instructions=[[TextArrow alloc ] initWithFrame:CGRectMake(screenWidth, vbuttonY, screenWidth-8, 44)];
    [self.view addSubview:instructions];
    
    
    /* Create the Tap Gesture Recognizer */
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)];
//    tapGestureRecognizer.numberOfTouchesRequired = 1;
//    tapGestureRecognizer.numberOfTapsRequired = 1;
//    [instructions addGestureRecognizer:tapGestureRecognizer];
//    instructions.userInteractionEnabled = YES;


    
    labelContainer=[[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:labelContainer];
    [self.view bringSubviewToFront:instructions];
    
    //set position relative to instruction arrow
    counterLabel=[[UILabel alloc]init];
    counterLabel.font = [UIFont fontWithName:@"DIN Condensed" size:screenWidth*.33];
    counterLabel.adjustsFontSizeToFitWidth = YES;
    counterLabel.textColor=[UIColor whiteColor];
    counterLabel.textAlignment=NSTextAlignmentCenter;
    counterLabel.frame=CGRectMake(0,0, screenWidth, screenWidth*.35);
    //counterLabel.center=CGPointMake(screenWidth*.5, instructions.frame.origin.y-counterLabel.frame.size.height*.30);
    counterLabel.clipsToBounds=NO;
    [labelContainer addSubview:counterLabel];
    
    counterGoalLabel=[[UILabel alloc]init];
    counterGoalLabel.font = [UIFont fontWithName:@"DIN Condensed" size:screenWidth*.33];
    counterGoalLabel.adjustsFontSizeToFitWidth = YES;
    counterGoalLabel.textColor=[UIColor whiteColor];
    counterGoalLabel.textAlignment=NSTextAlignmentCenter;
    counterGoalLabel.frame=CGRectMake(0,0, screenWidth, screenWidth*.35);
    //counterGoalLabel.center=CGPointMake(screenWidth*.5, instructions.frame.origin.y+instructions.frame.size.height+counterGoalLabel.frame.size.height*.55);
    counterGoalLabel.clipsToBounds=NO;
    [self.view addSubview:counterGoalLabel];
    
    counterGoalLabel.center=CGPointMake(screenWidth*.5, instructions.frame.origin.y-counterLabel.frame.size.height*.30);
    counterLabel.center=CGPointMake(screenWidth*.5, instructions.frame.origin.y+instructions.frame.size.height+counterGoalLabel.frame.size.height*.55);

    
    UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)];
    tapGestureRecognizer3.numberOfTouchesRequired = 1;
    tapGestureRecognizer3.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer3];
    self.view.userInteractionEnabled = YES;

    
    //goalPrecision=[[UILabel alloc] initWithFrame:CGRectMake(counterGoalLabel.frame.size.width*.5, counterGoalLabel.frame.size.height-30, counterGoalLabel.frame.size.width*.5-13, 40)];
    goalPrecision=[[UILabel alloc] initWithFrame:CGRectMake(counterGoalLabel.frame.size.width*.5, -30, counterGoalLabel.frame.size.width*.5-13, 40)];
    goalPrecision.font = [UIFont fontWithName:@"DIN Condensed" size:22.0];
    goalPrecision.textAlignment=NSTextAlignmentRight;
    goalPrecision.textColor = [UIColor whiteColor];
    goalPrecision.text = @"";
    [counterGoalLabel addSubview:goalPrecision];
    
    levelArrows=[[NSMutableArray alloc] init];
    for (int i=0; i<NUMLEVELARROWS; i++) {
        TextArrow *arrow;
        if(i==0)arrow=[[TextArrow alloc ] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight*.075)];
        else if(i==1)arrow=[[TextArrow alloc ] initWithFrame:CGRectMake(0,0, screenWidth, screenHeight*.065)];
        else if(i==2)arrow=[[TextArrow alloc ] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight*.055)];
        else arrow=[[TextArrow alloc ] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight*.045)];

        arrow.drawArrow=false;
        arrow.rightLabel.textColor=[UIColor blackColor];
        [levelArrows addObject:arrow];
        [self.view addSubview:arrow];
        [self.view sendSubviewToBack:arrow];
        [arrow slideDown:0];
    }
    
    levelAlert=[[TextArrow alloc ] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight*.125)];
    [levelAlert slideDown:0];
    levelAlert.drawArrow=false;
    [self.view addSubview:levelAlert];
    [self.view sendSubviewToBack:levelAlert];
    levelAlert.userInteractionEnabled=YES;

    nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * next=[UIImage imageNamed:@"next"];
    next = [next imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [nextButton setBackgroundImage:next forState:UIControlStateNormal];
    [nextButton adjustsImageWhenHighlighted];
    [nextButton setFrame:CGRectMake(0,0,levelAlert.frame.size.height*.85,levelAlert.frame.size.height*.85)];
    nextButton.center=CGPointMake( levelAlert.frame.size.width-nextButton.frame.size.width*.5-10,levelAlert.frame.size.height/2.0);
    [nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    nextButton.userInteractionEnabled=YES;
    [levelAlert addSubview:nextButton];
    
    shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * share=[UIImage imageNamed:@"share"];
    share = [share imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [shareButton setBackgroundImage:share forState:UIControlStateNormal];
    [shareButton adjustsImageWhenHighlighted];
    [shareButton setFrame:CGRectMake(0,0,levelAlert.frame.size.height*.85,levelAlert.frame.size.height*.85)];
    shareButton.center=CGPointMake(shareButton.frame.size.width*.5+10,levelAlert.frame.size.height/2.0);
    [shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    shareButton.userInteractionEnabled=YES;
    [levelAlert addSubview:shareButton];
    


    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"currentLevel"] == nil) currentLevel=0;
    else currentLevel = (int)[defaults integerForKey:@"currentLevel"];
    
    if([defaults objectForKey:@"best"] == nil) best=0;
    else best = (int)[defaults integerForKey:@"best"];
    
    if([defaults objectForKey:@"highScore"] == nil) experiencePoints=0;
    else experiencePoints = (int)[defaults integerForKey:@"highScore"];
    
    if([defaults objectForKey:@"practicing"] == nil) practicing=false;
    else practicing = (int)[defaults integerForKey:@"practicing"];
    

    //currentLevel=22;
    
    //[self loadData:currentLevel];
    //[self loadLevelProgress];
    
    //buttonstealer
    id progressDelegate = self;
    self.buttonStealer = [[RBVolumeButtons alloc] init];
    self.buttonStealer.upBlock = ^{
        [progressDelegate buttonPressed];
    };
    self.buttonStealer.downBlock = ^{
        [progressDelegate buttonPressed];
    };
    [self.buttonStealer startStealingVolumeButtonEvents];

    

    
    

    
    //dot array for level progress
    progressView=[[LevelProgressView alloc] initWithFrame:CGRectMake(0, screenHeight, self.view.frame.size.width, self.view.frame.size.height*2.0)];
    progressView.clipsToBounds=YES;
    [self.view addSubview:progressView];
    progressView.backgroundColor=[self getForegroundColor:currentLevel];

    
    trophyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * trophy=[UIImage imageNamed:@"trophy"];
    trophy = [trophy imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [trophyButton setBackgroundImage:trophy forState:UIControlStateNormal];
    [trophyButton adjustsImageWhenHighlighted];
    [trophyButton setFrame:CGRectMake(0,0,44,44)];
    trophyButton.center=CGPointMake(screenWidth/2.0, screenHeight-60);
    [trophyButton addTarget:self action:@selector(showGlobalLeaderboard) forControlEvents:UIControlEventTouchUpInside];
    [progressView addSubview:trophyButton];
    
    
    medalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * medal=[UIImage imageNamed:@"medal"];
    medal = [medal imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [medalButton setBackgroundImage:medal forState:UIControlStateNormal];
    [medalButton adjustsImageWhenHighlighted];
    [medalButton setFrame:CGRectMake(0,0,44,44)];
    medalButton.center=CGPointMake(screenWidth*1.0/5.0, screenHeight-60);
    [medalButton addTarget:self action:@selector(showXPLeaderboard) forControlEvents:UIControlEventTouchUpInside];
    [progressView addSubview:medalButton];
    
    

    bestLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,screenWidth,26)];
    bestLabel.center=CGPointMake(screenWidth*.5, trophyButton.frame.origin.y+trophyButton.frame.size.height+15);
    bestLabel.textAlignment=NSTextAlignmentCenter;
    bestLabel.font=[UIFont fontWithName:@"DIN Condensed" size:22.0];
    [progressView addSubview:bestLabel];
    
    
    highScoreLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,screenWidth,26)];
    highScoreLabel.center=CGPointMake(screenWidth/5.0, medalButton.frame.origin.y+medalButton.frame.size.height+15);
    highScoreLabel.textAlignment=NSTextAlignmentCenter;
    highScoreLabel.font=[UIFont fontWithName:@"DIN Condensed" size:22.0];
    [progressView addSubview:highScoreLabel];
    [self updateHighscore];

    restartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * restart=[UIImage imageNamed:@"restart"];
    restart = [restart imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [restartButton setBackgroundImage:restart forState:UIControlStateNormal];
    [restartButton adjustsImageWhenHighlighted];
    [restartButton setFrame:CGRectMake(0,0,44,44)];
    restartButton.center=CGPointMake(screenWidth*4/5.0, screenHeight-60);
    [restartButton addTarget:self action:@selector(restart) forControlEvents:UIControlEventTouchUpInside];
    [progressView addSubview:restartButton];
    
    
   restartExpandButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(0, 0, 44,44) raised:NO];
    restartExpandButton.center=restartButton.center;
    [restartExpandButton addTarget:self action:@selector(restartButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    restartExpandButton.cornerRadius = restartExpandButton.frame.size.width / 2;
    restartExpandButton.tapCircleDiameter = screenHeight*2.05;
    restartExpandButton.rippleFromTapLocation=NO;
    restartExpandButton.rippleBeyondBounds=YES;
    restartExpandButton.usesSmartColor=NO;
    [progressView addSubview:restartExpandButton];
    
    
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * play=[UIImage imageNamed:@"next"];
    play = [play imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [playButton setBackgroundImage:play forState:UIControlStateNormal];
    [playButton adjustsImageWhenHighlighted];
    [playButton setFrame:CGRectMake(0,0,44,44)];
    [playButton addTarget:self action:@selector(restartFromLastStage) forControlEvents:UIControlEventTouchUpInside];
    [progressView addSubview:playButton];
    [progressView bringSubviewToFront:playButton];
    playButton.alpha=0;


    
    //Dots
    dots=[NSMutableArray array];
    stageLabels=[NSMutableArray array];


    //[self updateDots];
    //[self updateTimeDisplay:0];
    
    
    
    ///*
    nPointsVisible=40;
    self.myGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth-22, screenHeight*.5)];
    self.myGraph.delegate = self;
    self.myGraph.dataSource = self;
    self.myGraph.colorTop =[UIColor clearColor];
    self.myGraph.colorBottom =[UIColor clearColor];

    self.myGraph.colorLine = [UIColor blackColor];
    self.myGraph.colorXaxisLabel = [UIColor blackColor];
    self.myGraph.colorYaxisLabel = [UIColor blackColor];
    self.myGraph.colorPoint=[UIColor blackColor];
    self.myGraph.widthLine = 2.0;
    self.myGraph.animationGraphStyle = BEMLineAnimationDraw;
    self.myGraph.enableTouchReport = YES;
    self.myGraph.enablePopUpReport = YES;
    self.myGraph.autoScaleYAxis = YES;
    
    self.myGraph.animationGraphEntranceTime = 0.8;
    //myGraph.alphaTop=.2;
    //myGraph.enableBezierCurve = YES;
    //myGraph.alwaysDisplayDots = YES;
    //self.myGraph.enableReferenceAxisLines = YES;
    //self.myGraph.enableYAxisLabel = YES;
    //self.myGraph.alwaysDisplayPopUpLabels = YES;
    
    //self.myGraph.userInteractionEnabled=YES;
    //self.myGraph.multipleTouchEnabled=YES;
    
    [progressView addSubview:self.myGraph];
    
    //    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    //    [pinch setDelegate:self];
    //    [self.myGraph addGestureRecognizer:pinch];
    //*/
    
    //stats
    /*
     UIFont * LF=[UIFont fontWithName:@"HelveticaNeue" size:32];
     UIFont * SMF=[UIFont fontWithName:@"HelveticaNeue" size:8];
     
     lastResults=[[UILabel alloc] initWithFrame:CGRectMake(0, 8, 50, 50)];
     lastResults.font = LF;
     lastResults.textColor =  [UIColor blackColor];
     [stats addSubview:lastResults];
     
     accuracy=[[UILabel alloc] initWithFrame:CGRectMake(stats.frame.size.width*.33, 8, 40, 50)];
     accuracy.font = LF;
     accuracy.textColor =  [UIColor blackColor];
     [stats addSubview:accuracy];
     
     precision=[[UILabel alloc] initWithFrame:CGRectMake(stats.frame.size.width*.66, 8, 50, 50)];
     precision.font = LF;
     precision.textColor =  [UIColor blackColor];
     precision.adjustsFontSizeToFitWidth=YES;
     [stats addSubview:precision];
     
     
     //UNITS
     UILabel* precisionUnit=[[UILabel alloc] initWithFrame:CGRectMake(precision.frame.origin.x+precision.frame.size.width, 0, 80, 50)];
     precisionUnit.text=@"ms";
     precisionUnit.font = SMF;
     [stats addSubview:precisionUnit];
     
     UILabel* accuracyUnit=[[UILabel alloc] initWithFrame:CGRectMake(accuracy.frame.origin.x+accuracy.frame.size.width, 0, 80, 50)];
     accuracyUnit.text=@"%";
     accuracyUnit.font = SMF;
     [stats addSubview:accuracyUnit];
     
     
     //LABELS
     float y=stats.frame.size.height-15;
     
     UILabel* lastResultLabel=[[UILabel alloc] initWithFrame:CGRectMake(lastResults.frame.origin.x, y, stats.frame.size.width*.33-12, 20)];
     lastResultLabel.text=@"LAST RESULTS";
     [lastResultLabel setTextAlignment:NSTextAlignmentRight];
     lastResultLabel.font = SMF;
     [stats addSubview:lastResultLabel];
     
     UILabel* accuracyLabel=[[UILabel alloc] initWithFrame:CGRectMake(accuracy.frame.origin.x, y, stats.frame.size.width*.33-12, 20)];
     accuracyLabel.text=@"ACCURACY";
     [accuracyLabel setTextAlignment:NSTextAlignmentRight];
     accuracyLabel.font = SMF;
     [stats addSubview:accuracyLabel];
     
     UILabel* precisionLabel=[[UILabel alloc] initWithFrame:CGRectMake(precision.frame.origin.x, y, stats.frame.size.width*.33-12, 20)];
     precisionLabel.text=@"PRECISION";
     [precisionLabel setTextAlignment:NSTextAlignmentRight];
     precisionLabel.font = SMF;
     [stats addSubview:precisionLabel];
     */
    
    
    
    
    //life hearsts
    if([defaults objectForKey:@"life"] == nil) life=NUMHEARTS;
    else life = (int)[defaults integerForKey:@"life"];
    hearts=[[NSMutableArray alloc]init];


    //big dot
    
    blob=[[UIView alloc] init];
    [self.view addSubview:blob];

    
    //set blob frame
    [self resetMainDot];
    
    
    mainDot = [[Dots alloc] init];
    mainDot.alpha = 1;
    mainDot.backgroundColor = [UIColor clearColor];
    [mainDot setFill:YES];
    [mainDot setClipsToBounds:NO];
    [self resetMainDot];
    [blob addSubview:mainDot];
    

    //mainDot.userInteractionEnabled = YES;
    //blob.userInteractionEnabled = YES;
    //self.view.userInteractionEnabled=YES;
//    UISwipeGestureRecognizer *swipeUpDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
//    [swipeUpDown setDirection:(UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown )];
//    [self.view addGestureRecognizer:swipeUpDown];
//    
    
    //satellites
    satellites=[NSArray array];
    for (int i=0;i<10;i++){
        Dots *sat = [[Dots alloc] init];
        sat.alpha = 1;
        sat.backgroundColor = [UIColor clearColor];
        [sat setFill:YES];
        [sat setClipsToBounds:NO];
        satellites = [satellites arrayByAddingObject:sat];
        [blob addSubview:satellites[i]];
    }
    [self setupSatellites];
    
    
    UIBlurEffect *blurEffect= [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    labelContainerBlur = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    labelContainerBlur.frame = self.view.bounds;
    labelContainerBlur.alpha=0;
    [labelContainer addSubview:labelContainerBlur];
    
    //labelContainer.userInteractionEnabled=YES;
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)];
//    tapGestureRecognizer.numberOfTouchesRequired = 1;
//    tapGestureRecognizer.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:tapGestureRecognizer];
//    
    blobBlur = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blobBlur.frame = self.view.bounds;
    blobBlur.alpha=1.0;
    [blob addSubview:blobBlur];
    //blobBlur.userInteractionEnabled = YES;

    
    xView=[[UIImageView alloc] init];
    [xView setImage:[[UIImage imageNamed: @"x"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self.view addSubview:xView];
    [self.view bringSubviewToFront:xView];
    
    xView.alpha=0;

    oView=[[UIImageView alloc] init];
    [oView setImage:[[UIImage imageNamed: @"o"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self.view addSubview:oView];
    [self.view bringSubviewToFront:oView];
    oView.alpha=0;
    [self xoViewOffScreen];

    
    [self.view sendSubviewToBack:progressView];
    [self.view sendSubviewToBack:blob];

    //game center
    [self authenticateLocalPlayer];
    
    
    if(life==0)[self restart];
    

}

-(void)restartButtonPressed{
    
    if(!restartExpandButton.growthFinished)return;
    [self restart];
}

-(void) restart{
    
    //set life asap so countdown timer stops
    life=NUMHEARTS;

    [UIView animateWithDuration:0.8
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         progressView.centerMessage.alpha=0;
                         progressView.subMessage.alpha=0;
                         progressView.lowerMessage.alpha=0;
                         playButton.alpha=0.0;
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:.8
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         restartButton.center=CGPointMake(screenWidth*4/5.0, screenHeight-60);
                     }
                     completion:^(BOOL finished){
                     }];
    

    
    
    for (int i=0; i<dots.count; i++){
        Dots* d=[dots objectAtIndex:i];
        
        [UIView animateWithDuration:0.6
                              delay:(arc4random()%1000)*.001
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             d.frame=CGRectOffset(d.frame, 0, screenHeight);
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
    
    for (int i=0; i<stageLabels.count; i++){
        TextArrow* sl=[stageLabels objectAtIndex:i];
        
        [UIView animateWithDuration:0.6
                              delay:(arc4random()%1000)*.001
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             sl.frame=CGRectOffset(sl.frame, 0, screenHeight);
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
    
    
    
    [self performSelector:@selector(setupGame) withObject:self afterDelay:1.5];

}

-(void)setupGame{
    [self removeDots];
    
    currentLevel=0;
    trialSequence=-1;
    progressView.centerMessage.text=@"";
    progressView.subMessage.text=@"";
    practicing=false;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:practicing forKey:@"practicing"];
    [defaults synchronize];

    //setup new dots
    life=NUMHEARTS;
    [self setupDots];
    [self updateLife];
    
}

-(void) restartFromLastStage{
    
    [UIView animateWithDuration:0.8
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         progressView.centerMessage.alpha=0;
                         progressView.subMessage.alpha=0;
                         progressView.lowerMessage.alpha=0;
                         playButton.alpha=0.0;
                     }
                     completion:^(BOOL finished){
                     }];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:.8
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         restartButton.center=CGPointMake(screenWidth*4/5.0, screenHeight-60);
                     }
                     completion:^(BOOL finished){
                     }];
    

    [self removeDots];

    experiencePoints-=lastStage*10.0;
    
    
    life=NUMHEARTS;
    currentLevel=lastStage*TRIALSINSTAGE;
    trialSequence=-1;
    progressView.centerMessage.text=@"";
    progressView.subMessage.text=@"";
    //practicing=true;
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setInteger:practicing forKey:@"practicing"];
    //[defaults synchronize];
    
    //setup new dots
    [self setupDots];
    [self updateLife];

}

-(void)addHeart:(int)i{
    UIImageView * heart=[[UIImageView alloc] init];
    [heart setImage:[[UIImage imageNamed: @"heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    heart.alpha=0.0;
    heart.frame=CGRectMake(16+(screenWidth-16)/10.0*(i%10), screenHeight+100,15,15);
    [hearts addObject:heart];
    [labelContainer addSubview:hearts[i]];
    [labelContainer sendSubviewToBack:hearts[i]];
}
-(void)updateHighscore{
    if(best>0) bestLabel.text=[NSString stringWithFormat:@"BEST %.01f",best];
    if(experiencePoints>0) {
        if (experiencePoints<10000) highScoreLabel.text=[NSString stringWithFormat:@"$%.02f",experiencePoints];
        else highScoreLabel.text=[NSString stringWithFormat:@"%i",(int)experiencePoints];
    }
        
        
}

-(int)getCurrentStage{
    return floorf(currentLevel/TRIALSINSTAGE);
}

-(void)removeDots{
    
    for (int i = 0; i < [dots count];i++){
        
        Dots *d=[dots objectAtIndex:i ];
        [d setFill:NO];
        [d setText:@"" level:@""];
        [d setStars:0];
        [d removeFromSuperview];
        
        
        //remove stagelabels
        if(i%TRIALSINSTAGE==0){
            int stage=floorf(i/TRIALSINSTAGE);
            TextArrow *sLabel=[stageLabels objectAtIndex:stage];
            sLabel.alpha=0;
            [sLabel removeFromSuperview];
        }
    }
    
    [dots removeAllObjects];
    [stageLabels removeAllObjects];
}

-(void)setupDots{
    int rowHeight=60;

            [self.view bringSubviewToFront:progressView];
             float d=.5;
             if(progressView.frame.origin.y==0)d=0.0;//progressview is already showing. don't animate
             

                [UIView animateWithDuration:.8
                                      delay:d
                     usingSpringWithDamping:.8
                      initialSpringVelocity:1.0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     progressView.frame=CGRectMake(0, 0, screenWidth, screenHeight*2.0);
                                     progressView.dotsContainer.frame=CGRectMake(0, 22, screenWidth, screenHeight*2.0);
                                     
                                 }
                                 completion:^(BOOL finished){

                                     int nDotsToShow=TRIALSINSTAGE+[self getCurrentStage]*TRIALSINSTAGE;

                                     if(nDotsToShow<TRIALSINSTAGE*SHOWNEXTRASTAGES)nDotsToShow=TRIALSINSTAGE*SHOWNEXTRASTAGES;


                                     for (int i = 0; i < nDotsToShow; i++){
                                    float dotDia=12;
                                    float margin=screenWidth/TRIALSINSTAGE/2.0+dotDia+40;
                                    //float y=15-rowHeight*floor(i/TRIALSINSTAGE)+rowHeight*([self getCurrentStage]+SHOWNEXTRASTAGES);
                                         float y=15-rowHeight*floor(i/TRIALSINSTAGE)+rowHeight*floor(nDotsToShow/TRIALSINSTAGE-1);

                                    
                                    //update existing dots
                                    if(i<[dots count]){
                                        
                                        Dots *dot=[dots objectAtIndex:i];
                                        [self updateDot:i];

                                        //shift dots down
                                        [UIView animateWithDuration:.8
                                                              delay:0.8
                                             usingSpringWithDamping:.5
                                              initialSpringVelocity:1.0
                                                            options:UIViewAnimationOptionCurveLinear
                                                         animations:^{
                                                             dot.frame=CGRectMake(margin+(screenWidth-margin)/TRIALSINSTAGE*(i%TRIALSINSTAGE),y,dotDia,dotDia);
                                                         }
                                                         completion:^(BOOL finished){
                                                             
                                                         }];
          

                                        
                                        //update stage label
                                        if(i%TRIALSINSTAGE==0){
                                            int stage=floorf(i/TRIALSINSTAGE);
                                            TextArrow *sLabel=[stageLabels objectAtIndex:stage];
                                            sLabel.alpha=1;

                                            //shift label down
                                            [UIView animateWithDuration:.8
                                                                  delay:0.8
                                                 usingSpringWithDamping:.5
                                                  initialSpringVelocity:1.0
                                                                options:UIViewAnimationOptionCurveLinear
                                                             animations:^{
                                                                 sLabel.frame=CGRectMake(0, y, 70, 15);
//                                                                 sLabel.color=[self getBackgroundColor:currentLevel];
                                                                 [sLabel setArrowColor:[self getBackgroundColor:currentLevel]];
                                                                 sLabel.instructionText.textColor=[self getForegroundColor:currentLevel];

                                                             }
                                                             completion:^(BOOL finished){
                                                                 
                                                                 
                                                             }];
                                        }


                                    }
                                    //add new stagelabel
                                    else{

                                        if(i%TRIALSINSTAGE==0){
                                            int stage=floorf(i/TRIALSINSTAGE);

                                            //add stage label
                                            TextArrow *sLabel = [[TextArrow alloc] initWithFrame:CGRectMake(0, -60, 70, 16)];
                                            sLabel.instructionText.textColor = [UIColor blackColor];
                                            sLabel.drawArrowRight=true;
                                            sLabel.alpha=1;

                                            [stageLabels addObject:sLabel];
                                            [progressView.dotsContainer addSubview:sLabel];
                                            
                                            [sLabel update:[NSString stringWithFormat:@"STAGE %i",stage+1] rightLabel:@"" color:[self getBackgroundColor:currentLevel] animate:NO];
                                            sLabel.instructionText.textColor=[self getForegroundColor:currentLevel];

                                            [UIView animateWithDuration:.4
                                                                  delay:0.8+stage*.1
                                                 usingSpringWithDamping:.5
                                                  initialSpringVelocity:1.0
                                                                options:UIViewAnimationOptionCurveLinear
                                                             animations:^{
                                                                 sLabel.frame=CGRectMake(0, y, 70, 15);
                                                             }
                                                             completion:^(BOOL finished){
                                                             }];
                                            
                                        }
                                        
                                        //add dot
                                        Dots *dot = [[Dots alloc] initWithFrame:CGRectMake(margin+(screenWidth-margin)/TRIALSINSTAGE*(i%TRIALSINSTAGE),y,dotDia,dotDia)];
                                        dot.alpha = 1;
                                        dot.backgroundColor = [UIColor clearColor];
                                        [dot setColor:self.view.backgroundColor];
                                        
                                        [dots addObject:dot];
                                        [progressView.dotsContainer addSubview:dots[i]];
                                        
                                        dot.transform = CGAffineTransformScale(CGAffineTransformIdentity, .001, .001);
                                        //add level label
                                        [self updateDot:i];
            
                                    //animate dot appearance
                                    [UIView animateWithDuration:.2
                                                          delay:.8+(i-currentLevel)*.05
                                         usingSpringWithDamping:.5
                                          initialSpringVelocity:1.0
                                                        options:UIViewAnimationOptionCurveLinear
                                                     animations:^{
                                                         dot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);

                                                     }
                                                     completion:^(BOOL finished){

                                                     }];
                                    
                                    }
                                }
                               
                                     int stage=floorf(currentLevel/TRIALSINSTAGE);

                        if(stage<SHOWNEXTRASTAGES) [self performSelector:@selector(loadLevel) withObject:self afterDelay:0.8];
                       else  [self performSelector:@selector(loadLevel) withObject:self afterDelay:2.0];
                }];
    
}

-(void)updateDotColors{
    for (int i=0; i<[dots count]; i++){
        Dots *dot=[dots objectAtIndex:i];
        
        //shift label down
        [UIView animateWithDuration:.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             dot.color=[self getBackgroundColor:currentLevel];
                         }
                         completion:^(BOOL finished){
                             dot.color=[self getBackgroundColor:currentLevel];
                             [dot setNeedsDisplay];
                         }];
        

    }
}

-(void) updateDot:(int)i{
    
    Dots *dot=[dots objectAtIndex:i];

    //goal String
    NSTimeInterval level=[self getLevel:i];
    NSDate* nDate = [NSDate dateWithTimeIntervalSince1970: level];
    NSDateFormatter* ngf = [[NSDateFormatter alloc] init];
    if(level<60)[ngf setDateFormat:@"s.S"];
    else [ngf setDateFormat:@"mm:ss.S"];
    NSString* nGoalString = [ngf stringFromDate:nDate];
    
    [dot setText:@"" level:nGoalString];
    
    if(i<currentLevel){
        [dot setFill:YES];
        
        float trialAccuracy=fabs([[[self.levelData objectAtIndex:i] objectForKey:@"accuracy"] floatValue]);
        //float trialGoal=fabs([[[self.ArrayOfValues objectAtIndex:i] objectForKey:@"goal"] floatValue]);
        //float accuracyPercent=100.0-trialAccuracy/trialGoal*100.0;
       
        if(trialAccuracy<=[self getLevelAccuracy:i]*1.0/5.0) [dot setStars:3];
        else if(trialAccuracy<=[self getLevelAccuracy:i]*2.0/5.0) [dot setStars:2];
        else if(trialAccuracy<=[self getLevelAccuracy:i]*3.0/5.0)[dot setStars:1];
    }
    else {
        [dot setFill:NO];
    }
   
}

-(void) updateDots{

    for (int i=0; i<[dots count]; i++)[self updateDot:i];
  

    //hide xo view`
    [UIView animateWithDuration:.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         xView.alpha=0.0;
                         oView.alpha=0.0;

                     }
                     completion:^(BOOL finished){
   
                     }];
}



-(void) updateLife{
    //add hearts to be the same as life
    if([hearts count]<life){
        for(int i=(int)[hearts count]; i<life; i++) [self addHeart:i];
    }
    
    for (int i=0;i<[hearts count];i++){

        UIImageView* heart=[hearts objectAtIndex:i];
        
        if(i<life) {
            [self.view bringSubviewToFront:heart];
            
            //update color
            [UIView animateWithDuration:.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 heart.tintColor=counterGoalLabel.textColor;
                             }
                             completion:^(BOOL finished){
                             }];

        
            if(heart.frame.origin.y>screenHeight){

                heart.alpha=.8;
                //heart.transform = CGAffineTransformScale(CGAffineTransformIdentity, .01, .01);

                    //heart in
                [UIView animateWithDuration:.4
                                      delay:0.05 * i
                     usingSpringWithDamping:0.5
                      initialSpringVelocity:1.0
                                    options:UIViewAnimationOptionCurveLinear
                                         animations:^{
                                             heart.frame=CGRectMake(16+(screenWidth-16)/10.0*(i%10)+floor(i/10.0)*2, screenHeight-70-floor(i/10.0)*2,15,15);
                                             //heart.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                                         }
                                         completion:^(BOOL finished){
                                         }];
            }
        }
        else{
            //drop heart
            
            //[self.view sendSubviewToBack:heart];
            //[self.view sendSubviewToBack:blob];
            [self.view bringSubviewToFront:progressView];
            
            [UIView animateWithDuration:.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 heart.frame=CGRectOffset(heart.frame, 0, 100);
                             }
                             completion:^(BOOL finished){
                                 
                             }];
        }
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:life forKey:@"life"];
    [defaults synchronize];

}


#pragma mark - Setup

-(void)setupSatellites{
    for (int i=0;i<[satellites count];i++){
        
        float satD=50+arc4random()%100;
        Dots *sat= [satellites objectAtIndex:i];
        sat.frame=CGRectMake(16+(self.view.frame.size.width-16)/10.0*i,260,satD,satD);
        int dir=(arc4random() % 2 ? 1 : -1);
        float h=mainDot.frame.size.height*(arc4random()%8/10.0);
        
        CGRect orbit=CGRectMake(mainDot.frame.origin.x+satD*.15, mainDot.center.y-h/2.0, mainDot.frame.size.width-satD*.5, h);
        [sat animateAlongPath:orbit rotate:i/10.0*M_PI_2*2.0 speed:dir*((4.0+arc4random()%40)/200.0)];

    }
}

-(void)resetMainDot{
    int d=screenWidth*.65;
    mainDot.frame=CGRectMake(0,0,d,d);
    mainDot.center=CGPointMake(screenWidth/2.0, (screenHeight-44)*.75);
    blob.frame=CGRectMake(0,screenHeight*.5,screenWidth,screenHeight*.5);
    blob.frame=self.view.frame;
}


#pragma mark - Action
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    
}


-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([progressView.subMessage.text isEqual:@"GAME OVER"] || life==0)return;
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.view];
    CGPoint previousLocation = [aTouch previousLocationInView:self.view];

    if ([progressView pointInside: [self.view convertPoint:location toView: progressView] withEvent:event]) {

        [self.view bringSubviewToFront:progressView];
        
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                                progressView.frame=CGRectOffset(progressView.frame, 0,location.y - previousLocation.y);
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
    
    
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([progressView.subMessage.text isEqual:@"GAME OVER"] || life==0)return;

    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.view];
    CGPoint previousLocation = [aTouch previousLocationInView:self.view];


        [UIView animateWithDuration:0.4
                              delay:0.0
             usingSpringWithDamping:.8
              initialSpringVelocity:1.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{

                             
                             //if(progressView.frame.origin.y<screenHeight/2.0)
                             //if(location.y<previousLocation.y-2 || ( progressView.frame.origin.y<screenHeight-44 && location.y<previousLocation.y) )
                             if( progressView.frame.origin.y<screenHeight-44 && location.y<previousLocation.y )
                             {
                                progressView.frame=CGRectMake(0, 0, screenWidth, screenHeight*2.0);
                                 progressView.dotsContainer.frame=CGRectMake(0, 22, screenWidth, screenHeight*2.0);
                                 [self.view bringSubviewToFront:progressView];
                             }
                            else {
                                progressView.frame=CGRectMake(0, screenHeight-44, screenWidth, screenHeight*2.0);
                                TextArrow *sLabel=[stageLabels objectAtIndex:[self getCurrentStage]];
                                float y=sLabel.frame.origin.y;
                                progressView.dotsContainer.frame=CGRectMake(0,-y+15, screenWidth, screenHeight*2.0);

                                [self.view sendSubviewToBack:progressView];
                                [self.view sendSubviewToBack:blob];
                            }
                         }
                         completion:^(BOOL finished){
                             
                         }];
}



//- (IBAction)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
//{
//    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
//        
//        nPointsVisible*=1.0/([gestureRecognizer scale]*[gestureRecognizer scale]);
//        
//        [gestureRecognizer setScale:1.0];
//        
//        if(nPointsVisible>=[self.trialData count]-1){
//            nPointsVisible=[self.trialData count]-1;
//            return;
//        }
//        else if(nPointsVisible<=10){
//            nPointsVisible=10;
//            return;
//        }
//        //self.myGraph.animationGraphEntranceTime = 0.0;
//        //[self.myGraph reloadGraph];
//    }
//}



//volume buttons
-(void)buttonPressed{
    
    if(progressView.frame.origin.y==0)return;
    //START
    if(trialSequence==0){
            
        trialSequence=1;

        startTime=[NSDate timeIntervalSinceReferenceDate];
        //[self updateTime];
        [instructions update:@"STOP" rightLabel:@"" color:[self getForegroundColor:currentLevel] animate:YES];
        
            [self setTimerGoalMarginDisplay];
        
            //[self.view bringSubviewToFront:blobBlur];
            [UIView animateWithDuration:0.6
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 //labelContainerBlur.alpha=1.0;
                                 progressView.frame=CGRectMake(0, screenHeight-44, screenWidth, screenHeight*2.0);
                                 TextArrow *sLabel=[stageLabels objectAtIndex:[self getCurrentStage]];
                                 float y=sLabel.frame.origin.y;
                                 progressView.dotsContainer.frame=CGRectMake(0,-y+15, screenWidth, screenHeight*2.0);
                                 //blobBlur.alpha=0;
                             }
                             completion:^(BOOL finished){

                             }];

            
    }
    //STOP
    else if(trialSequence==1){
            trialSequence=2;
            NSTimeInterval currentTime=[NSDate timeIntervalSinceReferenceDate];
            elapsed = currentTime-startTime;
            [self updateTimeDisplay:elapsed];
            [self animateLevelDotScore];
            counterLabel.alpha=1.0;

    }
    //NEXT
    else if(trialSequence==2 && levelAlert.frame.origin.y<screenHeight){
        [self nextButtonPressed];
    }

}



-(void)setTimerGoalMarginDisplay{
    NSString * stop;
    NSDate* aDate = [NSDate dateWithTimeIntervalSince1970: [self getLevelAccuracy:currentLevel]];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"±s.SSS"];
    stop =[NSString stringWithFormat:@"%@ SEC", [df stringFromDate:aDate]];
    goalPrecision.text=stop;
}

-(void)saveTrialData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    //save to disk
    NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
    float diff=elapsed-timerGoal;
    [myDictionary setObject:[NSNumber numberWithFloat:diff] forKey:@"accuracy"];
    [myDictionary setObject:[NSNumber numberWithFloat:timerGoal] forKey:@"goal"];
    [myDictionary setObject:[NSDate date] forKey:@"date"];
    //[self.ArrayOfValues  insertObject:myDictionary atIndex:currentLevel];
    //dave data into continuous array
    [self.trialData addObject:myDictionary];
    
    //save data into clean array
    [self.levelData  insertObject:myDictionary atIndex:currentLevel];
    [self saveLevelProgress];
    
    //save to parse
    PFObject *pObject = [PFObject objectWithClassName:@"results"];
    pObject[@"goal"] = [NSNumber numberWithFloat:(timerGoal)];
    pObject[@"accuracy"] = [NSNumber numberWithFloat:(elapsed-timerGoal)];
    pObject[@"date"]=[NSDate date];
    //pObject[@"timezone"]=[NSTimeZone localTimeZone];

    NSString*uuid;
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults stringForKey:@"uuid"] == nil){
        uuid=CFBridgingRelease(CFUUIDCreateString(NULL, CFUUIDCreate(NULL)));
        [defaults setObject:uuid forKey:@"uuid"];
    }
    else uuid =[defaults stringForKey:@"uuid"];
    pObject[@"uuid"]=uuid;
    [pObject saveEventually];
    
    
    //update graph
    self.myGraph.animationGraphEntranceTime = 0.8;
    [self.myGraph reloadGraph];
    
    [self saveValues];
    
    [defaults synchronize];
}

//- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url
- (void)share
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    //NSURL * url;
    //NSString *text=[NSString stringWithFormat:@"",];
    //NSString *text=@"BOOM!";

    UIImage *image =[self screenshot];
    
//    if (text) {
//        [sharingItems addObject:text];
//    }
    if (image) {
        [sharingItems addObject:image];
    }
//    if (url) {
//        [sharingItems addObject:url];
//    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (UIImage *)screenshot
{
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark DATA
//-(void)loadData:(float) level{
-(void)loadTrialData{
    
    //load values
    self.trialData = [[NSMutableArray alloc] init];
    
    //Creating a file path under iOS:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //timeValuesFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"timeData%i.dat",(int)level]];
    timeValuesFile = [documentsDirectory stringByAppendingPathComponent:@"trialData3.dat"];

    //Load the array
    self.trialData = [[NSMutableArray alloc] initWithContentsOfFile: timeValuesFile];
    
    if(self.trialData == nil)
    {
        //Array file didn't exist... create a new one
        self.trialData = [[NSMutableArray alloc] init];
        for (int i = 0; i <nPointsVisible ; i++) {
            NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
            [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"accuracy"];
            [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"goal"];
            [myDictionary setObject:[NSDate date] forKey:@"date"];
            [self.trialData addObject:myDictionary];
        }
        [self saveValues];
    }
}


-(void)saveValues{
    [self.trialData writeToFile:timeValuesFile atomically:YES];
}

#pragma mark - GameCenter
-(void)reportScore{
    if(_leaderboardIdentifier){
        //GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:_leaderboardIdentifier];
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"global"];
        score.value = best*10;
        
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
        
        GKScore *xp = [[GKScore alloc] initWithLeaderboardIdentifier:@"experiencepoints"];
        xp.value = experiencePoints*10;
        
        [GKScore reportScores:@[xp] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

-(void)showGlobalLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    gcViewController.gameCenterDelegate = self;
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = @"global";
    [self presentViewController:gcViewController animated:YES completion:nil];
}

-(void)showXPLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    gcViewController.gameCenterDelegate = self;
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = @"experiencepoints";
    [self presentViewController:gcViewController animated:YES completion:nil];
}
-(void)showAchievements{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    gcViewController.gameCenterDelegate = self;
    gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
    [self presentViewController:gcViewController animated:YES completion:nil];
}
-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark LEVELS
-(void)loadLevelProgress{
    //load values
    self.levelData = [[NSMutableArray alloc] init];
    
    //Creating a file path under iOS:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *File = [documentsDirectory stringByAppendingPathComponent:@"levelData.dat"];
    
    //Load the array
    self.levelData = [[NSMutableArray alloc] initWithContentsOfFile: File];
    
    if(self.levelData == nil)
    {
        //Array file didn't exist... create a new one
        self.levelData = [[NSMutableArray alloc] init];
        for (int i = 0; i < [dots count]; i++) {
            
            NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
            [myDictionary  setObject:[NSNumber numberWithInt:0] forKey:@"accuracy"];
            [self.levelData addObject:myDictionary];
 
        }
        [self saveLevelProgress];
    }
    
}

-(void)saveLevelProgress{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *File = [documentsDirectory stringByAppendingPathComponent:@"levelData.dat"];
    [self.levelData writeToFile:File atomically:YES];
}


-(void)setLevel:(int)level{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(level>0 && practicing==false){
        
        
        float lastSuccessfulGoal=fabs([[[self.trialData objectAtIndex:level-1] objectForKey:@"goal"] floatValue]);
        
        if(lastSuccessfulGoal>=best){
            best=lastSuccessfulGoal;
            [defaults setInteger:best forKey:@"best"];
        }
        
        
        float currentHS=(int)[defaults integerForKey:@"highScore"];
        if(experiencePoints>currentHS){
            currentHS=experiencePoints;
            [defaults setInteger:experiencePoints forKey:@"highScore"];
        }

        [self updateHighscore];


    }
     [defaults synchronize];
    
    
    timerGoal=[self getLevel:level];

    [self updateDotColors];

     //change background color
     [UIView animateWithDuration:0.4
                           delay:0.0
                         options:UIViewAnimationOptionCurveLinear
                      animations:^{
                          
                          trophyButton.alpha=1;
                          medalButton.alpha=1;
                          highScoreLabel.alpha=1;
                          bestLabel.alpha=1;

                          restartButton.alpha=1;
                          
                          counterGoalLabel.alpha=0;
                          counterLabel.alpha=0;
                          goalPrecision.alpha=0;
                          
                          if(practicing) self.view.backgroundColor=[UIColor colorWithWhite:.7 alpha:1.0];
                          else self.view.backgroundColor=[self getBackgroundColor:currentLevel];
                          
                          instructions.instructionText.textColor=self.view.backgroundColor;
                          instructions.rightLabel.textColor=self.view.backgroundColor;

                          [instructions setColor:[self getForegroundColor:currentLevel]];
                          progressView.backgroundColor=[self getForegroundColor:currentLevel];
                          counterLabel.textColor=[self getForegroundColor:currentLevel];
                          counterGoalLabel.textColor=[self getForegroundColor:currentLevel];
                          goalPrecision.textColor=[self getForegroundColor:currentLevel];
                          
                          restartButton.tintColor=[self getBackgroundColor:currentLevel];
                          restartExpandButton.tapCircleColor=[self getBackgroundColor:currentLevel];

                          trophyButton.tintColor=[self getBackgroundColor:currentLevel];
                          medalButton.tintColor=[self getBackgroundColor:currentLevel];
                          highScoreLabel.textColor=[self getBackgroundColor:currentLevel];
                          bestLabel.textColor=[self getBackgroundColor:currentLevel];

                          self.myGraph.colorLine = [self getBackgroundColor:currentLevel];
                          self.myGraph.colorXaxisLabel = [self getBackgroundColor:currentLevel];
                          self.myGraph.colorYaxisLabel = [self getBackgroundColor:currentLevel];
                          self.myGraph.colorPoint=[self getBackgroundColor:currentLevel];
                        }
                      completion:^(BOOL finished){

                          [self.myGraph reloadGraph];
                          
                          [self updateTimeDisplay:0];
                          [self setTimerGoalMarginDisplay];

                         [UIView animateWithDuration:0.2
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              counterGoalLabel.alpha=1;
                                              counterLabel.alpha=0;
                                              goalPrecision.alpha=1;
                                          }
                                          completion:^(BOOL finished){
                                              [self animateLevelReset];
                                          }];
     
          }];
    
}

-(float)getLevel:(int)level{
    float l;
    if(level<TRIALSINSTAGE)l=.5+level*0.1;
    else if(level<TRIALSINSTAGE*2)l=1.0+level%TRIALSINSTAGE*0.1;
    else if(level<TRIALSINSTAGE*3)l=1.5+level%TRIALSINSTAGE*0.2;
    else if(level<TRIALSINSTAGE*4)l=2.5+level%TRIALSINSTAGE*0.5;
    else l=level*1.0-TRIALSINSTAGE*3+1.0;
//    else if(level<TRIALSINSTAGE*5)l=5.0+level%TRIALSINSTAGE*1.0;
//    else l=5.0+level%TRIALSINSTAGE*1.0;
    
    return l;
}

-(float)getLevelAccuracy:(int)level{
//    if([self getLevel:level]<=5) return .1;
//    if([self getLevel:level]<=10) return .15;
//    else if([self getLevel:level]<=20) return .2;
//    else  return 1.0;
    return .1;
}


-(void)checkLevelUp{


    [self.view bringSubviewToFront:oView];
    [self.view bringSubviewToFront:xView];
    
    [UIView animateWithDuration:0.4
                          delay:0.4
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if([self isAccurate]){
                             Dots *dot=[dots objectAtIndex:currentLevel];
                             CGPoint xy=[dot.superview convertPoint:dot.frame.origin toView:nil];

                             oView.frame = CGRectMake( xy.x,xy.y,dot.frame.size.width,dot.frame.size.height);
                         }
                         else{
                             if(life-1>0){
                                 Dots *heart=[hearts objectAtIndex:life-1];
                                 xView.frame = CGRectMake( heart.frame.origin.x,heart.frame.origin.y,heart.frame.size.width,heart.frame.size.height);
                             }
                         }
                     }
                     completion:^(BOOL finished){
                       
                         [self xoViewOffScreen];
                         
                         //save trial data now
                         [self saveTrialData];

                         if([self isAccurate]){
                             if(life<NUMHEARTS) life=NUMHEARTS;
                             experiencePoints+=elapsed*timerGoal;

                            //add heart for triplestar level
                             float trialAccuracy=fabs(elapsed-timerGoal);
                             if(trialAccuracy<=[self getLevelAccuracy:currentLevel]*1/10.0)life+=3;
                             else if(trialAccuracy<=[self getLevelAccuracy:currentLevel]*2/10.0)life+=2;
                             else if(trialAccuracy<=[self getLevelAccuracy:currentLevel]*4/10.0)life++;
                             
                             //save current level now
                             currentLevel++;
                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                             [defaults setInteger:currentLevel forKey:@"currentLevel"];
                             [defaults synchronize];
                             
                            //add heart for clearing stage
                            if(currentLevel%TRIALSINSTAGE==0) life++;
                         }
                         else{
                             life--;
                         }
                         
                         if(life==0) lastStage=[self getCurrentStage];
                         if(practicing==false) [self reportScore];

                         [self performSelector:@selector(updateLife) withObject:self afterDelay:.1];
                         [self performSelector:@selector(updateDots) withObject:self afterDelay:.1];
                         [self performSelector:@selector(showLevelAlerts) withObject:self afterDelay:.5];


                     }];
    
    

    
}

-(void)showLevelAlerts{

    //arrow delay
    float d=0;
    float inc=.05;
    int arrowN=0;
    int margin=screenHeight-44-37;
    int spacing=-1;
    
    for (int i=0; i<NUMLEVELARROWS; i++){
        TextArrow * t=[levelArrows objectAtIndex:i];
        t.rightLabel.textColor=self.view.backgroundColor;
    }
 
    float diff=elapsed-timerGoal;

    TextArrow *t;//= [levelArrows objectAtIndex:arrowN];
    
    //ARROW1

    if(([self isAccurate] && currentLevel%TRIALSINSTAGE==0) || life==0) {
        NSString * stageClearedString;
        if(life==0) stageClearedString=@"GAME OVER";
        else {
            stageClearedString=[NSString stringWithFormat:@"STAGE %i CLEARED! ❤\U0000FE0E⁺¹",[self getCurrentStage]];
        }
        
        t= [levelArrows objectAtIndex:arrowN];
        [t update:@"" rightLabel:stageClearedString color:instructions.color animate:NO];
        margin-=spacing+t.frame.size.height;
        d+=inc;
        [t slideUpTo:margin delay:d];
        [self.view bringSubviewToFront:t];
    }
    arrowN++;

    
    NSString * bonusString=@"";
    float trialAccuracy=fabs(elapsed-timerGoal);
    if(trialAccuracy<=[self getLevelAccuracy:currentLevel]*1/10.0)      bonusString=@"PERFECT! ❤\U0000FE0E⁺³";
    else if(trialAccuracy<=[self getLevelAccuracy:currentLevel]*2/10.0) bonusString=@"BOOOOOM! ❤\U0000FE0E⁺²";
    else if(trialAccuracy<=[self getLevelAccuracy:currentLevel]*3/10.0) bonusString=@"WOOT! ❤\U0000FE0E⁺¹";
    else if(trialAccuracy<=[self getLevelAccuracy:currentLevel]*4/10.0) bonusString=@"MONEY! ❤\U0000FE0E⁺¹";
    else if(trialAccuracy<=[self getLevelAccuracy:currentLevel]*5/10.0) bonusString=@"GREAT!";
    else if(trialAccuracy<=[self getLevelAccuracy:currentLevel]*6/10.0) bonusString=@"NICE!";
    else if(trialAccuracy<=[self getLevelAccuracy:currentLevel]*7/10.0) bonusString=@"DONE!";
    else if(trialAccuracy<=[self getLevelAccuracy:currentLevel]*8/10.0) bonusString=@"SWEET!";
    else if(trialAccuracy<=[self getLevelAccuracy:currentLevel]*9/10.0) bonusString=@"CLOSE ENOUGH";
    else if(trialAccuracy<=[self getLevelAccuracy:currentLevel])        bonusString=@"MEH";
    
    else if(diff<-1)  bonusString=@"WAY TOO FAST!";
    else if(diff<-.5) bonusString=@"PATIENCE! GO SLOWER.";
    else if(diff<-.4) bonusString=@"SLOW DOWN";
    else if(diff<-.3) bonusString=@"BREATH. SLOW DOWN.";
    else if(diff<-.2) bonusString=@"SLOW DOWN A BIT";
    else if(diff<0)   bonusString=@"TOO FAST";
    
    else if(diff>1)  bonusString=@"WAY TOO SLOW!";
    else if(diff>.5) bonusString=@"SPEED UP!";
    else if(diff>.4) bonusString=@"GO FASTER!";
    else if(diff>.3) bonusString=@"TOO SLOW!";
    else if(diff>.2) bonusString=@"A BIT TOO SLOW";
    else if(diff>0)  bonusString=@"GO A BIT FASTER";
    t= [levelArrows objectAtIndex:arrowN];
    [t update:@"" rightLabel:bonusString color:instructions.color animate:NO];
    margin-=spacing+t.frame.size.height;
    d+=inc;
    [t slideUpTo:margin delay:d];
    [self.view bringSubviewToFront:t];
    arrowN++;
    
    
    
    NSString *diffString;
    diffString=[NSString stringWithFormat:@"%@ SECONDS",[self getTimeDiffString:diff]];
    t= [levelArrows objectAtIndex:arrowN];
    [t update:@"" rightLabel:diffString color:instructions.color animate:NO];
    margin-=spacing+t.frame.size.height;
    d+=inc;
    [t slideUpTo:margin delay:d];
    [self.view bringSubviewToFront:t];
    arrowN++;
    
    //ARROW2
    //float accuracyP=100.0-fabs(diff/(float)timerGoal)*100.0;
    float accuracyP=[self getAccuracyPercentage];
    NSString* percentAccuracyString = [NSString stringWithFormat:@"ACCURACY %02i%%", (int)accuracyP];
    t= [levelArrows objectAtIndex:arrowN];
    [t update:@"" rightLabel:percentAccuracyString color:instructions.color animate:NO];
    margin-=spacing+t.frame.size.height;
    d+=inc;
    [t slideUpTo:margin delay:d];
    [self.view bringSubviewToFront:t];
    arrowN++;
    
    
    
    NSString * stageProgressString;
    //if([self isAccurate]) stageProgressString=[NSString stringWithFormat:@"LEVEL %.01f CLEARED %0.1f POINTS",[self getLevel:currentLevel-1], elapsed*timerGoal];
    if([self isAccurate]) stageProgressString=[NSString stringWithFormat:@"+$%0.2f", elapsed*timerGoal];
    else if(life>1) stageProgressString=[NSString stringWithFormat:@"%i TRIES LEFT",life];
    else if(life>0) stageProgressString=@"ONE TRY LEFT";
    //else stageProgressString=@"GAME OVER";
    if(life>0){
        t= [levelArrows objectAtIndex:arrowN];
        [t update:@"" rightLabel:stageProgressString color:instructions.color animate:NO];
        margin-=spacing+t.frame.size.height;
        d+=inc;
        [t slideUpTo:margin delay:d];
        [self.view bringSubviewToFront:t];
    }
    arrowN++;
   

    //[levelAlert update:[NSString stringWithFormat:@"%.1f COOKIES",highScore] rightLabel:@""   color:instructions.color animate:NO];
    [levelAlert update:@"" rightLabel:@""   color:instructions.color animate:NO];

    //next buton
    levelAlert.rightLabel.frame=CGRectMake(levelAlert.rightLabel.frame.origin.x, levelAlert.rightLabel.frame.origin.y, levelAlert.frame.size.width-nextButton.frame.size.width*2.2, levelAlert.rightLabel.frame.size.height);
    levelAlert.rightLabel.textColor=[UIColor blackColor];
    TextArrow *sl=[stageLabels objectAtIndex:0];

    nextButton.tintColor=sl.color;
    shareButton.tintColor=sl.color;

    margin-=spacing+levelAlert.frame.size.height;
    d+=inc;
    [levelAlert slideUpTo:margin delay:d];
    [self.view bringSubviewToFront:levelAlert];

    

    //blank instruction
    [instructions update:@"" rightLabel:@"" color:counterGoalLabel.textColor animate:NO];
    d+=inc;
    [instructions slideIn:d];
    
    
}

-(void)getExperiencePoints{
    
}

-(void)showGameOverSequence{
    
    //show progressview
    [self.view bringSubviewToFront:progressView];
    [progressView bringSubviewToFront:progressView.subMessage];

    if(lastStage==0) {
        
        [self showGameOver];

        [UIView animateWithDuration:0.8
                              delay:0.5
             usingSpringWithDamping:.8
              initialSpringVelocity:1.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             progressView.frame=CGRectMake(0, 0, screenWidth, screenHeight*2.0);
                             progressView.dotsContainer.frame=CGRectMake(0, 22, screenWidth, screenHeight*2.0);
                         }
                         completion:^(BOOL finished){
                         }];
        
        return;
    }
    progressView.subMessage.text=[NSString stringWithFormat:@"SPEND $%.02f \nTO CONTINUE FROM STAGE %i?",lastStage*10.0,lastStage+1];
    progressView.subMessage.alpha=1.0;
    progressView.subMessage.textColor=trophyButton.tintColor;
    progressView.centerMessage.textColor=trophyButton.tintColor;

    playButton.alpha=1.0;
    playButton.tintColor=trophyButton.tintColor;
    playButton.center=CGPointMake(screenWidth/2.0, progressView.subMessage.frame.origin.y+progressView.subMessage.frame.size.height+10);

    
    progressView.lowerMessage.frame=CGRectMake(0, playButton.frame.origin.y+playButton.frame.size.height+30, progressView.lowerMessage.frame.size.width, progressView.lowerMessage.frame.size.height);
    progressView.lowerMessage.text=@"RESTART";
    progressView.lowerMessage.alpha=1.0;
    progressView.lowerMessage.textColor=trophyButton.tintColor;
    progressView.lowerMessage.textColor=trophyButton.tintColor;
    
    
    [UIView animateWithDuration:0.8
                          delay:0.5
         usingSpringWithDamping:.8
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         progressView.frame=CGRectMake(0, 0, screenWidth, screenHeight*2.0);
                         progressView.dotsContainer.frame=CGRectMake(0, 22, screenWidth, screenHeight*2.0);
                     }
                     completion:^(BOOL finished){
                         [self countdown];
                     }];

    
    //move restart button
    [UIView animateWithDuration:0.4
                          delay:0.8
         usingSpringWithDamping:.8
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         restartButton.center=CGPointMake(screenWidth*.5, progressView.lowerMessage.frame.origin.y+progressView.lowerMessage.frame.size.height+20);
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
}


-(void)countdown{
    [self.view bringSubviewToFront:progressView];
    [progressView bringSubviewToFront:progressView.subMessage];
    
    if(life==0){//check if countdown got interrupted by restart
        [progressView displayMessage:[NSString stringWithFormat:@"%i",resetCountdown]];
        resetCountdown--;
        if(resetCountdown>=0)[self performSelector:@selector(countdown) withObject:self afterDelay:1.0];
        else{
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 progressView.subMessage.alpha=0;
                                 progressView.lowerMessage.alpha=0;

                                 playButton.alpha=0.0;
                             }
                             completion:^(BOOL finished){
                                 [self showGameOver];
                                 
                                 
                                 
                                 
                             }];
        }
    }
}

-(void)showGameOver{
    progressView.subMessage.text=@"GAME OVER";
    progressView.subMessage.textColor=trophyButton.tintColor;

    [UIView animateWithDuration:0.4
                          delay:0.8
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         progressView.subMessage.alpha=1.0;
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
    [UIView animateWithDuration:0.4
                          delay:0.8
         usingSpringWithDamping:.8
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         restartButton.center=CGPointMake(screenWidth*.5, progressView.subMessage.frame.origin.y+progressView.subMessage.frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
}

-(void)nextButtonPressed{
    
    [self.view bringSubviewToFront:progressView];
    for(int i=0; i<NUMLEVELARROWS; i++)[[levelArrows objectAtIndex:i] slideDown:(float)i*.05];
    [levelAlert slideDown:(float)(NUMLEVELARROWS)*.05];
    [instructions slideOut:0];
    
    if(life==0){
        resetCountdown=20;
        currentLevel=0;
        [self performSelector:@selector(showGameOverSequence) withObject:self afterDelay:1];
    }
    
    //check for stage up to add dots
    else if ( (currentLevel%TRIALSINSTAGE==0 && [self isAccurate])) [self performSelector:@selector(setupDots) withObject:self afterDelay:.1];
    else [self performSelector:@selector(loadLevel) withObject:self afterDelay:.1];
    

    
}


-(void)loadLevel{
    if(currentLevel==0 && life==0){
        life=NUMHEARTS;
        [self updateLife];
    }
    
    [self setLevel:currentLevel];
    [self loadTrialData];
    [self loadLevelProgress];
    
    //[self.myGraph reloadGraph];
}


# pragma mark LABELS
-(void)updateTimeDisplay: (NSTimeInterval) interval{
    
    //main stopwatch
    NSTimeInterval absoluteTime=fabs(interval);
    [self timerMainDisplay:absoluteTime];
    
    //goal String
    NSTimeInterval goalInterval=timerGoal;
    [self timerGoalDisplay:goalInterval];
    
    //next goal String
    NSTimeInterval nextGoal=[self getLevel:currentLevel+1];
    NSDate* nDate = [NSDate dateWithTimeIntervalSince1970: nextGoal];
    NSDateFormatter* ngf = [[NSDateFormatter alloc] init];
    [ngf setDateFormat:@"sssss.SSS"];
    NSString* nGoalString = [ngf stringFromDate:nDate];
    [nextLevelLabel setText:[NSString stringWithFormat:@"NEXT LEVEL:%@",nGoalString]];
}


-(void)updateTime{
    
    NSTimeInterval currentTime=[NSDate timeIntervalSinceReferenceDate];
    elapsed = currentTime-startTime;
    
    if(trialSequence==1){

        //if(elapsed<1){
            [self updateTimeDisplay:currentTime-startTime];
            [self performSelector:@selector(updateTime) withObject:self afterDelay:0.0001];
//        }else{
//            [counterLabel setText:[NSString stringWithFormat:@"%02u:%02u.%03u",arc4random()%99, arc4random()%60, arc4random()%999]];
//            [self performSelector:@selector(updateTime) withObject:self afterDelay:arc4random()%10*0.001];
//        }
    }
//    else{
//        [self updateTimeDisplay:elapsed];
//        [self animateLevelDotScore];
// 
//    }
}



-(NSString *)getTimeDiffString:(NSTimeInterval)time{
    
    NSDate* aDate = [NSDate dateWithTimeIntervalSince1970: fabs(time)];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    if(time<60){
        if(time>=0) [df setDateFormat:@"+s.SSS"];
        else [df setDateFormat:@"-s.SSS"];
    }else{
        if(time>=0) [df setDateFormat:@"+s.SSS"];
        else [df setDateFormat:@"-s.SSS"];
    }
    NSString* counterString = [df stringFromDate:aDate];
    return counterString;
    
}



-(void)timerDiffDisplay:(NSTimeInterval)time{
    
    NSDate* aDate = [NSDate dateWithTimeIntervalSince1970: fabs(time)];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    if(time>0) [df setDateFormat:@"sssss.SSS"];
    else [df setDateFormat:@"sssss.SSS"];
    
    NSString* counterString = [df stringFromDate:aDate];
    [differencelLabel setText:counterString];
}



-(void)timerGoalDisplay:(NSTimeInterval)goal{
    NSDate* gDate = [NSDate dateWithTimeIntervalSince1970: goal];
    NSDateFormatter* gf = [[NSDateFormatter alloc] init];
    [gf setDateFormat:@"sssss.SSS"];
    NSString* goalString = [gf stringFromDate:gDate];
    [counterGoalLabel setText:goalString];
}

-(void)timerMainDisplay:(NSTimeInterval)time{
    
    NSDate* aDate = [NSDate dateWithTimeIntervalSince1970: fabs(time)];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    if(time>0) [df setDateFormat:@"sssss.SSS"];
    else [df setDateFormat:@"sssss.SSS"];
    
    NSString* counterString = [df stringFromDate:aDate];
    [counterLabel setText:counterString];
}

-(void)updateStats{
    /*
     //results
     lastResults.text=[NSString stringWithFormat:@"%02d",(int)nPointsVisible];
     
     //accuracy
     int averageAccuracy=0;
     for( int i=0; i<nPointsVisible; i++){
     int index=(int)[self.ArrayOfValues count]-(int)nPointsVisible+i; //show last nPoints
     float absResult=fabs([[[self.ArrayOfValues objectAtIndex:index] objectForKey:@"accuracy"] floatValue]);
     averageAccuracy+=abs((absResult-timerGoal)/timerGoal*100);
     }
     
     averageAccuracy=averageAccuracy/nPointsVisible;
     
     
     //float accuracyP=100.0-fabs(([[self.myGraph calculatePointValueAverage] floatValue])/1000.0)/(float)timerGoal*100.0;
     accuracy.text = [NSString stringWithFormat:@"%02i", (int)averageAccuracy];
     
     
     //precision
     float uncertainty=[[self.myGraph calculatePointValueMedian] floatValue]-[[self.myGraph calculateMinimumPointValue] floatValue]+[[self.myGraph calculateMaximumPointValue] floatValue]-[[self.myGraph calculatePointValueMedian] floatValue];
     precision.text=[NSString stringWithFormat:@"%d",(int)uncertainty];
     */
    
}


# pragma mark Blob
-(void)addBlob{
    
    //reposition maindot below screen
    [self resetMainDot];

//    blob.transform = CGAffineTransformScale(CGAffineTransformIdentity, .00001, .000001);
//
//    [UIView animateWithDuration:0.8
//                          delay:0.4
//         usingSpringWithDamping:.5
//          initialSpringVelocity:1.0
//                        options:UIViewAnimationOptionCurveEaseIn
//                     animations:^{
//                         blob.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
//                     }
//                     completion:^(BOOL finished){
//
//                     }];
}



# pragma mark 



-(void)animateLevelDotScore{

    [self showXO];
    [self performSelector:@selector(morphOrDropDots) withObject:self afterDelay:.1];
    
//    [UIView animateWithDuration:0.4
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         //blobBlur.alpha=1;
//                         labelContainerBlur.alpha=0.0;
//                         //[self.view sendSubviewToBack:blob];
//                        }
//         completion:^(BOOL finished){
//             
//  
//         }];

}

//-(void)countdownTimerLabel{
//
//    resetCounter*=1.10;
//
//    
//    //count up
//    [self timerDiffDisplay:resetCounter];
//    
//    if(resetCounter<=fabs(elapsed-timerGoal)){
//        [self performSelector:@selector(countdownTimerLabel) withObject:self afterDelay:0.0];
//    }else{
//        //[self timerGoalDisplay:0];
//        //[self timerMainDisplay:elapsed-timerGoal];
//        [self timerDiffDisplay:elapsed-timerGoal];
//        
//        
//        //show success label
//        //[self performSelector:@selector(showTrialInstruction) withObject:self afterDelay:0.0];
//        //drop dots or morph to levedots
//        //[self performSelector:@selector(morphOrDropDots) withObject:self afterDelay:1.5];
//
//        trialSequence=2;
//        
//        //pause before level reset animation
//        //[NSTimer scheduledTimerWithTimeInterval:.75 target:self selector:@selector(animateLevelReset) userInfo:nil repeats:NO];
//    }
//}


-(void)showXO{
    if([self isAccurate]){
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self displayXorO:YES];
        
    }
    else{
        //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self displayXorO:NO];
    }
}

-(void)displayXorO:(bool)showO{

    xView.alpha=1.0;
    oView.alpha=1.0;
    xView.tintColor=[self getBackgroundColor:currentLevel];
    oView.tintColor=[self getBackgroundColor:currentLevel];
    float w=screenWidth*.60;
    float y=(screenHeight-44)*.75-w/2.0;
    float x=screenWidth/2.0-w/2.0;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:.5
          initialSpringVelocity:.5
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         if([self isAccurate])oView.frame=CGRectMake( x, y, w, w);
                         else xView.frame=CGRectMake(x, y, w, w);
                     }
                     completion:^(BOOL finished){

//                         if(![self isAccurate])AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                     }];
    
}
-(void)xoViewOffScreen{
    //reset xoView
    float w=230;
    xView.alpha=1.0;
    oView.alpha=1.0;
    int y=-w;
    
    xView.frame=CGRectMake(screenWidth/2.0-w/2.0, y, w, w);
    oView.frame=CGRectMake(screenWidth/2.0-w/2.0, y, w, w);

}
-(void)morphOrDropDots{
    //[instructions update:@"" rightLabel:@"" color:[self getForegroundColor:currentLevel] animate:YES];
    [instructions slideOut:0];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         labelContainerBlur.alpha=0.0;
                     }
                     completion:^(BOOL finished){

                    }];
    
    
    [self checkLevelUp];
}

-(void)animateLevelReset{
    
    [instructions slideOut:0];
    [self updateTimeDisplay:0];

    
    [UIView animateWithDuration:0.8
                          delay:0
         usingSpringWithDamping:.8
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         //slide progressview down
                         progressView.frame=CGRectMake(0, screenHeight-44, self.view.frame.size.width, screenHeight*2.0);
                         TextArrow *sLabel=[stageLabels objectAtIndex:[self getCurrentStage]];
                         float y=sLabel.frame.origin.y;
                         progressView.dotsContainer.frame=CGRectMake(0,-y+15, screenWidth, screenHeight*2.0);
                         restartButton.center=CGPointMake(screenWidth*4/5.0, screenHeight-60);

                     }
                     completion:^(BOOL finished){
                         [self.view sendSubviewToBack:progressView];
                         [self.view sendSubviewToBack:blob];
                         [self updateLife];
                          //fade in new counters
                          [UIView animateWithDuration:0.2
                                                delay:0.0
                                              options:UIViewAnimationOptionCurveLinear
                                           animations:^{
                                               counterLabel.alpha=0.0;
                                               instructions.alpha=1.0;
                                               counterGoalLabel.alpha=1.0;
                                           }
                                           completion:^(BOOL finished){
                                               //[instructions resetFrame];
                                               [instructions update:@"START" rightLabel:@"" color:[self getForegroundColor:currentLevel] animate:NO];
                                               [instructions slideIn:0];
                                               [self performSelector:@selector(resetTrialSequence) withObject:self afterDelay:0.1];
                                           }];
                          
                         
                     }];
 
    
}


-(void)setTrialSequence:(int)n{
    trialSequence=n;
}

-(void)resetTrialSequence{
    trialSequence=0;
    [self performSelector:@selector(instructionBounce) withObject:self afterDelay:5.0];
}

-(void)instructionBounce{

    if(trialSequence==0)
    {
        [instructions update:@"START" rightLabel:@"PRESS VOLUME BUTTON" color:[self getForegroundColor:currentLevel] animate:NO];
        instructions.rightLabel.font=[UIFont fontWithName:@"DIN Condensed" size:screenHeight*.03];
        [instructions bounce];
        [self performSelector:@selector(instructionBounce) withObject:self afterDelay:5.0];
    }
    
}


# pragma mark Helpers

-(UIColor*) getBackgroundColor:(int)level {

    NSArray * backgroundColors = [[NSArray alloc] initWithObjects:
                                  //[UIColor colorWithRed:206/255.0 green:0/255.0 blue:78/255.0 alpha:1],
                                  [UIColor colorWithRed:255/255.0 green:217/255.0 blue:15/255.0 alpha:1],
                                  [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1],
                                  [UIColor colorWithRed:253/255.0 green:242/255.0 blue:62/255.0 alpha:1],
                                  [UIColor colorWithRed:0/255.0 green:163/255.0 blue:238/255.0 alpha:1],
                                  
                                  [UIColor colorWithRed:18/255.0 green:118/255.0 blue:165/255.0 alpha:1],
                                  [UIColor colorWithRed:82/255.0 green:82/255.0 blue:75/255.0 alpha:1],
                                  [UIColor colorWithRed:200/255.0 green:203/255.0 blue:207/255.0 alpha:1],//
                                  [UIColor colorWithRed:91/255.0 green:96/255.0 blue:122/255.0 alpha:1],
                                  nil];
    
    int currentStage=floorf(level/TRIALSINSTAGE);
    int cl=currentStage%[backgroundColors count];
    
    return backgroundColors[cl];
}

-(UIColor*) getForegroundColor:(int)level {
    
    NSArray * foregroundColor = [[NSArray alloc] initWithObjects:
                                  //[UIColor colorWithRed:248/255.0 green:238/255.0 blue:223/255.0 alpha:1],
                                 [UIColor colorWithRed:85/255.0 green:85/255.0 blue:98/255.0 alpha:1],
                                 [UIColor colorWithRed:255/255.0 green:153/255.0 blue:0/255.0 alpha:1],
                                  [UIColor colorWithRed:255/255.0 green:61/255.0 blue:132/255.0 alpha:1],
                                 [UIColor colorWithRed:236/255.0 green:236/255.0 blue:136/255.0 alpha:1],

                                  [UIColor colorWithRed:222/255.0 green:195/255.0 blue:153/255.0 alpha:1],
                                  [UIColor colorWithRed:254/255.0 green:253/255.0 blue:211/255.0 alpha:1],
                                  [UIColor colorWithRed:255/255.0 green:14/255.0 blue:0/255.0 alpha:1],//
                                  [UIColor colorWithRed:71/255.0 green:241/255.0 blue:0/255.0 alpha:1],

                                  nil];
    
    int currentStage=floorf(level/TRIALSINSTAGE);
    int cl=currentStage%[foregroundColor count];
    return foregroundColor[cl];
}





-(UIColor*) inverseColor:(UIColor*) color
{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:1.-r-.2 green:1.-g-.2 blue:1.-b-.2 alpha:a];
}



-(bool)isAccurate{
    //float accuracyP=100.0-fabs(elapsed-timerGoal)/(float)timerGoal*100.0;

    float diff=fabs(timerGoal-elapsed);
    
    if( diff<=[self getLevelAccuracy:currentLevel] ) return YES;
    else return NO;
//       
//    
//    if([self getLevel:currentLevel]<10 && diff<=.25) return YES;
//    else if([self getLevel:currentLevel]<30 && diff<=.5) return YES;
//    else if (diff<=1) return YES;
//    else return NO;
}

-(int)getAccuracyPercentage{
    float accuracyPercent;
    accuracyPercent=100.0-fabs(elapsed-timerGoal)/(float)timerGoal*100.0;

    if(accuracyPercent<0)accuracyPercent=0;
    
    return ceilf(accuracyPercent);
}


#pragma mark - SimpleLineGraph Data Source
///*
- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return nPointsVisible;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    if([self.trialData count]==0)return 0.0;
    NSInteger i=[self.trialData count]-nPointsVisible+index; //show last nPoints

    float accuracy=[[[self.trialData objectAtIndex:i] objectForKey:@"accuracy"] floatValue];
    //cap graph
    if(accuracy>1)accuracy=1;
    else if (accuracy<-1)accuracy=-1;
    
    return accuracy;
}




#pragma mark - SimpleLineGraph Delegate
- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @"ms";
}

- (NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 3;
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return [self.trialData count];
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    
    return @"";
    
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"MM.dd HH:mm"];
    
    //index=[self.ArrayOfValues count]-nPointsVisible+index;

    //NSString *stringFromDate = [formatter stringFromDate:[[self.ArrayOfValues objectAtIndex:index] objectForKey:@"date"]];
    //return [stringFromDate stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    //return stringFromDate;
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    self.labelValues.text = [NSString stringWithFormat:@"%02f", [[[self.trialData objectAtIndex:index] objectForKey:@"accuracy"] floatValue]  ];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //counterLabel.alpha = 0.0;
        //[counterLabel setText:counterString];
        //hide precision overlay
        

    } completion:^(BOOL finished) {
        //counterLabel.text = [NSString stringWithFormat:@"%f", [[self.myGraph calculatePointValueSum] floatValue]];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            //counterLabel.alpha = 1.0;
            //show precision overlay
        } completion:nil];
    }];
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    
    //[self updateStats];
    [self.myGraph drawPrecisionOverlay:[self getLevelAccuracy:currentLevel]];
    
    //last dot
    self.myGraph.lastDot.alpha=0.0;
    [UIView animateWithDuration:0.2 delay:.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.myGraph.lastDot.alpha=1.0;
    } completion:nil];
    
    
    //last label
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"YYYY.MM.dd HH:mm"];
    //NSString *stringFromDate = [formatter stringFromDate:[[self.ArrayOfValues lastObject] objectForKey:@"date"]];
    //self.myGraph.lastPointLabel.text=[NSString stringWithFormat:@"%@  |  %ims",stringFromDate,(int)([[[self.ArrayOfValues lastObject] objectForKey:@"accuracy"] floatValue]*1000)];

      self.myGraph.lastPointLabel.text=[NSString stringWithFormat:@"%.03f SEC",([[[self.trialData lastObject] objectForKey:@"accuracy"] floatValue])];
    
    
}
//*/




//- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView *)graph{
//    return -100;
//}
//- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph{
//    return 100;
//}






#pragma mark - ViewController Delegate

- (void)viewDidUnload
{
   self.buttonStealer = nil;
   [super viewDidUnload];
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //set view offscreen for bounce in
    progressView.frame=CGRectMake(0, screenHeight, progressView.frame.size.width, progressView.frame.size.height);
    trophyButton.alpha=0;
    medalButton.alpha=0;
    highScoreLabel.alpha=0;
    bestLabel.alpha=0;

    restartButton.alpha=0;
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadTrialData];
    [self loadLevelProgress];

    [self performSelector:@selector(setupDots) withObject:self afterDelay:.5];

    
    [UIView animateWithDuration:0.8
                          delay:0.4
         usingSpringWithDamping:.8
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         progressView.frame=CGRectMake(0, screenHeight-44, progressView.frame.size.width, progressView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self.view sendSubviewToBack:progressView];
                         [self.view sendSubviewToBack:blob];
                         [self.myGraph reloadGraph];

                     }];

//    if(trialSequence==0)[instructions updateText:@"START" animate:YES];
    
   [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    
   // Return YES for supported orientations
  // return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
}



@end
