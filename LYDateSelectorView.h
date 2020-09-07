#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYDateSelectorView : UIView

//单例
+(LYDateSelectorView *)initClient;

//时间区间
-(void)timeBucketWithPickerDate:(void (^)(NSDate *startDate, NSDate *endDate))completeBlock;

//时间date
-(void)dateWithPickerDate:(void (^)(NSDate *date))completeBlock;

@end

NS_ASSUME_NONNULL_END
