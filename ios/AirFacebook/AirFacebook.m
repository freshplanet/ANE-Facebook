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
//

#import "AirFacebook.h"

FREContext AirFBCtx = nil;


#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])


// @see https://developers.facebook.com/docs/mobile/ios/build/
@implementation AirFacebook
@synthesize facebook;


+(id) sharedInstance {
    static id sharedInstance = nil;
    if (sharedInstance == nil) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}



///////////////////////////////////////////////////////
// FACEBOOK LOGIN
///////////////////////////////////////////////////////

// @param appId facebook app id
// @param suffix suffix used for your other apps using the same app id (i.e paid version). can be set to null
- (void) initFacebookWithAppId:(NSString*)appId andSuffix:(NSString*)suffix andAccessToken:(NSString*)accessToken andExpirationTimestamp:(NSString*)expirationTimestamp
{
    if (suffix == nil)
    {
        facebook = [[Facebook alloc] initWithAppId:appId andDelegate:self];

    } else
    {
        facebook = [[Facebook alloc] initWithAppId:appId urlSchemeSuffix:suffix andDelegate:self];
    }

    
    if (accessToken != nil && expirationTimestamp != nil)
    {
        facebook.accessToken = accessToken;
        facebook.expirationDate = [NSDate dateWithTimeIntervalSince1970:[expirationTimestamp doubleValue]/1000];
    }
    
}



- (BOOL) handleOpenURL:(NSURL *)url {
    if (AirFBCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFBCtx, (uint8_t*)"handleOpenURL", (uint8_t*)[@"Success" UTF8String]); 
    }
    
    return [facebook handleOpenURL:url]; 
}

- (void) login:(NSArray*)permissions
{
    //Check for a valid session
    if (![facebook isSessionValid]) {
        if (AirFBCtx != nil)
        {
            FREDispatchStatusEventAsync(AirFBCtx, (uint8_t*)"LOGGING", (uint8_t*)[@"authorize" UTF8String]); 
        }

        [facebook authorize:permissions];
    } else
    {
        if (AirFBCtx != nil)
        {
            FREDispatchStatusEventAsync(AirFBCtx, (uint8_t*)"LOGGING", (uint8_t*)[@"Session valid" UTF8String]); 
            [self fbDidLogin];
        }

    }

}

- (void) askForMorePermissions:(NSArray*)permissions
{
    [facebook authorize:permissions];
}


- (void) logout
{
    [facebook logout];  
}



/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin 
{    
    NSString* result = [facebook accessToken];
    NSTimeInterval interval = [[facebook expirationDate] timeIntervalSince1970];
    interval *= 1000; //needs to be in ms
    NSNumber *myNumber = [NSNumber numberWithDouble:interval];
    result = [result stringByAppendingFormat:@"&%lld",[myNumber longLongValue]];
    if (AirFBCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFBCtx, (uint8_t*)"USER_LOGGED_IN", (uint8_t*)[result UTF8String]); 
    }
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled 
{
    NSLog(@"User did not log in");
    if (AirFBCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFBCtx, (uint8_t*)"USER_LOG_IN_CANCEL", (uint8_t*)[@"Success" UTF8String]); 
    }

}


/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt 
{
    NSString* result = [facebook accessToken];
    NSTimeInterval interval = [[facebook expirationDate] timeIntervalSince1970];
    interval *= 1000; //needs to be in ms
    NSNumber *myNumber = [NSNumber numberWithDouble:interval];
    result = [result stringByAppendingFormat:@"&%lld",[myNumber longLongValue]];
    if (AirFBCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFBCtx, (uint8_t*)"ACCESS_TOKEN_REFRESHED", (uint8_t*)[result UTF8String]); 
    }
 
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    NSLog(@"User did log out");
    if (AirFBCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFBCtx, (uint8_t*)"USER_LOGGED_OUT", (uint8_t*)[@"Success" UTF8String]); 
    }

}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
    NSLog(@"Session is invalid");
    if (AirFBCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFBCtx, (uint8_t*)"USER_SESSION_EXPIRED", (uint8_t*)[@"Success" UTF8String]); 
    }

}

