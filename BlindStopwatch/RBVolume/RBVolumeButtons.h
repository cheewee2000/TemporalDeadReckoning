
#import <Foundation/Foundation.h>

typedef void (^ButtonBlock)();

@interface RBVolumeButtons : NSObject
{
   float launchVolume;
   BOOL hadToLowerVolume;
   BOOL hadToRaiseVolume;
   
   BOOL _isStealingVolumeButtons;
   BOOL _suspended;
   UIView *_volumeView;
}

@property (nonatomic, copy) ButtonBlock upBlock;
@property (nonatomic, copy) ButtonBlock downBlock;
@property (readonly) float launchVolume;

-(void)startStealingVolumeButtonEvents;
-(void)stopStealingVolumeButtonEvents;

@end
