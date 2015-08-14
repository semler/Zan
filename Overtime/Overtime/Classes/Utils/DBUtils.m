//
//  DBUtils.m
//  DBUtils
//
//  Created by Xu Shawn on 8/2/12.
//
//

#import "DBUtils.h"

@implementation DBUtils

@synthesize dbRealPath, dbo;

static DBUtils *instance;

+ (DBUtils *)sharedDBUtils
{
	if (!instance)
		instance = [[DBUtils alloc] init];
	
	return instance;
}

- (void)dealloc
{
    [dbo close];
}

- (void)openDB
{
	if (dbo == nil) {
		dbo = [[FMDatabase alloc] initWithPath: dbRealPath];
		
		if (![dbo open]) {
			NSLog(@"Failed to open database.");
		} else {
            //NSLog(@"Database opened successfully.");
        }
	} else {
		NSLog(@"Database has already opened.");
	}
}

- (void)closeDB
{
    if (![dbo close]) {
        NSLog(@"Failed to close database.");
    } else {
        //NSLog(@"Database closed successfully.");
    }
    dbo = nil;
}

+ (NSString *)dbFilePath:(NSString *)dbFileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	return [documentsPath stringByAppendingString: [NSString stringWithFormat: @"/%@", dbFileName]];
}

- (void)setupDB:(NSString *)dbFileName
{
	if (dbFileName == nil) {
		return;
	}
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *err;
	
	self.dbRealPath = [[self class] dbFilePath:dbFileName];
    
	if (![fileManager fileExistsAtPath:self.dbRealPath]) {
		NSString *dbSrcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: dbFileName];
		BOOL copySuccess = [fileManager copyItemAtPath: dbSrcPath toPath: self.dbRealPath error: &err];
        
		if (!copySuccess) {
			NSLog(@"Failed to copy database '%@'.", [err localizedDescription]);
		}
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TASK_APP_VERSION_DISABLE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
	//NSLog(@"dbRealPath:%@", self.dbRealPath);
}

- (void)resetupDB:(NSString *)dbFileName
{
    [self.dbo close];
    [self setDbo:nil];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dbRealPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.dbRealPath error:nil];
    }
    [self setupDB:dbFileName];
}

+ (void)handleOldUser
{
    NSString *oldUser = [Master valueForKey:MSTKeyOldUser];
    
    if (oldUser.length == 0) {
        NSString *currentVersion = [Master valueForKey:MSTKeyVersion];
        
        if (currentVersion.length == 0) {
            [Master saveValue:@"1" forKey:MSTKeyOldUser];
        } else {
            [Master saveValue:@"0" forKey:MSTKeyOldUser];
        }
    }
}

+ (BOOL)updateTable
{
    BOOL ret = YES;
    
    NSString *currentVersion = [Master valueForKey:MSTKeyVersion];
    // SQL directory
    NSString *sqlDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SQL"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:sqlDirectory];
    
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    // Begin transaction
    [dbo beginTransaction];
    
    NSString *maxFileName = nil;
    NSString *file = nil;
    while (file = [dirEnum nextObject]) {
        // File name
        NSString *fileName = [file stringByDeletingPathExtension];
        // SQL file
        if ([[file pathExtension] compare:@"sql" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            if (maxFileName.length == 0) {
                maxFileName = fileName;
            }
            if ([maxFileName compare:fileName options:NSCaseInsensitiveSearch] == NSOrderedAscending) {
                maxFileName = fileName;
            }
            // File path
            NSString *filePath = [sqlDirectory stringByAppendingPathComponent:file];
            // Executed or not
            if (currentVersion.length > 0 && [currentVersion compare:fileName options:NSCaseInsensitiveSearch] != NSOrderedAscending) {
                continue;
            }
            // Execute SQL
            ret = [self executeSQL:filePath database:dbo];
            NSLog(@"Execute SQL: %@ %@", (ret ? @"Success" : @"Failure"), file);
            
            // Failed
            if (!ret) {
                break;
            }
        }
    }
    
    // End transaction
    if (ret) {
        // Commit
        [dbo commit];
        // Update version
        [Master saveValue:maxFileName forKey:MSTKeyVersion];
    } else {
        // Rollback
        [dbo rollback];
    }
    
    return ret;
}

+ (BOOL)executeSQL:(NSString *)sqlFilePath database:(FMDatabase *)dbo
{
    BOOL ret = YES;
    
    // SQL
    NSString *fileContent = [NSString stringWithContentsOfFile:sqlFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
    for (NSString *sql in lines) {
        NSString *trimmedSql = [sql stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmedSql.length > 0) {
            // Excute sql
            ret = [dbo executeUpdate:trimmedSql];
            // Failed
            if (!ret) {
                break;
            }
        }
    }
    
    return ret;
}

@end
