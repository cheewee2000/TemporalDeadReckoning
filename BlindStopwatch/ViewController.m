#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
//#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )
#import "RBVolumeButtons.h"


#define TRIALSINSTAGE 5
#define NUMHEARTS 3

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

    /* Create the Tap Gesture Recognizer */
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)];
//    tapGestureRecognizer.numberOfTouchesRequired = 1;
//    tapGestureRecognizer.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
    trialSequence=0;
    
    labelContainer=[[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:labelContainer];
    

    //instructions
    instructions=[[TextArrow alloc ] initWithFrame:CGRectMake(2.0, 137, screenWidth-8, 30.0)];
    [self.view addSubview:instructions];
    
    [labelContainer addSubview:counterLabel];
    [self.view addSubview:counterGoalLabel];
    [self.view addSubview:differencelLabel];

    [self.view bringSubviewToFront:instructions];
    
    levelArrows=[[NSMutableArray alloc] init];
    for (int i=0; i<3; i++) {
        TextArrow * arrow=[[TextArrow alloc ] initWithFrame:CGRectMake(2.0, 285+i*40, screenWidth-8, 30.0)];
        [levelArrows addObject:arrow];
        [self.view addSubview:arrow];
        [self.view sendSubviewToBack:arrow];
        [arrow slideOut:0];
    }

    
    goalPrecision=[[UILabel alloc] initWithFrame:CGRectMake(screenWidth*.5-5, counterGoalLabel.frame.size.height-30, screenWidth*.5-8, 40)];
    goalPrecision.font = [UIFont fontWithName:@"DIN Condensed" size:33.0];
    goalPrecision.textAlignment=NSTextAlignmentRight;
    goalPrecision.textColor = [UIColor whiteColor];
    goalPrecision.text = @"";
    [counterGoalLabel addSubview:goalPrecision];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"currentLevel"] == nil) currentLevel=0;
    else currentLevel = (int)[defaults integerForKey:@"currentLevel"];
    
    if([defaults objectForKey:@"maxLevel"] == nil) maxLevel=0;
    else maxLevel = (int)[defaults integerForKey:@"maxLevel"];

    [self loadData];

    //[self loadData:currentLevel];

    //[self loadLevelProgress];
    
    id progressDelegate = self;

    self.buttonStealer = [[RBVolumeButtons alloc] init];
    self.buttonStealer.upBlock = ^{
        [progressDelegate buttonPressed];
    };
    self.buttonStealer.downBlock = ^{
        [progressDelegate buttonPressed];

    };
    
    [self.buttonStealer startStealingVolumeButtonEvents];

    
    nPointsVisible=20;
    self.myGraph.colorTop =[UIColor clearColor];
    self.myGraph.colorBottom =[UIColor clearColor];
    self.myGraph.colorLine = [UIColor blackColor];
    self.myGraph.colorXaxisLabel = [UIColor blackColor];
    self.myGraph.colorYaxisLabel = [UIColor blackColor];
    self.myGraph.widthLine = 2.0;
    self.myGraph.colorPoint=[UIColor blackColor];
    self.myGraph.animationGraphStyle = BEMLineAnimationDraw;
    self.myGraph.enableTouchReport = YES;
    self.myGraph.enablePopUpReport = YES;
    self.myGraph.autoScaleYAxis = YES;

    self.myGraph.animationGraphEntranceTime = 0.8;
    //myGraph.alphaTop=.2;
    //myGraph.enableBezierCurve = YES;
    //myGraph.alwaysDisplayDots = YES;
    //myGraph.enableReferenceAxisLines = YES;
    //myGraph.enableYAxisLabel = YES;
    //myGraph.alwaysDisplayPopUpLabels = YES;
    
    self.myGraph.userInteractionEnabled=YES;
    self.myGraph.multipleTouchEnabled=YES;
    
