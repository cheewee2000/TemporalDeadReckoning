//
//  UIView+TextArrow.h
//  BlindStopwatch
//
//  Created by Che-Wei Wang on 9/10/14.
//
//



@interface TextArrow :UILabel{
    CGRect saveFrame;
 

    
}
//-(void)addTextLabel;
-(void)updateText:(NSString*) str animate:(BOOL) animate;

-(void)slideIn:(float) delay;
-(void)slideOut:(float) delay;
-(void)resetFrame;
-(void)update:(NSString*) str rightLabel:(NSString*) rStr color:(UIColor*)c animate:(BOOL) animate;
-(void)resetFrameY;
-(void)bounce;

@property UIColor *color;
@property UILabel *rightLabel;
@property UILabel *instructionText;
@property bool drawArrow;
@property bool drawArrowRight;

@end
