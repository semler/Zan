//
//  iCloudUtils.m
//  Overtime
//
//  Created by xuxiaoteng on 1/15/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "iCloudUtils.h"
#import "AppDelegate.h"

@implementation iCloudUtils

+ (void)uploadFileToiCloud
{
    [NSThread detachNewThreadSelector:@selector(startUpload) toTarget:[self class] withObject:nil];
}

+ (void)downloadFileFromiCloud
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:hud];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        [self startDownload];
    } completionBlock:^{
        [MBProgressHUD showHUDAddedTo:window animated:YES];
    }];
}

+ (void)startUpload
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *iCloudBaseURL = [manager URLForUbiquityContainerIdentifier:nil];
    if (iCloudBaseURL) {
        //        NSURL *iCloudDocumentsURL = [iCloudBaseURL URLByAppendingPathComponent:@"Documents"];
        NSURL *iCloudFileURL = [iCloudBaseURL URLByAppendingPathComponent:DB_FILE_NAME];
        NSString *dbFilePath = [DBUtils dbFilePath:DB_FILE_NAME];
        //        NSURL *dbFileURL = [NSURL fileURLWithPath:dbFilePath];
        
        NSError *error;
        
        // File exist in iCloud
        if ([manager isUbiquitousItemAtURL:iCloudFileURL]) {
            // Exist
            NSData *dbFileData = [NSData dataWithContentsOfFile:dbFilePath];
            BOOL success = [dbFileData writeToURL:iCloudFileURL atomically:YES];
            
            if (!success) {
                DLog(@"Sqlite file upload failed: %@", error);
            }
            DLog(@"Sqlite file backup(overwrite) to iCloud success");
        } else {
            // Not exist
            NSString *tempDBFilePath = [DBUtils dbFilePath:@"data_temp.sqlite"];
            NSURL *tempDBFileURL = [NSURL fileURLWithPath:tempDBFilePath];
            // Exist
            if ([manager fileExistsAtPath:tempDBFilePath]) {
                [manager removeItemAtPath:tempDBFilePath error:&error];
            }
            // Copy
            [manager copyItemAtPath:dbFilePath toPath:tempDBFilePath error:&error];
            
            if (![manager setUbiquitous:YES itemAtURL:tempDBFileURL destinationURL:iCloudFileURL error:&error]) {
                DLog(@"Sqlite file upload failed: %@", error);
            }
            DLog(@"Sqlite file backup(init) to iCloud success");
        }
    }
}

+ (BOOL)needsDownloadiCloudFile
{
    BOOL result = NO;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dbFilePath = [DBUtils dbFilePath:DB_FILE_NAME];
    
    if (![manager fileExistsAtPath:dbFilePath]) {
        NSURL *iCloudBaseURL = [manager URLForUbiquityContainerIdentifier:nil];
        if (iCloudBaseURL) {
            //            NSURL *iCloudDocumentsURL = [iCloudBaseURL URLByAppendingPathComponent:@"Documents"];
            NSURL *iCloudFileURL = [iCloudBaseURL URLByAppendingPathComponent:DB_FILE_NAME];
            
            NSError *error = nil;
            NSNumber *available = nil;
            if ([iCloudFileURL getResourceValue:&available forKey:NSURLIsUbiquitousItemKey error:&error]) {
                
                if (!error && [available boolValue]) {
                    result = YES;
                } else {
                    DLog(@"Not exist or error: %@", error);
                }
                //                NSString *downloaded = nil;
                //                if ([iCloudFileURL getResourceValue:&downloaded forKey:NSURLUbiquitousItemDownloadingStatusKey error:&error]) {
                //                    NSLog(@"NSURLUbiquitousItemDownloadingStatusKey: %@", downloaded);
                //                    if (!error && [downloaded isEqualToString:NSURLUbiquitousItemDownloadingStatusCurrent]) {
                //                        result = YES;
                //                    } else {
                //                        DLog(@"Not exist or error: %@", error);
                //                    }
                //                }
            }
        }
    }
    
    return result;
}

