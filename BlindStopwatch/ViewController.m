#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
//#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )
#import "RBVolumeButtons.h"

#import "HelloScene.h"


#define LEVELUPSIZE 10

@interface ViewController () {
    int previousStepperValue;

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
    running=false;
    reset=true;


    //instructions
    instructions=[[TextArrow alloc ] initWithFrame:CGRectMake(2.0, 137, self.view.frame.size.width-8, 30.0)];
    instructions.backgroundColor = [UIColor clearColor];
    instructions.textAlignment=NSTextAlignmentLeft;
    instructions.font = [UIFont fontWithName:@"DIN Condensed" size:38.0];
    instructions.text = @"";
    [self.view addSubview:instructions];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"currentLevel"] == nil) currentLevel=0;
    else currentLevel = (int)[defaults integerForKey:@"currentLevel"];
    
    if([defaults objectForKey:@"maxLevel"] == nil) maxLevel=0;
    else maxLevel = (int)[defaults integerForKey:@"maxLevel"];

    [self setLevel:currentLevel];
    [self loadData:currentLevel];
    [self loadLevelProgress];
    
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
    
    //Dots
    dots=[NSArray array];
    
    for (int i=0;i<10;i++){
        Dots *dot = [[Dots alloc] initWithFrame:CGRectMake(16+(self.view.frame.size.width-16)/10.0*i,260,15,15)];
        dot.alpha = 1;
        dot.backgroundColor = [UIColor clearColor];
        [dot setFill:NO];
        [dot setClipsToBounds:NO];
        dots = [dots arrayByAddingObject:dot];
        [self.view addSubview:dots[i]];
    }

    [self updateDots];
    [self updateTimeDisplay:0];

    
    //Levels
//    levels=[NSArray array];
//    
//    for (int i=0;i<=13;i++){
//        Level *level = [[Level alloc] initWithFrame:CGRectMake((self.view.frame.size.width-20)/13.0*i,self.view.frame.size.height-40,20,40)];
//        level.alpha = 1;
//        level.backgroundColor = [UIColor blackColor];
//        [level setClipsToBounds:NO];
//        levels = [levels arrayByAddingObject:level];
//        [self.view addSubview:levels[i]];
//    }
    
    [self updateDots];
    [self updateTimeDisplay:0];
    
    
    blob=[[UIView alloc] init];
    [self.view addSubview:blob];
    
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


    

    
    
    //3D
//    ascView=[[ASCView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*.5, self.view.frame.size.width, self.view.frame.size.height*.5)];
//    [ascView loadScene];
//    [self.view addSubview:ascView];
//    
    

        
//    SKView *spriteView = (SKView *) self.view;
//    spriteView.showsDrawCount = YES;
//    spriteView.showsNodeCount = YES;
//    spriteView.showsFPS = YES;
//
    //HelloScene* hello = [[HelloScene alloc] initWithSize:CGSizeMake(768,1024)];
    //SKView *spriteView = (SKView *) self.view;
    //[spriteView presentScene: hello];
    
    
}

