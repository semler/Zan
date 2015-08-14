//
//  LogUtils.m
//  Overtime
//
//  Created by xuxiaoteng on 1/15/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "LogUtils.h"

@implementation LogUtils

+ (void)saveLog:(NSString *)logText
{
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //	NSString *documentsPath = [paths objectAtIndex:0];
    //    NSString *filePath = [documentsPath stringByAppendingString:@"/log.txt"];
    //    NSMutableString *log = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    //	if (![fileManager fileExistsAtPath:filePath]) {
    //        log = [NSMutableString string];
    //    }
    //    [log appendString:logText];
    //    [log writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (void)saveRunningLog:(NSString *)logText
{
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //	NSString *documentsPath = [paths objectAtIndex:0];
    //    NSString *filePath = [documentsPath stringByAppendingString:@"/running.txt"];
    //    NSMutableString *log = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    //	if (![fileManager fileExistsAtPath:filePath]) {
    //        log = [NSMutableString string];
    //    }
    //    [log appendString:logText];
    //    [log writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
