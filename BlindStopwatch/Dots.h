//
//  UIView+Dots.h
//  BlindStopwatch
//
//  Created by Che-Wei Wang on 9/8/14.
//
//

#import <UIKit/UIKit.h>

@interface Dots:UIView
{
    bool fill;
    //UILabel *label;
    int startX;
    int startY;
    CGRect startFrame;
}

-(void) setFill:(bool) b;
-(void) setText:(NSString *) s;
-(void) resetPosition;
- (void) animateAlongPath:(CGRect) frame rotate:(float) radians speed:(float)speed;
@property UILabel *label;
@property float *labelValue;



@end
