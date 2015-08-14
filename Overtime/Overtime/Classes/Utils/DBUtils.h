//
//  DBUtils.h
//  DBUtils
//
//  Created by Xu Shawn on 8/2/12.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface DBUtils : NSObject

@property (nonatomic, retain) NSString *dbRealPath;
@property (nonatomic, retain) FMDatabase *dbo;

+ (DBUtils *)sharedDBUtils;
+ (NSString *)dbFilePath:(NSString *)dbFileName;
- (void)openDB;
- (void)closeDB;
- (void)setupDB:(NSString *)dbFileName;
+ (BOOL)updateTable;
+ (void)handleOldUser;
- (void)resetupDB:(NSString *)dbFileName;

@end
