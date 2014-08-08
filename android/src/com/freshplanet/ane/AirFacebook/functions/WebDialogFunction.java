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

import android.os.Bundle;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

public class WebDialogFunction extends BaseFunction implements FREFunction 
{
	
	private String method;
	private String callback;
	
	public FREObject call(FREContext context, FREObject[] args)
	{
		
		super.call(context, args);

		method = getStringFromFREObject(args[0]);
		Bundle parameters = getBundleOfStringFromFREArrays((FREArray)args[1], (FREArray)args[2]);
		callback = getStringFromFREObject(args[3]);
		
		// Start dialog activity
		AirFacebookExtension.context.launchDialogActivity(method, parameters, callback);
		
		return null;
		
	}
	
}
