package com.freshplanet.natExt.functions;

import android.content.Intent;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.natExt.ExtendAccessTokenActivity;

public class ExtendAccessTokenIfNeededFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		Intent i = new Intent(arg0.getActivity().getApplicationContext(), ExtendAccessTokenActivity.class);
		arg0.getActivity().startActivity(i);
		
		return null;
	}

}
