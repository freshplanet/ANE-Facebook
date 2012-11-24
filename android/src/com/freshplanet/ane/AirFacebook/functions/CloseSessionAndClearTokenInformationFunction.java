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

package com.freshplanet.ane.AirFacebook.functions;

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
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.AirFacebookExtensionContext;

public class CloseSessionAndClearTokenInformationFunction implements FREFunction, RequestListener
{	
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{	
		SessionStore.clear(arg0.getActivity().getApplicationContext());
		AsyncFacebookRunner mAsyncRunner = new AsyncFacebookRunner(AirFacebookExtensionContext.facebook);
		mAsyncRunner.logout(arg0.getActivity(), this);
		
		return null;
	}
	
	public void onComplete(String response, Object state)
	{
		AirFacebookExtension.log("INFO - Session closed");
	}
	
	public void onIOException(IOException e, Object state)
	{
		AirFacebookExtension.log("ERROR - " + e.getMessage());
	}
	
	public void onFileNotFoundException(FileNotFoundException e, Object state)
	{
		AirFacebookExtension.log("ERROR - " + e.getMessage());
	}
	
	public void onMalformedURLException(MalformedURLException e, Object state)
	{
		AirFacebookExtension.log("ERROR - " + e.getMessage());
	}
	
	public void onFacebookError(FacebookError e, Object state)
	{
		AirFacebookExtension.log("ERROR - " + e.getMessage());
	}
}