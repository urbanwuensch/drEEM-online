<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# ramancalibration #
Calibrate fluorescence signal by the division of Raman scatter peak area.



## Syntax
### [dataout = ramancalibration(data, blanksdataset)](#syntax1) ###
### [dataout = ramancalibration( ___ , Name,Value)](#syntax1) ###


## Description ##
### [dataout](#varargout) = ramancalibration([data, blanksdataset](#varargin)) <a name="syntax1"></a>

The `ramancalibration` function calibrates the fluorescence signal in `data` by the division of Raman scatter peak area at excitation=`ExWave` obtained from the blanks in `blanksdataset`.<br> The function computes the Signal-to-Background Ratio (SNB) by comparing the Raman peak to the background signal in `blanksdataset`, which will be saved in the `history` object of the `dataout`. <br>An entry will be added to the `history` field of the `data`, detailing the processing options used, including the excitation wavelength, integration range, Raman area, and baseline area. If no output argument is specified, the function will overwrite the original `data` in the workspace.

[comment]  I could not get to save SNB yet!

>
### [dataout](#varargout) = ramancalibration([ ___ , Name,Value](#varargin)) <a name="syntax1"></a>

specifies additional options using one or more name-value pair arguments. For example, you can specify the excitation wavelength for extracting Raman scan using `ExWave` or specify the emission range for the integration of the area under the peak using `iStart`, `iEnd`. <br>
Example: `ramancalibration(Samples, Blanks, 'ExWave', 350, 'iStart', 378, 'plot', true)` to use emission scan at an excitation of `350 nm` in the `Blanks` data set as the Raman scan, integrate the area under the peak starting from `378 nm`, and plotting the results. Other options (`iEnd`) will use their default value.  

## Input arguments ##
#### data - drEEMdataset containing samples  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods that contains samples that calibration will be performed on them.

#### blanksdataset - drEEMdataset for extracting Raman scans  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods that contains blanks. The Raman scans extracted from this dataset will be used for the calibration of the fluorescence data in `data`.

##### Name-Value Arguments  <a name="data"></a>
Specify optional pairs of arguments as `Name1=Value1,...,NameN=ValueN`, where `Name` is the argument name and `Value` is the corresponding value. Name-value arguments must appear after other arguments, `data` and `blankdataset` in this case, but the order of the pairs does not matter. 

Example: `'ExWave', 350, 'iStart', 378, 'iEnd', 424, 'plot', true` specifies that the function is expected to extract the Raman scans at excitation `ExWave`, to integrate under the emission scan from `iStart` to `iEnd` and plot the results.


#### ExWave -  excitation wavelength for extracting Raman scan  <a name="varargin"></a> <br> Type:  numeric
Indicates the excitation wavelength that the function uses to extract Raman scans. Default excitation wavelength is `350`.
The function checks if the specified `ExWave` is present in the `blanksdataset`. If present, the function extracts the corresponding scans directly. Otherwise, it interpolates the data in `blanksdataset` to approximate the scans at the specified excitation wavelength.


#### iStart - emission wavelength to start Raman peak area integration   <a name="varargin"></a> <br> Type: numeric
The function calculates the Raman area and baseline area over the specified integration range starting from `iStart`. Default starting wavelength is `378`.

#### iEnd - emission wavelength to end Raman peak area integration   <a name="varargin"></a> <br> Type: numeric 
The function calculates the Raman area and baseline area over the specified integration range ending at `iEnd`. Default starting wavelength is `424`.


#### plot - specify if the function should generate plots <a name="varargin"></a> <br> Type: numeric | logical
If `true`, the function generates various plots to visualize the Raman emission scans, Raman area, baseline area relative to Raman area, and `SNB` across the dataset.





## Output arguments (optional)##
#### dataout - drEEMdataset with EEMs in Raman units  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, in which the fluorescence signal is calibrated to Raman area according to the specified options (these `options` are stored in the `history` field of the `dataout`). If no output argument is specified, the function overwrites the original object, `data`, in the workspace.




## See Also ##

<a href="link.com">Link1</a> | 
<a href="link.com"> Link2 </a> |
<a href="link.com"> Link3 </a> |


## Topics ##