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
#import "FBSBJSON.h"

FREContext AirFBCtx = nil;


@implementation AirFacebook

@synthesize facebook = _facebook;


- (void)log:(NSString *)string
{
    NSLog(@"[Facebook] %@", string);
}


#pragma mark - Singleton

static AirFacebook *sharedInstance = nil;

+ (AirFacebook *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return self;
}


#pragma mark - Facebook Login

- (id)initWithAppID:(NSString *)appID urlSuffix:(NSString *)urlSuffix
{
    self = [self init];
    
    if (self)
    {
        if (!urlSuffix)
        {
            _facebook = [[Facebook alloc] initWithAppId:appID andDelegate:nil];
        }
        else
        {
            _facebook = [[Facebook alloc] initWithAppId:appID urlSchemeSuffix:urlSuffix andDelegate:nil];
        }
        
        [FBSession setDefaultAppID:appID];
        
        FBSession *session = [FBSession activeSession];
        if (session.state == FBSessionStateCreatedTokenLoaded && AirFBCtx)
        {
            [session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                [self sessionStateChanged:session state:status error:error];
            }];
        }
    }
    
    return self;
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    NSString *stateName = nil;
    NSString *eventName = nil;
    switch (state)
    {
        case FBSessionStateOpen:
            stateName = @"FBSessionStateOpen";
            eventName = @"USER_LOGGED_IN";
            _facebook.accessToken = session.accessToken;
            _facebook.expirationDate = session.expirationDate;
            break;
            
        case FBSessionStateClosed:
            stateName = @"FBSessionStateClosed";
            eventName = @"USER_LOGGED_OUT";
            _facebook.accessToken = nil;
            _facebook.expirationDate = nil;
            break;
            
        case FBSessionStateClosedLoginFailed:
            stateName = @"FBSessionStateClosedLoginFailed";
            eventName = @"USER_LOG_IN_ERROR";
            if (error) [self log:[NSString stringWithFormat:@"Login error: %@", [error localizedDescription]]];
            break;
            
        default:
            break;
    }
    
    // Print a debug log
    [self log:[NSString stringWithFormat:@"Session state changed: %@", stateName]];
    
    // Dispatch an event
    if (eventName && AirFBCtx)
    {
        FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)[eventName UTF8String], (const uint8_t *)"OK");
    }
}


#pragma mark - Facebook Request

- (void)requestWithGraphPath:(NSString *)path callback:(NSString *)callbackName
{
    [self requestWithGraphPath:path parameters:[NSDictionary dictionary] httpMethod:@"GET" callback:callbackName];
}

- (void) requestWithGraphPath:(NSString *)path parameters:(NSDictionary *)params callback:(NSString *)callbackName
{
    [self requestWithGraphPath:path parameters:params httpMethod:@"GET" callback:callbackName];
}

- (void) requestWithGraphPath:(NSString*)path parameters:(NSMutableDictionary*)params httpMethod:(NSString*)httpMethod callback:(NSString*)callbackName
{
    FBRequest *request = [FBRequest requestWithGraphPath:path parameters:params HTTPMethod:httpMethod];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // Log the result and the error if any
        [self log:[NSString stringWithFormat:@"Request response: %@", result]];
        if (error)
        {
            [self log:[NSString stringWithFormat:@"Request error: %@", [error localizedDescription]]];
        }
        
        // Serialize the result
        NSError *jsonError = nil;
        NSString *resultString = [[[FBSBJSON alloc] init] stringWithObject:result error:&jsonError];
        
        if (jsonError)
        {
            [self log:[NSString stringWithFormat:@"Request JSON error: %@", [jsonError localizedDescription]]];
        }
        else
        {
            NSString *eventName = callbackName ? callbackName : @"LOGGING";
            if (AirFBCtx)
            {
                FREDispatchStatusEventAsync(AirFBCtx, (const uint8_t *)[eventName UTF8String], (const uint8_t *)[resultString UTF8String]);
            }
        }
    }];
}


#pragma mark - Facebook Dialog

- (void)dialog:(NSString *)action parameters:(NSMutableDictionary *)params callback:(NSString*)callbackName
{
    AirFBDialog *dialogDelegate = [[AirFBDialog alloc] initWithName:callbackName context:AirFBCtx];
    [_facebook dialog:action andParams:params andDelegate:dialogDelegate];
}

@end



#pragma mark - C interface

