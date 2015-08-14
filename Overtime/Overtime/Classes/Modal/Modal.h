//
//  Modal.h
//  Overtime
//
//  Created by Xu Shawn on 3/11/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBUtils.h"

@interface Modal : NSObject

@property (nonatomic, strong) FMDatabase *dbo;
@property (nonatomic, assign) sqlite_int64 pid;
@property (nonatomic, copy) NSString *send_flag;
@property (nonatomic, copy) NSString *create_date;
@property (nonatomic, copy) NSString *update_date;
@property (nonatomic, copy) NSString *delete_flag;

- (BOOL)save;

@end
