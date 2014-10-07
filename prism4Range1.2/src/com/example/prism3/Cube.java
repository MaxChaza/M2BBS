package com.example.prism3;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

import android.mtp.MtpObjectInfo;
import android.opengl.GLES20;
import android.opengl.Matrix;

import com.example.prism3.utils.Light;
import com.example.prism3.utils.MatrixPrism;
import com.example.prism3.utils.ModelPrism;

public class Cube {
	/** Store our model data in a float buffer. */
	private final FloatBuffer mCubePositions;
	private final FloatBuffer mCubeNormals;
	private final FloatBuffer mCubeTextureCoordinates;

	/** How many bytes per float. */
	private final int mBytesPerFloat = 4;

	private float facteurX, facteurScale;
	private float x, y, z;

	private int nbFaces;

	public Cube(float x, float y, float z, float fX, float fScale) {
		facteurX = fX;
		facteurScale = fScale;
		float[] cubePositionData = {
				// In OpenGL counter-clockwise winding is default. This means
				// that when we look at a triangle,
				// if the points are counter-clockwise we are looking at the
				// "front". If not we are looking at
				// the back. OpenGL has an optimization where all back-facing
				// triangles are culled, since they
				// usually represent the backside of an object and aren't
				// visible anyways.

				// Back face
				-1.0f, 1.5f, 1.5f, -1.0f, -1.5f, 1.5f, 1.0f, 1.5f, 1.5f, -1.0f,
				-1.5f, 1.5f, 1.0f, -1.5f, 1.5f,
				1.0f,
				1.5f,
				1.5f,

				// Right face
				1.0f, 1.5f, -1.5f, 1.0f, -1.5f, -1.5f, 1.0f, 1.5f, 1.5f, 1.0f,
				-1.5f, -1.5f, 1.0f, -1.5f, 1.5f, 1.0f,
				1.5f,
				1.5f,

				// Left face
				-1.0f, 1.5f, 1.5f, -1.0f, -1.5f, 1.5f, -1.0f, 1.5f, -1.5f,
				-1.0f, -1.5f, 1.5f, -1.0f, -1.5f, -1.5f, -1.0f, 1.5f,
				-1.5f,

				// Bottom face
				-1.0f, -1.5f, -1.5f, -1.0f, -1.5f, 1.5f, 1.0f, -1.5f, -1.5f,
				-1.0f, -1.5f, 1.5f, 1.0f, -1.5f, 1.5f, 1.0f, -1.5f, -1.5f,

				// Top face
				1.0f, 1.5f, -1.5f, 1.0f, 1.5f, 1.5f, -1.0f, 1.5f, -1.5f, 1.0f,
				1.5f, 1.5f, -1.0f, 1.5f, 1.5f, -1.0f, 1.5f, -1.5f };

		nbFaces = cubePositionData.length;
	

		// X, Y, Z
		// The normal is used in light calculations and is a vector which points
		// orthogonal to the plane of the surface. For a cube model, the normals
		// should be orthogonal to the points of each face.
		final float[] cubeNormalData = {
				// Back face
				0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f,
				0.0f, -1.0f, 0.0f, 0.0f, -1.0f,
				0.0f,
				0.0f,
				-1.0f,

				// Right face
				-1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f,
				0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f,
				0.0f,
				0.0f,

				// Left face
				1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f,
				0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f,
				0.0f,

				// Bottom face
				0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
				1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f,

				// Top face
				0.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f,
				-1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f };

		// S, T (or X, Y)
		// Texture coordinate data.
		// Because images have a Y axis pointing downward (values increase as
		// you move down the image) while
		// OpenGL has a Y axis pointing upward, we adjust for that here by
		// flipping the Y axis.
		// What's more is that the texture coordinates are the same for every
		// face.
		final float[] cubeTextureCoordinateData = {
				// Front face
				0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
				1.0f,
				1.0f,
				1.0f,
				0.0f,

				// Right face
				0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f,
				1.0f,
				1.0f,
				0.0f,

				// Left face
				0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,
				1.0f,
				0.0f,

				// Top face
				0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,
				1.0f, 0.0f,

				// Bottom face
				0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,
				1.0f, 0.0f };

		// Initialize the buffers.
		mCubePositions = ByteBuffer
				.allocateDirect(cubePositionData.length * mBytesPerFloat)
				.order(ByteOrder.nativeOrder()).asFloatBuffer();
		mCubePositions.put(cubePositionData).position(0);

		mCubeNormals = ByteBuffer
				.allocateDirect(cubeNormalData.length * mBytesPerFloat)
				.order(ByteOrder.nativeOrder()).asFloatBuffer();
		mCubeNormals.put(cubeNormalData).position(0);

		mCubeTextureCoordinates = ByteBuffer
				.allocateDirect(
						cubeTextureCoordinateData.length * mBytesPerFloat)
				.order(ByteOrder.nativeOrder()).asFloatBuffer();
		mCubeTextureCoordinates.put(cubeTextureCoordinateData).position(0);
	}

