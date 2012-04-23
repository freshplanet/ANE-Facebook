package com.freshplanet.natExt;

import java.io.IOException;
import java.net.MalformedURLException;

import com.adobe.fre.FREContext;

import android.os.Bundle;

public class FBRequestThread extends Thread {

	private String paramsString;
	private String graphPath;
	private String callbackName;
	private FREContext context;
	private String httpMethod;
	
	private Bundle params;
	
	public FBRequestThread(FREContext context, String callbackName, String graphPath, String params)
	{
		this.paramsString = params;
		this.context = context;
		this.callbackName = callbackName;
		this.graphPath = graphPath;
		this.httpMethod = "GET";
	}
	
	public FBRequestThread(FREContext context, String callbackName, String graphPath, Bundle params, String httpMethod)
	{
		this.params = params;
		this.context = context;
		this.callbackName = callbackName;
		this.graphPath = graphPath;
		this.httpMethod = httpMethod;
	}

	
    @Override public void run() {
		String data = null;
		try {
			if (paramsString != null)
			{
				params = new Bundle();
				params.putString("fields", paramsString);
			}
			
			if (params != null)
			{
				data = FBExtensionContext.facebook.request(graphPath, params, this.httpMethod);
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