DEFINE_ANE_FUNCTION(initFacebook)
{
    uint32_t stringLength;
    
    // Retrieve application ID
    NSString *appID = nil;
    const uint8_t *string1;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &string1) == FRE_OK)
    {
        appID = [NSString stringWithUTF8String:(char*)string1];
    }
    
    NSString *urlSuffix = nil;
    const uint8_t *string2;
    if (FREGetObjectAsUTF8(argv[3], &stringLength, &string2) == FRE_OK)
    {
        urlSuffix = [NSString stringWithUTF8String:(char*)string2];
        
        if (urlSuffix != nil && [urlSuffix length] == 0)
        {
            urlSuffix = nil;
        }
    }
    
    // Init Facebook
    [[AirFacebook sharedInstance] initWithAppID:appID urlSuffix:urlSuffix];
    
    return nil;
}

DEFINE_ANE_FUNCTION(getAccessToken)
{
    FBSession *session = [FBSession activeSession];
    NSString *accessToken = [session accessToken];
    
    FREObject result;
    if (FRENewObjectFromUTF8(accessToken.length, (const uint8_t *)[accessToken UTF8String], &result) == FRE_OK)
    {
        return result;
    }
    else return nil;
}

DEFINE_ANE_FUNCTION(getExpirationTimestamp)
{
    FBSession *session = [FBSession activeSession];
    NSTimeInterval expirationTimestamp = [session.expirationDate timeIntervalSince1970];
    
    FREObject result;
    if (FRENewObjectFromUint32(expirationTimestamp, &result) == FRE_OK)
    {
        return result;
    }
    else return nil;
}

DEFINE_ANE_FUNCTION(isSessionValid)
{
    FBSession *session = [FBSession activeSession];
    BOOL isSessionValid = [session isOpen];
    
    FREObject result;
    if (FRENewObjectFromBool(isSessionValid, &result) == FRE_OK)
    {
        return result;
    }
    else return nil;
}

DEFINE_ANE_FUNCTION(login)
{
    // Retrieve permissions
    FREObject arr = argv[0]; // array
    uint32_t arr_len; // array length
    
    FREGetArrayLength(arr, &arr_len);
    
    NSMutableArray *permissions = [[NSMutableArray alloc] init];
    for (int32_t i = arr_len-1; i >= 0; i--)
    {
        // Get an element at index i
        FREObject element;
        FREGetArrayElementAt(arr, i, &element);
        
        // Convert it to NSString
        uint32_t stringLength;
        const uint8_t *string;
        if (FREGetObjectAsUTF8(element, &stringLength, &string) != FRE_OK)
        {
            continue;
        }
        NSString *permission = [NSString stringWithUTF8String:(char*)string];
        
        [permissions addObject:permission];
    }
    
    // Print debug log
    [[AirFacebook sharedInstance] log:[NSString stringWithFormat:@"Login with permissions: %@", permissions]];
    
    // Start login flow
    [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (status == FBSessionStateOpen)
        {
            NSArray *publishPermissions = [NSArray arrayWithObject:@"publish_actions"];
            [[FBSession activeSession] reauthorizeWithPublishPermissions:publishPermissions defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
                [[AirFacebook sharedInstance] sessionStateChanged:session state:status error:error];
            }];
        }
    }];
    
    [permissions release];
    
    return nil;
}

DEFINE_ANE_FUNCTION(logout)
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    return nil;
}

DEFINE_ANE_FUNCTION(askForMorePermissions)
{
    // Retrieve permissions
    FREObject arr = argv[0]; // array
    uint32_t arr_len; // array length
    
    FREGetArrayLength(arr, &arr_len);
    
    NSMutableArray *permissions = [[NSMutableArray alloc] init];
    for (int32_t i = arr_len-1; i >= 0; i--)
    {
        // Get an element at index i
        FREObject element;
        FREGetArrayElementAt(arr, i, &element);
        
        // Convert it to NSString
        uint32_t stringLength;
        const uint8_t *string;
        if (FREGetObjectAsUTF8(element, &stringLength, &string) != FRE_OK)
        {
            continue;
        }
        NSString *permission = [NSString stringWithUTF8String:(char*)string];
        
        [permissions addObject:permission];
    }
    
    FBSession *session = [FBSession activeSession];
    [session reauthorizeWithPermissions:permissions behavior:FBSessionLoginBehaviorUseSystemAccountIfPresent completionHandler:^(FBSession *session, NSError *error) {
        // TODO: Dispatch an event?
    }];
    
    [permissions release];
    
    return nil;
}