+ (void)startDownload
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *iCloudBaseURL = [manager URLForUbiquityContainerIdentifier:nil];
    if (iCloudBaseURL == nil) {
        DLog(@"iCloud is not active");
    } else {
        DLog(@"iCloud is actived");
    }
    
    //    NSURL *iCloudDocumentsURL = [iCloudBaseURL URLByAppendingPathComponent:@"Documents"];
    NSURL *iCloudFileURL = [iCloudBaseURL URLByAppendingPathComponent:DB_FILE_NAME];
    NSString *dbFilePath = [DBUtils dbFilePath:DB_FILE_NAME];
    NSURL *dbFileURL = [NSURL fileURLWithPath:dbFilePath];
    
    NSError *error = nil;
    NSNumber *exist = nil;
    if ([iCloudFileURL getResourceValue:&exist forKey:NSURLIsUbiquitousItemKey error:&error]) {
        if ([exist boolValue]) {
            
            // Exchange URL
            DLog(@"Exchange URL");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *error = nil;
                NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
                [coordinator coordinateReadingItemAtURL:iCloudFileURL options:0 error:&error byAccessor:^(NSURL *newURL) {
                    //                data = [NSData dataWithContentsOfURL:newURL];
                    //                [data writeToFile:dbFilePath atomically:YES];
                    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
                    [MBProgressHUD hideAllHUDsForView:window animated:YES];
                    
                    DLog(@"Exchange URL successful");
                    NSError *fileError = nil;
                    if ([manager copyItemAtURL:iCloudFileURL toURL:dbFileURL error:&fileError]) {
                        
                        if (error) {
                            DLog(@"Sqlite file restore to local failed: %@", error);
                        } else {
                            DLog(@"Sqlite file restore to local success");
                            
                            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                            [appDelegate performSelectorOnMainThread:@selector(startApplication:) withObject:@(YES) waitUntilDone:NO];
                        }
                    } else {
                        DLog(@"Sqlite file download failed: %@", error);
                    }
                }];
            });
            
            //            if (![manager startDownloadingUbiquitousItemAtURL:iCloudFileURL error:&error]) {
            //                if (error) {
            //                    DLog(@"Sqlite file restore to local failed: %@", error);
            //                } else {
            //                    DLog(@"Sqlite file restore to local success");
            //                }
            //            } else {
            //                DLog(@"Sqlite file download failed: %@", error);
            //            }
            
            //            NSString *downloaded = nil;
            //            if ([iCloudFileURL getResourceValue:&downloaded forKey:NSURLUbiquitousItemDownloadingStatusKey error:&error]) {
            //                if ([downloaded isEqualToString:NSURLUbiquitousItemDownloadingStatusNotDownloaded]) {
            //
            //                    NSNumber *downloading = nil;
            //                    if ([iCloudFileURL getResourceValue:&downloading forKey:NSURLUbiquitousItemIsDownloadingKey error:&error]) {
            //                        if (![downloading boolValue]) {
            ////                            if (![manager setUbiquitous:YES itemAtURL:iCloudFileURL destinationURL:dbFileURL error:&error]) {
            ////                                DLog(@"Sqlite file download failed: %@", error);
            ////                            }
            ////                            DLog(@"Sqlite file restore to local success");
            //
            ////                            if (![manager startDownloadingUbiquitousItemAtURL:iCloudFileURL error:&error]) {
            ////                                if (error) {
            ////                                    DLog(@"Sqlite file restore to local failed: %@", error);
            ////                                } else {
            ////                                    DLog(@"Sqlite file restore to local success");
            ////                                }
            ////                            } else {
            ////                                DLog(@"Sqlite file download failed: %@", error);
            ////                            }
            //                        } else {
            //                            DLog(@"Downloading...");
            //                        }
            //                    }
            //                    
            //                } else {
            //                    DLog(@"Downloaded...");
            //                }
            //            }
        } else {
            DLog(@"Not exist...");
        }
    }
    
}

@end
