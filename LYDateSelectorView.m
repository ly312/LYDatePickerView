#import "LYDateSelectorView.h"
#import "LYDatePickerView.h"

//时间回调
typedef void (^ TimeBucketBlock)(NSDate *, NSDate *);
typedef void (^ DateBlock)(NSDate *);

@interface LYDateSelectorView ()<LYDatePickerViewDelegate>

@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat whiteViewHeight;
@property (nonatomic) CGFloat pickerHeight;

//白色背景
@property (nonatomic, strong) UIView *whiteView;

@property (nonatomic, copy) TimeBucketBlock timeBucketBlock;
@property (nonatomic, copy) DateBlock dateBlock;

//开始时间
@property (nonatomic, strong) UIButton *bStart;
//结束时间
@property (nonatomic, strong) UIButton *bEnd;

//开始时间date
@property (nonatomic, strong) NSDate *startDate;
//结束时间date
@property (nonatomic, strong) NSDate *endDate;

//选择器
@property (nonatomic, strong) LYDatePickerView *selectorPicker;

//区分当前操作时间——开始时间或结束时间
@property (nonatomic) BOOL timeType;

//区分是否是时间段选择
@property (nonatomic) BOOL isBucket;

@end

@implementation LYDateSelectorView

+(LYDateSelectorView *)initClient{
    
    static LYDateSelectorView *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return client;
    
}

-(void)timeBucketWithPickerDate:(void (^)(NSDate * _Nonnull, NSDate * _Nonnull))completeBlock{
    
    _isBucket = YES;
    _whiteViewHeight = 400.f;
    _pickerHeight = 250.f;
    
    _timeBucketBlock = completeBlock;
    [self createUI];
    
}

-(void)dateWithPickerDate:(void (^)(NSDate * _Nonnull))completeBlock{
    
    _isBucket = NO;
    _whiteViewHeight = 300.f;
    _pickerHeight = 250.f;
    
    _dateBlock = completeBlock;
    [self createUI];
    
}

#pragma mark - 创建布局
-(void)createUI{
    
    _height = [UIScreen mainScreen].bounds.size.height;
    _width = [UIScreen mainScreen].bounds.size.width;
    
    //取消手势
    UITapGestureRecognizer *cancelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCancelAction)];
    [self addGestureRecognizer:cancelTap];
    
    //白色背景
    self.whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, _height, _width, _whiteViewHeight)];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.whiteView];
    
    //取消
    UIButton *bCancel = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 80, 40)];
    [bCancel setTitle:@"取消" forState:0];
    [bCancel setTitleColor:[UIColor blackColor] forState:0];
    bCancel.titleLabel.font = [UIFont systemFontOfSize:14];
    bCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [bCancel addTarget:self action:@selector(tapCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.whiteView addSubview:bCancel];
    
    //完成
    UIButton *bConfirm = [[UIButton alloc]initWithFrame:CGRectMake(_width - CGRectGetWidth(bCancel.frame) - bCancel.frame.origin.x, 0, CGRectGetWidth(bCancel.frame), CGRectGetHeight(bCancel.frame))];
    [bConfirm setTitle:@"完成" forState:0];
    [bConfirm setTitleColor:[UIColor blackColor] forState:0];
    bConfirm.titleLabel.font = [UIFont systemFontOfSize:14];
    bConfirm.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [bConfirm addTarget:self action:@selector(buttonConfirm) forControlEvents:UIControlEventTouchUpInside];
    [self.whiteView addSubview:bConfirm];
    
    if (_isBucket) {
        
        //默认时间
        self.endDate = [NSDate date];
        self.startDate = [NSDate date];
        
        CGFloat edge = 20.f;
        CGFloat labelWidth = (_width - edge * 5) / 2;
        
        //开始时间
        _bStart = [[UIButton alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(bConfirm.frame) + edge * 2, labelWidth, 40)];
        [_bStart setTitle:[self dateFormatWithDate:[NSDate date]] forState:0];
        [_bStart setTitleColor:[UIColor cyanColor] forState:0];
        _bStart.tag = 1000;
        [_bStart addTarget:self action:@selector(buttonTypeTimeSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self.whiteView addSubview:_bStart];
        UIImageView *ivLineStart = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_bStart.frame), CGRectGetMaxY(_bStart.frame), CGRectGetWidth(_bStart.frame), 1)];
        ivLineStart.backgroundColor = [UIColor lightGrayColor];
        [self.whiteView addSubview:ivLineStart];
        
        //至
        UILabel *lFromTo = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_bStart.frame) + edge, CGRectGetMinY(_bStart.frame), edge, CGRectGetHeight(_bStart.frame))];
        lFromTo.text = @"至";
        lFromTo.textColor = [UIColor blackColor];
        lFromTo.textAlignment = NSTextAlignmentCenter;
        lFromTo.font = [UIFont systemFontOfSize:16];
        [self.whiteView addSubview:lFromTo];
        
        //结束时间
        _bEnd = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lFromTo.frame) + edge, CGRectGetMinY(_bStart.frame), CGRectGetWidth(_bStart.frame), CGRectGetHeight(_bStart.frame))];
        [_bEnd setTitle:[self dateFormatWithDate:[NSDate date]] forState:0];
        [_bEnd setTitleColor:[UIColor lightGrayColor] forState:0];
        _bEnd.tag = 1001;
        [_bEnd addTarget:self action:@selector(buttonTypeTimeSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self.whiteView addSubview:_bEnd];
        UIImageView *ivLineEnd = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_bEnd.frame), CGRectGetMaxY(_bEnd.frame), CGRectGetWidth(ivLineStart.frame), CGRectGetHeight(ivLineStart.frame))];
        ivLineEnd.backgroundColor = [UIColor lightGrayColor];
        [self.whiteView addSubview:ivLineEnd];
        
    }
    
    //选择器
    self.selectorPicker = [[LYDatePickerView alloc]initWithDatePickerView];
    self.selectorPicker.frame = CGRectMake(0, _whiteViewHeight - _pickerHeight, _width, _pickerHeight);
    self.selectorPicker.pvDelegate = self;
    [self.whiteView addSubview:self.selectorPicker];
    [self show];
    
}