- (void)extendAccessTokenIfNeeded
{
    if ([facebook shouldExtendAccessToken])
    {
        [facebook extendAccessToken];
    } else
    {
        [self fbDidExtendToken:[facebook accessToken] expiresAt:[facebook expirationDate]];
    }
}


///////////////////////////////////////////////////////
// FACEBOOK REQUEST (Graph API)
///////////////////////////////////////////////////////



- (void)requestWithGraphPath:(NSString*)path andCallback:(NSString*)callbackName
{
    AirFBRequest *requestDelegate = [[AirFBRequest alloc] init];
    [requestDelegate setName:callbackName];
    [requestDelegate setContext:AirFBCtx];
    
    
    [facebook requestWithGraphPath:path andParams:[[[NSMutableDictionary alloc] init] autorelease] andHttpMethod:@"GET" andDelegate:requestDelegate];
}


- (void) requestWithGraphPath:(NSString*)path andParams:(NSMutableDictionary*)params andCallback:(NSString*)callbackName
{
    AirFBRequest *requestDelegate = [[AirFBRequest alloc] init];
    [requestDelegate setName:callbackName];
    [requestDelegate setContext:AirFBCtx];
    
    
    [facebook requestWithGraphPath:path andParams:params andHttpMethod:@"GET" andDelegate:requestDelegate];
}


- (void) requestWithGraphPath:(NSString*)path andParams:(NSMutableDictionary*)params andHttpMethod:(NSString*)httpMethod andCallback:(NSString*)callbackName
{
    AirFBRequest *requestDelegate = [[AirFBRequest alloc] init];
    [requestDelegate setName:callbackName];
    [requestDelegate setContext:AirFBCtx];

    [facebook requestWithGraphPath:path andParams:params andHttpMethod:httpMethod andDelegate:requestDelegate];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{    
    if (AirFBCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFBCtx, (uint8_t*)"GRAPH_API_ERROR", (uint8_t*)[[error description] UTF8String]); 
    }
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    NSString* dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (AirFBCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFBCtx, (uint8_t*)"GRAPH_API_SUCCESS", (uint8_t*)[dataString UTF8String]); 
    } 
    [dataString release];
}

///////////////////////////////////////////////////////
// FACEBOOK DIALOG (App Requests)
///////////////////////////////////////////////////////



- (void)dialog:(NSString *)action andParams:(NSMutableDictionary *)params andCallback:(NSString*)callbackName
{
    AirFBDialog *dialogDelegate = [[AirFBDialog alloc] init];
    [dialogDelegate setName:callbackName];
    [dialogDelegate setContext:AirFBCtx];
    
    [facebook dialog:action andParams:params andDelegate:dialogDelegate];
}






@end

// init Facebook Library
DEFINE_ANE_FUNCTION(initFacebook)
{
    
    uint32_t stringLength;
    const uint8_t *string1;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &string1) != FRE_OK)
    {
        return nil;
    }
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"AppId" UTF8String]); 

    NSString *appId = [NSString stringWithUTF8String:(char*)string1];

    const uint8_t *string2;
    NSString *accessToken = nil;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &string2) == FRE_OK)
    {
        accessToken = [NSString stringWithUTF8String:(char*)string2];
    }
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"accessToken" UTF8String]); 

    
    const uint8_t *string3;
    NSString *expirationTimestamp = nil;
    if (FREGetObjectAsUTF8(argv[2], &stringLength, &string3) == FRE_OK)
    {
         expirationTimestamp = [NSString stringWithUTF8String:(char*)string3];
    }
    
    NSString* suffix = nil;
    const uint8_t *string4;
    if (FREGetObjectAsUTF8(argv[3], &stringLength, &string4) == FRE_OK)
    {
        FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"suffix" UTF8String]); 

        suffix = [NSString stringWithUTF8String:(char*)string4];
        FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[suffix UTF8String]); 

        if (suffix != nil && [suffix length] == 0)
        {
            suffix = nil;
        }
    }

    
    
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"ExpirationToken" UTF8String]); 
    [[AirFacebook sharedInstance] initFacebookWithAppId:appId andSuffix:suffix andAccessToken:accessToken andExpirationTimestamp:expirationTimestamp];
    
    return nil;
}


