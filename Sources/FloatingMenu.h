#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, InspectorPageType) {
    InspectorPageTypeLayout = 0,
    InspectorPageTypeColors,
    InspectorPageTypeTypography,
};

@interface FloatingMenu : UIView
+ (instancetype)sharedInstance;
- (void)showInView:(UIView *)parentView;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
