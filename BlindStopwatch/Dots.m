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
        startFrame=self.frame;

        
        self.label=[[UILabel alloc] initWithFrame:CGRectMake(0, 40, 100, 20)];
        self.label.text=@"";
        self.label.textAlignment = NSTextAlignmentLeft;
        [self.label setTransform:CGAffineTransformMakeRotation(M_PI *.25)];
        [self addSubview:self.label];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        
        self.level=[[UILabel alloc] initWithFrame:CGRectMake(0, 40, 100, 20)];
        self.level.text=@"";
        self.level.textAlignment = NSTextAlignmentLeft;
        [self.level setTransform:CGAffineTransformMakeRotation(M_PI *.25)];
        [self addSubview:self.level];
        self.level.backgroundColor = [UIColor clearColor];
        self.level.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];

    }
    return self;
}



- (void) animateAlongPath:(CGRect)orbit rotate:(float) radians speed:(float)speed{
    // Set up path movement
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.repeatCount = INFINITY;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = 3.0;
    pathAnimation.speed =speed;
    
    // Create a circle path
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGRect circleContainer = orbit; // create a circle from this square, it could be the frame of an UIView
    
    CGPathAddEllipseInRect(curvedPath, NULL, circleContainer);
    
    CGRect bounds = CGPathGetBoundingBox(curvedPath); // might want to use CGPathGetPathBoundingBox
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, center.x, center.y);
    transform = CGAffineTransformRotate(transform, radians);
    transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
    CGPathRef rotatedPath=CGPathCreateCopyByTransformingPath(curvedPath, &transform);

    pathAnimation.path = rotatedPath;
    CGPathRelease(curvedPath);
    
    [self.layer addAnimation:pathAnimation forKey:@"myCircleAnimation"];
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
    self.frame=startFrame;
    [self setNeedsDisplay];
}

-(void) setFill:(bool) b
{
    fill=b;
    [self setNeedsDisplay];
}

-(void) setText:(NSString *) s level:(NSString *)l
{
    self.label.text=s;
    self.label.alpha=0.0;
    
    self.level.text=l;
    self.level.alpha=0.0;

//    [UIView animateWithDuration:0.4
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveLinear
//                     animations:^{
//                         self.label.alpha=1.0;
//                         self.level.alpha=1.0;
//                     }
//                     completion:^(BOOL finished){
//                     }];
    self.label.alpha=1.0;
    self.level.alpha=1.0;
    [self setNeedsDisplay];
}

@end
