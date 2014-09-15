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
    UILabel *label;
    
}

-(void) setFill:(bool) b;
-(void) setText:(NSString *) s;



@end
