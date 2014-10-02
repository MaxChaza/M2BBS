package com.example.prism3;

import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.HashSet;
import java.util.Iterator;

import android.graphics.Color;
import android.opengl.GLES20;
import android.opengl.Matrix;
import android.util.FloatMath;

import com.example.prism3.utils.Light;
import com.example.prism3.utils.MatrixPrism;
import com.example.prism3.utils.ModelPrism;
import com.threed.jpct.Object3D;
import com.threed.jpct.SimpleVector;

public class Cylinder {

	private static final float TWO_PI = (float) (2 * Math.PI);

	private static int fanTriangleCount;

	private static int stripTriangleCount;

	private static FloatBuffer sideVerticesBuf;
	private static FloatBuffer sideNormalsBuf;
	private static FloatBuffer mSideTextureCoordinates;

	private static FloatBuffer topVerticesBuf;
	private static FloatBuffer topNormalsBuf;
	private static FloatBuffer mTopTextureCoordinates;

	private static FloatBuffer bottomVerticesBuf;
	private static FloatBuffer bottomNormalsBuf;
	private static FloatBuffer mBottomTextureCoordinates;

	/** How many bytes per float. */
	private final int mBytesPerFloat = 4;

	private float radius, originalRadius, length, x, y, z;

	private boolean isVisible;
	private boolean isCreated;
	