// extend Access Token if Needed.
DEFINE_ANE_FUNCTION(extendAccessTokenIfNeeded)
{
    [[AirFacebook sharedInstance] extendAccessTokenIfNeeded];
    FREDispatchStatusEventAsync(context, (uint8_t*)"REFRESH_TOKEN_DONE", (uint8_t*)[@"Success" UTF8String]); 
    return nil;
}


// log out from Facebook
DEFINE_ANE_FUNCTION(logout)
{
    [[AirFacebook sharedInstance] logout];
    return nil;
}

// log in
DEFINE_ANE_FUNCTION(login)
{

    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"login" UTF8String]); 

    FREObject arr = argv[0]; // array
    uint32_t arr_len; // array length
    
    FREGetArrayLength(arr, &arr_len);
    
    NSMutableArray* permissions = [[NSMutableArray alloc] init];
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"permissions" UTF8String]); 
    for(int32_t i=arr_len-1; i>=0;i--){
        
        // get an element at index
        FREObject element;
        FREGetArrayElementAt(arr, i, &element);

        // convert it to NSString
        uint32_t stringLength;
        const uint8_t *string;
        if (FREGetObjectAsUTF8(element, &stringLength, &string) != FRE_OK)
        {
            continue;
        }
        NSString *permission = [NSString stringWithUTF8String:(char*)string];

        [permissions addObject:permission];

    }
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"call air facebook" UTF8String]); 
    
    [[AirFacebook sharedInstance] login:[NSArray arrayWithArray:permissions]];
    
    return nil;
}

// log in
DEFINE_ANE_FUNCTION(askForMorePermissions)
{
    
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"ask for more permissions" UTF8String]); 
    
    FREObject arr = argv[0]; // array
    uint32_t arr_len; // array length
    
    FREGetArrayLength(arr, &arr_len);
    
    NSMutableArray* permissions = [[NSMutableArray alloc] init];
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"permissions" UTF8String]); 
    for(int32_t i=arr_len-1; i>=0;i--){
        
        // get an element at index
        FREObject element;
        FREGetArrayElementAt(arr, i, &element);
        
        // convert it to NSString
        uint32_t stringLength;
        const uint8_t *string;
        if (FREGetObjectAsUTF8(element, &stringLength, &string) != FRE_OK)
        {
            continue;
        }
        NSString *permission = [NSString stringWithUTF8String:(char*)string];
        
        [permissions addObject:permission];
        
    }
    
    [[AirFacebook sharedInstance] askForMorePermissions:[NSArray arrayWithArray:permissions]];
    
    return nil;
}



// handle Open URL
DEFINE_ANE_FUNCTION(handleOpenURL)
{
    
    uint32_t stringLength;
    const uint8_t *string;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &string) != FRE_OK)
    {
        return nil;
    }
    NSString *urlString = [NSString stringWithUTF8String:(char*)string];
    NSURL* url = [NSURL URLWithString:urlString];
    
    [[AirFacebook sharedInstance] handleOpenURL:url];
    
    return nil;
}

