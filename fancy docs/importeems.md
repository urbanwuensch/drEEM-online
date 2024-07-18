<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# importeems #
Import measurement files and create drEEMdataset object



## Syntax
### [dataout = importeems(filePattern)](#syntax1) ###
### [dataout = importeems( ___ , Name,Value)](#syntax2) ###



## Description ##
[comment]: <> (The description gives an explanation on different function syntax versions above)
### [dataout](#dataout) = importeems ([filePattern](#data)) <a name="syntax1"></a>
returns a drEEMdataset class object that contains excitation-emission matrices.


### [dataout](#dataout) = importeems([ ___ ](#data), [Name,Value](#options))<a name="syntax2"></a>
specifies optional pair of arguments using one or more name-value arguments. For example, you can specify whether the wavelength data is stored in columns or rows.


## Input arguments ##
#### filePattern  - Pattern of the measurement data   <a name="data"></a> <br> Data Type: char | string

A text specifying the pattern of the files to be imported. This can include wildcard characters (*) to match multiple files. The pattern will be completely removed from the sample name after import to leave only the non-repeating filename information. For example `S001PEM.dat` will be known as `S001` in the produced dataset. <br>


Example: `'*.csv'`<br>
Example: `'* - Waterfall Plot Samples.dat'`

##### Name-Value Arguments  <a name="data"></a>
Specify optional pairs of arguments as `Name1=Value1,...,NameN=ValueN`, where `Name` is the argument name and `Value` is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter. 

Example: `'columnWave', true, 'rowWave', true, 'columnIsExcitation', false, 'NumHeaderLines', 2` specifies that the measurement files contain wavelength information in both columns and rows, where the rows correspond to excitation data and the first 2 rows of data are skipped as headers. 

#### columnWave   - Specify if column data contains wavelength data<br> Data Type: logical | numeric
If `true`, the data in the measurement files are expected to have wavelength information in columns. Default is `true`.<br>

Example: `'columnWave', true` if the wavelength data for the columns exist.<br>
Example: `'columnWave', 1`

#### rowWave    - Specify if row data contains wavelength data<br> Data Type: logical | numeric
If `true`, the data in the measurement files are expected to have wavelength information in rows. Default is `true`.<br>

Example: `'rowWave', false` <br>
Example: `'rowWave', 0`


#### columnIsExcitation - Specify if excitation data is stored in the columns<br> Data Type: logical | numeric
If `true`, the columns represent excitation wavelengths. If `false`, the data matrix will be rotated so that it matches the standard settings in the toolbox. Default is `true`.<br>

Example: `'rowWave', false` <br>
Example: `'rowWave', 0`


#### NumHeaderLines - Specify number of header lines <br> Data Type: numeric
Specifies the number of header lines to skip in each file. Default is `0`.<br>

Example: `'rowWave', 2` <br>

## Output arguments ##
#### dataout   - A drEEMdataset object containing the imported measurement   <a name="data"></a> <br> Data Type: drEEMdataset class object
A drEEMdataset object containing the imported measurement.


## See Also ##

<a href="link.com">importabsorbance</a> | 
<a href="link.com"> Link2 </a> |



## Topics ##