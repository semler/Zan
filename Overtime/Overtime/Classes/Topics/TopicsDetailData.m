//
//  TopicsDetailData.m
//  Overtime
//
//  Created by 于　超 on 2015/07/29.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "TopicsDetailData.h"

@implementation TopicsDetailData

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    _news_id = [dict valueForKeyPath:@"news_id"];
    _guid = [dict valueForKeyPath:@"guid"];
    _title = [dict valueForKeyPath:@"title"];
    _category = [dict valueForKeyPath:@"category"];
    _link = [dict valueForKeyPath:@"link"];
    _image = [dict valueForKeyPath:@"image"];
    _content = [dict valueForKeyPath:@"content"];
    _des = [dict valueForKeyPath:@"description"];
    _pub_date = [dict valueForKeyPath:@"pub_date"];
    return self;
}

@end

