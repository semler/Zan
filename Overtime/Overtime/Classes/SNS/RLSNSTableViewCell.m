//
//  SNSTableViewCell.m
//  Overtime
//
//  Created by Ryuukou on 4/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "RLSNSTableViewCell.h"
#import "SNSFriend.h"

@interface RLSNSTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *murmurLabel;
@property (nonatomic, weak) IBOutlet UILabel *careerLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIButton *supportButton;
@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@property (nonatomic, weak) IBOutlet UIButton *reportButton;

@end

@implementation RLSNSTableViewCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundView = nil;
    self.backgroundColor = [UIColor clearColor];
//    self.backgroundColor = [ui]
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFriendInfo:(SNSFriend *)friendInfo
{
    _friendInfo = friendInfo;
    //avatar by level
    NSString *name = [AppManager avatarNameBySex:friendInfo.sex levelType:friendInfo.level];
    self.avatarView.image = [UIImage imageNamed:name];
    self.murmurLabel.text = friendInfo.message;
    if (friendInfo.companyName.length > 0 && friendInfo.careerName.length > 0) {
        self.careerLabel.text = [NSString stringWithFormat:@"%@会社の\n%@", friendInfo.companyName, friendInfo.careerName];
    } else {
        self.careerLabel.text = @"会社";
    }
    NSDictionary *dic = [MTLJSONAdapter JSONDictionaryFromModel:friendInfo error:nil];
    self.timeLabel.text = dic[@"message_last_updated"];
    self.countLabel.text = friendInfo.supportCount;
    self.supportButton.enabled = !friendInfo.isSupported;
}

#pragma mark - Func

- (IBAction)report:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(snsTableViewCellReportHandle:)]) {
        [self.delegate snsTableViewCellReportHandle:self];
    }
}

- (IBAction)support:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(snsTableViewCellSupportHandle:)]) {
        [self.delegate snsTableViewCellSupportHandle:self];
    }
}

@end
