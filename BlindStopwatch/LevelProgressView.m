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
        self.centerMessage.center=CGPointMake(self.frame.size.width/2.0, self.frame.size.height/4.0-80);
        self.centerMessage.text=@"";
        self.centerMessage.textAlignment = NSTextAlignmentCenter;
        self.centerMessage.backgroundColor = [UIColor clearColor];
        self.centerMessage.font = [UIFont fontWithName:@"DIN Condensed" size:140];
        self.centerMessage.textColor=[UIColor whiteColor];
        [self addSubview:self.centerMessage];

        
        self.subMessage=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, 100)];
        self.subMessage.center=CGPointMake(self.frame.size.width/2.0, self.centerMessage.center.y+160);
        self.subMessage.text=@"";
        self.subMessage.numberOfLines=2;
        self.subMessage.textAlignment = NSTextAlignmentCenter;
        self.subMessage.backgroundColor = [UIColor clearColor];
        self.subMessage.font = [UIFont fontWithName:@"DIN Condensed" size:40];
        self.subMessage.textColor=[UIColor whiteColor];
        [self addSubview:self.subMessage];
        [self bringSubviewToFront:self.subMessage];
        
 
        
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
