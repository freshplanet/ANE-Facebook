package com.freshplanet.ane.AirFacebook.functions;

import android.content.Intent;

import android.net.Uri;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.facebook.share.model.ShareLinkContent;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.ShareDialogActivity;

import java.util.List;

public class ShareLinkDialogFunction extends BaseFunction implements FREFunction
{
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);

		// Retrieve callback
		String contentUrl = getStringProperty(args[0], "contentUrl");
		List<String> peopleIds = getStringListProperty(args[0], "peopleIds");
		String placeId = getStringProperty(args[0], "placeId");
		String ref = getStringProperty(args[0], "ref");
		String contentTitle = getStringProperty(args[0], "contentTitle");
		String contentDescription = getStringProperty(args[0], "contentDescription");
		String imageUrl = getStringProperty(args[0], "imageUrl");
		
		Boolean useShareApi = getBooleanFromFREObject(args[1]);
		String callback = getStringFromFREObject(args[2]);

		AirFacebookExtension.log("ShareLinkDialogFunction");

		ShareLinkContent.Builder builder = new ShareLinkContent.Builder();
		if(contentUrl != null) builder.setContentUrl(Uri.parse(contentUrl));
		if(peopleIds != null) builder.setPeopleIds(peopleIds);
		if(placeId != null) builder.setPlaceId(placeId);
		if(ref != null) builder.setRef(ref);
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