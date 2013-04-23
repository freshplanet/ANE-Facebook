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

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.AirFacebookExtensionContext;

public class IsSessionOpenFunction implements FREFunction
{
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		AirFacebookExtension.log("INFO - IsSessionOpenedFunction");
		AirFacebookExtension.log("INFO - IsSessionOpenedFunction, AirFacebookExtensionContext=" + AirFacebookExtension.context);
		if (AirFacebookExtensionContext.session == null) {
			AirFacebookExtension.log("INFO - IsSessionOpenedFunction: session is null");
		} else
			AirFacebookExtension.log("INFO - IsSessionOpenedFunction: session.isOpened " + AirFacebookExtensionContext.session.isOpened());
		try
		{
			return FREObject.newObject(AirFacebookExtensionContext.session.isOpened());
		}
		catch (Exception e)
		{
			AirFacebookExtension.log("ERROR - " + e.getMessage());
			return null;
		}
	}
}