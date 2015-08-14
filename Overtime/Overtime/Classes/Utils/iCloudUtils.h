//
//  iCloudUtils.h
//  Overtime
//
//  Created by xuxiaoteng on 1/15/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iCloudUtils : NSObject

+ (void)uploadFileToiCloud;
+ (void)downloadFileFromiCloud;
+ (BOOL)needsDownloadiCloudFile;

@end