//    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
//    [pinch setDelegate:self];
//    [self.myGraph addGestureRecognizer:pinch];
    
    
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
    
    
    
    blob=[[UIView alloc] init];
    //[self.view addSubview:blob];
    //set blob frame
    [self resetMainDot];
    
    //dot array for level progress
    progressView=[[LevelProgressView alloc] initWithFrame:self.view.frame];
    progressView.frame=CGRectOffset(progressView.frame, 0, screenHeight-44);
    [self.view addSubview:progressView];
    
    //Dots
    dots=[NSMutableArray array];

    [self setupDots];
    [self updateDots];
    [self updateTimeDisplay:0];
    
    //life hearsts
    if([defaults objectForKey:@"life"] == nil) life=NUMHEARTS;
    else life = (int)[defaults integerForKey:@"life"];
    hearts=[NSArray array];
    for (int i=0; i<NUMHEARTS; i++){
        Dots *heart = [[Dots alloc] initWithFrame:CGRectMake(16+(screenWidth-16)/10.0*(i%10), screenHeight-70,15,15)];
        heart.alpha = 1;
        heart.backgroundColor = [UIColor clearColor];
        [heart setFill:NO];
        hearts = [hearts arrayByAddingObject:heart];
        [self.view addSubview:hearts[i]];
        [self.view sendSubviewToBack:hearts[i]];
    }

    [self updateLife];
    

    //big dot
    mainDot = [[Dots alloc] init];
    mainDot.alpha = 1;
    mainDot.backgroundColor = [UIColor clearColor];
    [mainDot setFill:YES];
    [mainDot setClipsToBounds:NO];
    [self resetMainDot];
    [blob addSubview:mainDot];
    
    //satellites
    satellites=[NSArray array];
    for (int i=0;i<20;i++){
        Dots *sat = [[Dots alloc] init];
        sat.alpha = 1;
        sat.backgroundColor = [UIColor clearColor];
        [sat setFill:YES];
        [sat setClipsToBounds:NO];
        satellites = [satellites arrayByAddingObject:sat];
        [blob addSubview:satellites[i]];
    }
    [self setupSatellites];

    differencelLabel.alpha=0;
    [self.view bringSubviewToFront:differencelLabel];
    
    

    
    UIBlurEffect *blurEffect= [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    labelContainerBlur = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    labelContainerBlur.frame = self.view.bounds;
    labelContainerBlur.alpha=0;
    [labelContainer addSubview:labelContainerBlur];
   
//    blobBlur = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    blobBlur.frame = self.view.bounds;
//    blobBlur.alpha=0.0;
//    [blob addSubview:blobBlur];
    
    [self.view sendSubviewToBack:blob];
    
    
    xView=[[UIImageView alloc] init];
    [xView setImage:[UIImage imageNamed: @"x"]];
    [self.view addSubview:xView];
    [self.view sendSubviewToBack:xView];
    xView.alpha=0;

    oView=[[UIImageView alloc] init];
    [oView setImage:[UIImage imageNamed: @"o"]];
    [self.view addSubview:oView];
    [self.view sendSubviewToBack:oView];
    oView.alpha=0;
    [self xoViewOffScreen];

    [self.view sendSubviewToBack:progressView];
    
    [self setLevel:currentLevel];

    
}

-(void)setupDots{
    int currentStage=floorf(currentLevel/TRIALSINSTAGE);
    int rowHeight=60;

    for (int i = 0; i < [dots count];i++){
        [[dots objectAtIndex:i ]  setFill:NO];
        [[dots objectAtIndex:i ]  setText:@""];
        [[dots objectAtIndex:i ] removeFromSuperview];
    }
    [dots removeAllObjects];
    
    for (int i = 0; i < TRIALSINSTAGE+currentStage*TRIALSINSTAGE;i++){
        float dotDia=15;
        float margin=screenWidth/TRIALSINSTAGE/2.0+dotDia;
        Dots *dot = [[Dots alloc] initWithFrame:CGRectMake(margin+(screenWidth-margin)/TRIALSINSTAGE*(i%TRIALSINSTAGE),15-rowHeight*floor(i/TRIALSINSTAGE)+rowHeight*currentStage,dotDia,dotDia)];
        dot.alpha = 1;
        dot.backgroundColor = [UIColor clearColor];
        [dots addObject:dot];
        [progressView addSubview:dots[i]];
    }
    [self updateDots];
}

-(void) updateDots{

    for (int i=0; i<[dots count]; i++){
        if(i<currentLevel){
            [[dots objectAtIndex:i ] setFill:YES];
            
            //update text
            float diff=[[[self.ArrayOfValues objectAtIndex:i] objectForKey:@"accuracy"] floatValue];
            
            if(diff>=0)[[dots objectAtIndex:i] setText:[NSString stringWithFormat:@"+%.03fs", diff]];
            else [[dots objectAtIndex:i] setText:[NSString stringWithFormat:@"%.03fs", diff]];
        }
        else {
            [[dots objectAtIndex:i ]  setFill:NO];
            [[dots objectAtIndex:i ]  setText:@""];
        }
    }
    
    
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
    for (int i=0;i<NUMHEARTS;i++){
        Dots* d=[hearts objectAtIndex:i];
        if(i<life) [d setFill:YES];
        else [d setFill:NO];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:life forKey:@"life"];
}


#pragma mark - Setup

-(void)setupSatellites{
    for (int i=0;i<[satellites count];i++){
        float satD=30+arc4random()%100;
        Dots *sat= [satellites objectAtIndex:i];
        sat.frame=CGRectMake(16+(self.view.frame.size.width-16)/10.0*i,260,satD,satD);
        int dir=(arc4random() % 2 ? 1 : -1);
        float h=mainDot.frame.size.height*(arc4random()%7/10.0);
        
        CGRect orbit=CGRectMake(mainDot.frame.origin.x+satD*.15, mainDot.center.y-h/2.0, mainDot.frame.size.width-satD*.5, h);
        [sat animateAlongPath:orbit rotate:i/10.0*M_PI_2*2.0 speed:dir*((1.0+arc4random()%40)/200.0)];

    }
}

-(void)resetMainDot{
    int d=180;
    mainDot.frame=CGRectMake(self.view.frame.size.width/2.0-d/2.0,self.view.frame.size.width/2.0+d-44,d,d);
    //blob.frame=CGRectMake(0,self.view.frame.size.height*.5,self.view.frame.size.width,self.view.frame.size.height*.5);
    blob.frame=self.view.frame;

}


#pragma mark - Action
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}


