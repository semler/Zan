//
//  SliderView.m
//  iwam
//
//  Created by Xu Shawn on 3/8/13.
//
//

#import "SliderView.h"

#define SliderTag 1

@interface SliderView () {
    UIImageView *sliderImageView;
}

@property (nonatomic, assign) BOOL moving;
@property (nonatomic, assign) BOOL moved;
@property (nonatomic, assign) CGFloat startY;
@property (nonatomic, assign) CGFloat lastValue;
@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat maxY;

@end

@implementation SliderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.minY = 0;
        self.maxY = 150.0;
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *bgImage = [UIImage imageNamed:@"slider_bg"];
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [bgImageView setImage:bgImage];
        [self addSubview:bgImageView];
        
        UIImage *sliderImage = [UIImage imageNamed:@"slider_button"];
        sliderImageView = [[UIImageView alloc] initWithFrame:CGRectMake((bgImageView.width - self.width) / 2, (self.maxY - self.minY) /  2, self.width, sliderImage.size.height)];
        [sliderImageView setContentMode:UIViewContentModeCenter];
        [sliderImageView setImage:sliderImage];
        [sliderImageView setTag:SliderTag];
        [sliderImageView setUserInteractionEnabled:YES];
        [self addSubview:sliderImageView];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    if ([touch view].tag == SliderTag) {
        CGFloat currentY = [touch locationInView:self].y;
        
        
        if (sliderImageView.top >= self.minY && sliderImageView.top <= self.maxY) {
            self.startY = currentY;
            self.moving = YES;
            self.moved = NO;
        }
    } else {
        self.moving = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.moving) {
        self.moved = YES;
        
        UITouch *touch = [touches anyObject];
        
        CGFloat currentY = [touch locationInView:self].y;
        CGFloat offsetY = currentY - self.startY;
        CGFloat sliderY = sliderImageView.top + offsetY;
        
        if (sliderY >= self.minY && sliderY <= self.maxY) {
            sliderY = currentY;
        }
        if (sliderY < self.minY) {
            sliderY = self.minY;
        } else if (sliderY > self.maxY) {
            sliderY = self.maxY;
        }
//        NSLog(@"%f %f %f %f %f", sliderImageView.top, currentY, offsetY, sliderY, self.startY);
        [sliderImageView setTop:sliderY];
        self.startY = currentY;

        self.value = (sliderY - self.minY) * (self.maxValue - self.minValue) / (self.maxY - self.minY) + self.minValue;
        if (self.lastValue != self.value) {
            self.lastValue = self.value;
            if ([self.delegate respondsToSelector:@selector(sliderView:valueDidChanged:)]) {
                [self.delegate sliderView:self valueDidChanged:self.value];
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.moving = NO;
    
    if (self.moved) {
        self.moved = NO;
        
        if ([self.delegate respondsToSelector:@selector(sliderView:stoppedAtValue:)]) {
            [self.delegate sliderView:self stoppedAtValue:self.value];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.moving = NO;
    
    if (self.moved) {
        self.moved = NO;
        
        if ([self.delegate respondsToSelector:@selector(sliderView:stoppedAtValue:)]) {
            [self.delegate sliderView:self stoppedAtValue:self.value];
        }
    }
}

- (void)setValue:(CGFloat)value
{
    _value = value;
    CGFloat sliderY = (value - self.minValue) * (self.maxY - self.minY) / (self.maxValue - self.minValue) + self.minY;
    [sliderImageView setTop:sliderY];
}

@end
