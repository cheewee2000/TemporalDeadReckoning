//
//  UIView+TextArrow.m
//  BlindStopwatch
//
//  Created by Che-Wei Wang on 9/10/14.
//
//

#import "TextArrow.h"

@implementation TextArrow :UIView

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
}


@end
