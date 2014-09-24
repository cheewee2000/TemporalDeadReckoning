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
            
        instructionText = [ [UILabel alloc ] initWithFrame:CGRectMake(h*.5, 0, self.frame.size.width, h+9) ];
        instructionText.textColor = [UIColor whiteColor];
        instructionText.backgroundColor = [UIColor clearColor];
        instructionText.font = [UIFont fontWithName:@"DIN Condensed" size:33.0];
        instructionText.text = @"START";
        instructionText.alpha=1.00;
        [self addSubview:instructionText];
        [self bringSubviewToFront:instructionText];
        
        self.rightLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(h*.5, 0, self.frame.size.width-h*.5-5, h+9) ];
        self.rightLabel.textColor = [UIColor whiteColor];
        self.rightLabel.textAlignment=NSTextAlignmentRight;
        self.rightLabel.backgroundColor = [UIColor clearColor];
        self.rightLabel.font = [UIFont fontWithName:@"DIN Condensed" size:33.0];
        self.rightLabel.text = @"";
        self.rightLabel.alpha=1.00;
        [self addSubview:self.rightLabel];
        [self bringSubviewToFront:self.rightLabel];
        
        self.color=[UIColor colorWithRed:1 green:1 blue:0 alpha:1];
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
    
    CGFloat r,g,b,a;
    [self.color getRed:&r green:&g blue:&b alpha:&a];
    
    CGContextSetRGBFillColor(ctx, r, g, b, a);
    CGContextFillPath(ctx);
    
    
    [super drawRect: rect];

}


-(void)slideOut{
    
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.frame = CGRectMake(-self.frame.size.width,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                     
                     }];
    
    [self setNeedsDisplay];
}
-(void)slideIn{
    
    //set arrow to right of frame
    self.frame = CGRectMake(self.frame.size.width*1.25,self.frame.origin.y,self.frame.size.width,self.frame.size.height);

    [UIView animateWithDuration:0.2
                           delay:0.0
          usingSpringWithDamping:.8
           initialSpringVelocity:1.0
                         options:UIViewAnimationOptionCurveLinear
                      animations:^{
                          self.frame = CGRectMake(0,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
                      }
                      completion:^(BOOL finished){
                      }];
    
    [self setNeedsDisplay];
}

-(void)updateText:(NSString*) str animate:(BOOL) animate{

    if(animate){
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.frame = CGRectMake(-self.frame.size.width,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         instructionText.text=str;
                         self.frame = CGRectMake(self.frame.size.width*1.25,self.frame.origin.y,self.frame.size.width,self.frame.size.height);

                         [UIView animateWithDuration:0.2
                                               delay:0.0
                              usingSpringWithDamping:.8
                               initialSpringVelocity:1.0
                                             options:UIViewAnimationOptionCurveLinear
                          
                                          animations:^{
                                              self.frame = CGRectMake(0,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
                                          }
                                          completion:^(BOOL finished){
                                          }];
                         
    }];
    }
    else{
        instructionText.text=str;
    }
    
    [self setNeedsDisplay];
}



@end
