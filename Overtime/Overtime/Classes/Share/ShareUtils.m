//
//  ShareUtils.m
//  Overtime
//
//  Created by xuxiaoteng on 2/18/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "ShareUtils.h"

#define ALERT_TAG_FB 1
#define ALERT_TAG_TW 2

@implementation ShareUtils

+ (BOOL)isLineInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]];
}

+ (void)shareTextToLine:(NSString *)text
{
    if ([self isLineInstalled]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"line://msg/text/%@", [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"LINEアプリがインストールされていません。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"戻る", nil];
        [alertView show];
    }
}

+ (void)shareTextToFacebook:(NSString *)text
{
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [composeViewController setInitialText:text];
    UINavigationController *navigationController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
    [navigationController presentViewController:composeViewController animated:YES completion:nil];
}

+ (void)shareTextToTwitter:(NSString *)text
{
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeViewController setInitialText:text];
    UINavigationController *navigationController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
    [navigationController presentViewController:composeViewController animated:YES completion:nil];
}

@end
