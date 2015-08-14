//
//  AdStore.h
//  AdStore
//
#import <Foundation/Foundation.h>
#define ADSTORE_API_URL						@"https://a1.adstore.jp/app/"
#define BROWSER_API_URL						@"https://a1.adstore.jp/app/"

@interface AdStore : NSObject
+(void)setConfig:(NSString *)deviceId hash:(BOOL)isHash all:(BOOL)isAll;
+(NSString*)getBrowserURLwithAccessCode:(NSString*)code andScheme:(NSString*)scheme;
+(NSString*)getId;
+(void)track:(NSString *)code schemeWithURL:(NSString *)scheme;
+(void)event:(NSString *)code actionCode:(NSString *)actionCode;
+(void)event:(NSString *)code actionCode:(NSString *)actionCode memberId:(NSString *)memberId;
+(void)addCourse:(NSString *)code courseCode:(NSString *)courseCode memberId:(NSString *)memberId;
+(void)changeCourse:(NSString *)code courseCode:(NSString *)courseCode memberId:(NSString *)memberId;
+(void)removeCourse:(NSString *)code courseCode:(NSString *)courseCode memberId:(NSString *)memberId;
+(void)addItemwithItemID:(NSString *)itemID ItemName:(NSString *)itemName ItemPrice:(double)itemPrice ItemCount:(int)itemCount;
+(void)order:(NSString *)code ordernumber:(NSString *)orderNumber memberId:(NSString*)memberId total:(int)total;
@end
