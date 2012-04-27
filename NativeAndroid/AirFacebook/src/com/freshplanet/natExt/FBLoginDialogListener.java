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

package com.freshplanet.natExt;

import android.os.Bundle;

import com.adobe.fre.FREContext;
import com.facebook.android.DialogError;
import com.facebook.android.FacebookError;
import com.facebook.android.Facebook.DialogListener;

public class FBLoginDialogListener implements DialogListener {

	@Override
	public void onComplete(Bundle values) {
		
		String access_token = FBExtensionContext.facebook.getAccessToken();
		long access_expires = FBExtensionContext.facebook.getAccessExpires();
		
		
		FREContext freContext = FBExtension.context;
		freContext.dispatchStatusEventAsync("USER_LOGGED_IN", access_token+"&"+Long.toString(access_expires));
	}

	@Override
	public void onFacebookError(FacebookError e) {
		FREContext freContext = FBExtension.context;
		freContext.dispatchStatusEventAsync("USER_LOG_IN_FB_ERROR", e.getMessage());
	}

	@Override
	public void onError(DialogError e) {
		FREContext freContext = FBExtension.context;
		freContext.dispatchStatusEventAsync("USER_LOG_IN_ERROR", e.getMessage());
	}

	@Override
	public void onCancel() {
		FREContext freContext = FBExtension.context;
		freContext.dispatchStatusEventAsync("USER_LOG_IN_CANCEL", "null");
	}

}