// request with Graph Path.
// makes a call to graph api.
DEFINE_ANE_FUNCTION(requestWithGraphPath)
{
    uint32_t stringLength;
    const uint8_t *string1;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &string1) != FRE_OK)
    {
        return nil;
    }
    NSString *callback = [NSString stringWithUTF8String:(char*)string1];

    
    const uint8_t *string2;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &string2) != FRE_OK)
    {
        return nil;
    }
    NSString *path = [NSString stringWithUTF8String:(char*)string2];
    
    const uint8_t *string3;
    NSString *params = nil;
    if (FREGetObjectAsUTF8(argv[2], &stringLength, &string3) == FRE_OK)
    {
        params = [NSString stringWithUTF8String:(char*)string3];
    }

    if (params != nil)
    {
        if ([params length] > 3)
        {
            NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:params forKey:@"fields"];
            [[AirFacebook sharedInstance] requestWithGraphPath:path andParams:dict andCallback:callback];
        } else
        {
            [[AirFacebook sharedInstance] requestWithGraphPath:path andCallback:callback];
        }
        
    } else
    {
        [[AirFacebook sharedInstance] requestWithGraphPath:path andCallback:callback];

    }
    
    
    return nil;
}



// open a Facebook Dialog
DEFINE_ANE_FUNCTION(openDialog)
{
    
    uint32_t stringLength;
    
    const uint8_t *string1;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &string1) != FRE_OK)
    {
        return nil;
    }
    NSString *method = [NSString stringWithUTF8String:(char*)string1];
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"Method" UTF8String]); 

    
    const uint8_t *string2;
    NSString *message = @"";
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &string2) == FRE_OK)
    {
       message = [NSString stringWithUTF8String:(char*)string2];
    }
     
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"Message" UTF8String]); 

    const uint8_t *string3;
    NSString* toUsers = nil;
    if (FREGetObjectAsUTF8(argv[2], &stringLength, &string3) == FRE_OK)
    {
        toUsers = [NSString stringWithUTF8String:(char*)string3];
    }
    
    const uint8_t *dataParam;
    NSString* paramString = nil;
    if (FREGetObjectAsUTF8(argv[4], &stringLength, &dataParam) == FRE_OK)
    {
        paramString = [NSString stringWithUTF8String:(char*)dataParam];
    }

    
    NSMutableDictionary* params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setValue:message forKey:@"message"];
    
    if (toUsers != nil && [toUsers length] > 0)
    {
        [params setValue:toUsers forKey:@"to"];
        [params setObject: @"1" forKey:@"frictionless"];
    }
    if (paramString != nil) {
        [params setValue:paramString forKey:@"data"];
    }
    
    
    const uint8_t *string4;
    NSString *callbackName = nil;
    if (FREGetObjectAsUTF8(argv[3], &stringLength, &string4) == FRE_OK)
    {
        callbackName = [NSString stringWithUTF8String:(char*)string4];
    }
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[callbackName UTF8String]); 
    
    [[AirFacebook sharedInstance] dialog:method andParams:params andCallback:callbackName];    
    return nil;
}

