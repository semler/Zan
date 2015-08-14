//
//  RLTutorialView.h
//  Overtime
//
//  Created by Ryuukou on 21/1/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RLTutorialDelegate;
@class SNSSelf;
@interface RLTutorialView : UIView

@property (nonatomic, weak) id<RLTutorialDelegate> delegate;
@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, assign, readwrite) BOOL tutorial;

- (instancetype)initWithFrame:(CGRect)frame index:(NSUInteger)index tutorial:(BOOL)tutorial;

@end

@protocol RLTutorialDelegate <NSObject>

- (void)tutorialViewButtonTaped:(RLTutorialView *)view withObject:(NSDictionary *)params;
- (void)tutorialView:(RLTutorialView *)view inputChangedWithResult:(BOOL)result;

@end
