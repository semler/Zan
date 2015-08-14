//
//  CustomPicker.m
//  Utils
//
//  Created by Xu Shawn on 10/23/12.
//  Copyright (c) 2012 Bravesoft. All rights reserved.
//

#import "CustomPicker.h"

@interface CustomPicker ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation CustomPicker

#pragma mark - Class method

+ (CustomPicker *)sharedInstance
{
    static CustomPicker *instance = nil;
    
    if (instance == nil) {
        instance = [[CustomPicker alloc] init];
    }
    return instance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bottom, self.width, 260.0)];
        [_containerView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.9]];
        [self addSubview:_containerView];
        [self addToolbar];
    }
    return self;
}

- (UIPickerView *)pickerView
{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.top = 44.0;
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.showsSelectionIndicator = YES;
        [_containerView addSubview:_pickerView];
    }
    return _pickerView;
}

- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.top = 44.0;
//        _datePicker.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Tokyo"];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_containerView addSubview:_datePicker];
    }
    return _datePicker;
}

- (void)setPickerType:(CustomPickerType)pickerType
{
    _pickerType = pickerType;
    
    switch (_pickerType) {
        case CustomPickerTypeDefault:
        case CustomPickerTypeArray: {
            [self.containerView bringSubviewToFront:self.pickerView];
            [self.datePicker setHidden:YES];
            [self.pickerView setHidden:NO];
            break;
        }
        case CustomPickerTypeDate: {
            [self.datePicker setDatePickerMode:UIDatePickerModeDate];
            [self.containerView bringSubviewToFront:self.datePicker];
            [self.pickerView setHidden:YES];
            [self.datePicker setHidden:NO];
            break;
        }
        case CustomPickerTypeTime: {
            [self.datePicker setDatePickerMode:UIDatePickerModeTime];
            [self.containerView bringSubviewToFront:self.datePicker];
            [self.pickerView setHidden:YES];
            [self.datePicker setHidden:NO];
            break;
        }
        case CustomPickerTypeTime5: {
            [self.datePicker setDatePickerMode:UIDatePickerModeTime];
            [self.datePicker setMinuteInterval:5];
            [self.containerView bringSubviewToFront:self.datePicker];
            [self.pickerView setHidden:YES];
            [self.datePicker setHidden:NO];
            break;
        }
        default:
            break;
    }
}

- (void)addToolbar
{
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.width, 44.0)];
//    [toolbar setTranslucent:NO];
//    [toolbar setBarStyle:UIBarStyleBlack];
    [_containerView addSubview:self.toolbar];
}

- (NSArray *)barButtonItems
{
    NSMutableArray *buttonArray = [NSMutableArray array];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil
                                      action:nil];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"キャンセル"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(cancel)];
    [cancelItem setTintColor:[UIColor blackColor]];
    // Add button
    [buttonArray addObject:cancelItem];
    
    if (self.showResetButton) {
        UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithTitle:@"リセット"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(reset)];
        [resetItem setTintColor:[UIColor blackColor]];
        // Add button
        [buttonArray addObject:resetItem];
        [buttonArray addObject:flexibleSpace];
    } else {
        [buttonArray addObject:flexibleSpace];
    }
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                 initWithTitle:@"完了"
                                 style:UIBarButtonItemStyleDone
                                 target:self
                                 action:@selector(done)];
    [doneItem setTintColor:[UIColor blackColor]];
    // Add button
    [buttonArray addObject:doneItem];
    
    return buttonArray;
}

- (void)selectPickerValues
{
    if ([self.selectedValues count] > 0) {
        switch (self.pickerType) {
            case CustomPickerTypeDefault:
            case CustomPickerTypeArray: {
                if ([self hasMultiComponent]) {
                    for (int i = 0; i < [_selectedValues count]; i++) {
                        NSString *value = [self.selectedValues objectAtIndex:i];
                        NSInteger row = [[self.dataSource objectAtIndex:i] indexOfObject:value];
                        if (row != NSNotFound) {
                            [self.pickerView selectRow:row inComponent:i animated:YES];
                        } else {
                            [self.pickerView selectRow:0 inComponent:i animated:YES];
                        }
                    }
                } else {
                    NSString *value = [self.selectedValues objectAtIndex:0];
                    NSInteger row = [self.dataSource indexOfObject:value];
                    if (row != NSNotFound) {
                        [self.pickerView selectRow:row inComponent:0 animated:YES];
                    } else {
                        [self.pickerView selectRow:0 inComponent:0 animated:YES];
                    }
                }
                break;
            }
            case CustomPickerTypeDate: {
                NSDate *date = [[self.selectedValues objectAtIndex:0] localDateWithFormat:@"yyyy-MM-dd"];
                [self.datePicker setDate:date animated:YES];
                break;
            }
            case CustomPickerTypeTime:
            case CustomPickerTypeTime5: {
                NSDate *date = [[self.selectedValues objectAtIndex:0] localDateWithFormat:@"HH:mm"];
                [self.datePicker setDate:date animated:YES];
                break;
            }
            default:
                break;
        }
    } else {
        if (self.pickerType == CustomPickerTypeDate ||
            self.pickerType == CustomPickerTypeTime ||
            self.pickerType == CustomPickerTypeTime5) {
            [self.datePicker setDate:[NSDate date] animated:YES];
        } else {
            for (int i = 0; i < [self.pickerView numberOfComponents]; i++) {
                [self.pickerView selectRow:0 inComponent:i animated:YES];
            }
        }
    }
}

#pragma mark - Action

