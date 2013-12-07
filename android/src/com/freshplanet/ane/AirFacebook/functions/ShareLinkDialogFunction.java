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
import com.freshplanet.ane.AirFacebook.ShareDialogActivity;

public class ShareLinkDialogFunction extends BaseFunction implements FREFunction
{
	public FREObject call(FREContext context, FREObject[] args)
	{
		
		super.call(context, args);
		
		// Retrieve callback
		String callback = getStringFromFREObject(args[7]);
		String link = getStringFromFREObject(args[0]);
		String name = getStringFromFREObject(args[1]);
		String caption = getStringFromFREObject(args[2]);
		String description = getStringFromFREObject(args[3]);
		String pictureUrl = getStringFromFREObject(args[4]);
		
		// Start dialog activity
		Intent i = new Intent(context.getActivity().getApplicationContext(), ShareDialogActivity.class);
		i.putExtra(ShareDialogActivity.extraPrefix+".link", link);
		i.putExtra(ShareDialogActivity.extraPrefix+".name", name);
		i.putExtra(ShareDialogActivity.extraPrefix+".caption", caption);
		i.putExtra(ShareDialogActivity.extraPrefix+".description", description);
		i.putExtra(ShareDialogActivity.extraPrefix+".pictureUrl", pictureUrl);
		i.putExtra(ShareDialogActivity.extraPrefix+".callback", callback);
		context.getActivity().startActivity(i);
		
		return null;
		
	}
}