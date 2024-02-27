<img src="top right corner logo.png" width="100" height="auto" align="right"/>
# importeems #
Create drEEMdataset from fluorescence data
## Syntax
### [dataout=importeems(filePattern)](#syntax1) ###
### [dataout=importeems(filePattern,Name,Value)](#syntax2) ###



## Description ##
[comment]: <> (The description gives an explanation on different function syntax versions above)
### [dataout](#dataout) = importeems([filePattern](#filePattern)) <a name="syntax1"></a>
Import fluorescence excitation emission matrices and create drEEMdataset based on settings that are suitable for e.g. the Horiba AquaLog (with the HJY Export function). For modifications, use the [Name,Value](#options) notation to modify import options.


### [dataout](#dataout) = importeems([filePattern](#filePattern),[Name,Value](#options))<a name="syntax2"></a>
Import fluorescence excitation emission matrices and create drEEMdataset based on custom settings.


## Input arguments ##
#### filePattern  - string patter to recognize files for import   <a name="filePattern"></a>
### character or string array
The function will search for files in the current directory that end with the specified pattern. E.g. `"*PEM.dat"`. The pattern will be completely removed from the sample name after import to leave only the non-repeating filename information. For example `S001PEM.dat` will be known as `S001` in the produced dataset.

##### Name-Value Arguments  <a name="data"></a>
Specify optional pairs of arguments as Name1=Value1,...,NameN=ValueN, where Name is the argument name and Value is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter. 

#### colWave  - Specify if the files contain wavelength information for each column
### true (default) | numeric
If true, it is assumed that the first imported row contains wavelength information. If numeric, it is assumed that the wavelength information is provided. An error will indicate that the provided numeric array does not match the size of the imported EEMs.

#### colRow  - Specify if the files contain wavelength information for each row
### true (default) | numeric
If true, it is assumed that the first imported column contains wavelength information. If numeric, it is assumed that the wavelength information is provided. An error will indicate that the provided numeric array does not match the size of the imported EEMs.

#### columnIsEx  - Specify if columns indicate excitation wavelengths
### true (default) | false
Use this option to indicate the orientation of the EEMs to be imported. If the option is set to true, columns are assumed to contain excitation scans. If false, columns are assumed to contain emission scans.

#### numHeaderLines  - Number of rows to skip in each file
### numeric (default: 0)
Specify how many rows should be skipped	from the top of the file. This can be necessary if a lengthy header is provided in each file.

## Output arguments ##
#### dataout  - drEEMdataset <a name="dataout"></a>
A dataset of the class `drEEMdataset` with standardized contents and automated validation methods.