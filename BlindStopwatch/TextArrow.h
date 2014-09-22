//
//  UIView+TextArrow.h
//  BlindStopwatch
//
//  Created by Che-Wei Wang on 9/10/14.
//
//



@interface TextArrow :UILabel{
    UILabel *instructionText;

    
}
-(void)addTextLabel;
-(void)updateText:(NSString*) str;
-(void)slideIn;
-(void)slideOut;
@property UIColor *color;

@end