-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.view];
    CGPoint previousLocation = [aTouch previousLocationInView:self.view];

    [self.view bringSubviewToFront:progressView];
    
    
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
//                         blob.frame = CGRectOffset(blob.frame, (location.x - previousLocation.x), 0);
//                         counterGoalLabel.frame = CGRectOffset(counterGoalLabel.frame, (location.x - previousLocation.x)*.5, 0);
//                         instructions.frame = CGRectOffset(instructions.frame, (location.x - previousLocation.x)*.3, 0);
                            progressView.frame=CGRectOffset(progressView.frame, 0,location.y - previousLocation.y);
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

        [UIView animateWithDuration:0.4
                              delay:0.0
             usingSpringWithDamping:.5
              initialSpringVelocity:1.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
//                             [self resetMainDot];
//                             counterGoalLabel.frame=CGRectMake(0, counterGoalLabel.frame.origin.y, counterGoalLabel.frame.size.width, counterGoalLabel.frame.size.height);
//                             counterLabel.frame = CGRectMake(0,counterLabel.frame.origin.y,counterLabel.frame.size.width,counterLabel.frame.size.height);
//                             instructions.frame = CGRectMake(0,instructions.frame.origin.y,instructions.frame.size.width,instructions.frame.size.height);
                            if(progressView.frame.origin.y<screenHeight/2.0) progressView.frame=self.view.frame;
                            else {
                                progressView.frame=CGRectMake(0, screenHeight-44, screenWidth, screenHeight);
                                [self.view sendSubviewToBack:progressView];

                            }
                             
//                             if(location.y - previousLocation.y<-100) progressView.frame=self.view.frame;
//                             else if(location.y - previousLocation.y>100)  progressView.frame=CGRectMake(0, screenHeight-44, screenWidth, screenHeight);
//                             
                         }
                         completion:^(BOOL finished){
                             
                         }];

}

- (IBAction)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        nPointsVisible*=1.0/([gestureRecognizer scale]*[gestureRecognizer scale]);
        
        [gestureRecognizer setScale:1.0];
        
        if(nPointsVisible>=[self.ArrayOfValues count]-1){
            nPointsVisible=[self.ArrayOfValues count]-1;
            return;
        }
        else if(nPointsVisible<=10){
            nPointsVisible=10;
            return;
        }
        self.myGraph.animationGraphEntranceTime = 0.0;
        [self.myGraph reloadGraph];
    }
}



//volume buttons
-(void)buttonPressed{
    
    //START
        if(trialSequence==0){
            trialSequence=1;

            startTime=[NSDate timeIntervalSinceReferenceDate];
            [self updateTime];
            [instructions updateText:@"STOP" animate:YES];
            [self setTimerGoalMarginDisplay];
            
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 labelContainerBlur.alpha=1;
                                 //blobBlur.alpha=0.0;
                                 //[self.view bringSubviewToFront:blob];
                                 
                             }
                             completion:^(BOOL finished){
                                 //slide out level Arrows
                                 for(int i=0; i<3; i++)[[levelArrows objectAtIndex:i] slideOut:(float)i*.2];
                             }];

            
    }
    //STOP
    else if(trialSequence==1){
            trialSequence=2;
            ///AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            counterLabel.alpha=1.0;

    }

}



-(void)updateInstructionReset{
    [instructions updateText:@"RESET" animate:YES];
    
}
-(void)setTimerGoalMarginDisplay{
    NSString * stop;
    NSDate* aDate = [NSDate dateWithTimeIntervalSince1970: [self getLevelAccuracy:currentLevel]];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"±mm:ss.SSS"];
    stop = [df stringFromDate:aDate];
    goalPrecision.text=stop;
}

