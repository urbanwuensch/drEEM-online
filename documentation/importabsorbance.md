 <img src="top right corner logo.png" width="100" height="auto" align="right"/>

# importabsorbance #
Import absorbance measurement files and create drEEMdataset object



## Syntax
### [dataout = importabsorbance(filePattern)](#syntax1) ###
### [dataout = importabsorbance( ___ , Name,Value)](#syntax2) ###



## Description ##
[comment]: <> (The description gives an explanation on different function syntax versions above)
### [dataout](#dataout) = importabsorbance ([filePattern](#data)) <a name="syntax1"></a><br>
returns a drEEMdataset class object that contains absorbance spectra and   their associated information.

### [dataout](#dataout) = importabsorbance([ ___ ](#data), [Name,Value](#options))<a name="syntax2"></a>
specifies optional pair of arguments using one or more name-value arguments. For example, you can specify the column number that holds the wavelength data or the column that holds the absorbance data.


## Input arguments ##
#### filePattern  - Text pattern to identify files for import   <a name="data"></a> <br> Data Type: char | string

A text specifying the pattern of the files to be imported. This can include wildcard characters (*) to match multiple files. The pattern will be completely removed from the sample name after import to leave only the non-repeating filename information. For example `S001PEM.dat` will be known as `S001` in the produced dataset.
<br>

Example: `'*.csv'`<br>
Example: `'* - Abs Spectra Graphs.dat'`

##### Name-Value Arguments  <a name="data"></a>
Specify optional pairs of arguments as `Name1=Value1,...,NameN=ValueN`, where Name is the argument name and Value is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter. 

Example: `'waveColumn', 1, 'AbsorbanceColumn', 10, 'NumHeaderLines', 2` specifies that the measurement files contain the wavelength information and absorbance data in the first and tenth columns, respectively and the first 2 rows of data are skipped as headers. 

#### waveColumn   - Specify which column of data contains wavelength data<br> Data Type: numeric
The wavelength data in the measurement files are expected to be found in the specified column. Default is column `1`.<br>


Example: `'columnWave', 1` if the first column contains the wavelength information.

#### AbsorbanceColumn    - which column of data contains absorbance data<br> Data Type: numeric
Specify which column of data in the measurement files contains the absorbance data. Default is column `10`.<br>


Example: `'AbsorbanceColumn', 10` if the tenth column contains the absorbance data.


#### NumHeaderLines - Specify number of header lines <br> Data Type: numeric
Specify the number of  lines (rows) to skip from the top in each file. Default is `0`.<br>

Example: `'rowWave', 2` to remove the first 2 rows of each file<br>

## Output arguments ##
#### dataout   - A drEEMdataset object containing the imported measurement   <a name="data"></a> <br> Data Type: drEEMdataset class object
A drEEMdataset class object containing the imported absorbance data with standardized fields and automated validation methods.


## See Also ##

<a href="link.com">importeems</a> | 
<a href="link.com"> Link2 </a> |



## Topics ##