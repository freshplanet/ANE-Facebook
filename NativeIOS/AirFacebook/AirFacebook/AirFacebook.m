//
//  AirFacebook.m
//  AirFacebook
//
//  Created by Thibaut Crenn on 3/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AirFacebook.h"

void *refToSelf;
FREContext AirFBCtx = nil;



// @see https://developers.facebook.com/docs/mobile/ios/build/
@implementation AirFacebook
@synthesize facebook;



- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    refToSelf = self;
    return self;
}


///////////////////////////////////////////////////////
// FACEBOOK LOGIN
///////////////////////////////////////////////////////


- (void) initFacebookWithAppId:(NSString*)appId andAccessToken:(NSString*)accessToken andExpirationTimestamp:(NSString*)expirationTimestamp
{
    facebook = [[Facebook alloc] initWithAppId:appId andDelegate:self];
    
    if (accessToken != nil && expirationTimestamp != nil)
    {
        facebook.accessToken = accessToken;
        facebook.expirationDate = [NSDate dateWithTimeIntervalSince1970:[expirationTimestamp doubleValue]];
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
        [facebook authorize:permissions];
    }

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
    
    
    [facebook requestWithGraphPath:path andParams:[[NSMutableDictionary alloc] init] andHttpMethod:@"GET" andDelegate:requestDelegate];
}


- (void) requestWithGraphPath:(NSString*)path andParams:(NSMutableDictionary*)params andCallback:(NSString*)callbackName
{
    AirFBRequest *requestDelegate = [[AirFBRequest alloc] init];
    [requestDelegate setName:callbackName];
    [requestDelegate setContext:AirFBCtx];
    
    
    [facebook requestWithGraphPath:path andParams:params andHttpMethod:@"GET" andDelegate:requestDelegate];
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
}

///////////////////////////////////////////////////////
// FACEBOOK DIALOG (App Requests)
///////////////////////////////////////////////////////



- (void)dialog:(NSString *)action andParams:(NSMutableDictionary *)params
{
    [facebook dialog:action andParams:params andDelegate:self];
}




@end


FREObject initFacebook(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) 
{
    FREDispatchStatusEventAsync(ctx, (uint8_t*)"INIT_STARTED", (uint8_t*)[@"Started" UTF8String]); 

    if (refToSelf == nil)
    {
        [[AirFacebook alloc] init];
    }
    
    uint32_t stringLength;
    const uint8_t *string1;
    FREGetObjectAsUTF8(argv[0], &stringLength, &string1);
    NSString *appId = [NSString stringWithUTF8String:(char*)string1];

    const uint8_t *string2;
    FREGetObjectAsUTF8(argv[1], &stringLength, &string2);
    NSString *accessToken = [NSString stringWithUTF8String:(char*)string2];

    
    const uint8_t *string3;
    
    FREGetObjectAsUTF8(argv[2], &stringLength, &string3);
    NSString *expirationTimestamp = [NSString stringWithUTF8String:(char*)string3];

    
    
    [(AirFacebook*)refToSelf initFacebookWithAppId:appId andAccessToken:accessToken andExpirationTimestamp:expirationTimestamp];
    
    
    FREDispatchStatusEventAsync(ctx, (uint8_t*)"INIT_DONE", (uint8_t*)[@"Success" UTF8String]); 
    
    return nil;
}


FREObject extendAccessTokenIfNeeded(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    [(AirFacebook*)refToSelf extendAccessTokenIfNeeded];
    
    FREDispatchStatusEventAsync(ctx, (uint8_t*)"REFRESH_TOKEN_DONE", (uint8_t*)[@"Success" UTF8String]); 

    
    return nil;
}

