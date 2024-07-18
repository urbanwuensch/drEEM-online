<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# subtractblanks #
subtract blanks from the samples



## Syntax
### [dataout = subtractblanks(data, blanksdataset)](#syntax1) ###



## Description ##
### [dataout](#varargout) = subtractblanks([data, blanksdataset](#varargin)) <a name="syntax1"></a>

Subtracts EEMs of blank stored in `blanksdataset` from EEMs stored in `data`.
The function `subtractblanks` makes sure the `blanksdataset` and `data`  have the same wavelengths, as this can be the case, especially,
after the `ifecorrection` function has been applied on `data` and some parts are deleted due to lacking absorbance coverage. `subtractblanks` makes sure that the `blanksdataset` will also be cut to be compatible.
Next, if the subtraction was successful, the function will plot the EEMs stored in `data`, `blanksdataset`, and `dataout` at an excitation of 275, where protein-like and humic-like fluorescence signal is likely to be observed, for the user to check the performance of the subtraction.

An entry will be added to the `history` field of the `dataout`. If no output argument is specified, the function will overwrite the original `data` in the workspace.


## Input arguments ##
#### data - drEEMdataset containing the samples  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods that contain the EEMs from which the blanks will be subtracted. 

#### blanksdataset - drEEMdataset containing the blanks  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods that contain the blanks which will be subtracted from the EEMs stored in `data`. 




## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, containing the blanksubtracted data.
If no output argument is specified, the function overwrites the original object in the workspace. `dataout` contains a `history` object containing information with respect to the implemented `subtractblank` function.




## See Also ##

<a href="link.com">ifecorrection</a> | 
<a href="link.com"> drEEMdataset </a> |
<a href="link.com"> Link3 </a> |


## Topics ##