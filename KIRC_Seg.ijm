run("Close All");
MainRoot = "H:" + File.separator + "Datasets" + File.separator + "TCGA_KIRC" + File.separator + "nationwidechildrens.org_KIRC.diagnostic_images.Level_1.82.9.0" + File.separator;
outputFile = MainRoot + "WSINames.txt"; 
print (outputFile);

string = File.openAsString(outputFile);
xlines = split(string, "\n");
n_xlines = lengthOf(xlines);
xValues=newArray(n_xlines); 

xcoor=newArray(n_xlines);
for (n=0; n<n_xlines; n++){
	xcoor[n] = xlines[n];
	root = MainRoot + xcoor[n] + File.separator ;
	print (root);
	images = getFileList(root);
	print("Number of Images: " + images.length);
	
	Seg_Dir = root + "Segmentation_Fiji" + File.separator;
	if(!File.exists(Seg_Dir)){
		File.makeDirectory(Seg_Dir);
		print("Directory for Segmentation is created: " + Seg_Dir);
	}

	for( i=0; i<images.length; i++){
		imageName = substring( images[i], 0, lengthOf(images[i])-5 );
		imageExt = substring( images[i], lengthOf(images[i])-5, lengthOf(images[i]) );
		//print("Image Name: " + imageName + "\t Image Extension: " + imageExt);
	
		if( File.exists(root + images[i]) ){
			if( toUpperCase(imageExt) == ".TIFF" || toUpperCase(imageExt) == ".TIF" || toUpperCase(imageExt) == ".BMP" || toUpperCase(imageExt) == ".PNG" ){
		
				open( root+images[i] );
				run("RGB Stack");
				run("Convert Stack to Images");
				selectWindow("Red");
			
				run("Duplicate...", "title=Seg");
				run("Gaussian Blur...", "sigma=1.5");
				//run("Robust Automatic Threshold Selection", "noise=10 lambda=3 min=100");
				setAutoThreshold("Default dark");
				//setOption("BlackBackground", true);
				//run("Threshold...");
				setThreshold(0, 125);
				run("Convert to Mask");
				run("Fill Holes");
				run("Watershed");
				run("Options...", "iterations=2 count=1 black edm=Overwrite do=Open");
				
				//run("Set Measurements...", "  redirect=None decimal=0");
				run("Set Measurements...", "area mean standard modal min perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack redirect=None decimal=3");
				run("Analyze Particles...", "size=100-3000 show=Masks");
				run("Invert LUT");
				rename("Segmented");
	
				run("Duplicate...", "title=Segmented2");
				saveAs( "Tiff", Seg_Dir + imageName + "_Binary" + ".TIFF");
			
				saveAs("Results", Seg_Dir+imageName+".csv");
				run("Clear Results");
				close("Results");

				//run("Merge Channels...", "c1=[Red] c2=[Green] c3=[Blue] c5=[Segmented] keep");
				//saveAs( "Tiff", Seg_Dir + imageName + "_Detection" + ".TIF" );

				run("Close All");
			}
		}
	}
}