DEFINE_ANE_FUNCTION(extendAccessTokenIfNeeded)
{
    // Doesn't do anything on iOS (handled automagically by Facebook SDK 3.0)
    return nil;
}

DEFINE_ANE_FUNCTION(postOGAction)
{
    uint32_t stringLength;
    
    // Retrieve OpenGraph action name
    NSString *action = nil;
    const uint8_t *actionName;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &actionName) == FRE_OK)
    {
        action = [NSString stringWithUTF8String:(char*)actionName];
    }
    
    // Retrieve OpenGraph action parameters
    FREObject arrKey = argv[1]; // array
    FREObject arrValue = argv[2];
    uint32_t arr_len = 0; // array length
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if (arrKey)
    {
        if (FREGetArrayLength(arrKey, &arr_len) != FRE_OK)
        {
            arr_len = 0;
        }
        
        for(int32_t i = arr_len-1; i >= 0; i--)
        {
            // Get an element at index i
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
            
            // Convert it to NSString
            uint32_t stringLength;
            
            const uint8_t *keyString;
            if (FREGetObjectAsUTF8(key, &stringLength, &keyString) != FRE_OK)
            {
                continue;
            }
            NSString *keyObject = [NSString stringWithUTF8String:(char*)keyString];
            
            const uint8_t *valueString;
            if (FREGetObjectAsUTF8(value, &stringLength, &valueString) != FRE_OK)
            {
                continue;
            }
            NSString *valueObject = [NSString stringWithUTF8String:(char*)valueString];
            
            [params setValue:valueObject forKey:keyObject];
        }
    }
    
    // Retrieve callback name
    const uint8_t *string3;
    NSString *callbackName = nil;
    if (FREGetObjectAsUTF8(argv[3], &stringLength, &string3) == FRE_OK)
    {
        callbackName = [NSString stringWithUTF8String:(char*)string3];
    }
    
    // Retrieve method name
    const uint8_t *string4;
    NSString *method = @"POST";
    if (FREGetObjectAsUTF8(argv[4], &stringLength, &string4) == FRE_OK)
    {
        method = [NSString stringWithUTF8String:(char*)string4];
    }
    
    [[AirFacebook sharedInstance] requestWithGraphPath:action parameters:params httpMethod:method callback:callbackName];
    
    [params release];
    
    return nil;
}

DEFINE_ANE_FUNCTION(openDialog)
{
    uint32_t stringLength;
    
    // Retrieve method name
    const uint8_t *string1;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &string1) != FRE_OK)
    {
        return nil;
    }
    NSString *method = [NSString stringWithUTF8String:(char*)string1];
    
    // Retrieve message
    const uint8_t *string2;
    NSString *message = @"";
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &string2) == FRE_OK)
    {
        message = [NSString stringWithUTF8String:(char*)string2];
    }
    
    // Retrieve recipients
    const uint8_t *string3;
    NSString* toUsers = nil;
    if (FREGetObjectAsUTF8(argv[2], &stringLength, &string3) == FRE_OK)
    {
        toUsers = [NSString stringWithUTF8String:(char*)string3];
    }
    
    // Retrieve parameters string
    const uint8_t *dataParam;
    NSString* paramString = nil;
    if (FREGetObjectAsUTF8(argv[4], &stringLength, &dataParam) == FRE_OK)
    {
        paramString = [NSString stringWithUTF8String:(char*)dataParam];
    }
    
    // Create parameters dictionary
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:message forKey:@"message"];
    if (toUsers != nil && [toUsers length] > 0)
    {
        [params setValue:toUsers forKey:@"to"];
        [params setObject: @"1" forKey:@"frictionless"];
    }
    if (paramString != nil)
    {
        [params setValue:paramString forKey:@"data"];
    }
    
    // Retrieve callback name
    const uint8_t *string4;
    NSString *callbackName = nil;
    if (FREGetObjectAsUTF8(argv[3], &stringLength, &string4) == FRE_OK)
    {
        callbackName = [NSString stringWithUTF8String:(char*)string4];
    }
    
    [[AirFacebook sharedInstance] dialog:method parameters:params callback:callbackName];
    
    [params release];
    
    return nil;
}