FREObject login(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    FREObject arr = argv[0]; // array
    uint32_t arr_len; // array length
    
    FREGetArrayLength(arr, &arr_len);
    
    NSMutableArray* permissions = [[NSMutableArray alloc] init];
    
    for(int32_t i=arr_len-1; i>=0;i--){
        
        // get an element at index
        FREObject element;
        FREGetArrayElementAt(arr, i, &element);

        // convert it to NSString
        uint32_t stringLength;
        const uint8_t *string;
        FREGetObjectAsUTF8(element, &stringLength, &string);
        NSString *permission = [NSString stringWithUTF8String:(char*)string];

        [permissions addObject:permission];
        if (AirFBCtx != nil)
        {
            FREDispatchStatusEventAsync(AirFBCtx, (uint8_t*)"ADD_OBJET", (uint8_t*)[permission UTF8String]); 
        }

    }
    
    
    [(AirFacebook*)refToSelf login:[NSArray arrayWithArray:permissions]];
    
    FREDispatchStatusEventAsync(ctx, (uint8_t*)"LOGIN_DONE", (uint8_t*)[@"Success" UTF8String]); 
    
    
    return nil;
}


FREObject handleOpenURL(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    
    uint32_t stringLength;
    const uint8_t *string;
    FREGetObjectAsUTF8(argv[0], &stringLength, &string);
    NSString *urlString = [NSString stringWithUTF8String:(char*)string];
    NSURL* url = [NSURL URLWithString:urlString];
    
    [(AirFacebook*)refToSelf handleOpenURL:url];
    
    return nil;
}

FREObject requestWithGraphPath(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    
    uint32_t stringLength;
    const uint8_t *string1;
    FREGetObjectAsUTF8(argv[0], &stringLength, &string1);
    NSString *callback = [NSString stringWithUTF8String:(char*)string1];

    
    const uint8_t *string2;
    FREGetObjectAsUTF8(argv[1], &stringLength, &string2);
    NSString *path = [NSString stringWithUTF8String:(char*)string2];
    
    const uint8_t *string3;
    FREGetObjectAsUTF8(argv[2], &stringLength, &string3);
    if (string3 != NULL)
    {
        NSString *params = [NSString stringWithUTF8String:(char*)string3];
        if ([params length] > 3)
        {
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            [dict setValue:params forKey:@"fields"];
            [(AirFacebook*)refToSelf requestWithGraphPath:path andParams:dict andCallback:callback];
        } else
        {
            [(AirFacebook*)refToSelf requestWithGraphPath:path andCallback:callback];
        }
    } else
    {
        [(AirFacebook*)refToSelf requestWithGraphPath:path andCallback:callback];

    }
    
    
    return nil;
}




// method, message, to
FREObject openDialog(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    
    uint32_t stringLength;
    
    const uint8_t *string1;
    FREGetObjectAsUTF8(argv[0], &stringLength, &string1);
    NSString *method = [NSString stringWithUTF8String:(char*)string1];
    
    const uint8_t *string2;
    FREGetObjectAsUTF8(argv[1], &stringLength, &string2);
    NSString *message = [NSString stringWithUTF8String:(char*)string2];


    const uint8_t *string3;
    FREGetObjectAsUTF8(argv[2], &stringLength, &string3);
    NSString* toUsers = [NSString stringWithUTF8String:(char*)string3];
    
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setValue:message forKey:@"message"];
    
    if (toUsers != nil && [toUsers length] > 0)
    {
        [params setValue:toUsers forKey:@"to"];
    }
    
    if (AirFBCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFBCtx, (uint8_t*)"OPEN_DIALOG", (uint8_t*)[@"call of function" UTF8String]); 
    }

    
    [(AirFacebook*)refToSelf dialog:method andParams:params];    
    return nil;
}



// ContextInitializer()
//
// The context initializer is called when the runtime creates the extension context instance.
void AirFBContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{
    
    
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 6;
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

    
    
    *functionsToSet = func;
    
    AirFBCtx = ctx;
}

// ContextFinalizer()
//
// Set when the context extension is created.

void AirFBContextFinalizer(FREContext ctx) { 
    NSLog(@"Entering ContextFinalizer()");
    
    NSLog(@"Exiting ContextFinalizer()");	
}



// airFacebookInitializer()
//
// The extension initializer is called the first time the ActionScript side of the extension
// calls ExtensionContext.createExtensionContext() for any context.

void AirFBInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) 
{
    
    NSLog(@"Entering ExtInitializer()");                    
    
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirFBContextInitializer; 
	*ctxFinalizerToSet = &AirFBContextFinalizer;
    
    NSLog(@"Exiting ExtInitializer()"); 
}