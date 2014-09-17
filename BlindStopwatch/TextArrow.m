//
//  UIView+TextArrow.m
//  BlindStopwatch
//
//  Created by Che-Wei Wang on 9/10/14.
//
//

#import "TextArrow.h"

@implementation TextArrow :UILabel


- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        
    int h=self.frame.size.height;
        
    instructionText = [ [UILabel alloc ] initWithFrame:CGRectMake(h*.5, 0, self.frame.size.width, h+11) ];
    instructionText.textColor = [UIColor blackColor];
    instructionText.backgroundColor = [UIColor clearColor];
    instructionText.font = [UIFont fontWithName:@"DIN Condensed" size:36.0];
    instructionText.text = @"START";
    instructionText.alpha=1.00;
    [self addSubview:instructionText];
    [self bringSubviewToFront:instructionText];

    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMidY(rect));  // top left
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect)+CGRectGetMaxY(rect)/2, CGRectGetMaxY(rect));  // mid right
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));  // bottom left
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // top left
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect)+CGRectGetMaxY(rect)/2, CGRectGetMinY(rect));  // mid right
    CGContextClosePath(ctx);
    CGContextSetRGBFillColor(ctx, 1, 1, 0, 1);
    CGContextFillPath(ctx);
    
    
    [super drawRect: rect];

}


//- (void)drawTextInRect:(CGRect)rect
//{
//    
//    self.textColor = [UIColor blackColor];
//    self.backgroundColor = [UIColor clearColor];
//    self.font = [UIFont fontWithName:@"DIN Condensed" size:38.0];
//    self.text = @"START";
//    self.alpha=1.00;
//    
//    [super drawTextInRect:rect];
//    
//
//    
//    
//}


//-(void)addTextLabel{
//    
//    UILabel *instructionLabel;
//    int h=self.frame.size.height;
//    instructionLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(h*.5, 0, self.frame.size.width, h+12+30) ];
//    instructionLabel.textColor = [UIColor blackColor];
//    instructionLabel.backgroundColor = [UIColor clearColor];
//    instructionLabel.font = [UIFont fontWithName:@"DIN Condensed" size:38.0];
//    instructionLabel.text = @"START";
//    instructionLabel.alpha=1.00;
//    [self addSubview:instructionLabel];
//    [self bringSubviewToFront:instructionLabel];
//    
//}

-(void)updateText:(NSString*) str{

    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn

                     animations:^{
                         self.frame = CGRectMake(-self.frame.size.width,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         instructionText.text=str;
                         self.frame = CGRectMake(self.frame.size.width,self.frame.origin.y,self.frame.size.width,self.frame.size.height);

                         [UIView animateWithDuration:0.2
                                               delay:0
                              usingSpringWithDamping:.8
                               initialSpringVelocity:1.0
                                             options:UIViewAnimationOptionCurveLinear
                          
                                          animations:^{
                                              self.frame = CGRectMake(0,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
                                          }
                                          completion:^(BOOL finished){
                                          }];
                         
    }];
    
    [self setNeedsDisplay];
}



@end
