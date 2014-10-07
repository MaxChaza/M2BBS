package com.example.prism3.utils;

import android.opengl.GLES20;
import android.opengl.Matrix;

public class Light {

	/**
	 * Stores a copy of the model matrix specifically for the light position.
	 */
	private float[] mLightModelMatrix = new float[16];

	/** This is a handle to our light point program. */
	private int mPointProgramHandle;

	/** Used to hold a light centered on the origin in model space. We need a 4th coordinate so we can get translations to work when
	 *  we multiply this by our transformation matrices. */
	private final float[] mLightPosInModelSpace = new float[] {0.0f, 0.70f, -2.0f, 1.0f};
	
	/** Used to hold the current position of the light in world space (after transformation via model matrix). */
	private final float[] mLightPosInWorldSpace = new float[4];
	
	/** Used to hold the transformed position of the light in eye space (after transformation via modelview matrix) */
	private final float[] mLightPosInEyeSpace = new float[4];
	/** This will be used to pass in the light position. */
	private int mLightPosHandle;
	

	public float getmLightPosInEyeSpace(int i) {
		return mLightPosInEyeSpace[i];
	}

	public void setMPointProgramHandle(int mPointProgramHandle2) {
		mPointProgramHandle = mPointProgramHandle2;
	}
	
	public int getmLightPosHandle() {
		return mLightPosHandle;
	}

	public void setmLightPosHandle(int mLightPosHandle) {
		this.mLightPosHandle = mLightPosHandle;
	}

	public int getMPointProgramHandle() {
		return mPointProgramHandle;
	}

	public float getmLightPosInModelSpace(int i) {
		return mLightPosInModelSpace[i];
	}

	public int getmPointProgramHandle() {
		return mPointProgramHandle;
	}

	public void setmPointProgramHandle(int mPointProgramHandle) {
		this.mPointProgramHandle = mPointProgramHandle;
	}

	public float[] getmLightPosInModelSpace() {
		return mLightPosInModelSpace;
	}

	public float[] getmLightPosInWorldSpace() {
		return mLightPosInWorldSpace;
	}

	public float[] getmLightPosInEyeSpace() {
		return mLightPosInEyeSpace;
	}

	public float[] getmLightModelMatrix() {
		return mLightModelMatrix;
	}

	public void setmLightModelMatrix(float[] mLightModelMatrix) {
		this.mLightModelMatrix = mLightModelMatrix;
	}

}
