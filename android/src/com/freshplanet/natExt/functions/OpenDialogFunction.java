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

import android.content.Intent;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.natExt.FBDialogActivity;

public class OpenDialogFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		// Retrieve method name
		String method = null;
		try
		{
			method = arg1[0].getAsString();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("LOGGING", "Error - " + e.getMessage());
		}
		
		// Retrieve message
		String message = null;
		try
		{
			message = arg1[1].getAsString();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("LOGGING", "Error - " + e.getMessage());
		}
		
		// Retrieve recipient
		String to = null;
		if (arg1.length > 2 && arg1[2] != null)
		{
			try
			{
				to = arg1[2].getAsString();
			}
			catch (Exception e)
			{
				e.printStackTrace();
				arg0.dispatchStatusEventAsync("LOGGING", "Error - " + e.getMessage());
			}
		}
		
		// Retrieve callback name
		String callbackName = null;
		if (arg1.length > 3 && arg1[3] != null)
		{
			try
			{
				callbackName = arg1[3].getAsString();
			}
			catch (Exception e)
			{
				e.printStackTrace();
				arg0.dispatchStatusEventAsync("LOGGING", "Error - " + e.getMessage());
			}
		}
		
		// Start Facebook Dialog activity
		Intent i = new Intent(arg0.getActivity().getApplicationContext(), FBDialogActivity.class);
		i.putExtra("message", message);
		i.putExtra("method", method);
		if (to != null && to.length() > 0)
		{
			i.putExtra("to", to);
		}
		arg0.getActivity().startActivity(i);
		
		// Trigger the callback if necessary
		if (callbackName != null)
		{
			arg0.dispatchStatusEventAsync(callbackName, "{}");
		}
		
		return null;
	}
}