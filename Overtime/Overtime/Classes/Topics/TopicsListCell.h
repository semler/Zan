//
//  TopicsCell.h
//  Overtime
//
//  Created by 于　超 on 2015/07/28.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopicsListData.h"

@interface TopicsListCell : UITableViewCell

@property (strong, nonatomic) TopicsListData *data;
@property (nonatomic) int index;
@property (nonatomic) int totalCount;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void) initFrame;

@end
