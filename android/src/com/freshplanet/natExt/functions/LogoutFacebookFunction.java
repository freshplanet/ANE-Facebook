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

package com.freshplanet.natExt.functions;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.MalformedURLException;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.facebook.android.AsyncFacebookRunner;
import com.facebook.android.AsyncFacebookRunner.RequestListener;
import com.facebook.android.FacebookError;
import com.facebook.android.SessionStore;
import com.freshplanet.natExt.FBExtensionContext;

public class LogoutFacebookFunction implements FREFunction, RequestListener
{
	private FREContext freContext;
	
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		freContext = arg0;
		
		SessionStore.clear(arg0.getActivity().getApplicationContext());
		AsyncFacebookRunner mAsyncRunner = new AsyncFacebookRunner(FBExtensionContext.facebook);
		mAsyncRunner.logout(freContext.getActivity(), this);
		
		return null;
	}
	
	@Override
	public void onComplete(String response, Object state)
	{
		freContext.dispatchStatusEventAsync("USER_LOGGED_OUT", "Success");
	}
	
	@Override
	public void onIOException(IOException e, Object state)
	{
		freContext.dispatchStatusEventAsync("USER_LOGGED_OUT_ERROR", e.getMessage());
	}

	@Override
	public void onFileNotFoundException(FileNotFoundException e, Object state)
	{
		freContext.dispatchStatusEventAsync("USER_LOGGED_OUT_ERROR", e.getMessage());
	}
  
	@Override
	public void onMalformedURLException(MalformedURLException e, Object state)
	{
		freContext.dispatchStatusEventAsync("USER_LOGGED_OUT_ERROR", e.getMessage());
	}
	
	@Override
	public void onFacebookError(FacebookError e, Object state)
	{
		freContext.dispatchStatusEventAsync("USER_LOGGED_OUT_ERROR", e.getMessage());
	}
}