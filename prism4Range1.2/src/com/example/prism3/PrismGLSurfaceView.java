package com.example.prism3;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.util.AttributeSet;
import android.view.MotionEvent;

public class PrismGLSurfaceView extends GLSurfaceView 
{	
	private PrismRenderer mRenderer;
    
    private float mDensity;
        	
	public PrismGLSurfaceView(Context context) 
	{
		super(context);		
	}
	
	public PrismGLSurfaceView(Context context, AttributeSet attrs) 
	{
		super(context, attrs);		
	}

	// Hides superclass method.
	public void setRenderer(PrismRenderer renderer, float density) 
	{
		mRenderer = renderer;
		mDensity = density;
		super.setRenderer(renderer);
	}
}