-(void)saveTrialData{
    //save to disk
    NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
    [myDictionary setObject:[NSNumber numberWithFloat:(elapsed-timerGoal)] forKey:@"accuracy"];
    [myDictionary setObject:[NSDate date] forKey:@"date"];
    [self.ArrayOfValues insertObject:myDictionary atIndex:currentLevel];
    
    //save to parse
    PFObject *pObject = [PFObject objectWithClassName:@"results"];
    pObject[@"goal"] = [NSNumber numberWithFloat:(timerGoal)];
    pObject[@"accuracy"] = [NSNumber numberWithFloat:(elapsed-timerGoal)];
    pObject[@"date"]=[NSDate date];
    //pObject[@"timezone"]=[NSTimeZone localTimeZone];

    NSString*uuid;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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


#pragma mark DATA
//-(void)loadData:(float) level{
-(void)loadData{
    
    //load values
    self.ArrayOfValues = [[NSMutableArray alloc] init];
    
    //Creating a file path under iOS:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //timeValuesFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"timeData%i.dat",(int)level]];
    timeValuesFile = [documentsDirectory stringByAppendingPathComponent:@"trialData1.dat"];

    //Load the array
    self.ArrayOfValues = [[NSMutableArray alloc] initWithContentsOfFile: timeValuesFile];
    
    if(self.ArrayOfValues == nil)
    {
        //Array file didn't exist... create a new one
        self.ArrayOfValues = [[NSMutableArray alloc] init];
        for (int i = 0; i < 10; i++) {
            NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
            [myDictionary setObject:[NSNumber numberWithFloat:0.0] forKey:@"accuracy"];
            [myDictionary setObject:[NSDate date] forKey:@"date"];
            [self.ArrayOfValues addObject:myDictionary];
        }
    }
}


-(void)saveValues{
    [self.ArrayOfValues writeToFile:timeValuesFile atomically:YES];
}


#pragma mark LEVELS
//-(void)loadLevelProgress{
//    //load values
//    levelData = [[NSMutableArray alloc] init];
//    
//    //Creating a file path under iOS:
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    
//    NSString *File = [documentsDirectory stringByAppendingPathComponent:@"levelProgressDictionary.dat"];
//    
//    //Load the array
//    levelData = [[NSMutableArray alloc] initWithContentsOfFile: File];
//    
//    if(levelData == nil)
//    {
//        //Array file didn't exist... create a new one
//        levelData = [[NSMutableArray alloc] init];
//        for (int i = 0; i < [dots count]; i++) {
//            
//            NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
//            [myDictionary  setObject:[NSNumber numberWithInt:0] forKey:@"accuracy"];
////            for(int j=0; j<10; j++){
////                [myDictionary setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"progress-accuracy-%i",j]];
////            }
//            [levelData addObject:myDictionary];
// 
//        }
//        [self saveLevelProgress];
//    }
//    
//}

//-(void)saveLevelProgress{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *File = [documentsDirectory stringByAppendingPathComponent:@"levelProgressDictionary.dat"];    
//    [levelData writeToFile:File atomically:YES];
//}


-(void)setLevel:(int)level{
    
    //[self updateDots];
    
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     [defaults setInteger:currentLevel forKey:@"currentLevel"];
    
    if(level>=maxLevel){
        maxLevel=level;
        [defaults setInteger:maxLevel forKey:@"maxLevel"];

    }
     [defaults synchronize];
    
    
    timerGoal=[self getLevel:level];
    [self updateTimeDisplay:0];

    
     //change background color
     [UIView animateWithDuration:0.4
                           delay:0.0
                         options:UIViewAnimationOptionCurveLinear
                      animations:^{
                          self.view.backgroundColor=[self getBackgroundColor];
                          
                          UIColor * inverse=[self inverseColor:self.view.backgroundColor];
                          [instructions setColor:inverse];
                          progressView.backgroundColor=inverse;
                          
                        }
                      completion:^(BOOL finished){

                         //move timergoal label back in
                         [UIView animateWithDuration:0.6
                                               delay:0.0
                              usingSpringWithDamping:.6
                               initialSpringVelocity:1.0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              
                                              [instructions updateText:@"START" animate:NO];
                                              [self setTimerGoalMarginDisplay];
 
                                              
                                              //timergoal in
                                              //counterGoalLabel.frame=CGRectMake(0, counterGoalLabel.frame.origin.y, counterGoalLabel.frame.size.width, counterGoalLabel.frame.size.height);
                                              //counterLabel.frame = CGRectMake(0,counterLabel.frame.origin.y,counterLabel.frame.size.width,counterLabel.frame.size.height);
                                              //instructions.frame = CGRectMake(0,instructions.frame.origin.y,instructions.frame.size.width,instructions.frame.size.height);
                                              
                                              
                                              //counterLabel
                                              //instructions.frame = CGRectMake(0,instructions.frame.origin.y,instructions.frame.size.width,instructions.frame.size.height);

                                          }
                                          completion:^(BOOL finished){
                                              trialSequence=0;
                                              //[self addBlob];
                                              
                                              //slide out level Arrows
                                              //for(int i=0; i<3; i++)[[levelArrows objectAtIndex:i] slideOut:2+(float)i*.33];
                                              
                                          }];
     
          }];
    
}

-(float)getLevel:(int)level{
    float l;
    if(level<TRIALSINSTAGE)l=.5+level*.1;
    else if(level<TRIALSINSTAGE*2)l=level*.25;
    else if(level<TRIALSINSTAGE*3)l=level*.5;
    else if(level<TRIALSINSTAGE*4)l=level*1.0;
    else if(level<TRIALSINSTAGE*5)l=level*2.0;
    else l=level*5.0;
    return l;
}

-(float)getLevelAccuracy:(int)level{
    if([self getLevel:level]<=5) return .1;
    if([self getLevel:level]<=10) return .25;
    else if([self getLevel:level]<=20) return .5;
    else  return 1.0;
}


-(void)checkLevelUp{


    [UIView animateWithDuration:.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         if([self isAccurate]){
                             Dots *dot=[dots objectAtIndex:currentLevel];
                             oView.frame = CGRectMake( dot.frame.origin.x,dot.frame.origin.y+screenHeight-44,dot.frame.size.width,dot.frame.size.height);

                         }
                         else{
                             Dots *dot=[hearts objectAtIndex:life-1];
                             xView.frame = CGRectMake( dot.frame.origin.x,dot.frame.origin.y,dot.frame.size.width,dot.frame.size.height);
                             
                         }
                     }
                     completion:^(BOOL finished){
                       
                         [self xoViewOffScreen];
                         
                         if([self isAccurate]){
                             life=NUMHEARTS;
                             currentLevel++;
                         }
                         else{
                             life--;
                         }
                         
                         if(life==0) currentLevel=0;
                         
                         
                         
                         //check for stage up to add dots
                         if (currentLevel%TRIALSINSTAGE==0) [self setupDots];
                         
                         
                         //[self saveLevelProgress];
                         //[self loadLevel];
                         
                         //need delay here for currentLevel to get set !!!!!!
                         [self performSelector:@selector(loadLevel) withObject:self afterDelay:0.5];
                         [self performSelector:@selector(animateLevelReset) withObject:self afterDelay:1.0];
                         


                     }];
    
    

    
}


