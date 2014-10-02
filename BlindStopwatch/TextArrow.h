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

-(void)slideIn;
-(void)slideOut;
-(void)resetFrame;
-(void)update:(NSString*) str rightLabel:(NSString*) rStr color:(UIColor*)c animate:(BOOL) animate;
-(void)resetFrameY;

@property UIColor *color;
@property UILabel *rightLabel;
@property UILabel *instructionText;

@end
