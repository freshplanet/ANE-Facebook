//
//  FREConversionUtil.h
//  AirFacebook
//
//  Created by Ján Horváth on 30/06/15.
//
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"

@interface FREConversionUtil : NSObject

+ (FREObject)fromString:(NSString *)value;
+ (FREObject)fromNumber:(NSNumber *)value;
+ (FREObject)fromInt:(NSInteger)value;
+ (FREObject)fromUInt:(NSUInteger)value;
+ (FREObject)fromBoolean:(BOOL)value;

+ (NSString *)toString:(FREObject)object;
+ (NSNumber *)toNumber:(FREObject)object;
+ (NSInteger)toInt:(FREObject)object;
+ (NSUInteger)toUInt:(FREObject)object;
+ (BOOL)toBoolean:(FREObject)object;
+ (NSArray *)toStringArray:(FREObject)object;

+ (FREObject)getProperty:(NSString *)name fromObject:(FREObject)object;
+ (NSUInteger)getArrayLength:(FREObject *)array;
+ (FREObject *)getArrayItemAt:(NSUInteger)index on:(FREObject)array;

@end