-(void)loadLevel{
    if(currentLevel==0 && life==0){
        life=NUMHEARTS;
    }
    [self updateDots];
    [self updateLife];
    [self setLevel:currentLevel];
    [self loadData];
    [self.myGraph reloadGraph];
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
    [ngf setDateFormat:@"mm:ss.SSS"];
    NSString* nGoalString = [ngf stringFromDate:nDate];
    [nextLevelLabel setText:[NSString stringWithFormat:@"NEXT LEVEL:%@",nGoalString]];
}


-(void)updateTime{
    
    NSTimeInterval currentTime=[NSDate timeIntervalSinceReferenceDate];
    elapsed = currentTime-startTime;
    
    if(trialSequence==1){

        if(elapsed<1){
            [self updateTimeDisplay:currentTime-startTime];
            [self performSelector:@selector(updateTime) withObject:self afterDelay:.01];
        }else{
            [counterLabel setText:[NSString stringWithFormat:@"%02u:%02u.%03u",arc4random()%99, arc4random()%60, arc4random()%999]];
            [self performSelector:@selector(updateTime) withObject:self afterDelay:arc4random()%10*0.001];
        }
    }
    else{
        [self updateTimeDisplay:elapsed];
        [self animateLevelDotScore];
 
    }
}



-(NSString *)getTimeDiffString:(NSTimeInterval)time{
    
    NSDate* aDate = [NSDate dateWithTimeIntervalSince1970: fabs(time)];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    if(time>0) [df setDateFormat:@"+mm:ss.SSS"];
    else [df setDateFormat:@"-mm:ss.SSS"];
    
    NSString* counterString = [df stringFromDate:aDate];
    return counterString;
    
}



-(void)timerDiffDisplay:(NSTimeInterval)time{
    
    NSDate* aDate = [NSDate dateWithTimeIntervalSince1970: fabs(time)];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    if(time>0) [df setDateFormat:@"mm:ss.SSS"];
    else [df setDateFormat:@"mm:ss.SSS"];
    
    NSString* counterString = [df stringFromDate:aDate];
    [differencelLabel setText:counterString];
}



-(void)timerGoalDisplay:(NSTimeInterval)goal{
    NSDate* gDate = [NSDate dateWithTimeIntervalSince1970: goal];
    NSDateFormatter* gf = [[NSDateFormatter alloc] init];
    [gf setDateFormat:@"mm:ss.SSS"];
    NSString* goalString = [gf stringFromDate:gDate];
    [counterGoalLabel setText:goalString];
}

-(void)timerMainDisplay:(NSTimeInterval)time{
    
    NSDate* aDate = [NSDate dateWithTimeIntervalSince1970: fabs(time)];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    if(time>0) [df setDateFormat:@"mm:ss.SSS"];
    else [df setDateFormat:@"mm:ss.SSS"];
    
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

    blob.transform = CGAffineTransformScale(CGAffineTransformIdentity, .00001, .000001);

    [UIView animateWithDuration:0.8
                          delay:0.4
         usingSpringWithDamping:.5
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         blob.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                     }
                     completion:^(BOOL finished){

                     }];
}



# pragma mark Animate Level


-(void)animateLevelDotScore{
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         //blobBlur.alpha=1;
                         labelContainerBlur.alpha=0.0;
                         //[self.view sendSubviewToBack:blob];
                        }
         completion:^(BOOL finished){
             
             [self showXO];
             
             TextArrow *t= [levelArrows objectAtIndex:0];
             
             float d=1.0;
             //update text
             float diff=elapsed-timerGoal;
             NSString *diffString;
             //if(diff>=0)diffString=[NSString stringWithFormat:@"OFF BY +%.03f", diff];
             //else diffString=[NSString stringWithFormat:@"OFF BY %.03f", diff];
             diffString=[NSString stringWithFormat:@"OFF BY %@",[self getTimeDiffString:diff]];
                          
             
             [t update:@"" rightLabel:diffString color:[self inverseColor:[self getBackgroundColor]] animate:NO];
             [t slideIn:.3+d];
             
             float accuracyP=100.0-fabs(diff/(float)timerGoal)*100.0;
             NSString* percentAccuracyString = [NSString stringWithFormat:@"ACCURACY %02i%%", (int)accuracyP];
             t= [levelArrows objectAtIndex:1];
             [t update:@"" rightLabel:percentAccuracyString color:[self inverseColor:[self getBackgroundColor]] animate:NO];
             [t slideIn:.6+d];
             
             NSString * stageProgressString;
             if([self isAccurate]){
                 stageProgressString=[NSString stringWithFormat:@"LEVEL %.03f CLEARED",[self getLevel:currentLevel]];
             }
             else if(life>2) stageProgressString=[NSString stringWithFormat:@"%i TRIES LEFT",life-1];
             else if(life>1) stageProgressString=@"ONE TRY LEFT";
             else{
                 stageProgressString=@"GAME OVER";
             }
             
             t= [levelArrows objectAtIndex:2];
             [t update:@"" rightLabel:stageProgressString color:[self inverseColor:[self getBackgroundColor]] animate:NO];
             [t slideIn:.9+d];
             
             
             
             [UIView animateWithDuration:1.0
                                   delay:0.0
                                 options:UIViewAnimationOptionCurveEaseInOut
                              animations:^{
                                  //differencelLabel.alpha=1;
                            }
                              completion:^(BOOL finished){
                                  //differencelLabel.text=@"00:00.000";
                                  //resetCounter=fabs(elapsed-timerGoal)*.15;
                                  //count difference
                                  //[self performSelector:@selector(countdownTimerLabel) withObject:self afterDelay:0.2];

                                  //show success label
                                  //[self performSelector:@selector(showTrialInstruction) withObject:self afterDelay:1.8];
                                  //drop dots or morph to levedots
                                  [self performSelector:@selector(morphOrDropDots) withObject:self afterDelay:2.5];
                                  //for(int i=0; i<3; i++)[[levelArrows objectAtIndex:i] slideOut:10+(float)i*.2];

                                  
                              }];
             
             
             
             

             
         }];

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
        //[instructions update:@"" rightLabel:@"NICE" color:[UIColor colorWithRed:0 green:1 blue:0 alpha:1] animate:YES];
        [self displayXorO:YES];
        
    }
    else{
        [self displayXorO:NO];

        //if(elapsed-timerGoal>0)[instructions update:@"" rightLabel:@"TOO SLOW" color:[UIColor colorWithRed:1 green:0 blue:0 alpha:1] animate:YES];
        //if(elapsed-timerGoal<0)[instructions update:@"" rightLabel:@"TOO FAST" color:[UIColor colorWithRed:1 green:0 blue:0 alpha:1] animate:YES];
    }

}

