//
//  UIView+Dots.m
//  BlindStopwatch
//
//  Created by Che-Wei Wang on 9/8/14.
//
//

#import "Dots.h"

@implementation Dots:UIView 

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        self.label=[[UILabel alloc] initWithFrame:CGRectMake(-10, 50, 100, 20)];
        self.label.text=@"";
        self.label.textAlignment = NSTextAlignmentLeft;
        [self.label setTransform:CGAffineTransformMakeRotation(M_PI *.33)];
        [self addSubview:self.label];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        //startY=self.frame.origin.x;
        //startY=self.frame.origin.y;
        startFrame=self.frame;
        
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat lineWidth = 1;
    CGRect borderRect = CGRectInset(rect, lineWidth , lineWidth );
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0,0,0, 1.0);
     CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
    CGContextSetLineWidth(context, lineWidth);
    if(fill) CGContextFillEllipseInRect (context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
}
-(void) resetPosition
{
    //self.frame=CGRectMake(startX, startY, self.frame.size.width, self.frame.size.height);
    self.frame=startFrame;

    [self setNeedsDisplay];
}

-(void) setFill:(bool) b
{
    fill=b;
    [self setNeedsDisplay];
}

-(void) setText:(NSString *) s
{
    self.label.text=s;
    self.label.alpha=0.0;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.label.alpha=1.0;

                     }
                     completion:^(BOOL finished){
                     }];

    
    
    [self setNeedsDisplay];
}

@end
