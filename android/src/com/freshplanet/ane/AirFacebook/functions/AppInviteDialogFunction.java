package com.freshplanet.ane.AirFacebook.functions;

import android.content.Intent;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.facebook.share.model.AppInviteContent;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.AppInviteActivity;

public class AppInviteDialogFunction extends BaseFunction implements FREFunction
{
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);
		
		// Retrieve callback
		String appLinkUrl = getStringFromFREObject(args[0]);
		String previewImageUrl = getStringFromFREObject(args[1]);
		String callback = getStringFromFREObject(args[2]);

		AirFacebookExtension.log("AppInviteDialogFunction");

		AppInviteContent.Builder builder = new AppInviteContent.Builder();
		if(appLinkUrl != null) builder.setApplinkUrl(appLinkUrl);
		if(previewImageUrl != null) builder.setPreviewImageUrl(previewImageUrl);
		AppInviteContent content = builder.build();

		// Start dialog activity
		Intent i = new Intent(context.getActivity().getApplicationContext(), AppInviteActivity.class);
		i.putExtra(AppInviteActivity.extraPrefix + ".callback", callback);
		i.putExtra(AppInviteActivity.extraPrefix + ".content", content);
		context.getActivity().startActivity(i);

		return null;
		
	}
}