// open a Facebook Dialog
DEFINE_ANE_FUNCTION(openFeedDialog)
{
    
    uint32_t stringLength;
    // method
    const uint8_t *string1;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &string1) != FRE_OK)
    {
        return nil;
    }
    NSString *method = [NSString stringWithUTF8String:(char*)string1];
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"Method" UTF8String]); 
    
    
    NSMutableDictionary* params = [[[NSMutableDictionary alloc] init] autorelease];
    // message
    const uint8_t *string2;
    NSString *message = @"";
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &string2) == FRE_OK)
    {
        message = [NSString stringWithUTF8String:(char*)string2];
        [params setValue:message forKey:@"message"];

    }
    
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[@"Message" UTF8String]); 
    
    // name
    const uint8_t *string3;
    NSString* name = nil;
    if (FREGetObjectAsUTF8(argv[2], &stringLength, &string3) == FRE_OK)
    {
        name = [NSString stringWithUTF8String:(char*)string3];
        [params setValue:name forKey:@"name"];

    }
    
    // picture
    const uint8_t *string4;
    NSString* picture = nil;
    if (FREGetObjectAsUTF8(argv[3], &stringLength, &string4) == FRE_OK)
    {
        picture = [NSString stringWithUTF8String:(char*)string4];
        [params setValue:picture forKey:@"picture"];

    }

    // link
    const uint8_t *string5;
    NSString* link = nil;
    if (FREGetObjectAsUTF8(argv[4], &stringLength, &string5) == FRE_OK)
    {
        link = [NSString stringWithUTF8String:(char*)string5];
        [params setValue:link forKey:@"link"];

    }

    // caption
    const uint8_t *string6;
    NSString* caption = nil;
    if (FREGetObjectAsUTF8(argv[5], &stringLength, &string6) == FRE_OK)
    {   
        caption = [NSString stringWithUTF8String:(char*)string6];
        [params setValue:caption forKey:@"caption"];

    }

    // description
    const uint8_t *string7;
    NSString* description = nil;
    if (FREGetObjectAsUTF8(argv[6], &stringLength, &string7) == FRE_OK)
    {
        description = [NSString stringWithUTF8String:(char*)string7];
        [params setValue:description forKey:@"description"];

    }
    
    // userId
    const uint8_t *string8;
    NSString *toUsers = nil;
    if (FREGetObjectAsUTF8(argv[7], &stringLength, &string8) == FRE_OK)
    {
        toUsers = [NSString stringWithUTF8String:(char*)string8];
        [params setValue:toUsers forKey:@"to"];
    }
    
    // callbackName
    const uint8_t *string9;
    NSString *callbackName = nil;
    if (FREGetObjectAsUTF8(argv[8], &stringLength, &string9) == FRE_OK)
    {
        callbackName = [NSString stringWithUTF8String:(char*)string9];
    }
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[callbackName UTF8String]); 
    
    [[AirFacebook sharedInstance] dialog:method andParams:params andCallback:callbackName];    
    return nil;
}


// delete a list of request
DEFINE_ANE_FUNCTION(deleteRequests)
{
    // loop through an array.

        NSString *jsonString = NULL;
        FREObject arrKey = argv[0]; // array
        uint32_t arr_len = 0; // array length
        if (arrKey != nil)
        {

            if (FREGetArrayLength(arrKey, &arr_len) != FRE_OK)
            {
                arr_len = 0;
            }
             
            for(int32_t i=arr_len-1; i>=0;i--){
                
                // get an element at index
                FREObject requestId;
                if (FREGetArrayElementAt(arrKey, i, &requestId) != FRE_OK)
                {
                    continue;
                }
                                
                // convert it to NSString
                uint32_t stringLength;
                const uint8_t *keyString;
                if (FREGetObjectAsUTF8(requestId, &stringLength, &keyString) != FRE_OK)
                {
                    continue;
                }
                                
                NSString *jsonRequest = [NSString stringWithFormat:@"{ \"method\": \"DELETE\", \"relative_url\": \"%@\" }", [NSString stringWithUTF8String:(char*) keyString]];
                
                if ( jsonString == NULL || [jsonString length] == 0)
                {
                    jsonString = @"[ ";
                    jsonString = [jsonString stringByAppendingString:jsonRequest];
                } else
                {
                    jsonString = [jsonString stringByAppendingFormat:@", %@", jsonRequest];
                }
            }
            
            if (jsonString != nil)
            {
                jsonString = [jsonString stringByAppendingFormat:@"]"];
            }
        
            if (jsonString != nil && jsonString.length > 0)
            {

                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:jsonString forKey:@"batch"];
                [[AirFacebook sharedInstance] requestWithGraphPath:@"me" andParams:params andHttpMethod:@"POST" andCallback:@"DELETE_INVITE"];
            }
        }
    
    return nil;
}

