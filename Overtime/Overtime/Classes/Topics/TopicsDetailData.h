//
//  TopicsDetailData.h
//  Overtime
//
//  Created by 于　超 on 2015/07/29.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicsDetailData : NSObject

@property (nonatomic, strong) NSString *news_id;
@property (nonatomic, strong) NSString *guid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *des;
@property (nonatomic, strong) NSString *pub_date;

- (id)initWithDict:(NSDictionary *)dict;

@end
