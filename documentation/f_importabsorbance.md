<img src="top right corner logo.png" width="100" height="auto" align="right"/>
# importabsorbance #
Create drEEMdataset from absorbance data
## Syntax
### [dataout=importabsorbance(filePattern)](#syntax1) ###
### [dataout=importabsorbance(filePattern,Name,Value)](#syntax2) ###



## Description ##
### [dataout](#dataout) = importabsorbance([filePattern](#filePattern)) <a name="syntax1"></a>
Import absorbance spectra and create drEEMdataset based on settings that are suitable for e.g. the Horiba AquaLog (with the HJY Export function). For modifications, use the [Name,Value](#options) notation to modify import options.


### [dataout](#dataout) = importabsorbance([filePattern](#filePattern),[Name,Value](#options))<a name="syntax2"></a>
Import absorbance spectra and create drEEMdataset based on custom settings.


## Input arguments ##
#### filePattern  - string patter to recognize files for import   <a name="filePattern"></a>
### character or string array
The function will search for files in the current directory that end with the specified pattern. E.g. `"*PEM.dat"`. The pattern will be completely removed from the sample name after import to leave only the non-repeating filename information. For example `S001PEM.dat` will be known as `S001` in the produced dataset.

##### Name-Value Arguments  <a name="data"></a>
Specify optional pairs of arguments as Name1=Value1,...,NameN=ValueN, where Name is the argument name and Value is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter. 

#### waveColumn  - Wavelength column
### numeric (default: 1)
Specify the column number that contains the wavelegnth information. E.g. `waveColumn=1` if the first column in the file contains the wavelenth information.

#### absColumn  - Absorbance column
### numeric (default: 10)
Specify the column number that contains the absorbance information. E.g. `waveColumn=10` if the 10th column in the file contains the absorbance information. It is assumed that the absorbance is provided per cm.


#### numHeaderLines  - Number of rows to skip in each file
### numeric (default: 0)
Specify how many rows should be skipped	from the top of the file. This can be necessary if a lengthy header is provided in each file.

## Output arguments ##
#### dataout  - drEEMdataset <a name="dataout"></a>
A dataset of the class `drEEMdataset` with standardized contents and automated validation methods.