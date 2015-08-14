//
//  LegalCell.h
//  Overtime
//
//  Created by xuxiaoteng on 2/1/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LegalCellIdentifier @"LegalCell"

@interface LegalCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) IBOutlet UIImageView *lineImageView;

@end
