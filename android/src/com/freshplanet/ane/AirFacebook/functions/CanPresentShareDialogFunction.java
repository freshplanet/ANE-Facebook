package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.ShareDialog;

public class CanPresentShareDialogFunction extends BaseFunction
{
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);

		try {
			return FREObject.newObject(ShareDialog.canShow(ShareLinkContent.class));
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return null;
		}
	}
}