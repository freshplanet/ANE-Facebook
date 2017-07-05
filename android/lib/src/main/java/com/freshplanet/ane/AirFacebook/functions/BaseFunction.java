package com.freshplanet.ane.AirFacebook.functions;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import android.os.Bundle;

import com.adobe.fre.*;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.AirFacebookExtensionContext;

public class BaseFunction implements FREFunction
{
	public static final int TYPE_STRING = 0;
	public static final int TYPE_INT = 1;
	public static final int TYPE_BOOL = 2;

	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{
		AirFacebookExtension.context = (AirFacebookExtensionContext)context;
		return null;
	}

	protected String getStringProperty(FREObject object, String property)
	{
		try
		{
			FREObject propertyObject = object.getProperty(property);
			if(propertyObject == null){
				return null;
			}
			return getStringFromFREObject(propertyObject);
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return null;
		}
	}

	protected int getIntProperty(FREObject object, String property)
	{
		try
		{
			FREObject propertyObject = object.getProperty(property);
			if(propertyObject == null){
				return 0;
			}
			return getIntFromFREObject(propertyObject);
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return 0;
		}
	}

	protected List<String> getStringListProperty(FREObject object, String property)
	{
		try
		{
			FREArray propertyArray = (FREArray)object.getProperty(property);
			if(propertyArray == null){
				return null;
			}
			return getListOfStringFromFREArray(propertyArray);
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return null;
		}
	}

	protected FREArray getFREArrayFromSet(Set<String> items) {

		try
		{
			long i = 0;
			FREArray array = FREArray.newArray(items.size());
			for (String item : items) {
				array.setObjectAt(i, FREObject.newObject(item));
				i++;
			}
			return array;
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return null;
		}
	}

	protected String getStringFromFREObject(FREObject object)
	{
		try
		{
			return object.getAsString();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return null;
		}
	}

	protected int getIntFromFREObject(FREObject object)
	{
		try
		{
			return object.getAsInt();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return 0;
		}
	}
	
	protected Boolean getBooleanFromFREObject(FREObject object)
	{
		try
		{
			return object.getAsBool();
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return false;
		}
	}
	
	protected List<String> getListOfStringFromFREArray(FREArray array)
	{
		List<String> result = new ArrayList<String>();
		
		try
		{
			for (int i = 0; i < array.getLength(); i++)
			{
				try
				{
					result.add(getStringFromFREObject(array.getObjectAt((long)i)));
				} 
				catch (Exception e)
				{
					e.printStackTrace();
				}
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return null;
		}
		
		return result;
	}

	protected List<Integer> getListOfIntegerFromFREArray(FREArray array)
	{
		List<Integer> result = new ArrayList<Integer>();

		try
		{
			for (int i = 0; i < array.getLength(); i++)
			{
				try
				{
					result.add(getIntFromFREObject(array.getObjectAt((long) i)));
				}
				catch (Exception e)
				{
					e.printStackTrace();
				}
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return null;
		}

		return result;
	}
	
	protected Bundle getBundleOfStringFromFREArrays(FREArray keys, FREArray values)
	{
		Bundle result = new Bundle();
		
		try
		{
			long length = Math.min(keys.getLength(), values.getLength());
			for (int i = 0; i < length; i++)
			{
				try
				{
					String key = getStringFromFREObject(keys.getObjectAt((long)i));
					String value = getStringFromFREObject(values.getObjectAt((long)i));
					result.putString(key, value);
				}
				catch (Exception e)
				{
					e.printStackTrace();
				}
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return null;
		}
		
		return result;
	}

	protected Bundle getBundleFromFREArrays(FREArray keys, FREArray types, FREArray values)
	{
		Bundle result = new Bundle();

		try
		{
			long length = keys.getLength();

			if(length != types.getLength() || length != values.getLength()){
				throw new Error("Wrong input arrays length!");
			}

			for (long i = 0; i < length; i++) {
				try {
					String key = getStringFromFREObject(keys.getObjectAt(i));
					int type = getIntFromFREObject(types.getObjectAt(i));
					FREObject valueObject = values.getObjectAt(i);
					switch (type){
						case TYPE_STRING:
							result.putString(key, valueObject.getAsString());
							break;
						case TYPE_INT:
							result.putInt(key, valueObject.getAsInt());
							break;
						case TYPE_BOOL:
							result.putBoolean(key, valueObject.getAsBool());
							break;
					}
				}
				catch (Exception e)
				{
					e.printStackTrace();
				}
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return null;
		}

		return result;
	}
}