	public Cylinder(float xAx, float yAx, float zAx, float rayon, float longueur) {
		x = xAx;
		y = yAx;
		z = zAx;
		radius = rayon;
		originalRadius = rayon;
		length = longueur;
		int sides = 20;

		isVisible = true;
		isCreated = false;

		double dTheta = TWO_PI / sides;

		float[] sideVertices = new float[(sides + 1) * 6];
		float[] sideNormals = new float[(sides + 1) * 6];
		float[] sideTexture = new float[((sides + 1) * 6) * 2 / 3];
		for (int i = 0; i < sideTexture.length; i++) {
			sideTexture[i] = 0;
		}

		int sideVidx = 0;
		int sideNidx = 0;

		float[] topVertices = new float[(sides + 2) * 3];
		float[] topNormals = new float[(sides + 2) * 3];
		float[] topTexture = new float[((sides + 2) * 3) * 2 / 3];
		for (int i = 0; i < topTexture.length; i++) {
			topTexture[i] = 0;
		}

		float[] bottomVertices = new float[(sides + 2) * 3];
		float[] bottomNormals = new float[(sides + 2) * 3];
		float[] bottomTexture = new float[((sides + 2) * 3) * 2 / 3];
		for (int i = 0; i < bottomTexture.length; i++) {
			bottomTexture[i] = 0;
		}
		int capVidx = 3;
		int capNidx = 3;

		topVertices[0] = 0f;
		topVertices[1] = 0f;
		topVertices[2] = .5f;

		topNormals[0] = 0f;
		topNormals[1] = 0f;
		topNormals[2] = 1f;

		bottomVertices[0] = 0f;
		bottomVertices[1] = 0f;
		bottomVertices[2] = -.5f;

		bottomNormals[0] = 1f;
		bottomNormals[1] = 1f;
		bottomNormals[2] = 1f;

		for (float theta = 0; theta <= (TWO_PI + dTheta); theta += dTheta) {

			sideVertices[sideVidx++] = FloatMath.cos(theta); // X

			sideVertices[sideVidx++] = FloatMath.sin(theta); // Y

			sideVertices[sideVidx++] = 0.5f; // Z

			sideVertices[sideVidx++] = FloatMath.cos(theta); // X

			sideVertices[sideVidx++] = FloatMath.sin(theta); // Y

			sideVertices[sideVidx++] = -0.5f; // Z

			float forceLumiere = 7f;

			sideNormals[sideNidx++] = FloatMath.cos(theta) * forceLumiere; // X

			sideNormals[sideNidx++] = FloatMath.sin(theta) * forceLumiere; // Y

			sideNormals[sideNidx++] = 0f; // Z

			sideNormals[sideNidx++] = FloatMath.cos(theta) * forceLumiere; // X

			sideNormals[sideNidx++] = FloatMath.sin(theta) * forceLumiere; // Y

			sideNormals[sideNidx++] = 0f; // Z

			// X

			topVertices[capVidx] = FloatMath.cos(theta);

			bottomVertices[capVidx++] = FloatMath.cos(TWO_PI - theta);

			// Y

			topVertices[capVidx] = FloatMath.sin(theta);

			bottomVertices[capVidx++] = FloatMath.sin(TWO_PI - theta);

			// Z

			topVertices[capVidx] = 0.5f;

			bottomVertices[capVidx++] = -0.5f;

			// Normals

			topNormals[capNidx] = 0f;

			bottomNormals[capNidx++] = 0f;

			topNormals[capNidx] = 0f;

			bottomNormals[capNidx++] = 0f;

			topNormals[capNidx] = 1f;

			bottomNormals[capNidx++] = -1f;

		}

		stripTriangleCount = sideVertices.length / 3;
		fanTriangleCount = sides + 2;

		sideVerticesBuf = ByteBuffer
				.allocateDirect(sideVertices.length * mBytesPerFloat)
				.order(ByteOrder.nativeOrder()).asFloatBuffer();
		sideVerticesBuf.put(sideVertices).position(0);

		sideNormalsBuf = ByteBuffer
				.allocateDirect(sideNormals.length * mBytesPerFloat)
				.order(ByteOrder.nativeOrder()).asFloatBuffer();
		sideNormalsBuf.put(sideNormals).position(0);

		mSideTextureCoordinates = ByteBuffer
				.allocateDirect(sideTexture.length * mBytesPerFloat)
				.order(ByteOrder.nativeOrder()).asFloatBuffer();
		mSideTextureCoordinates.put(sideTexture).position(0);

		topVerticesBuf = ByteBuffer
				.allocateDirect(topVertices.length * mBytesPerFloat)
				.order(ByteOrder.nativeOrder()).asFloatBuffer();
		topVerticesBuf.put(topVertices).position(0);

		topNormalsBuf = ByteBuffer
				.allocateDirect(topNormals.length * mBytesPerFloat)
				.order(ByteOrder.nativeOrder()).asFloatBuffer();
		topNormalsBuf.put(topNormals).position(0);

		mTopTextureCoordinates = ByteBuffer
				.allocateDirect(topTexture.length * mBytesPerFloat)
				.order(ByteOrder.nativeOrder()).asFloatBuffer();
		mTopTextureCoordinates.put(topTexture).position(0);

		bottomVerticesBuf = ByteBuffer
				.allocateDirect(bottomVertices.length * mBytesPerFloat)
				.order(ByteOrder.nativeOrder()).asFloatBuffer();
		bottomVerticesBuf.put(bottomVertices).position(0);

		bottomNormalsBuf = ByteBuffer
				.allocateDirect(bottomNormals.length * mBytesPerFloat)
				.order(ByteOrder.nativeOrder()).asFloatBuffer();
		bottomNormalsBuf.put(bottomNormals).position(0);

		mBottomTextureCoordinates = ByteBuffer
				.allocateDirect(bottomTexture.length * mBytesPerFloat)
				.order(ByteOrder.nativeOrder()).asFloatBuffer();
		mBottomTextureCoordinates.put(bottomTexture).position(0);

	}

	public float getRadius() {
		return radius;
	}

	public void setRadius(float radius) {
		this.radius = radius;
	}

	public float getLength() {
		return length;
	}

	public void setLength(float length) {
		this.length = length;
	}

	public float getZ() {
		return z;
	}

	public void setZ(float z) {
		this.z = z;
	}

	public void drawCylinder(MatrixPrism matrix, Light light, ModelPrism model,
			int texture) {

		// Set the active texture unit to texture unit 0.
		GLES20.glActiveTexture(GLES20.GL_TEXTURE0);

		// Bind the texture to this unit.
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texture);

		// Tell the texture uniform sampler to use this texture in the shader by
		// binding to texture unit 0.
		GLES20.glUniform1i(model.getmTextureUniformHandle(), 0);

