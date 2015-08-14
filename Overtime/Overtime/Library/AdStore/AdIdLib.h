//
//  AdIdLib.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <Security/Security.h>

#define urlEncode(c) [AdEncoder urlEncode:c]
#define toString(c) [AdEncoder toString:c]
#define DEVICE_ID_UUID          @"UUID"
#define DEVICE_ID_OPENUDID      @"OpenUDID"
#define DEVICE_ID_ADVERTISING   @"IdentifierForAdvertising"
#define DEVICE_ID_HASH_FLG      @"isDeviceIDHash"
#define DEVICE_ID_ALL_FLG       @"isDeviceIDAll"

@interface AdIdLib : NSObject
+(NSString *)getId:(NSString*)Idkey;
+(NSString *)getMacAddress;
@end
