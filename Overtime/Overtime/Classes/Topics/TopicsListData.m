//
//  TopicsData.m
//  Overtime
//
//  Created by 于　超 on 2015/07/28.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "TopicsListData.h"

@implementation TopicsListData

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    _news_id = [dict valueForKeyPath:@"news_id"];
    _guid = [dict valueForKeyPath:@"guid"];
    _title = [dict valueForKeyPath:@"title"];
    _category = [dict valueForKeyPath:@"category"];
    _thumbnail = [dict valueForKeyPath:@"thumbnail"];
    _pub_date = [dict valueForKeyPath:@"pub_date"];
    return self;
}

@end
