package com.example.prism3.utils;

import java.io.File;
import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.HashMap;

import org.xmlpull.v1.XmlSerializer;

import com.example.prism3.PrismActivity;

import android.content.Context;
import android.util.Log;
import android.util.Xml;
import android.widget.Toast;

public class XMLBuilder {
	private Writer writer;
	private String absolutePath;
	private final Context context;
	private PrismActivity prismActivity;
	private Integer zone;
	private Integer concentration;
	private String technique;
	private String participant, serie;
	private Float taille;
	private static ArrayList<ArrayList<HashMap>> tasks;

	public XMLBuilder(Context applicationContext, Integer nbSpheres,
			Integer nbDivisions, Float tailleSpheres, String typeSelection, String part, String ser) {
		super();
		context = applicationContext;
		zone = nbDivisions;
		taille = tailleSpheres;
		technique = typeSelection;
		concentration = nbSpheres;
		participant = part;
		serie = ser;
	}

	public void write(ArrayList<ArrayList<HashMap>> data) {

		String root = "/sdcard/Prism";
		File outDir = new File(root);
		tasks = data;

		if (!outDir.isDirectory()) {
			outDir.mkdir();
		}
		try {
			if (!outDir.isDirectory()) {
				throw new IOException(
						"Unable to create directory EZ_time_tracker. Maybe the SD card is mounted?");
			}
			if (!outDir.isDirectory()) {
				outDir.isFile();
			}
			new WriteTask().execute(context, outDir, participant,
					CreateXMLString());
		} catch (IOException e) {
			Log.w("eztt", e.getMessage(), e);
			Toast.makeText(context,
					e.getMessage() + " Unable to write to external storage.",
					Toast.LENGTH_LONG).show();
		}
	}

	public String CreateXMLString() throws IllegalArgumentException,
			IllegalStateException, IOException {
		XmlSerializer xmlSerializer = Xml.newSerializer();
		StringWriter writer = new StringWriter();

		xmlSerializer.setOutput(writer);

		// Start Document
		xmlSerializer.startDocument("UTF-8", true);
		xmlSerializer.setFeature(
				"http://xmlpull.org/v1/doc/features.html#indent-output", true);

		// Open Tag <Expe3DMobile>
		xmlSerializer.startTag("", "Expe3DMobile");
		xmlSerializer.attribute("", "nombrezone", zone.toString());
		xmlSerializer.attribute("", "concentration", concentration.toString());
		xmlSerializer.attribute("", "technique", technique);
		xmlSerializer.attribute("", "participant", participant);
		xmlSerializer.attribute("", "taillesphere", taille.toString());
		xmlSerializer.attribute("", "serie", serie);
		for (ArrayList<HashMap> task : tasks) {
			xmlSerializer.startTag("", "Task");

			for (HashMap log : task) {
				if (log.get("name").equals("Task")) {
					// System.out.println("Task");
					log.remove("name");

					for (Object key : log.keySet()) {
						// System.out.println("attribut Task : " + (String) log.get(key));
						
						xmlSerializer.attribute("", (String) key,
								(String) log.get(key));
					}
				} else {
					if (log.get("name").equals("ListOfSphere")) {
						// System.out.println("ListOfSphere");
						String name = (String) log.get("name");
						xmlSerializer.startTag("", "ListOfSphere");

						ArrayList<HashMap> spheres = new ArrayList<HashMap>();
						spheres = (ArrayList<HashMap>) log.get("spheres");
						// System.out.println("liste de spheres : " +spheres.size());
						
						for (HashMap<String, String> hash : spheres) {
							// System.out.println("Sphere name : " + (String) hash.get("name"));
							Object name1 = hash.get("name");
							xmlSerializer.startTag("", (String) name1);
							hash.remove("name");

							for (Object key1 : hash.keySet()) {
								// System.out.println("Sphere pas name : " + (String) hash.get(key1));
								if (!key1.equals("name"))
									xmlSerializer.attribute("", (String) key1,
											(String) hash.get(key1));
							}
							xmlSerializer.endTag("", (String) name1);
						}
						xmlSerializer.endTag("", "ListOfSphere");

					} else {
						if (log.get("name").equals("ListOfDisplayedSphere")) {

							// System.out.println("ListOfDisplayedSphere");
							String name = (String) log.get("name");
							xmlSerializer.startTag("", "ListOfDisplayedSphere");
							
							for (Object key : log.keySet()) {
								// System.out.println("spheredisplay  name : " + (String) hash.get("name"));
									if (!key.equals("name")&&!key.equals("spheres"))
									xmlSerializer.attribute("",
											(String) key,
											(String) log.get(key));
							}
							
							ArrayList<HashMap> spheres = new ArrayList<HashMap>();
							spheres = (ArrayList<HashMap>) log.get("spheres");
							// System.out.println("diplay : " + spheres.size());
							
							for (HashMap<String, String> hash : spheres) {
								// System.out.println("Autre  name : " + (String) hash.get("name"));
								Object name1 = hash.get("name");
								xmlSerializer.startTag("", (String) name1);

								for (Object key1 : hash.keySet()) {
									// System.out.println("spheredisplay  name : " + (String) hash.get("name"));
										if (!key1.equals("name"))
										xmlSerializer.attribute("",
												(String) key1,
												(String) hash.get(key1));
								}
								xmlSerializer.endTag("", (String) name1);
							}
							xmlSerializer.endTag("", "ListOfDisplayedSphere");

						} else {

							// System.out.println("Ailleur");
							// System.out.println(" name : " + (String) log.get("name"));
							Object name = log.get("name");
							xmlSerializer.startTag("", (String) name);
							log.remove("name");

							for (Object key : log.keySet()) {
								// System.out.println("Attribut key : " +(String)key);
								// System.out.println("Attribut value : " + (String) log.get(key));
								xmlSerializer.attribute("", (String) key,
										(String) log.get(key));
							}
							xmlSerializer.endTag("", (String) name);
						}
					}
				}
			}

			xmlSerializer.endTag("", "Task");
		}
		// end tag <Expe3DMobile>
		xmlSerializer.endTag("", "Expe3DMobile");
		xmlSerializer.endDocument();
		xmlSerializer.flush();
		return writer.toString();
	}

	public Writer getWriter() {
		return writer;
	}

	public String getAbsolutePath() {
		return absolutePath;
	}

}
