package com.example.prism3.utils;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.List;

public class SphereModel {
	/**
	 * Maximum allowed depth. Precision of spheres
	 */

	private static final int MAXIMUM_ALLOWED_DEPTH = 5;

	/**
	 * Used in vertex strip calculations, related to properties of a
	 * icosahedron.
	 */
	public static final int VERTEX_MAGIC_NUMBER = 5;

	/** How many bytes per float. */
	public static final int mBytesPerFloat = 4;

	/** Each vertex is made up of 3 points, x, y, z. */
	public static final int AMOUNT_OF_NUMBERS_PER_VERTEX_POINT = 3;

	/**
	 * Each texture point is made up of 2 points, x, y (in reference to the
	 * texture being a 2D image).
	 */
	// private static final int AMOUNT_OF_NUMBERS_PER_TEXTURE_POINT = 2;

	/** Buffer holding the vertices. */
	private final List<FloatBuffer> mSphereBuffer = new ArrayList<FloatBuffer>();

	/** The vertices for the sphere. */
	private final List<float[]> mSpheres = new ArrayList<float[]>();

	/** Total number of strips for the given depth. */
	private final int mTotalNumStrips;

	private int depth;

	public SphereModel(int de) {
		depth = de;
		// Clamp depth to the range 1 to MAXIMUM_ALLOWED_DEPTH;
		final int d = Math.max(1, Math.min(MAXIMUM_ALLOWED_DEPTH, depth));

		// Calculate basic values for the sphere.
		this.mTotalNumStrips = Maths.power(2, d - 1) * VERTEX_MAGIC_NUMBER;

		final int numVerticesPerStrip = Maths.power(2, d) * 3;
		final double altitudeStepAngle = Maths.ONE_TWENTY_DEGREES
				/ Maths.power(2, d);
		final double azimuthStepAngle = Maths.THREE_SIXTY_DEGREES
				/ this.mTotalNumStrips;
		double x, y, z, h, altitude, azimuth;

		for (int stripNum = 0; stripNum < this.mTotalNumStrips; stripNum++) {
			// Setup arrays to hold the points for this strip.
			final float[] vertices = new float[numVerticesPerStrip
					* ModelPrism.mPositionDataSize + numVerticesPerStrip
					* ModelPrism.mNormalDataSize + numVerticesPerStrip
					* ModelPrism.mTextureCoordinateDataSize]; // NOPMD
			// final float[] vertices = new float[numVerticesPerStrip
			// * NUM_FLOATS_PER_VERTEX + numVerticesPerStrip
			// * NUM_FLOATS_PER_TEXTURE]; // NOPMD
			int vertexPos = 0;
			// Calculate position of the first vertex in this strip.
			altitude = Maths.NINETY_DEGREES;
			azimuth = stripNum * azimuthStepAngle;
			// float lightForce = 10f;
			// Draw the rest of this strip.
			for (int vertexNum = 0; vertexNum < numVerticesPerStrip; vertexNum += 2) {
				// First point - Vertex.
				y = Math.sin(altitude);
				h = Math.cos(altitude);
				z = h * Math.sin(azimuth);
				x = h * Math.cos(azimuth);
				vertices[vertexPos++] = (float) x;
				vertices[vertexPos++] = (float) y;
				vertices[vertexPos++] = (float) z;

				float forceLumiere = 5f;
				// Normal of point
				vertices[vertexPos++] = (-((float) 0 - (float) x))
						* forceLumiere;
				vertices[vertexPos++] = (-((float) 0 - (float) y))
						* forceLumiere;
				vertices[vertexPos++] = (-((float) 0 - (float) z))
						* forceLumiere;

				// First point - Texture.
				vertices[vertexPos++] = (float) (1 - azimuth
						/ Maths.THREE_SIXTY_DEGREES);
				vertices[vertexPos++] = (float) (1 - (altitude + Maths.NINETY_DEGREES)
						/ Maths.ONE_EIGHTY_DEGREES);

				// Second point - Vertex.
				altitude -= altitudeStepAngle;
				azimuth -= azimuthStepAngle / 2.0;
				y = Math.sin(altitude);
				h = Math.cos(altitude);
				z = h * Math.sin(azimuth);
				x = h * Math.cos(azimuth);
				vertices[vertexPos++] = (float) x;
				vertices[vertexPos++] = (float) y;
				vertices[vertexPos++] = (float) z;

				// Normal of point
				vertices[vertexPos++] = (-((float) 0 - (float) x))
						* forceLumiere;
				vertices[vertexPos++] = (-((float) 0 - (float) y))
						* forceLumiere;
				vertices[vertexPos++] = (-((float) 0 - (float) z))
						* forceLumiere;

				// Second point - Texture.
				vertices[vertexPos++] = (float) (1 - azimuth
						/ Maths.THREE_SIXTY_DEGREES);
				vertices[vertexPos++] = (float) (1 - (altitude + Maths.NINETY_DEGREES)
						/ Maths.ONE_EIGHTY_DEGREES);

				azimuth += azimuthStepAngle;
			}

			this.mSpheres.add(vertices);

			ByteBuffer byteBuffer = ByteBuffer
					.allocateDirect(numVerticesPerStrip
							* ModelPrism.mPositionDataSize * Float.SIZE
							+ numVerticesPerStrip * ModelPrism.mNormalDataSize
							* Float.SIZE + numVerticesPerStrip
							* ModelPrism.mTextureCoordinateDataSize
							* Float.SIZE);
			byteBuffer.order(ByteOrder.nativeOrder());
			FloatBuffer fb = byteBuffer.asFloatBuffer();
			fb.put(this.mSpheres.get(stripNum));
			fb.position(0);
			this.mSphereBuffer.add(fb);
		}
	}

	public int getmTotalNumStrips() {
		return mTotalNumStrips;
	}

	public List<FloatBuffer> getmSphereBuffer() {
		return mSphereBuffer;
	}

	public List<float[]> getmSpheres() {
		return mSpheres;
	}

}
