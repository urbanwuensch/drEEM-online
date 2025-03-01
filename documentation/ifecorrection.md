<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# ifecorrection #
Correct the inner filter effects.



## Syntax
### [dataout = ifecorrection(data)](#syntax1) ###
Applies the absorbance based inner filter effect correction
### [ifecorrection(data)](#syntax1) ###
Runs the function in diagnosis mode without output argument. Use this to see how much on average the IFE correction would affect your fluorescence at each wavelength in the EEM.

## Description ##
### [dataout](#varargout) = ifecorrection([data](#varargin)) <a name="syntax1"></a>

The `ifecorrection` implements Absorbance (ABA) Method for correcting fluorescence inner filter effects. The method assumes that EEMs and Absorbance were measured in a square cuvette with standard right-angle geometry. 
> Reference: Parker, C. A.; Barnes, W. J., Some experiments with spectrofluorimeters and filter fluorimeters. Analyst 1957, 82, 606-618.


`ifecorrection` only works on the part of the EEMs in `data` that is covered by absorbance data. In case the `absWave` range is shorter than the EEM range (`Ex` and `Em` in `data`), a message is displayed/will be stored in `history` informing the user of this, but the correction will be carried out on a subset of `data` that have matching EEM and absorbance wavelengths. 
Samples with high absorbance (>2) will be identified and these areas will be set to NaN and will not be used for the correction. A warning for this will be displayed.

An entry will be added to the `history` field of the `data`, detailing the processing options used. If no output argument is specified, the function will overwrite the original `data` in the workspace.


## Input arguments ##
#### data - drEEMdataset for association  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods that contain the absorbance data which will be used for the calculations. If the absorbance data does not exist or consists only of missing numbers an error will be generated.



## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, in which the EEMs (`X`) are accounted for inner filter effects.
If no output argument is specified, the function overwrites the original object in the workspace.




## See Also ##

<a href="link.com">processabsorbance</a> | 
<a href="link.com"> drEEMdataset </a> |
<a href="link.com"> Link3 </a> |


## Topics ##