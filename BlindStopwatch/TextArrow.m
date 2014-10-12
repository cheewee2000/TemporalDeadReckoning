//
//  UIView+TextArrow.m
//  BlindStopwatch
//
//  Created by Che-Wei Wang on 9/10/14.
//
//

#import "TextArrow.h"
#define SLIDESPEED .14
@implementation TextArrow :UILabel


- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment=NSTextAlignmentLeft;
        self.font = [UIFont fontWithName:@"DIN Condensed" size:38.0];
        self.text = @"";
        
        
        int h=self.frame.size.height;
            
        self.instructionText = [ [UILabel alloc ] initWithFrame:CGRectMake(h*.5, 0, self.frame.size.width, h+9) ];
        self.instructionText.textColor = [UIColor whiteColor];
        self.instructionText.backgroundColor = [UIColor clearColor];
        self.instructionText.font = [UIFont fontWithName:@"DIN Condensed" size:33.0];
        self.instructionText.text = @"";
        self.instructionText.alpha=1.00;
        [self addSubview:self.instructionText];
        [self bringSubviewToFront:self.instructionText];
        
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
        saveFrame=theFrame;
        self.drawArrow=true;
        
        
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    if(self.drawArrow){
        CGContextMoveToPoint (ctx, CGRectGetMinX(rect), CGRectGetMidY(rect));  // mid left
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect)+CGRectGetMaxY(rect)/2, CGRectGetMaxY(rect));  // bottom left
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));  // bottom left
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // top left
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect)+CGRectGetMaxY(rect)/2, CGRectGetMinY(rect));  // mid right
    }else{
        CGContextMoveToPoint (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    }
    CGContextClosePath(ctx);

    
    CGFloat r,g,b,a;
    [self.color getRed:&r green:&g blue:&b alpha:&a];
    
    CGContextSetRGBFillColor(ctx, r, g, b, a);
    CGContextFillPath(ctx);
    
    
    [super drawRect: rect];

}

-(void)resetFrame{
    self.frame=saveFrame;
}
-(void)resetFrameY{
    self.frame=CGRectMake(self.frame.origin.x, saveFrame.origin.y, self.frame.size.width, self.frame.size.height);
}

-(void)slideOut:(float) delay{
    
    if(self.frame.origin.x<10 && self.frame.origin.x>=0 ){
    [UIView animateWithDuration:SLIDESPEED
                          delay:delay
         usingSpringWithDamping:.8
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.frame = CGRectMake(-self.frame.size.width*1.1,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         //set arrow to right of frame
                         self.frame = CGRectMake(saveFrame.size.width*1.1,saveFrame.origin.y,saveFrame.size.width,saveFrame.size.height);

                     }];
    }
    else{
        self.frame = CGRectMake(saveFrame.size.width*1.1,saveFrame.origin.y,saveFrame.size.width,saveFrame.size.height);
    }
    
    
    
    [self setNeedsDisplay];
}
-(void)slideIn:(float) delay{
    
    //set arrow to right of frame
    self.frame = CGRectMake(saveFrame.size.width*1.1,saveFrame.origin.y,saveFrame.size.width,saveFrame.size.height);

    [UIView animateWithDuration:SLIDESPEED
                           delay:delay
          usingSpringWithDamping:.8
           initialSpringVelocity:1.0
                         options:UIViewAnimationOptionCurveLinear
                      animations:^{
                          self.frame = CGRectMake(0,saveFrame.origin.y,saveFrame.size.width,saveFrame.size.height);
                      }
                      completion:^(BOOL finished){
                          self.frame = CGRectMake(0,saveFrame.origin.y,saveFrame.size.width,saveFrame.size.height);
                      }];
    
    [self setNeedsDisplay];
}

-(void)updateText:(NSString*) str animate:(BOOL) animate{

    if(animate){
    [UIView animateWithDuration:SLIDESPEED
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.frame = CGRectMake(-self.frame.size.width,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         self.instructionText.text=str;
                         self.frame = CGRectMake(self.frame.size.width*1.1,self.frame.origin.y,self.frame.size.width,self.frame.size.height);

                         [UIView animateWithDuration:SLIDESPEED
                                               delay:0.1
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
        self.instructionText.text=str;
    }
    
    [self setNeedsDisplay];
}

-(void)update:(NSString*) str rightLabel:(NSString*) rStr color:(UIColor*)c animate:(BOOL) animate{
    
    if(animate){
        [UIView animateWithDuration:SLIDESPEED
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.frame = CGRectMake(-self.frame.size.width,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             self.instructionText.text=str;
                             self.rightLabel.text=rStr;
                             self.color=c;
                             [self setNeedsDisplay];

                             self.frame = CGRectMake(self.frame.size.width*1.25,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
                             
                             [UIView animateWithDuration:SLIDESPEED
                                                   delay:0.1
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
        self.instructionText.text=str;
        self.rightLabel.text=rStr;
        self.color=c;
    }
    
    [self setNeedsDisplay];
}




@end