-(void)displayXorO:(bool)showO{

    xView.alpha=1.0;
    oView.alpha=1.0;
    [UIView animateWithDuration:0.6
                          delay:0.0
         usingSpringWithDamping:.5
          initialSpringVelocity:.5
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         float w=210;
                         if([self isAccurate])oView.frame=CGRectMake(screenWidth/2.0-w/2.0, screenHeight-44-w-22, w, w);
                         else xView.frame=CGRectMake(screenWidth/2.0-w/2.0, screenHeight-44-w-22, w, w);
                     }
                     completion:^(BOOL finished){
 
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
    
    if([self isAccurate]){

        [self.view bringSubviewToFront:progressView];
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
//                             
//                             counterGoalLabel.frame=CGRectMake(-screenWidth, counterGoalLabel.frame.origin.y, counterGoalLabel.frame.size.width, counterGoalLabel.frame.size.height);
//                             counterLabel.frame = CGRectMake(-screenWidth,counterLabel.frame.origin.y,counterLabel.frame.size.width,counterLabel.frame.size.height);
//                             instructions.frame = CGRectMake(-screenWidth,instructions.frame.origin.y,instructions.frame.size.width,instructions.frame.size.height);
                             
//                             counterGoalLabel.frame=CGRectOffset(counterGoalLabel.frame, -screenWidth, 0);
//                             counterLabel.frame=CGRectOffset(counterLabel.frame, -screenWidth, 0);
//                             instructions.frame=CGRectOffset(instructions.frame, -screenWidth, 0);

                             //counterLabel.frame=CGRectOffset(counterLabel.frame, 0, screenHeight);
                             //instructions.frame=CGRectOffset(instructions.frame, 0, screenHeight);
                             
                             counterLabel.alpha=0.0;
                             counterGoalLabel.alpha=0.0;
                             instructions.alpha=0;

                             //progressView.frame=self.view.frame;

                             //blobBlur.alpha=0;
                             labelContainerBlur.alpha=0.0;
                         }
                         completion:^(BOOL finished){
                             
                             //counterGoalLabel.frame=CGRectMake(screenWidth, counterGoalLabel.frame.origin.y, counterGoalLabel.frame.size.width, counterGoalLabel.frame.size.height);
                             //counterLabel.frame = CGRectMake(screenWidth,counterLabel.frame.origin.y,counterLabel.frame.size.width,counterLabel.frame.size.height);
                             //instructions.frame = CGRectMake(screenWidth,instructions.frame.origin.y,instructions.frame.size.width,instructions.frame.size.height);
                             [self.view sendSubviewToBack:progressView];
                             

//                             instructions.frame=CGRectOffset(instructions.frame, 0, -screenHeight*2);
//                             counterGoalLabel.frame=CGRectMake(0,-180,screenWidth,108);
//                             counterLabel.frame=CGRectMake(0,-108,screenWidth,108);
                             //counterGoalLabel.frame=CGRectOffset(counterGoalLabel.frame, 2.0*screenWidth, 0);
                             //counterLabel.frame=CGRectOffset(counterLabel.frame, 2.0*screenWidth, 0);
                             
                             
                             [self saveTrialData];
                             [self checkLevelUp];
                        }];
    }
    else{
        [UIView animateWithDuration:0.8
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             //blobBlur.alpha=0;
                             labelContainerBlur.alpha=0.0;
                             counterLabel.alpha=0.0;
                             //counterGoalLabel.alpha=0.0;
                             instructions.alpha=0;

                         }
                         completion:^(BOOL finished){
                             
                [UIView animateWithDuration:.4
                                      delay:.5
                                    options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{

                                     if(life==0){
                                         //drop dots
                                         for (int i=0; i<dots.count; i++){
                                             Dots* d=[dots objectAtIndex:i];
                                             
                                             [UIView animateWithDuration:0.4
                                                                   delay:(arc4random()%10)*.1
                                                                 options:UIViewAnimationOptionCurveEaseIn
                                                              animations:^{
                                                                  d.frame=CGRectMake(d.frame.origin.x, self.view.frame.size.height,d.frame.size.width,d.frame.size.height);
                                                                  
                                                              }
                                                              completion:^(BOOL finished){
                                                                  
                                                                  
                                                              }];
                                             
                                         }
                                     }
                                 }
                                 completion:^(BOOL finished){

                                     [self saveTrialData];
                                     [self checkLevelUp];

                                 }];
                 }];
        
    }
    

}

