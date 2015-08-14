//
//  SNSTableViewCell.h
//  Overtime
//
//  Created by Ryuukou on 4/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNSFriend;
@protocol SNSTableViewCellDelegate;
@interface RLSNSTableViewCell : UITableViewCell

@property (nonatomic, strong) SNSFriend *friendInfo;
@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, weak) id<SNSTableViewCellDelegate> delegate;

@end

@protocol SNSTableViewCellDelegate <NSObject>

- (void)snsTableViewCellSupportHandle:(RLSNSTableViewCell *)cell;
- (void)snsTableViewCellReportHandle:(RLSNSTableViewCell *)cell;

@end
