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
    for (NSInteger i = 0; i < arrayLength; i++)
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
    for (NSInteger i = 0; i < numItems; i++)
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

// nodrock functions

//FREResult NSStringToFREObject(FREObject *object, NSString *value)
//{
//    return FRENewObjectFromUTF8((uint32_t)value.length, (const uint8_t *)[value UTF8String], object);
//}
//
//FREResult NSArrayToFREObject(FREObject *object, NSArray *value)
//{
//    uint32_t arrayLength = (uint32_t)value.count;
//    
//    FRENewObject((const uint8_t*)"Array", 0, NULL, object, nil);
//    FRESetArrayLength(*object, arrayLength);
//    
//    for(int32_t i = 0; i < arrayLength; i++)
//    {
//        NSString* item = [value objectAtIndex: i];
//        FREObject element;
//        NSStringToFREObject(element, item);
//        FRESetArrayElementAt(*object, i, element);
//    }
//    return FRE_OK;
//}
//
//FREResult setObjectStringProperty(FREObject object, const uint8_t* propertyName, NSString *value)
//{
//    FREObject property;
//    NSStringToFREObject(&property, value);
//    return FRESetObjectProperty(object, propertyName, property, nil);
//}
//
//FREResult setObjectStringArrayProperty(FREObject object, const uint8_t* propertyName, NSArray *value)
//{
//    FREObject property;
//    NSArrayToFREObject(&property, value);
//    return FRESetObjectProperty(object, propertyName, property, nil);
//}



