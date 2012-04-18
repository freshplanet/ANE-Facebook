package com.freshplanet.natExt;

import java.io.IOException;
import java.net.MalformedURLException;

import com.adobe.fre.FREContext;

import android.os.Bundle;

public class FBRequestThread extends Thread {

	private String params;
	private String graphPath;
	private String callbackName;
	private FREContext context;
	
	public FBRequestThread(FREContext context, String callbackName, String graphPath, String params)
	{
		this.params = params;
		this.context = context;
		this.callbackName = callbackName;
		this.graphPath = graphPath;
	}
	
	
	
    @Override public void run() {
		String data = null;
		try {
			if (params != null)
			{
				Bundle bundle = new Bundle();
				bundle.putString("fields", params);
				
				data = FBExtensionContext.facebook.request(graphPath, bundle);

			} else
			{
				data = FBExtensionContext.facebook.request(graphPath);
			}
		} catch (MalformedURLException e) {
			e.printStackTrace();
			context.dispatchStatusEventAsync(callbackName, e.getMessage());
		} catch (IOException e) {
			e.printStackTrace();
			context.dispatchStatusEventAsync(callbackName, e.getMessage());
		} catch (Exception e)
		{
			e.printStackTrace();
			context.dispatchStatusEventAsync(callbackName, e.getMessage());
		}
		
		if (data != null)
		{
			context.dispatchStatusEventAsync(callbackName, data);
		}

    }

	
	
}