- (BOOL)hasMultiComponent
{
    if ([self.dataSource count] > 0) {
        id obj = [self.dataSource objectAtIndex:0];
        if ([obj isKindOfClass:[NSArray class]]) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

- (BOOL)resignFirstResponder
{
    [self hide];
    return YES;
}

- (void)cancel
{
    [self hide];
}

- (void)reset
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customPicker:didSelectDone:)]) {
        [self.delegate customPicker:self didSelectDone:@""];
    }
    [self hide];
}

- (void)done
{
    id value;
    
    switch (self.pickerType) {
        case CustomPickerTypeDefault: {
            value = [NSMutableString string];
            
            if ([self hasMultiComponent]) {
                for (int i = 0; i < [self.dataSource count]; i++) {
                    NSArray *item = [self.dataSource objectAtIndex:i];
                    [value appendString:[item objectAtIndex:[self.pickerView selectedRowInComponent:i]]];
                }
            } else {
                [value appendString:[self.dataSource objectAtIndex:[self.pickerView selectedRowInComponent:0]]];
            }
            break;
        }
        case CustomPickerTypeDate: {
            value = [NSMutableString string];
            
            NSDate *date = [self.datePicker date];
            [value appendString:[self dateToString:date withFormat:@"yyyy-MM-dd"]];
            break;
        }
        case CustomPickerTypeTime: {
            value = [NSMutableString string];
            
            NSDate *date = [self.datePicker date];
            [value appendString:[self dateToString:date withFormat:@"HH:mm"]];
            break;
        }
        case CustomPickerTypeTime5: {
            value = [NSMutableString string];
            
            NSDate *date = [self getCeiledDate:[self.datePicker date]];
            [value appendString:[self dateToString:date withFormat:@"HH:mm"]];
            break;
        }
        case CustomPickerTypeArray: {
            value = [NSMutableArray array];
            
            if ([self hasMultiComponent]) {
                for (int i = 0; i < [self.dataSource count]; i++) {
                    NSArray *item = [self.dataSource objectAtIndex:i];
                    [value addObject:[item objectAtIndex:[self.pickerView selectedRowInComponent:i]]];
                }
            }
            break;
        }
        default:
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customPicker:didSelectDone:)]) {
        [self.delegate customPicker:self didSelectDone:value];
    }
    [self hide];
}

- (NSString *)dateToString:(NSDate *)date withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    return [formatter stringFromDate:date];
}

- (NSDate *)getRoundedDate:(NSDate *)inDate
{
    NSInteger minuteInterval = 5;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:inDate];
    NSInteger minutes = [dateComponents minute];
    
    float minutesF = [[NSNumber numberWithInteger:minutes] floatValue];
    float minuteIntervalF = [[NSNumber numberWithInteger:minuteInterval] floatValue];
    
    // Determine whether to add 0 or the minuteInterval to time found by rounding down
    NSInteger roundingAmount = (fmodf(minutesF, minuteIntervalF)) > minuteIntervalF/2.0 ? minuteInterval : 0;
    NSInteger minutesRounded = ( (NSInteger)(minutes / minuteInterval) ) * minuteInterval;
    NSDate *roundedDate = [[NSDate alloc] initWithTimeInterval:60.0 * (minutesRounded + roundingAmount - minutes) sinceDate:inDate];
    
    return roundedDate;
}

- (NSDate *)getCeiledDate:(NSDate *)inDate
{
    NSInteger minuteInterval = 5;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:inDate];
    NSInteger minutes = [dateComponents minute];
    
    float minutesF = [[NSNumber numberWithInteger:minutes] floatValue];
    float minuteIntervalF = [[NSNumber numberWithInteger:minuteInterval] floatValue];
    
    NSInteger ceilingAmount = fmodf(minutesF, minuteIntervalF);
    NSInteger minutesCeiled = minutes - ceilingAmount;
    NSDate *roundedDate = [[NSDate alloc] initWithTimeInterval:60.0 * (minutesCeiled - minutes) sinceDate:inDate];
    
    return roundedDate;
}

- (void)showInView:(UIView *)view;
{
    [view addSubview:self];
    [self reloadData];
    [self selectPickerValues];

    [self.toolbar setItems:[self barButtonItems]];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.containerView.bottom = self.height;
    }];
}

- (void)hide
{
    [self setShowResetButton:NO];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.containerView.top = self.bottom;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)reloadData
{
    switch (self.pickerType) {
        case CustomPickerTypeDefault:
        case CustomPickerTypeArray: {
            [self.pickerView reloadAllComponents];
            break;
        }
        case CustomPickerTypeDate: {
            break;
        }
        case CustomPickerTypeTime:
        case CustomPickerTypeTime5: {
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIPickerDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([self hasMultiComponent]) {
        return [self.dataSource count];
    } else {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([self hasMultiComponent]) {
        return [[self.dataSource objectAtIndex:component] count];
    } else {
        return [self.dataSource count];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *value = @"";
    
    if ([self hasMultiComponent]) {
        value = [[self.dataSource objectAtIndex:component] objectAtIndex:row];
    } else {
        value = [self.dataSource objectAtIndex:row];
    }

    if (view) {
        UILabel *label = (UILabel *)view;
        label.text = value;
        return label;
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   [pickerView rowSizeForComponent:component].width,
                                                                   [pickerView rowSizeForComponent:component].height)];
        label.text = value;
        label.font = [UIFont boldSystemFontOfSize:18.0];
        label.adjustsFontSizeToFitWidth = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        return label;
    }
}

#pragma mark - UIPickerDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

@end
