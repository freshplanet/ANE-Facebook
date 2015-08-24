//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//////////////////////////////////////////////////////////////////////////////////////

#import "FPANEUtils.h"

const int PARAM_TYPE_STRING = 0;
const int PARAM_TYPE_INT = 1;
const int PARAM_TYPE_BOOL = 2;

#pragma mark - Dispatch events

void FPANE_DispatchEvent(FREContext context, NSString *eventName)
{
    FREDispatchStatusEventAsync(context, (const uint8_t *)[eventName UTF8String], (const uint8_t *)"");
}

void FPANE_DispatchEventWithInfo(FREContext context, NSString *eventName, NSString *eventInfo)
{
    FREDispatchStatusEventAsync(context, (const uint8_t *)[eventName UTF8String], (const uint8_t *)[eventInfo UTF8String]);
}

void FPANE_Log(FREContext context, NSString *message)
{
    FPANE_DispatchEventWithInfo(context, @"LOGGING", message);
}


#pragma mark - FREObject -> Obj-C

NSInteger FPANE_FREObjectToNSInteger(FREObject object)
{
    int32_t value;
    FREGetObjectAsInt32(object, &value);
    return [[NSNumber numberWithInt:value] integerValue];
}

NSUInteger FPANE_FREObjectToNSUInteger(FREObject object)
{
    uint32_t value;
    FREGetObjectAsUint32(object, &value);
    return [[NSNumber numberWithInt:value] unsignedIntegerValue];
}

NSString * FPANE_FREObjectToNSString(FREObject object)
{
    uint32_t stringLength;
    const uint8_t *string;
    FREGetObjectAsUTF8(object, &stringLength, &string);
    return [NSString stringWithUTF8String:(char*)string];
}

BOOL * FPANE_FREObjectToBOOL(FREObject object)
{
    uint32_t boolValue;
    FREGetObjectAsBool(object, &boolValue);
    return boolValue != 0;
}

NSArray * FPANE_FREObjectToNSArrayOfNSString(FREObject object)
{
    uint32_t arrayLength;
    FREGetArrayLength(object, &arrayLength);
    
    uint32_t stringLength;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:arrayLength];
    for (uint32_t i = 0; i < arrayLength; i++)
    {
        FREObject itemRaw;
        FREGetArrayElementAt(object, i, &itemRaw);
        
        // Convert item to string. Skip with warning if not possible.
        const uint8_t *itemString;
        if (FREGetObjectAsUTF8(itemRaw, &stringLength, &itemString) != FRE_OK)
        {
            NSLog(@"Couldn't convert FREObject to NSString at index %u", i);
            continue;
        }
        
        NSString *item = [NSString stringWithUTF8String:(char*)itemString];
        [mutableArray addObject:item];
    }
    
    return [NSArray arrayWithArray:mutableArray];
}

NSDictionary * FPANE_FREObjectsToNSDictionaryOfNSString(FREObject keys, FREObject values)
{
    uint32_t numKeys, numValues;
    FREGetArrayLength(keys, &numKeys);
    FREGetArrayLength(values, &numValues);
    
    uint32_t stringLength;
    uint32_t numItems = MIN(numKeys, numValues);
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:numItems];
    for (uint32_t i = 0; i < numItems; i++)
    {
        FREObject keyRaw, valueRaw;
        FREGetArrayElementAt(keys, i, &keyRaw);
        FREGetArrayElementAt(values, i, &valueRaw);
        
        // Convert key and value to strings. Skip with warning if not possible.
        const uint8_t *keyString, *valueString;
        if (FREGetObjectAsUTF8(keyRaw, &stringLength, &keyString) != FRE_OK || FREGetObjectAsUTF8(valueRaw, &stringLength, &valueString) != FRE_OK)
        {
            NSLog(@"Couldn't convert FREObject to NSString at index %u", i);
            continue;
        }
        
        NSString *key = [NSString stringWithUTF8String:(char*)keyString];
        NSString *value = [NSString stringWithUTF8String:(char*)valueString];
        [mutableDictionary setObject:value forKey:key];
    }
    
    return [NSDictionary dictionaryWithDictionary:mutableDictionary];
}

NSDictionary * FPANE_FREObjectsToNSDictionary(FREObject keys, FREObject types, FREObject values)
{
    uint32_t numKeys, numTypes, numValues;
    FREGetArrayLength(keys, &numKeys);
    FREGetArrayLength(types, &numTypes);
    FREGetArrayLength(values, &numValues);
    
    if(numKeys != numTypes || numKeys != numValues || numKeys == 0){
        return nil;
    }
    
    uint32_t stringLength;
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:numKeys];
    for (uint32_t i = 0; i < numKeys; i++)
    {
        FREObject keyRaw, typeRaw, valueRaw;
        FREGetArrayElementAt(keys, i, &keyRaw);
        FREGetArrayElementAt(types, i, &typeRaw);
        FREGetArrayElementAt(values, i, &valueRaw);
        
        // Convert key and value to strings. Skip with warning if not possible.
        const uint8_t *keyString;
        uint32_t type;
    
        if (FREGetObjectAsUTF8(keyRaw, &stringLength, &keyString) != FRE_OK || FREGetObjectAsUint32(typeRaw, &type) != FRE_OK)
        {
            NSLog(@"Couldn't convert FREObject to NSString at index %u", i);
            continue;
        }
        
        NSString *key = [NSString stringWithUTF8String:(char*)keyString];
        
        switch (type) {
            case PARAM_TYPE_STRING:
            {
                NSString *value = FPANE_FREObjectToNSString(valueRaw);
                [mutableDictionary setObject:value forKey:key];
                break;
            }
            case PARAM_TYPE_INT:
            {
                NSInteger value = FPANE_FREObjectToNSInteger(valueRaw);
                [mutableDictionary setObject:@(value) forKey:key]; // same as [NSNumber numberWithLong:value]
                break;
            }
            case PARAM_TYPE_BOOL:
            {
                BOOL value = FPANE_FREObjectToBOOL(valueRaw);
                [mutableDictionary setObject:@(value) forKey:key]; // same as [NSNumber numberWithBool:value]
                break;
            }
            default:
                continue;
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:mutableDictionary];
}


#pragma mark - Obj-C -> FREObject

FREObject FPANE_BOOLToFREObject(BOOL boolean)
{
    FREObject result;
    FRENewObjectFromBool(boolean, &result);
    return result;
}

FREObject FPANE_NSStringToFREObject(NSString *string)
{
    FREObject result;
    FRENewObjectFromUTF8((uint32_t)string.length, (const uint8_t *)[string UTF8String], &result);
    return result;
}

FREObject FPANE_NSArrayToFREObject(NSArray *value)
{
    FREObject result;
    uint32_t arrayLength = (uint32_t)value.count;
    
    FRENewObject((const uint8_t*)"Array", 0, NULL, &result, nil);
    FRESetArrayLength(result, arrayLength);
    
    for(int32_t i = 0; i < arrayLength; i++)
    {
        NSString* item = [value objectAtIndex: i];
        FREObject element = FPANE_NSStringToFREObject(item);
        FRESetArrayElementAt(result, i, element);
    }
    return result;
}

FREObject FPANE_doubleToFREObject(double value)
{
    FREObject result;
    FRENewObjectFromDouble(value, &result);
    return result;
}

