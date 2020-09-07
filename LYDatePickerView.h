#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LYDatePickerViewDelegate <NSObject>

-(void)dateWithSelect:(NSDate *)date;

@end

@interface LYDatePickerView : UIPickerView<UIPickerViewDelegate, UIPickerViewDataSource>

-(instancetype)initWithDatePickerView;

@property (nonatomic, assign) id<LYDatePickerViewDelegate> pvDelegate;

@property (nonatomic, strong, readonly) NSDate *date;

@end

NS_ASSUME_NONNULL_END
