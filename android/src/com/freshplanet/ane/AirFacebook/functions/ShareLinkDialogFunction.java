package com.freshplanet.ane.AirFacebook.functions;

import android.content.Intent;

import android.net.Uri;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.facebook.share.model.ShareLinkContent;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.ShareDialogActivity;

public class ShareLinkDialogFunction extends BaseFunction implements FREFunction
{
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);
		
		// Retrieve callback
		String contentUrl = getStringFromFREObject(args[0]);
		String contentTitle = getStringFromFREObject(args[1]);
		String contentDescription = getStringFromFREObject(args[2]);
		String imageUrl = getStringFromFREObject(args[3]);
		Boolean useShareApi = getBooleanFromFREObject(args[4]);
		String callback = getStringFromFREObject(args[5]);

		AirFacebookExtension.log("ShareLinkDialogFunction");

		ShareLinkContent.Builder builder = new ShareLinkContent.Builder();
		if(contentUrl != null) builder.setContentUrl(Uri.parse(contentUrl));
		if(contentTitle != null) builder.setContentTitle(contentTitle);
		if(imageUrl != null) builder.setImageUrl(Uri.parse(imageUrl));
		if(contentDescription != null) builder.setContentDescription(contentDescription);
		ShareLinkContent content = builder.build();

		// Start dialog activity
		Intent i = new Intent(context.getActivity().getApplicationContext(), ShareDialogActivity.class);
		i.putExtra(ShareDialogActivity.extraPrefix + ".callback", callback);
		i.putExtra(ShareDialogActivity.extraPrefix + ".content", content);
		i.putExtra(ShareDialogActivity.extraPrefix + ".useShareApi", useShareApi);
		context.getActivity().startActivity(i);

		return null;
		
	}
}