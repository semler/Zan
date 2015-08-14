//
//  SliderView.h
//  iwam
//
//  Created by Xu Shawn on 3/8/13.
//
//

#import <UIKit/UIKit.h>

@class SliderView;

@protocol SliderDelegate <NSObject>

- (void)sliderView:(SliderView *)sliderView valueDidChanged:(CGFloat)value;
- (void)sliderView:(SliderView *)sliderView stoppedAtValue:(CGFloat)value;

@end

@interface SliderView : UIView

@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) id<SliderDelegate> delegate;

@end