-(void)buttonTypeTimeSelect:(UIButton *)sender{
    
    if (sender.tag - 1000 == 0) {
        [_bStart setTitleColor:[UIColor cyanColor] forState:0];
        [_bEnd setTitleColor:[UIColor lightGrayColor] forState:0];
        self.timeType = NO;
    }else{
        [_bStart setTitleColor:[UIColor lightGrayColor] forState:0];
        [_bEnd setTitleColor:[UIColor cyanColor] forState:0];
        self.timeType = YES;
    }
    
}

-(void)dateWithSelect:(NSDate *)date{
    
    //时间转时间戳
    NSString *time = [self dateFormatWithDate:date];
    
    //选择结束时间
    if (self.timeType) {
        self.endDate = date;
        [_bEnd setTitle:time forState:0];
    }
    
    //选择开始时间
    else{
        self.startDate = date;
        [_bStart setTitle:time forState:0];
    }
    
}

-(void)buttonConfirm{
    
    if (_isBucket) {
        
        //开始时间的时间戳
        NSInteger sDate = [self timestampWithDate:self.startDate];
        //结束时间的时间戳
        NSInteger eDate = [self timestampWithDate:self.endDate];
        
        //开始时间的时间戳大于结束时间的时间戳是不对的，直接return，提示时间不对
        if (sDate > eDate) {
            NSLog(@"时间不对");
            return;
        }
        
        if (_timeBucketBlock) {
            _timeBucketBlock(self.startDate,self.endDate);
        }
        
    }else{
        if (_dateBlock) {
            _dateBlock(_selectorPicker.date);
        }
    }
    [self tapCancelAction];
    
}

//显示手势
-(void)show{
    
    __weak typeof(self) selfWeak = self;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
        selfWeak.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:0.25 animations:^{
        selfWeak.whiteView.frame = CGRectMake(0, selfWeak.height - selfWeak.whiteViewHeight, selfWeak.width, selfWeak.whiteViewHeight);
        selfWeak.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    }];
    
}

//取消手势
-(void)tapCancelAction{
    
    __weak typeof(self) selfWeak = self;
    [UIView animateWithDuration:0.2 animations:^{
        selfWeak.whiteView.frame = CGRectMake(0, selfWeak.height, selfWeak.width, selfWeak.whiteViewHeight);
        selfWeak.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [selfWeak removeFromSuperview];
    }];
    
}

//时间格式
-(NSString *)dateFormatWithDate:(NSDate *)date{
    
    NSString *formatStr = @"yyyy-MM-dd";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatStr];
    return [dateFormatter stringFromDate:date];
    
}

//时间转时间戳
-(NSInteger)timestampWithDate:(NSDate *)date{
    return [date timeIntervalSince1970] / 1000;
}

@end