		drawSide(matrix, light, model, texture);
		drawBottom(matrix, light, model, texture);
		drawTop(matrix, light, model, texture);

	}

	public void drawSide(MatrixPrism matrix, Light light, ModelPrism model,
			int texture) {
		// Draw sides

		// Pass in the position information
		sideVerticesBuf.position(0);
		GLES20.glVertexAttribPointer(model.getmPositionHandle(),
				ModelPrism.mPositionDataSize, GLES20.GL_FLOAT, false, 0,
				sideVerticesBuf);

		// Pass in the normal information
		sideNormalsBuf.position(0);
		GLES20.glVertexAttribPointer(model.getmNormalHandle(),
				ModelPrism.mNormalDataSize, GLES20.GL_FLOAT, false, 0,
				sideNormalsBuf);

		mSideTextureCoordinates.position(0);
		GLES20.glVertexAttribPointer(model.getmTextureCoordinateHandle(),
				ModelPrism.mTextureCoordinateDataSize, GLES20.GL_FLOAT, false,
				0, mSideTextureCoordinates);
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

		GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, stripTriangleCount);
	}

	public void drawTop(MatrixPrism matrix, Light light, ModelPrism model,
			int texture) {
		// Pass in the position information
		topVerticesBuf.position(0);
		GLES20.glVertexAttribPointer(model.getmPositionHandle(),
				ModelPrism.mPositionDataSize, GLES20.GL_FLOAT, false, 0,
				topVerticesBuf);

		// Pass in the normal information
		topNormalsBuf.position(0);
		GLES20.glVertexAttribPointer(model.getmNormalHandle(),
				ModelPrism.mNormalDataSize, GLES20.GL_FLOAT, false, 0,
				topNormalsBuf);

		mTopTextureCoordinates.position(0);
		GLES20.glVertexAttribPointer(model.getmTextureCoordinateHandle(),
				ModelPrism.mTextureCoordinateDataSize, GLES20.GL_FLOAT, false,
				0, mTopTextureCoordinates);
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

		GLES20.glDrawArrays(GLES20.GL_TRIANGLE_FAN, 0, fanTriangleCount);

	}

	public void drawBottom(MatrixPrism matrix, Light light, ModelPrism model,
			int texture) {
		// Pass in the position information
		bottomVerticesBuf.position(0);
		GLES20.glVertexAttribPointer(model.getmPositionHandle(),
				ModelPrism.mPositionDataSize, GLES20.GL_FLOAT, false, 0,
				bottomVerticesBuf);

		// Pass in the normal information
		bottomNormalsBuf.position(0);
		GLES20.glVertexAttribPointer(model.getmNormalHandle(),
				ModelPrism.mNormalDataSize, GLES20.GL_FLOAT, false, 0,
				bottomNormalsBuf);

		mBottomTextureCoordinates.position(0);
		GLES20.glVertexAttribPointer(model.getmTextureCoordinateHandle(),
				ModelPrism.mTextureCoordinateDataSize, GLES20.GL_FLOAT, false,
				0, mBottomTextureCoordinates);

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

		GLES20.glDrawArrays(GLES20.GL_TRIANGLE_FAN, 0, fanTriangleCount);

	}

	public HashSet<MaSphere> collateCylinder(HashSet<MaSphere> listEntrante) {
		HashSet<MaSphere> listSortante = new HashSet<>();
		for (MaSphere maSphere : listEntrante) {
			if (Math.sqrt(Math.pow((this.x - maSphere.getX()), 2)
					+ Math.pow((this.y - maSphere.getY()), 2)) <= this.radius
					+ maSphere.getRayon()) {
				listSortante.add(maSphere);
			}
		}
		return listSortante;
	}

	public boolean isCollateCylinderAndCible(MaSphere cible) {
		return Math.sqrt(Math.pow((this.x - cible.getX()), 2)
					+ Math.pow((this.y - cible.getY()), 2)) <= this.radius
					+ cible.getRayon();
	}

	public boolean isVisible() {
		return isVisible;
	}

	public void setVisible(boolean isVisible) {
		this.isVisible = isVisible;
	}

	public boolean isCreated() {
		return isCreated;
	}

	public void setCreated(boolean isCreated) {
		this.isCreated = isCreated;
	}

	public void setX(float x2) {
		x = x2;
	}

	public void setY(float y2) {
		y = y2;
	}

	public float getX() {
		return x;
	}

	public float getY() {
		return y;
	}

	public float getOriginalRadius() {
		return originalRadius;
	}
	
}