DEFINE_ANE_FUNCTION(openFeedDialog)
{
    uint32_t stringLength;
    
    // Retrieve method name
    const uint8_t *string1;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &string1) != FRE_OK)
    {
        return nil;
    }
    NSString *method = [NSString stringWithUTF8String:(char*)string1];
    
    // Create parameters dictionary
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    // Retrieve message
    const uint8_t *string2;
    NSString *message = @"";
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &string2) == FRE_OK)
    {
        message = [NSString stringWithUTF8String:(char*)string2];
        [params setValue:message forKey:@"message"];
    }
    
    // Retrieve name
    const uint8_t *string3;
    NSString *name = nil;
    if (FREGetObjectAsUTF8(argv[2], &stringLength, &string3) == FRE_OK)
    {
        name = [NSString stringWithUTF8String:(char*)string3];
        [params setValue:name forKey:@"name"];
    }
    
    // Retrieve picture
    const uint8_t *string4;
    NSString *picture = nil;
    if (FREGetObjectAsUTF8(argv[3], &stringLength, &string4) == FRE_OK)
    {
        picture = [NSString stringWithUTF8String:(char*)string4];
        [params setValue:picture forKey:@"picture"];
    }
    
    // Retrieve link
    const uint8_t *string5;
    NSString *link = nil;
    if (FREGetObjectAsUTF8(argv[4], &stringLength, &string5) == FRE_OK)
    {
        link = [NSString stringWithUTF8String:(char*)string5];
        [params setValue:link forKey:@"link"];
    }
    
    // Retrieve caption
    const uint8_t *string6;
    NSString *caption = nil;
    if (FREGetObjectAsUTF8(argv[5], &stringLength, &string6) == FRE_OK)
    {
        caption = [NSString stringWithUTF8String:(char*)string6];
        [params setValue:caption forKey:@"caption"];
    }
    
    // Retrieve description
    const uint8_t *string7;
    NSString *description = nil;
    if (FREGetObjectAsUTF8(argv[6], &stringLength, &string7) == FRE_OK)
    {
        description = [NSString stringWithUTF8String:(char*)string7];
        [params setValue:description forKey:@"description"];
    }
    
    // Retrieve recipients
    const uint8_t *string8;
    NSString *toUsers = nil;
    if (FREGetObjectAsUTF8(argv[7], &stringLength, &string8) == FRE_OK)
    {
        toUsers = [NSString stringWithUTF8String:(char*)string8];
        [params setValue:toUsers forKey:@"to"];
    }
    
    // Retrieve callback name
    const uint8_t *string9;
    NSString *callbackName = nil;
    if (FREGetObjectAsUTF8(argv[8], &stringLength, &string9) == FRE_OK)
    {
        callbackName = [NSString stringWithUTF8String:(char*)string9];
    }
    
    // Present a native or popup dialog depending on iOS version
    if ([FBNativeDialogs canPresentShareDialogWithSession:nil])
    {
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        NSURL *imageURL = [NSURL URLWithString:picture];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        NSURL *url = [NSURL URLWithString:link];
        [FBNativeDialogs presentShareDialogModallyFrom:rootViewController initialText:name image:image url:url handler:nil];
    }
    else
    {
        [[AirFacebook sharedInstance] dialog:method parameters:params callback:callbackName];
    }
    
    [params release];
    
    return nil;
}

