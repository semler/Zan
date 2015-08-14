//
//  ArcView.h
//  Overtime
//
//  Created by Xu Shawn on 3/31/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "BaseView.h"

@interface ArcView : BaseView

@property (nonatomic, assign) NSInteger startAngle;
@property (nonatomic, assign) NSInteger endAngle;

- (void)reloadAtStartAngle:(NSInteger)startAngle endAngle:(NSInteger)endAngle;

@end