-(void)animateLevelReset{
    [instructions slideOut:0];

    if([self isAccurate]){

        [self updateTimeDisplay:0];
        //[self setTimerGoalMarginDisplay];


        //reset and scale tiny dot
        //[self resetMainDot];
        //mainDot.frame=CGRectMake(mainDot.center.x, mainDot.center.y, 1, 1);
//        counterLabel.alpha=1.0;
//        counterGoalLabel.alpha=1.0;
//        [self slideInCounterLabel];
        
        //fade out diff label
//        [UIView animateWithDuration:0.4
//                              delay:0
//                            options:UIViewAnimationOptionCurveLinear
//                         animations:^{
//                             differencelLabel.alpha=0;
//                             //counterGoalLabel.frame=CGRectMake(0,55,screenWidth,108);
//                             //counterLabel.frame=CGRectMake(0,169,screenWidth,108);
//                             counterLabel.frame = CGRectMake(0,counterLabel.frame.origin.y,counterLabel.frame.size.width,counterLabel.frame.size.height);
//                             counterGoalLabel.frame = CGRectMake(0,counterGoalLabel.frame.origin.y,counterGoalLabel.frame.size.width,counterGoalLabel.frame.size.height);
//
//                             
//                         }
//                         completion:^(BOOL finished){
//                         }];
        
        
          [UIView animateWithDuration:.4
                                delay:0
               usingSpringWithDamping:.5
                initialSpringVelocity:1.0
                              options:UIViewAnimationOptionCurveLinear
                           animations:^{
                               progressView.frame=CGRectMake(0, screenHeight-44, self.view.frame.size.width, screenHeight);
                               //[self resetMainDot];

                           }
                           completion:^(BOOL finished){
                               
                               //fade in counters
                               [UIView animateWithDuration:0.4
                                                     delay:.5
                                                   options:UIViewAnimationOptionCurveLinear
                                                animations:^{
                                                    counterLabel.alpha=1.0;
                                                    counterGoalLabel.alpha=1.0;
                                                    instructions.alpha=1.0;
                                                    differencelLabel.alpha=0;
                                                    
  

                                                }
                                                completion:^(BOOL finished){
                                                    
                                                    UIColor * inverse=[self inverseColor:self.view.backgroundColor];
                                                    [instructions update:@"START" rightLabel:@"" color:inverse animate:NO];
                                                    [instructions slideIn:0.0];
                                                    trialSequence=0;

                                                    differencelLabel.text=@"00:00.000";
                                                    
                                                }];
                               
                               
                           }];
          
          

          
        
         
 
                   
    }
    
    else{
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
//                             counterLabel.alpha=0.0;
//                             counterGoalLabel.alpha=0.0;
//                             instructions.alpha=0.0;

                             progressView.frame=CGRectMake(0, screenHeight-44, self.view.frame.size.width, screenHeight);

                             if(life==0){
                                 //reset Dots
                                 for (int i=0; i<dots.count; i++){
                                     Dots* d=[dots objectAtIndex:i];
                      
                                          d.alpha=0.0;
                                          [d resetPosition];
      
                                          //fade in new dots
                                          [UIView animateWithDuration:0.8
                                                                delay:0.4
                                                              options:UIViewAnimationOptionCurveEaseIn
                                                           animations:^{
                                                               d.alpha=1.0;
                                                           }
                                                           completion:^(BOOL finished){
                                                               
                                                           }];
        
                                 }
                             }
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.8
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{

                                                  differencelLabel.alpha=0;

                                              }
                                              completion:^(BOOL finished){
                                                  [self updateTimeDisplay:0];
                                                  //[self setTimerGoalMarginDisplay];
     
                                                  

                                                  //fade in new counters
                                                  [UIView animateWithDuration:0.8
                                                                        delay:.5
                                                                      options:UIViewAnimationOptionCurveLinear
                                                                   animations:^{
                                                                       counterLabel.alpha=1.0;
                                                                       instructions.alpha=1.0;
                                                                       counterGoalLabel.alpha=1.0;
                                                                   }
                                                                   completion:^(BOOL finished){
                                                                       //[self addBlob];
                                                                       
                                                                       [instructions resetFrame];
                                                                       UIColor * inverse=[self inverseColor:self.view.backgroundColor];
                                                                       [instructions update:@"START" rightLabel:@"" color:inverse animate:NO];
                                                                       [instructions slideIn:0];
                                                                       trialSequence=0;

                                                                       differencelLabel.text=@"00:00.000";

                                                                   }];
                                                  
                                              }];
                             
                         }];
    }
 
    
}


