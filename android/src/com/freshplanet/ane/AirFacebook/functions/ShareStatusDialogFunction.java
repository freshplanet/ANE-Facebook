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

import android.content.Intent;
import android.os.Bundle;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.facebook.widget.FacebookDialog;
import com.facebook.widget.FacebookDialog.ShareDialogBuilder;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.AirFacebookExtensionContext;
import com.freshplanet.ane.AirFacebook.ShareDialogActivity;
import com.freshplanet.ane.AirFacebook.WebDialogActivity;

public class ShareStatusDialogFunction implements FREFunction
{
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		
		// Retrieve callback
		String callback = null;
		try {
			callback = arg1[0].getAsString();
		} catch (Exception e) {
			AirFacebookExtension.log("ERROR - " + e.getMessage());
		}
		
		// Start dialog activity
		Intent i = new Intent(arg0.getActivity().getApplicationContext(), ShareDialogActivity.class);
		i.putExtra(ShareDialogActivity.extraPrefix+".callback", callback);
		arg0.getActivity().startActivity(i);
		
		return null;
		
	}
}