pathfile=File.openDialog("Choose the file to Open:"); 
filestring=File.openAsString(pathfile); 
rows=split(filestring, "\n"); 
x=newArray(rows.length); 
y=newArray(rows.length); 
for(i=0; i<rows.length; i++){ 
columns=split(rows[i],"\t"); 
x[i]=parseInt(columns[0]); 
y[i]=parseInt(columns[1]); 
} 

run("Z1 CZI to TIF for Timelapse and Multiview 07012015 SD JH", "experiment=full_coal_2 number=2 angles/views?=4 timepoints=360 illuminations=2 bin=1 bin=1 bin=1 original=/n/regal/rycroft_lab/jordan/full_coal2/full_coal_2.czi choose=/n/regal/rycroft_lab/jordan/full_coal2/");