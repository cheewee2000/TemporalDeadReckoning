//
//  UIView+Dots.m
//  BlindStopwatch
//
//  Created by Che-Wei Wang on 9/8/14.
//
//

#import "Dots.h"

@implementation Dots:UIView 

- (void)drawRect:(CGRect)rect
{
    
    CGFloat lineWidth = 1;
    
    CGRect borderRect = CGRectInset(rect, lineWidth * 0.5, lineWidth * 0.5);
    
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
@end
