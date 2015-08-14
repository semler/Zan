//
//  CustomPicker.h
//  Utils
//
//  Created by Xu Shawn on 10/23/12.
//  Copyright (c) 2012 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomPicker;

typedef enum {
    CustomPickerTypeDefault,
    CustomPickerTypeDate,
    CustomPickerTypeTime,
    CustomPickerTypeTime5,
    CustomPickerTypeArray
} CustomPickerType;

@protocol CustomPickerDelegate <NSObject>

- (void)customPicker:(CustomPicker *)picker didSelectDone:(id)value;

@end

@interface CustomPicker : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign) id<CustomPickerDelegate> delegate;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *selectedValues;
@property (nonatomic, retain) NSString *minimumDateString;
@property (nonatomic, retain) NSString *maximumDateString;
@property (nonatomic, assign) CustomPickerType pickerType;
@property (nonatomic, assign) BOOL showResetButton;

+ (CustomPicker *)sharedInstance;
- (void)showInView:(UIView *)view;
- (void)reloadData;
- (void)hide;
- (BOOL)resignFirstResponder;

@end