-(void)setupSatellites{
    for (int i=0;i<10;i++){
        float s=30+arc4random()%100;
        Dots *sat= [satellites objectAtIndex:i];
        sat.frame=CGRectMake(16+(self.view.frame.size.width-16)/10.0*i,260,s,s);
        int dir=(arc4random() % 2 ? 1 : -1);
        float h=mainDot.frame.size.height*(arc4random()%7/10.0);
        
        CGRect orbit=CGRectMake(mainDot.frame.origin.x+s*.25, mainDot.center.y-h/2.0, mainDot.frame.size.width-s*.5, h);
        [sat animateAlongPath:orbit rotate:i/10.0*M_PI_2*2.0 speed:dir*((10.0+arc4random()%60)/100.0)];

    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}


-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:mainDot];
    CGPoint previousLocation = [aTouch previousLocationInView:mainDot];

    
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         blob.frame = CGRectOffset(blob.frame, (location.x - previousLocation.x), 0);
                         counterGoalLabel.frame = CGRectOffset(counterGoalLabel.frame, (location.x - previousLocation.x)*.25, 0);
                         counterLabel.frame = CGRectOffset(counterLabel.frame, (location.x - previousLocation.x)*.5, 0);

                         for (int i=0;i<10;i++){
                             Dots *dot = [dots objectAtIndex:i];
                             if(location.x-previousLocation.x>0)dot.frame=CGRectOffset(dot.frame, (location.x - previousLocation.x)*(1+i), 0);
                             else dot.frame=CGRectOffset(dot.frame, (location.x - previousLocation.x)*(10-i), 0);
                             
                             //Dots *sat = [satellites objectAtIndex:i];

                             //if(location.x-previousLocation.x>0)sat.frame=CGRectOffset(sat.frame, (location.x - previousLocation.x)*(1+i)*.12, 0);
                             //else sat.frame=CGRectOffset(sat.frame, (location.x - previousLocation.x)*(10-i)*.12, 0);
                         }
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if(blob.center.x<self.view.frame.size.width*.1 && currentLevel<maxLevel){
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             blob.frame = CGRectOffset(blob.frame, -self.view.frame.size.width, 0);
                             counterGoalLabel.frame = CGRectOffset(counterGoalLabel.frame, -self.view.frame.size.width, 0);
                             counterLabel.frame = CGRectOffset(counterLabel.frame, -self.view.frame.size.width, 0);
                             for (int i=0;i<10;i++){
                                 Dots *dot = [dots objectAtIndex:i];
                                 dot.frame = CGRectOffset(dot.frame, -self.view.frame.size.width, 0);
                             }
                         }
                         completion:^(BOOL finished){
                             currentLevel++;
                             counterGoalLabel.frame = CGRectOffset(counterGoalLabel.frame, self.view.frame.size.width*3, 0);
                             counterLabel.frame = CGRectOffset(counterLabel.frame, self.view.frame.size.width*3, 0);
                             [self loadLevel];
                             
                         }];
        
        

    }
    
    else if(blob.center.x>self.view.frame.size.width*.9 && currentLevel>0){
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             blob.frame = CGRectOffset(blob.frame, self.view.frame.size.width, 0);
                             counterGoalLabel.frame = CGRectOffset(counterGoalLabel.frame, self.view.frame.size.width, 0);
                             counterLabel.frame = CGRectOffset(counterLabel.frame, self.view.frame.size.width, 0);
                             for (int i=0;i<10;i++){
                                 Dots *dot = [dots objectAtIndex:i];
                                 dot.frame = CGRectOffset(dot.frame, self.view.frame.size.width, 0);
                             }
                         }
                         completion:^(BOOL finished){
                             currentLevel--;
                             counterGoalLabel.frame = CGRectOffset(counterGoalLabel.frame, -self.view.frame.size.width*3, 0);
                             counterLabel.frame = CGRectOffset(counterLabel.frame, -self.view.frame.size.width*3, 0);
                             [self loadLevel];
                             
                         }];
        
        
    }
    
    //bounce back
    else{

        [UIView animateWithDuration:0.4
                              delay:0.0
             usingSpringWithDamping:.5
              initialSpringVelocity:1.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             [self resetMainDot];
                             counterGoalLabel.frame=CGRectMake(0, 55, counterGoalLabel.frame.size.width, counterGoalLabel.frame.size.height);
                             counterLabel.frame = CGRectMake(0,counterLabel.frame.origin.y,counterLabel.frame.size.width,counterLabel.frame.size.height);
                             for (int i=0;i<10;i++){
                                 Dots *dot = [dots objectAtIndex:i];
                                 [dot resetPosition];
                                 
                             }
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        
    }

}

-(void)resetMainDot{
    int d=200;
    mainDot.frame=CGRectMake(self.view.frame.size.width/2.0-d/2.0,self.view.frame.size.width/2.0-d/2.0,d,d);
    blob.frame=CGRectMake(0,self.view.frame.size.height*.5,self.view.frame.size.width,self.view.frame.size.height*.5);

}



