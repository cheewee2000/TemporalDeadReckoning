//
//  LevelProgressView.m
//  BlindStopwatch
//
//  Created by Che-Wei Wang on 10/4/14.
//
//

#import "LevelProgressView.h"

@implementation LevelProgressView
- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        
        self.dotsContainer=[[UIView alloc] init];
        self.dotsContainer.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*2);
        [self addSubview:self.dotsContainer];
        [self bringSubviewToFront:self.dotsContainer];
        
        self.centerMessage=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, 160)];
        self.centerMessage.center=CGPointMake(self.frame.size.width/2.0, self.frame.size.height/5.0-80);
        self.centerMessage.text=@"";
        self.centerMessage.textAlignment = NSTextAlignmentCenter;
        self.centerMessage.backgroundColor = [UIColor clearColor];
        self.centerMessage.font = [UIFont fontWithName:@"DIN Condensed" size:140];
        self.centerMessage.textColor=[UIColor whiteColor];
        [self addSubview:self.centerMessage];

        
        self.subMessage=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, 80)];
        self.subMessage.center=CGPointMake(self.frame.size.width/2.0, self.centerMessage.center.y+90);
        self.subMessage.text=@"";
        self.subMessage.numberOfLines=2;
        self.subMessage.textAlignment = NSTextAlignmentCenter;
        self.subMessage.backgroundColor = [UIColor clearColor];
        self.subMessage.font = [UIFont fontWithName:@"DIN Condensed" size:24];
        self.subMessage.textColor=[UIColor whiteColor];
        [self addSubview:self.subMessage];
        [self bringSubviewToFront:self.subMessage];
        
        self.lowerMessage=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, 80)];
        self.lowerMessage.center=CGPointMake(self.frame.size.width/2.0, self.subMessage.center.y+90);
        self.lowerMessage.text=@"";
        self.lowerMessage.numberOfLines=2;
        self.lowerMessage.textAlignment = NSTextAlignmentCenter;
        self.lowerMessage.backgroundColor = [UIColor clearColor];
        self.lowerMessage.font = [UIFont fontWithName:@"DIN Condensed" size:24];
        self.subMessage.textColor=[UIColor whiteColor];
        [self addSubview:self.lowerMessage];
        [self bringSubviewToFront:self.lowerMessage];
 
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)displayMessage:(NSString*)s{
    [self bringSubviewToFront:self.centerMessage];

    self.centerMessage.text=s;
    self.centerMessage.alpha=0;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.centerMessage.alpha=1;
                     }
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.8
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.centerMessage.alpha=0;
                                          }
                                          completion:^(BOOL finished){
                                              
                                          }];
                     }];
    
}

@end
