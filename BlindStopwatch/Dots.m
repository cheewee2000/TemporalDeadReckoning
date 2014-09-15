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
        label=[[UILabel alloc] initWithFrame:CGRectMake(-10, 50, 100, 20)];
        label.text=@"";
        label.textAlignment = NSTextAlignmentLeft;
        [label setTransform:CGAffineTransformMakeRotation(M_PI *.33)];
        [self addSubview:label];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
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


-(void) setFill:(bool) b
{
    fill=b;
    [self setNeedsDisplay];

}

-(void) setText:(NSString *) s
{

    label.text=s;
    [self setNeedsDisplay];    
}

@end