#pragma mark DATA
-(void)loadData:(float) level{
    //load values
    self.ArrayOfValues = [[NSMutableArray alloc] init];
    
    //Creating a file path under iOS:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    timeValuesFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"timeData%i.dat",(int)level]];
    
    //Load the array
    self.ArrayOfValues = [[NSMutableArray alloc] initWithContentsOfFile: timeValuesFile];
    
    if(self.ArrayOfValues == nil)
    {
        //Array file didn't exist... create a new one
        self.ArrayOfValues = [[NSMutableArray alloc] init];
        for (int i = 0; i < nPointsVisible; i++) {
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
-(void)loadLevelProgress{
    //load values
    levelData = [[NSMutableArray alloc] init];
    
    //Creating a file path under iOS:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *File = [documentsDirectory stringByAppendingPathComponent:@"levelProgressDictionary.dat"];
    
    //Load the array
    levelData = [[NSMutableArray alloc] initWithContentsOfFile: File];
    
    if(levelData == nil)
    {
        //Array file didn't exist... create a new one
        levelData = [[NSMutableArray alloc] init];
        for (int i = 0; i < 13; i++) {
           // [levelData addObject:[NSNumber numberWithInt:0] ];
            
            NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
            [myDictionary  setObject:[NSNumber numberWithInt:0] forKey:@"progress"];
            for(int j=0; j<10; j++){
                [myDictionary setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"progress-accuracy-%i",j]];
            }
            [levelData addObject:myDictionary];
 
        }
        [self saveLevelProgress];
    }
    
}

-(void)saveLevelProgress{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *File = [documentsDirectory stringByAppendingPathComponent:@"levelProgressDictionary.dat"];    
    [levelData writeToFile:File atomically:YES];
}




-(void)setLevel:(int)level{
    if(level>maxLevel)return;
    else if(level<0)return;

    
    for (int i=0; i<dots.count; i++){
        Dots* d=[dots objectAtIndex:i];
        d.alpha=0;
        [d resetPosition];

    }
    
    [self updateDots];
    
     const int timeIncrements []= { 1, 2, 5, 10, 20, 30, 60, 120, 180, 300, 600, 1200, 1800 };
    
    timerGoal=timeIncrements[level];
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     [defaults setInteger:currentLevel forKey:@"currentLevel"];
     [defaults synchronize];
    
    [self updateTimeDisplay:0];

     //change background color
     [UIView animateWithDuration:0.4
                           delay:0.0
                         options:UIViewAnimationOptionCurveLinear
                      animations:^{

                         NSArray * backgroundColors = [[NSArray alloc] initWithObjects:
                                            [UIColor colorWithRed:47/255.0 green:206/255.0 blue:3/255.0 alpha:1],
                                            [UIColor colorWithRed:253/255.0 green:242/255.0 blue:62/255.0 alpha:1],
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
                          self.view.backgroundColor=backgroundColors[cl];
                          instructions.color=[self inverseColor:backgroundColors[cl]];
                          
                    }
                      completion:^(BOOL finished){

                         //move timergoal label back in
                         [UIView animateWithDuration:0.6
                                               delay:0.0
                              usingSpringWithDamping:.6
                               initialSpringVelocity:1.0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{

                                            //timergoal in
                                              counterGoalLabel.frame=CGRectMake(0, 55, counterGoalLabel.frame.size.width, counterGoalLabel.frame.size.height);
                                              counterLabel.frame = CGRectMake(0,counterLabel.frame.origin.y,counterLabel.frame.size.width,counterLabel.frame.size.height);
                                          }
                                          completion:^(BOOL finished){
                                              //[instructions slideOut];
                                              //[instructions slideIn];

                                              [instructions updateText:@"START"];
                                              running=false;
                                              reset=true;
                                              
                                              [self addBlob];

                                              
                                              for (int i=0; i<dots.count; i++){

                                                  [UIView animateWithDuration:0.8
                                                                        delay:arc4random()%10/10.0
                                                                      options:UIViewAnimationOptionCurveLinear
                                                                   animations:^{
                                                                           Dots* d=[dots objectAtIndex:i];
                                                                           d.alpha=1.0;
                                                                   }
                                                                   completion:^(BOOL finished){

                                                                   }];
                                              }

                                              
                                              

                                              
                                          }];
     
          }];
    
                         
                         
                
    
    
    
    
    

}

-(UIColor*) inverseColor:(UIColor*) color
{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:a];
}


-(int)getLevel:(int)level{
    const int timeIncrements []= { 1, 2, 5, 10, 20, 30, 60, 120, 180, 300, 600, 1200, 1800 };
   return timeIncrements[level];
}


-(void) updateDots{
    for (int i=0;i<10;i++){        
        //if(i<[[levelData objectAtIndex:currentLevel] integerValue]){
        Dots* d=[dots objectAtIndex:i ];
        
        if(i<[[[levelData objectAtIndex:currentLevel] objectForKey:@"progress"] integerValue]){
          [d setFill:YES];
            float levelProgressAccuracy=[[[levelData objectAtIndex:currentLevel] objectForKey:[NSString stringWithFormat:@"progress-accuracy-%i",i]] floatValue];
            if(d.label.text.length==0){
                if(levelProgressAccuracy>=0)[d setText:[NSString stringWithFormat:@"+%.03fs", levelProgressAccuracy]];
                else [[dots objectAtIndex:i] setText:[NSString stringWithFormat:@"%.03fs", levelProgressAccuracy]];
            }
        }
        else {
            [[dots objectAtIndex:i] setFill:NO];
            [[dots objectAtIndex:i] setText:@""];
        }
    }
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
    if(running){
        //NSTimeInterval currentTime=[NSDate timeIntervalSinceReferenceDate];
        //[self updateTimeDisplay:currentTime-startTime];
        
        [counterLabel setText:[NSString stringWithFormat:@"%02u:%02u.%03u",arc4random()%99, arc4random()%60, arc4random()%999]];
        [self performSelector:@selector(updateTime) withObject:self afterDelay:arc4random()%10*0.001];
    }
    else{
        NSTimeInterval currentTime=[NSDate timeIntervalSinceReferenceDate];
        //elapsed = startTime - currentTime;
        elapsed = currentTime-startTime;
        [self updateTimeDisplay:elapsed];
    }
}


-(void)countdownTimerLabel{
    
    //goal String
    resetCounter*=.98;
    [self timerGoalDisplay:resetCounter];
    
    //main stopwatch
    NSTimeInterval diff=elapsed-(timerGoal-resetCounter);
    [self timerMainDisplay:diff];
    
    if(resetCounter>.1){
        [self performSelector:@selector(countdownTimerLabel) withObject:self afterDelay:0.0];
    }else{
        [self timerGoalDisplay:0];
        [self timerMainDisplay:elapsed-timerGoal];
        
        //pause before level reset animation
        [NSTimer scheduledTimerWithTimeInterval:.75 target:self selector:@selector(animateLevelReset) userInfo:nil repeats:NO];

    }
}



-(void)addBlob{
    
    //reposition maindot below screen
    [self resetMainDot];
    //blob.alpha=0.0;
    //blob.frame=CGRectMake(100,1, 1, 1);
    blob.transform = CGAffineTransformScale(CGAffineTransformIdentity, .00001, .000001);

    //mainDot.frame = CGRectMake(mainDot.center.x, mainDot.center.y, 1,1);
//    for (int i=0;i<10;i++){
//        Dots *sat = [satellites objectAtIndex:i];
//        sat.frame = CGRectMake(mainDot.center.x, mainDot.center.y, 1,1);
//    }
    [UIView animateWithDuration:0.8
                          delay:0.4
         usingSpringWithDamping:.5
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         //blob.alpha=1.0;
                         blob.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);

                         //[self resetMainDot];
                         
                     }
                     completion:^(BOOL finished){
                         //[self updateTimeDisplay:0];
                         

//                         [self setupSatellites];

                         
                     }];
}

