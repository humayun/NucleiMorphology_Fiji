run("Close All");
inDirectory = "R:" + File.separator + "Beck Lab" + File.separator + "RCC" + File.separator + "AllImages" + File.separator;
outDirectory = "R:" + File.separator + "Beck Lab" + File.separator + "RCC" + File.separator + "AllImages" + File.separator + "Segmentation2" + File.separator;
if(!File.exists(outDirectory)){
	File.makeDirectory(outDirectory);
	print("Directory for Segmentation is created: " + outDirectory);
}

images = getFileList(inDirectory);
print("Number of Images: " + images.length);

for( i=494; i<images.length; i++){
	imageName = substring( images[i], 0, lengthOf(images[i])-4 );
	imageExt = substring( images[i], lengthOf(images[i])-4, lengthOf(images[i]) );

	if( File.exists(inDirectory + images[i]) ){
		if( toUpperCase(imageExt) == ".TIF" || toUpperCase(imageExt) == ".TIFF" || toUpperCase(imageExt) == ".JPEG" || toUpperCase(imageExt) == ".BMP" || toUpperCase(imageExt) == ".PNG" ){
		
			print("Segmenting image: " + imageName + "\tImage Number: " + i+1);
	
			open( inDirectory+images[i] );

			//run("Color Threshold...");

			min=newArray(3);
			max=newArray(3);
			filter=newArray(3);
			a=getTitle();
			run("HSB Stack");
			run("Convert Stack to Images");
			selectWindow("Hue");
			rename("0");
			selectWindow("Saturation");
			rename("1");
			selectWindow("Brightness");
			rename("2");
			min[0]=0;
			max[0]=255;
			filter[0]="pass";
			min[1]=0;
			max[1]=255;
			filter[1]="pass";
			min[2]=171;
			max[2]=255;
			filter[2]="pass";
			for (j=0;j<3;j++){
			  selectWindow(""+j);
			  setThreshold(min[j], max[j]);
			  run("Convert to Mask");
			  if (filter[j]=="stop")  run("Invert");
			}
			imageCalculator("AND create", "0","1");
			imageCalculator("AND create", "Result of 0","2");
			for (j=0;j<3;j++){
			  selectWindow(""+j);
			  close();
			}
			selectWindow("Result of 0");
			close();
			selectWindow("Result of Result of 0");
			rename(a);

			setOption("BlackBackground", true);
			run("Make Binary");
			run("Fill Holes");
			run("Open");
			run("Watershed");
			run("Set Measurements...", "area circularity decimal=3");
			run("Analyze Particles...", "size=200-2000 pixel circularity=0.20-1.00 show=Masks");
			run("Invert LUT");
			rename("Seg1");
			run("Duplicate...", "title=Seg2");
			
			saveAs( "Png", outDirectory + imageName + "_Binary" + ".png");
	
			open( inDirectory+images[i] );
			run("RGB Stack");
			run("Convert Stack to Images");
				
			run("Merge Channels...", "c1=[Red] c2=[Green] c3=[Blue] c7=[Seg1] keep");
			saveAs( "Png", outDirectory + imageName + "_Overlay" + ".png" );

			run("Clear Results");
			close("Results");
			run("Close All");
		}
	}
}