-(void)slideOutCounterLabel{
    //move counter with arrow
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
     
                     animations:^{
                         counterLabel.frame = CGRectMake(-counterLabel.frame.size.width,counterLabel.frame.origin.y,counterLabel.frame.size.width,counterLabel.frame.size.height);
                     }
                     completion:^(BOOL finished){
                    }];
}


-(void)slideInCounterLabel{

     //counterLabel.text=@"00:00.000";
     counterLabel.frame = CGRectMake(counterLabel.frame.size.width,counterLabel.frame.origin.y,counterLabel.frame.size.width,counterLabel.frame.size.height);
     
     [UIView animateWithDuration:0.2
                           delay:0.4
          usingSpringWithDamping:.8
           initialSpringVelocity:1.0
                         options:UIViewAnimationOptionCurveLinear
      
                      animations:^{
                          counterLabel.frame = CGRectMake(0,counterLabel.frame.origin.y,counterLabel.frame.size.width,counterLabel.frame.size.height);
                      }
                      completion:^(BOOL finished){
                      }];
    
}

-(void)slideOutInCounterLabel{
    counterLabel.text=@"00:00.000";
    counterLabel.frame = CGRectMake(counterLabel.frame.size.width,counterLabel.frame.origin.y,counterLabel.frame.size.width,counterLabel.frame.size.height);
    
    [UIView animateWithDuration:0.2
                          delay:0.4
         usingSpringWithDamping:.8
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveLinear
     
                     animations:^{
                         counterLabel.frame = CGRectMake(0,counterLabel.frame.origin.y,counterLabel.frame.size.width,counterLabel.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self slideInCounterLabel];
                     }];
    
}









# pragma mark Helpers

-(UIColor*) getBackgroundColor{
    
    NSArray * backgroundColors = [[NSArray alloc] initWithObjects:
                                  [UIColor colorWithRed:47/255.0 green:206/255.0 blue:3/255.0 alpha:1],
                                  [UIColor colorWithRed:254/255.0 green:3/255.0 blue:215/255.0 alpha:1],
                                  [UIColor colorWithRed:255/255.0 green:61/255.0 blue:132/255.0 alpha:1],
                                  [UIColor colorWithRed:250/255.0 green:128/255.0 blue:167/255.0 alpha:1],
                                  [UIColor colorWithRed:255/255.0 green:191/255.0 blue:53/255.0 alpha:1],
                                  [UIColor colorWithRed:0/255.0 green:168/255.0 blue:198/255.0 alpha:1],
                                  [UIColor colorWithRed:174/255.0 green:226/255.0 blue:57/255.0 alpha:1],
                                  [UIColor colorWithRed:255/255.0 green:78/255.0 blue:80/255.0 alpha:1],
                                  [UIColor colorWithRed:255/255.0 green:0/255.0 blue:81/255.0 alpha:1],
                                  [UIColor colorWithRed:182/255.0 green:255/255.0 blue:0/255.0 alpha:1],
                                  [UIColor colorWithRed:34/255.0 green:141/255.0 blue:255/255.0 alpha:1],
                                  [UIColor colorWithRed:255/255.0 green:0/255.0 blue:146/255.0 alpha:1],
                                  [UIColor colorWithRed:186/255.0 green:1/255.0 blue:255/255.0 alpha:1],
                                  
                                  nil];
    
    int cl=currentLevel%[backgroundColors count];
    
    return backgroundColors[cl];
}
-(UIColor*) inverseColor:(UIColor*) color
{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:a];
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



#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return nPointsVisible;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    if([self.ArrayOfValues count]==0)return 0.0;
    index=[self.ArrayOfValues count]-nPointsVisible+index; //show last nPoints
    return ([[[self.ArrayOfValues objectAtIndex:index] objectForKey:@"accuracy"] floatValue]*1000);
}




#pragma mark - SimpleLineGraph Delegate
- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @"ms";
}

- (NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 3;
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return [self.ArrayOfValues count];
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
    self.labelValues.text = [NSString stringWithFormat:@"%02f", [[[self.ArrayOfValues objectAtIndex:index] objectForKey:@"accuracy"] floatValue]  ];
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
    
    [self updateStats];
    [self.myGraph drawPrecisionOverlay:timerGoal];
    
    //last dot
    self.myGraph.lastDot.alpha=0.0;
    [UIView animateWithDuration:0.2 delay:.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.myGraph.lastDot.alpha=1.0;
    } completion:nil];
    
    
    //last label
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY.MM.dd HH:mm"];
    NSString *stringFromDate = [formatter stringFromDate:[[self.ArrayOfValues lastObject] objectForKey:@"date"]];
    
    self.myGraph.lastPointLabel.text=[NSString stringWithFormat:@"%@  |  %ims",stringFromDate,(int)([[[self.ArrayOfValues lastObject] objectForKey:@"accuracy"] floatValue]*1000)];

    
    
    
}





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
    
//HelloScene* hello = [[HelloScene alloc] initWithSize:CGSizeMake(768,1024)];
//SKView *spriteView = (SKView *) self.view;
//[spriteView presentScene: hello];
    
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated
{
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


@end