	/**
	 * Draws a cube.
	 */
	public void drawCube(MatrixPrism matrix, Light light, ModelPrism model,
			int texture) {

		// Set the active texture unit to texture unit 0.
		GLES20.glActiveTexture(GLES20.GL_TEXTURE0);

		// Bind the texture to this unit.
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texture);

		// Tell the texture uniform sampler to use this texture in the shader by
		// binding to texture unit 0.
		GLES20.glUniform1i(model.getmTextureUniformHandle(), 0);

		// Pass in the position information
		mCubePositions.position(0);
		GLES20.glVertexAttribPointer(model.getmPositionHandle(),
				ModelPrism.mPositionDataSize, GLES20.GL_FLOAT, false, 0,
				mCubePositions);

		// Pass in the normal information
		mCubeNormals.position(0);
		GLES20.glVertexAttribPointer(model.getmNormalHandle(),
				ModelPrism.mNormalDataSize, GLES20.GL_FLOAT, false, 0,
				mCubeNormals);

		// Pass in the texture coordinate information
		mCubeTextureCoordinates.position(0);
		GLES20.glVertexAttribPointer(model.getmTextureCoordinateHandle(),
				ModelPrism.mTextureCoordinateDataSize, GLES20.GL_FLOAT, false,
				0, mCubeTextureCoordinates);
		// This multiplies the view matrix by the model matrix, and stores the
		// result in the MVP matrix
		// (which currently contains model * view).
		Matrix.multiplyMM(matrix.getmMVPMatrix(), 0, matrix.getmViewMatrix(),
				0, matrix.getmModelMatrix(), 0);

		// Pass in the modelview matrix.
		GLES20.glUniformMatrix4fv(model.getmMVMatrixHandle(), 1, false,
				matrix.getmMVPMatrix(), 0);

		// This multiplies the modelview matrix by the projection matrix, and
		// stores the result in the MVP matrix
		// (which now contains model * view * projection).
		Matrix.multiplyMM(matrix.getmTemporaryMatrix(), 0,
				matrix.getmProjectionMatrix(), 0, matrix.getmMVPMatrix(), 0);
		System.arraycopy(matrix.getmTemporaryMatrix(), 0,
				matrix.getmMVPMatrix(), 0, 16);

		// Pass in the combined matrix.
		GLES20.glUniformMatrix4fv(model.getmMVPMatrixHandle(), 1, false,
				matrix.getmMVPMatrix(), 0);

		// Pass in the light position in eye space.
		GLES20.glUniform3f(light.getmLightPosHandle(),
				light.getmLightPosInEyeSpace(0),
				light.getmLightPosInEyeSpace(1),
				light.getmLightPosInEyeSpace(2));

		// Draw the cube.
		GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, nbFaces / 3);
	}
	public float getFacteurX() {
		return facteurX;
	}

	public void setFacteurX(float facteurX) {
		this.facteurX = facteurX;
	}

	public float getFacteurScale() {
		return facteurScale;
	}

	public void setFacteurScale(float facteurScale) {
		this.facteurScale = facteurScale;
	}
	public float getX() {
		return x;
	}

	public void setX(float x) {
		this.x = x;
	}

	public float getY() {
		return y;
	}

	public void setY(float y) {
		this.y = y;
	}

	public float getZ() {
		return z;
	}

	public void setZ(float z) {
		this.z = z;
	}
}
