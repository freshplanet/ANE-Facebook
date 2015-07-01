//
//  FREConversionUtil.m
//  AirFacebook
//
//  Created by Ján Horváth on 30/06/15.
//
//

#import "FREConversionUtil.h"

@implementation FREConversionUtil

+ (FREObject)fromString:(NSString *)value {
    FREObject object;
    
    FREResult result = FRENewObjectFromUTF8((uint32_t) [value length], (uint8_t *) [value UTF8String], &object);
    
    if (result != FRE_OK) {
    
        return nil;
    }
    
    return object;
}

+ (FREObject)fromNumber:(NSNumber *)value {
    FREObject object;
    
    FREResult result = FRENewObjectFromDouble([value doubleValue], &object);
    
    if (result != FRE_OK) {
        
        return nil;
    }
    
    return object;
}

+ (FREObject)fromInt:(NSInteger)value {
    FREObject object;
    
    FREResult result = FRENewObjectFromInt32((int32_t) value, &object);
    
    if (result != FRE_OK) {
        
        return nil;
    }
    
    return object;
}

+ (FREObject)fromUInt:(NSUInteger)value {
    FREObject object;
    
    FREResult result = FRENewObjectFromInt32((uint32_t) value, &object);
    
    if (result != FRE_OK) {
       
        return nil;
    }
    
    return object;
}

+ (FREObject)fromBoolean:(BOOL)value {
    FREObject object;
    
    FREResult result = FRENewObjectFromBool((uint32_t) value, &object);
    
    if (result != FRE_OK) {
    
        return nil;
    }
    
    return object;
}

+ (NSString *)toString:(FREObject)object {
    uint32_t length;
    const uint8_t *value;
    
    FREResult result = FREGetObjectAsUTF8(object, &length, &value);
    
    if (result != FRE_OK) {
        
        return nil;
    }
    
    return [NSString stringWithUTF8String:(char *) value];
}

+ (NSNumber *)toNumber:(FREObject)object {
    double value = 0;
    
    FREResult result = FREGetObjectAsDouble(object, &value);
    
    if (result != FRE_OK) {
        
        return [NSNumber numberWithDouble:value];
    }
    
    return [NSNumber numberWithDouble:value];
}

+ (NSInteger)toInt:(FREObject)object {
    int32_t value = 0;
    
    FREResult result = FREGetObjectAsInt32(object, &value);
    
    if (result != FRE_OK) {
        
        return value;
    }
    
    return value;
}

+ (NSUInteger)toUInt:(FREObject)object {
    uint32_t value = 0;
    
    FREResult result = FREGetObjectAsUint32(object, &value);
    
    if (result != FRE_OK) {
        
        return value;
    }
    
    return value;
}

+ (BOOL)toBoolean:(FREObject)object {
    uint32_t value = 0;
    
    FREResult result = FREGetObjectAsBool(object, &value);
    
    if (result != FRE_OK) {
        
        return (value) ? YES : NO;
    }
    
    return (value) ? YES : NO;
}

+ (NSArray *)toStringArray:(FREObject)object {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    @try {
        NSUInteger length = [FREConversionUtil getArrayLength:object];
        for(NSUInteger i = 0; i<length; i++){
            [array addObject:[FREConversionUtil toString:[FREConversionUtil getArrayItemAt:i on:object]]];
        }
    }
    @catch (NSException *exception) {
        
        return nil;
    }
    
    return [array copy];
}

