<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# processabsorbance #
Correct baseline drift in absorbance data, extrapolate to longer wavelength, zero out the negative values and plot the results.



## Syntax
### [dataout = processabsorbance(data)](#syntax1) ###
### [dataout = processabsorbance( ___ , Name,Value)](#syntax1) ###


## Description ##
### [dataout](#varargout) = processabsorbance([data](#varargin)) <a name="syntax1"></a>

The `processabsorbance` function reads `absorbance` values from `data` and performs multiple processes on the data, e.g. baseline drift correction, extrapolating the longer wavelength (needed for inner filter effects correction) and setting out the negative values to zeroes, in the stated order. If extrapolation is requested, baseline correction will be carried out both prior and after the extrapolation to ensure data quality. 
If no option is specified, the function will use the default values for processing. When the processing is finished, the function will plot the original absorbance data, the extrapolated data, and the final processed data in one figure.<br>
An entry will be added to the `history` field of the `data`, detailing the processing options used. If no output argument is specified, the function will overwrite the original `data` in the workspace.


>
### [dataout](#varargout) = processabsorbance([ ___ , Name,Value](#varargin)) <a name="syntax1"></a>

specifies additional options using one or more name-value pair arguments. For example, you can specify if a baseline correction must be performed, and whether the absorbance data must be extrapolate or not. <br>
Example: `data = processabsorbance(data,'correctBase',false)` to skip the baseline correction step. 

## Input arguments ##
#### data - drEEMdataset for absorbance treatment  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods that contain the absorbance data. If the absorbance data does not exist or consists only of missing numbers an error will be generated.

##### Name-Value Arguments  <a name="data"></a>
Specify optional pairs of arguments as `Name1=Value1,...,NameN=ValueN`, where `Name` is the argument name and `Value` is the corresponding value. Name-value arguments must appear after other arguments, `data` in this case, but the order of the pairs does not matter. 

Example: `'correctBase', true, 'baseWave', 650, 'zero', true, 'extrapolate', false` specifies that function is expected to perform baseline correction using the wavelengths greater than `650` for its calculations, to set out negative values to zero and finally, extrapolate the data to longer wavelengths that are needed for inner filter effects correction.


#### correctBase - specify if baseline correction is needed  <a name="varargin"></a> <br> Type:  numeric | logical
Indicates if the baseline correction should be performed. Default value is `true`.
The baseline correction is applied using the mean absorbance beyond the specified or default `baseWave`




#### baseWave - Wavelength value   <a name="varargin"></a> <br> Type: numeric
Specify the wavelength from which the absorbance data is used for baseline correction. Default value is `590`.

#### zero - specify if negative values should be set to zero   <a name="varargin"></a> <br> Type: numeric | logical
If `true` the negative values will be set to zeroes.
Default is `false`


#### extrapolate - specify if data should be extrapolated to longer wavelengths <a name="varargin"></a> <br> Type: numeric | logical
If `true`, the function performs a non-linear fit of the absorbance data (`b1*exp(b2/1000*(350-lambda))+b3`) to model the exponential absorbance spectra, based on (c) Stedmon 2001, and extrapolate it to cover the wavelength range needed for EEM data.
Default is `true`




## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, in which the absorbance data is updated with the new data processed according to the specified options (these `options` are stored in the `history` field of the `data`). If no output argument is specified, the function overwrites the original object in the workspace.




## See Also ##

<a href="link.com">importabsorbance</a> | 
<a href="link.com"> drEEMdataset </a> |
<a href="link.com"> Link3 </a> |


## Topics ##