DEFINE_ANE_FUNCTION(deleteRequests)
{
    // Loop through the array given as parameter.
    
    NSString *jsonString = nil;
    
    FREObject arrKey = argv[0]; // array
    uint32_t arr_len = 0; // array length
    if (arrKey != nil)
    {
        // Retrieve array length
        if (FREGetArrayLength(arrKey, &arr_len) != FRE_OK)
        {
            arr_len = 0;
        }
        
        // Loop through array
        for (int32_t i = arr_len-1; i >= 0; i--)
        {
            // Get an element at index i
            FREObject requestId;
            if (FREGetArrayElementAt(arrKey, i, &requestId) != FRE_OK)
            {
                continue;
            }
            
            // Convert it to NSString
            uint32_t stringLength;
            const uint8_t *keyString;
            if (FREGetObjectAsUTF8(requestId, &stringLength, &keyString) != FRE_OK)
            {
                continue;
            }
            
            // Build JSON string
            NSString *jsonRequest = [NSString stringWithFormat:@"{ \"method\": \"DELETE\", \"relative_url\": \"%@\" }", [NSString stringWithUTF8String:(char*) keyString]];
            
            if (!jsonString || [jsonString length] == 0)
            {
                jsonString = @"[ ";
                jsonString = [jsonString stringByAppendingString:jsonRequest];
            }
            else
            {
                jsonString = [jsonString stringByAppendingFormat:@", %@", jsonRequest];
            }
        }
        
        // Add closing bracket to JSON string
        if (jsonString) jsonString = [jsonString stringByAppendingFormat:@"]"];
        
        // Perform Facebook request
        if (jsonString != nil && jsonString.length > 0)
        {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:jsonString forKey:@"batch"];
            [[AirFacebook sharedInstance] requestWithGraphPath:@"me" parameters:params httpMethod:@"POST" callback:@"DELETE_INVITE"];
        }
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(requestWithGraphPath)
{
    uint32_t stringLength;
    
    // Retrieve callback name
    const uint8_t *string1;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &string1) != FRE_OK)
    {
        return nil;
    }
    NSString *callback = [NSString stringWithUTF8String:(char*)string1];

    // Retrieve graph path
    const uint8_t *string2;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &string2) != FRE_OK)
    {
        return nil;
    }
    NSString *path = [NSString stringWithUTF8String:(char*)string2];
    
    // Retrieve request params
    const uint8_t *string3;
    NSString *paramString = nil;
    if (FREGetObjectAsUTF8(argv[2], &stringLength, &string3) == FRE_OK)
    {
        paramString = [NSString stringWithUTF8String:(char*)string3];
    }

    // Perform Facebook request
    if (paramString != nil)
    {
        if ([paramString length] > 3)
        {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:paramString forKey:@"fields"];
            [[AirFacebook sharedInstance] requestWithGraphPath:path parameters:params callback:callback];
        }
        else
        {
            [[AirFacebook sharedInstance] requestWithGraphPath:path callback:callback];
        }
        
    }
    else
    {
        [[AirFacebook sharedInstance] requestWithGraphPath:path callback:callback];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(handleOpenURL)
{
    // Retrieve URL
    uint32_t stringLength;
    const uint8_t *string;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &string) != FRE_OK)
    {
        return nil;
    }
    NSString *urlString = [NSString stringWithUTF8String:(char*)string];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Print a debug log
    [[AirFacebook sharedInstance] log:[NSString stringWithFormat:@"Handle open URL: %@", url]];
    
    // Give the URL to the Facebook session
    FBSession *session = [FBSession activeSession];
    [session handleOpenURL:url];
    
    return nil;
}



// ANE setup

// ContextInitializer()
//
// The context initializer is called when the runtime creates the extension context instance.
void AirFBContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 14;
    *numFunctionsToTest = nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    func[0].name = (const uint8_t*) "initFacebook";
    func[0].functionData = NULL;
    func[0].function = &initFacebook;
    
    func[1].name = (const uint8_t*) "getAccessToken";
    func[1].functionData = NULL;
    func[1].function = &getAccessToken;

    func[2].name = (const uint8_t*) "getExpirationTimestamp";
    func[2].functionData = NULL;
    func[2].function = &getExpirationTimestamp;

    func[3].name = (const uint8_t*) "isSessionValid";
    func[3].functionData = NULL;
    func[3].function = &isSessionValid;

    func[4].name = (const uint8_t*) "login";
    func[4].functionData = NULL;
    func[4].function = &login;
    
    func[5].name = (const uint8_t*) "logout";
    func[5].functionData = NULL;
    func[5].function = &logout;

    func[6].name = (const uint8_t*) "askForMorePermissions";
    func[6].functionData = NULL;
    func[6].function = &askForMorePermissions;
    
    func[7].name = (const uint8_t*) "extendAccessTokenIfNeeded";
    func[7].functionData = NULL;
    func[7].function = &extendAccessTokenIfNeeded;
    
    func[8].name = (const uint8_t*) "postOGAction";
    func[8].functionData = NULL;
    func[8].function = &postOGAction;

    func[9].name = (const uint8_t*) "openDialog";
    func[9].functionData = NULL;
    func[9].function = &openDialog;
    
    func[10].name = (const uint8_t*) "openFeedDialog";
    func[10].functionData = NULL;
    func[10].function = &openFeedDialog;
    
    func[11].name = (const uint8_t*) "deleteRequests";
    func[11].functionData = NULL;
    func[11].function = &deleteRequests;
    
    func[12].name = (const uint8_t*) "requestWithGraphPath";
    func[12].functionData = NULL;
    func[12].function = &requestWithGraphPath;
    
    func[13].name = (const uint8_t*) "handleOpenURL";
    func[13].functionData = NULL;
    func[13].function = &handleOpenURL;
    
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
void AirFBInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) 
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirFBContextInitializer; 
	*ctxFinalizerToSet = &AirFBContextFinalizer;
}

void AirFBFinalizer(void *extData) { }