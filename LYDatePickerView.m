#import "LYDatePickerView.h"

static CGFloat rowsHeight = 44.0;

@interface LYDatePickerView ()

@property (nonatomic, strong) NSIndexPath *todayIndexPath;
@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) NSArray *days;
@property (nonatomic, strong) NSCalendar *calendar;

@end

@implementation LYDatePickerView

-(instancetype)initWithDatePickerView{
    
    self = [super init];
    if (self) {
        
        self.delegate = self;
        self.dataSource = self;
        
        self.years = [self nameOfYears];
        self.months = [self nameOfMonths];
        self.days = [self nameOfDays];
        self.todayIndexPath = [self todayPath];
        [self selectCurrentDate];
        
    }
    return self;
    
}

- (void)selectCurrentDate{
    
    NSIndexPath *selectIndexPath = [self todayPath];
    
    //设置当前年份
    [self selectRow:selectIndexPath.section
        inComponent:0
           animated:YES];
    [self pickerView:self didSelectRow:selectIndexPath.row inComponent:0];
    
    selectIndexPath = [self todayPath];
    
    //设置当前月份
    [self selectRow:selectIndexPath.row
        inComponent:1
           animated:YES];
    [self pickerView:self didSelectRow:selectIndexPath.row inComponent:1];
    
    //设置当前日期
    CGFloat day = [[[self currentDayName] substringToIndex:[self currentDayName].length] floatValue] - 1;
    [self selectRow:day inComponent:2 animated:YES];
    [self pickerView:self didSelectRow:day inComponent:2];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    //获取当前选中的是几号
    NSInteger currert = [pickerView selectedRowInComponent:2] + 1;
    
    //判断二月份最大天数和30号和31号
    if (currert > [self daysCountWithSelectDate]) {
        [pickerView selectRow:[self daysCountWithSelectDate] inComponent:2 animated:NO];
    }
    
    if (component == 0 || component == 1) {
        self.days = [self nameOfDays];
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
    }
    
    if ([self.pvDelegate respondsToSelector:@selector(dateWithSelect:)]) {
        [self.pvDelegate dateWithSelect:[self date]];
    }
    
}

-(NSDate *)date{

    NSString *year = [self.years objectAtIndex:([self selectedRowInComponent:0])];
    NSString *month = [self.months objectAtIndex:([self selectedRowInComponent:1])];
    NSString *day = [self.days objectAtIndex:([self selectedRowInComponent:2]) % self.days.count];

    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy年M月d日"];
    NSString *dateString = [NSString stringWithFormat:@"%@%@%@", year, month, day];
    NSDate *date = [formatter dateFromString:dateString];
    return date;

}

#pragma mark - UIPickerViewDelegate

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return [self componentWidth];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{

    UILabel *returnView = [self labelForComponent:component];
    returnView.text = [self titleForRow:row forComponent:component];
    return returnView;
    
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return rowsHeight;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if(component == 0){
        return self.years.count;
    }else if (component == 1) {
        return self.months.count;
    }else {
        return self.days.count;
    }
    
}

-(CGFloat)componentWidth{
    return self.bounds.size.width / 3;
}

-(NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if(component == 0) {
        return [self.years objectAtIndex:(row)];
    }else if(component == 1) {
        return [self.months objectAtIndex:(row)];
    }else {
        NSInteger DayCount = self.days.count;
        return [self.days objectAtIndex:(row % DayCount)];
    }
    
}

-(UILabel *)labelForComponent:(NSInteger)component{
    
    CGRect frame = CGRectMake(0, 0, [self componentWidth], rowsHeight);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.userInteractionEnabled = NO;
    return label;
    
}



#pragma mark --------- 华丽的分割线 ---------



//当前时间
-(NSIndexPath *)todayPath{
    
    CGFloat row = 0.f;
    CGFloat section = 0.f;
    
    NSString *year  = [self currentYearName];
    NSString *month = [self currentMonthName];
    
    for(NSString *cellYear in self.years) {
        
        if([cellYear isEqualToString:year]) {
            section = [self.years indexOfObject:cellYear];
            break;
        }
        
    }
    
    for(NSString *cellMonth in self.months) {
        
        if([cellMonth isEqualToString:month]) {
            row = [self.months indexOfObject:cellMonth];
            break;
        }
        
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section];
    
}

//年份数组
-(NSArray *)nameOfYears{
    
    NSMutableArray *years = [NSMutableArray array];
    NSInteger currentYear = [[[self currentYearName] substringToIndex:4] integerValue];
    
    for(NSInteger year = currentYear - 5; year <= currentYear; year++) {
        NSString *yearStr = [NSString stringWithFormat:@"%li年", (long)year];
        [years addObject:yearStr];
    }
    return years;
    
}

//月份数组
-(NSArray *)nameOfMonths{
    return @[[self month:1],
             [self month:2],
             [self month:3],
             [self month:4],
             [self month:5],
             [self month:6],
             [self month:7],
             [self month:8],
             [self month:9],
             [self month:10],
             [self month:11],
             [self month:12]];
}

//日期数组
-(NSArray *)nameOfDays{
    
    NSUInteger numberOfDaysInMonth = [self daysCountWithSelectDate];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 1; i < numberOfDaysInMonth + 1 ; i ++) {
        NSString *day = [NSString stringWithFormat:@"%d日",i];
        [tempArr addObject:day];
    }
    return tempArr;
    
}

//根据当前年月获取当前月天数
-(NSInteger)daysCountWithSelectDate{
    self.calendar = [NSCalendar currentCalendar];
    NSRange range = [self.calendar rangeOfUnit:NSCalendarUnitDay
                                        inUnit:NSCalendarUnitMonth
                                       forDate:[self monthDate]];
    return range.length;
}

//根据当前年月返回日期
-(NSDate *)monthDate{
    
    NSString *year = [self.years objectAtIndex:([self selectedRowInComponent:0])];
    NSString *month = [self.months objectAtIndex:([self selectedRowInComponent:1])];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy年M月"];
    NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", year, month]];
    return date;
    
}

//当前年份
-(NSString *)currentYearName{
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy年"];
    return [formatter stringFromDate:[NSDate date]];
    
}

//当前月份
-(NSString *)currentMonthName{
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formatter setLocale:usLocale];
    [formatter setDateFormat:@"M月"];
    return [formatter stringFromDate:[NSDate date]];
    
}

//当前日期
-(NSString *)currentDayName{
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd日"];
    return [formatter stringFromDate:[NSDate date]];
    
}

-(NSString *)month:(NSInteger)month{
    return [NSString stringWithFormat:@"%ld月",month];
}

@end