-(void)fadeInOutCountersAndDots{
    //fade in new counters
    [UIView animateWithDuration:0.8
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         counterLabel.alpha=0.0;
                         counterGoalLabel.alpha=0.0;
                     }
                     completion:^(BOOL finished){
                         [self updateTimeDisplay:0];
                         [self checkLevelUp];
                         [self updateDots];

                         
                         [instructions updateText:@"START"];
                         
                         //fade in new counters
                         [UIView animateWithDuration:0.8
                                               delay:.5
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              counterLabel.alpha=1.0;
                                              counterGoalLabel.alpha=1.0;
                                          }
                                          completion:^(BOOL finished){
                                              [self addBlob];
                                          }];
                         
                     }];
    
    

    
}
-(void)animateLevelReset{
    
    if([self isAccurate]){

    [UIView animateWithDuration:1.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                        //morph to dot array
                        int levelProgress=(int)[[[levelData objectAtIndex:currentLevel] objectForKey:@"progress"] integerValue];
                        Dots *dot=[dots objectAtIndex:levelProgress];
                        //Dots *sat=[satellites objectAtIndex:levelProgress];
                         
                        //sat.frame = CGRectMake( dot.frame.origin.x,dot.frame.origin.y,dot.frame.size.width,dot.frame.size.height);
                        mainDot.frame = CGRectMake( dot.frame.origin.x,dot.frame.origin.y-self.view.frame.size.height*.5,dot.frame.size.width,dot.frame.size.height);
                        //sat.frame = CGRectMake( dot.frame.origin.x,dot.frame.origin.y,dot.frame.size.width,dot.frame.size.height);

                     }
                     completion:^(BOOL finished){
                        //[self fadeInOutCountersAndDots];
                         [UIView animateWithDuration:0.8
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              counterLabel.alpha=0.0;
                                              counterGoalLabel.alpha=0.0;
                                          }
                                          completion:^(BOOL finished){
                                              [self updateTimeDisplay:0];
                                              [self checkLevelUp];
                                              [self updateDots];

                                              
                                              [instructions updateText:@"START"];
                                              
                                              //reset tiny dot
                                              [self resetMainDot];
                                              mainDot.frame=CGRectMake(mainDot.center.x, mainDot.center.y, 1, 1);
                                              
                                              //fade in new counters
                                              [UIView animateWithDuration:0.8
                                                                    delay:.5
                                                   usingSpringWithDamping:.5
                                               
                                                    initialSpringVelocity:1.0
                                                                  options:UIViewAnimationOptionCurveLinear
                                                               animations:^{
                                                                   counterLabel.alpha=1.0;
                                                                   counterGoalLabel.alpha=1.0;
                                                                   [self resetMainDot];

                                                               }
                                                               completion:^(BOOL finished){
                                                                   //[self addBlob];
                                                               }];
                                              
                                          }];
                         
 
                         
                     }];
    }
    
    else{
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             int offDist=100;
                             //slide down big dot
                             blob.frame = CGRectMake(blob.frame.origin.x,self.view.frame.size.height+offDist,blob.frame.size.width,blob.frame.size.height);
                             
                             counterLabel.alpha=0.0;
                             counterGoalLabel.alpha=0.0;
                             
                             //drop dots
                             for (int i=0; i<dots.count; i++){
                                 Dots* d=[dots objectAtIndex:i];
                                 
                                 [UIView animateWithDuration:0.8
                                                       delay:(arc4random()%10)*.06
                                                     options:UIViewAnimationOptionCurveEaseIn
                                                  animations:^{
                                                      d.frame=CGRectMake(d.frame.origin.x, self.view.frame.size.height,d.frame.size.width,d.frame.size.height);
                                                      
                                                  }
                                                  completion:^(BOOL finished){
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
                                                      
                                                  }];
                                 
                             }
                         }
                         completion:^(BOOL finished){
                             [self fadeInOutCountersAndDots];

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

-(bool)isAccurate{
 float accuracyP=100.0-fabs(elapsed-timerGoal)/(float)timerGoal*100.0;
 if(accuracyP>=90){
     return YES;
 }
 return NO;
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


# pragma mark ACTIONS
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


//stepper button
- (IBAction)valueChanged:(UIStepper *)sender {

    if([sender value]>0)currentLevel++;
    else currentLevel--;
    sender.value=0;

    [self loadLevel];
    


}

-(void)loadLevel{

    
    if(currentLevel>maxLevel){
        currentLevel=maxLevel;
        return;
    }
    else if (currentLevel<0){
        currentLevel=0;
        return;
    }
    
    [self loadData:currentLevel];
    [self setLevel:currentLevel];
    
    [self.myGraph reloadGraph];
    
}

//volume buttons
-(void)buttonPressed{
    
    //START
    if(running==false && reset){
        running=true;
        reset=false;
        startTime=[NSDate timeIntervalSinceReferenceDate];
        [self updateTime];
        [instructions updateText:@"STOP"];
    }
    //STOP
    else if(running==true){
        running=false;
        //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [instructions updateText:@"RESET"];
        counterLabel.alpha=1.0;

    }
    
    //RESET
    else
    {
        resetCounter=timerGoal;
        [self countdownTimerLabel];
        
        reset=true;
        
        //save to disk
        NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
        [myDictionary setObject:[NSNumber numberWithFloat:(elapsed-timerGoal)] forKey:@"accuracy"];
        [myDictionary setObject:[NSDate date] forKey:@"date"];
        [self.ArrayOfValues addObject:myDictionary];
        
        
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
}

-(void)checkLevelUp{
    
    int currentLevelProgress=(int)[[[levelData objectAtIndex:currentLevel] objectForKey:@"progress"] integerValue];

    if([self isAccurate]){
        [[levelData objectAtIndex:currentLevel] setObject:[NSNumber numberWithFloat:elapsed-timerGoal] forKey:[NSString stringWithFormat:@"progress-accuracy-%i",currentLevelProgress]];
        currentLevelProgress++;
        [[levelData objectAtIndex:currentLevel] setObject:[NSNumber numberWithInt:currentLevelProgress] forKey:@"progress"];
        [self saveLevelProgress];
    }
    else{
        [[levelData objectAtIndex:currentLevel] setObject:[NSNumber numberWithInt:0] forKey:@"progress"];
        [self saveLevelProgress];
    }
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(currentLevelProgress>=LEVELUPSIZE){
        [[levelData objectAtIndex:currentLevel] setObject:[NSNumber numberWithInt:0] forKey:@"progress"];
        
        [self saveLevelProgress];
        currentLevel++;
        
        if(currentLevel>maxLevel)maxLevel=currentLevel;
        
        [self setLevel:currentLevel];
        
        [defaults setFloat:currentLevel forKey:@"currentLevel"];
        [defaults setFloat:maxLevel forKey:@"maxLevel"];
        
        [self loadData:currentLevel];
    }
    
    
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
