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

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.AirFacebookExtensionContext;
import com.freshplanet.ane.AirFacebook.ShareDialogActivity;

public class ShareLinkDialogFunction implements FREFunction
{
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		// Retrieve callback
		String callback = null;
		String link = null;
		String name = null;
		String caption = null;
		String description = null;
		String pictureUrl = null;
		try {
			link = arg1[0].getAsString();
			name = arg1[1].getAsString();
			caption = arg1[2].getAsString();
			description = arg1[3].getAsString();
			pictureUrl = arg1[4].getAsString();
			callback = arg1[7].getAsString();
		} catch (Exception e) {
			AirFacebookExtension.log("ERROR - " + e.getMessage());
		}
		
		// Start dialog activity
		Intent i = new Intent(arg0.getActivity().getApplicationContext(), ShareDialogActivity.class);
		i.putExtra(ShareDialogActivity.extraPrefix+".link", link);
		i.putExtra(ShareDialogActivity.extraPrefix+".name", name);
		i.putExtra(ShareDialogActivity.extraPrefix+".caption", caption);
		i.putExtra(ShareDialogActivity.extraPrefix+".description", description);
		i.putExtra(ShareDialogActivity.extraPrefix+".pictureUrl", pictureUrl);
		i.putExtra(ShareDialogActivity.extraPrefix+".callback", callback);
		arg0.getActivity().startActivity(i);
		
		return null;
	}
}