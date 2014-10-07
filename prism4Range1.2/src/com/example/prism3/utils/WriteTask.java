package com.example.prism3.utils;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Environment;
import android.widget.Toast;

public class WriteTask extends AsyncTask<Object, Void, Void> {

	Context context;

	@Override
	protected Void doInBackground(Object... params) {
		context = (Context) params[0];
		Integer i = 1;
		String name = (String) params[2] + i.toString() + ".xml";
		File outputFile = new File((File) params[1], name);
		while(outputFile.exists()){
			i++;
			name = (String) params[2] + i.toString() + ".xml";
			outputFile = new File((File) params[1], name);
		}
		
		BufferedWriter writer;
		try {
			writer = new BufferedWriter(new FileWriter(outputFile));

			writer.write((String) params[3]);

			writer.close();
			context.getApplicationContext().sendBroadcast(
					new Intent(Intent.ACTION_MEDIA_MOUNTED, Uri.parse("file://"
							+ Environment.getExternalStorageDirectory())));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}

	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		Toast.makeText(context.getApplicationContext(),
				"Report successfully saved!", Toast.LENGTH_LONG).show();
	}
}