+ (FREObject)getProperty:(NSString *)name fromObject:(FREObject)object {
    FREObject value;
    FREResult result = FREGetObjectProperty(object, (uint8_t *) [name UTF8String], &value, NULL);
    
    if (result != FRE_OK) {
        NSException *exception;
        
        switch (result) {
            case FRE_ACTIONSCRIPT_ERROR:
                exception = [NSException exceptionWithName:@"ActionscriptError" reason:@"An ActionScript error occurred. The runtime sets the thrownException parameter to represent the ActionScript Error class or subclass object." userInfo:NULL];
                break;
            case FRE_ILLEGAL_STATE:
                exception = [NSException exceptionWithName:@"IllegalState" reason:@"The extension context has acquired an ActionScript BitmapData or ByteArray object. The context cannot call this method until it releases the BitmapData or ByteArray object." userInfo:NULL];
                break;
            case FRE_INVALID_ARGUMENT:
                exception = [NSException exceptionWithName:@"InvalidArgument" reason:@"The propertyName or propertyValue parameter is NULL." userInfo:NULL];
                break;
            case FRE_INVALID_OBJECT:
                exception = [NSException exceptionWithName:@"InvalidObject" reason:@"The FREObject parameter is invalid." userInfo:NULL];
                break;
            case FRE_NO_SUCH_NAME:
                exception = [NSException exceptionWithName:@"NoSuchName" reason:@"The propertyName parameter does not match a property of the ActionScript class object that the object parameter represents. Another, less likely, reason for this return value exists. Specifically, consider the unusual case when an ActionScript class has two properties with the same name but the names are in different ActionScript namespaces." userInfo:NULL];
                break;
            case FRE_TYPE_MISMATCH:
                exception = [NSException exceptionWithName:@"TypeMismatch" reason:@"The FREObject parameter does not represent an ActionScript class object." userInfo:NULL];
                break;
            case FRE_WRONG_THREAD:
                exception = [NSException exceptionWithName:@"WrongThread" reason:@"The method was called from a thread other than the one on which the runtime has an outstanding call to a native extension function." userInfo:NULL];
                break;
            default:
                exception = NULL;
        }
        
        if (exception != NULL) @throw exception;
    }
    
    return value;
}

+ (NSUInteger)getArrayLength:(FREObject *)array {
    uint32_t length;
    FREResult result = FREGetArrayLength(array, &length);
    
    if (result != FRE_OK) {
        NSException *exception;
        
        switch (result) {
            case FRE_ILLEGAL_STATE:
                exception = [NSException exceptionWithName:@"IllegalState" reason:@"The extension context has acquired an ActionScript BitmapData or ByteArray object. The context cannot call this method until it releases the BitmapData or ByteArray object." userInfo:NULL];
                break;
            case FRE_INVALID_ARGUMENT:
                exception = [NSException exceptionWithName:@"InvalidArgument" reason:@"The propertyName or propertyValue parameter is NULL." userInfo:NULL];
                break;
            case FRE_INVALID_OBJECT:
                exception = [NSException exceptionWithName:@"InvalidObject" reason:@"The FREObject parameter is invalid." userInfo:NULL];
                break;
            case FRE_TYPE_MISMATCH:
                exception = [NSException exceptionWithName:@"TypeMismatch" reason:@"The FREObject parameter does not represent an ActionScript class object." userInfo:NULL];
                break;
            case FRE_WRONG_THREAD:
                exception = [NSException exceptionWithName:@"WrongThread" reason:@"The method was called from a thread other than the one on which the runtime has an outstanding call to a native extension function." userInfo:NULL];
                break;
            default:
                exception = NULL;
        }
        
        if (exception != NULL) @throw exception;
    }
    
    return [[NSNumber numberWithInteger:length] unsignedIntegerValue];
}

+ (FREObject *)getArrayItemAt:(NSUInteger)index on:(FREObject)array {
    FREObject value;
    FREResult result = FREGetArrayElementAt(array, (uint32_t) index, &value);
    
    if (result != FRE_OK) {
        NSException *exception;
        
        switch (result) {
            case FRE_ILLEGAL_STATE:
                exception = [NSException exceptionWithName:@"IllegalState" reason:@"The extension context has acquired an ActionScript BitmapData or ByteArray object. The context cannot call this method until it releases the BitmapData or ByteArray object." userInfo:NULL];
                break;
            case FRE_INVALID_ARGUMENT:
                exception = [NSException exceptionWithName:@"InvalidArgument" reason:@"The propertyName or propertyValue parameter is NULL." userInfo:NULL];
                break;
            case FRE_INVALID_OBJECT:
                exception = [NSException exceptionWithName:@"InvalidObject" reason:@"The FREObject parameter is invalid." userInfo:NULL];
                break;
            case FRE_TYPE_MISMATCH:
                exception = [NSException exceptionWithName:@"TypeMismatch" reason:@"The FREObject parameter does not represent an ActionScript class object." userInfo:NULL];
                break;
            case FRE_WRONG_THREAD:
                exception = [NSException exceptionWithName:@"WrongThread" reason:@"The method was called from a thread other than the one on which the runtime has an outstanding call to a native extension function." userInfo:NULL];
                break;
            default:
                exception = NULL;
        }
        
        if (exception != NULL) @throw exception;
    }
    
    return value;
}

@end