// make a post to the 
DEFINE_ANE_FUNCTION(postOGAction)
{

    uint32_t stringLength;
    
    const uint8_t *actionName;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &actionName) != FRE_OK)
    {
        return nil;
    }
    NSString *action = [NSString stringWithUTF8String:(char*)actionName];
    FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[action UTF8String]); 
    
    
    FREObject arrKey = argv[1]; // array
    FREObject arrValue = argv[2];
    uint32_t arr_len = 0; // array length
    NSMutableDictionary* params = [[[NSMutableDictionary alloc] init] autorelease];
    if (arrKey != nil)
    {
        
        if (FREGetArrayLength(arrKey, &arr_len) != FRE_OK)
        {
            arr_len = 0;
        }
        
        for(int32_t i=arr_len-1; i>=0;i--){
            
            // get an element at index
            FREObject key;
            if (FREGetArrayElementAt(arrKey, i, &key) != FRE_OK)
            {
                continue;
            }
            
            FREObject value;
            if (FREGetArrayElementAt(arrValue, i, &value) != FRE_OK)
            {
                continue;
            }

            // convert it to NSString
            uint32_t stringLength;
            const uint8_t *keyString;
            if (FREGetObjectAsUTF8(key, &stringLength, &keyString) != FRE_OK)
            {
                continue;
            }

            NSString *keyObject = [NSString stringWithUTF8String:(char*)keyString];

            FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[keyObject UTF8String]); 

            
            const uint8_t *valueString;
            if (FREGetObjectAsUTF8(value, &stringLength, &valueString) != FRE_OK)
            {
                continue;
            }
            
            NSString *valueObject = [NSString stringWithUTF8String:(char*)valueString];
            
            FREDispatchStatusEventAsync(context, (uint8_t*)"LOGGING", (uint8_t*)[valueObject UTF8String]); 

            
            [params setValue:valueObject forKey:keyObject];
        }
        
    }
        
    [[AirFacebook sharedInstance] requestWithGraphPath:action andParams:params andHttpMethod:@"POST" andCallback:nil];
        
    return nil;
}

// ContextInitializer()
//
// The context initializer is called when the runtime creates the extension context instance.
void AirFBContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{
    
    
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 11;
    *numFunctionsToTest = nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    func[0].name = (const uint8_t*) "initFacebook";
    func[0].functionData = NULL;
    func[0].function = &initFacebook;
    
    func[1].name = (const uint8_t*) "extendAccessTokenIfNeeded";
    func[1].functionData = NULL;
    func[1].function = &extendAccessTokenIfNeeded;

    func[2].name = (const uint8_t*) "handleOpenURL";
    func[2].functionData = NULL;
    func[2].function = &handleOpenURL;

    func[3].name = (const uint8_t*) "login";
    func[3].functionData = NULL;
    func[3].function = &login;

    func[4].name = (const uint8_t*) "openDialog";
    func[4].functionData = NULL;
    func[4].function = &openDialog;
    
    func[5].name = (const uint8_t*) "requestWithGraphPath";
    func[5].functionData = NULL;
    func[5].function = &requestWithGraphPath;

    func[6].name = (const uint8_t*) "logout";
    func[6].functionData = NULL;
    func[6].function = &logout;
    
    
    func[7].name = (const uint8_t*) "deleteRequests";
    func[7].functionData = NULL;
    func[7].function = &deleteRequests;
    
    func[8].name = (const uint8_t*) "postOGAction";
    func[8].functionData = NULL;
    func[8].function = &postOGAction;

    func[9].name = (const uint8_t*) "openFeedDialog";
    func[9].functionData = NULL;
    func[9].function = &openFeedDialog;

    func[10].name = (const uint8_t*) "askForMorePermissions";
    func[10].functionData = NULL;
    func[10].function = &askForMorePermissions;
    
    *functionsToSet = func;
    
    AirFBCtx = ctx;
}

// ContextFinalizer()
//
// Set when the context extension is created.

void AirFBContextFinalizer(FREContext ctx) { }



// airFacebookInitializer()
//
// The extension initializer is called the first time the ActionScript side of the extension
// calls ExtensionContext.createExtensionContext() for any context.

void AirFBInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) 
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirFBContextInitializer; 
	*ctxFinalizerToSet = &AirFBContextFinalizer;
}

void AirFBFinalizer(void *extData) { }