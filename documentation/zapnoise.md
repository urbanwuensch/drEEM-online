<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# zapnoise #
Set part of emission or excitation spectra from one or more samples to NaN.



## Syntax

### [dataout = zapnoise(data, Sample, EmRange, ExRange)](#syntax1) ###


## Description ##
### [dataout](#varargout) = zapnoise([data, Sample, EmRange, ExRange](#varargin)) <a name="syntax1"></a>

Removes noisy data (set to `NaN`) in the emission range of `EmRange` and excitation range of `ExRange` from specified `Sample`(s), in `data`. <br>
Example: `zapnoise(data, [2:5],[300:350],[200:210])` sets all the values in the emission range of `300` to `350` and excitation range of `200` to `210` for samples `2` to `5` in `data` to `NaN`s.
<br>
Note:The input arguments are **not** Name-Value pairs. This means all the input arguments must be provided for the function.


## Input arguments ##
#### data - drEEMdataset for association  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods.


#### Sample - specify which samples to remove noise from  <a name="varargin"></a> <br> Type:  numeric | Logical
Specify the samples' numbers or a logical array to zap the noise from those samples. `Sample`, when a numerical array, the length of the array must be less than or equal to the total number of samples in the `data` (`data.nSample`); when `Sample` is a logical array the length of the array should be equal to `data.nSample`.<br>
Example: `(__, [1 5], __, __)` to zap the noise from the first and fifth samples.<br>
Example: `(__, contains(data.filelist,'kf')), __, __)` to remove the noise from the samples that their name in the `filelist` field contains character `'kf'`.<br>
Example: `(__, [1: data.nSample], __, __)` to remove the noise from all samples in `data`.

#### EmRange - specify the emission range for zapping <a name="varargin"></a> <br> Type: numeric
Specify the range of emission wavelengths to be zapped from `Sample`. The provided range must be within the emission range of `data`. If only one wavelength is provided (not a range) the function will automatically set the range to two closest neighboring wavelengths around the specified wavelength.<br>

Example: `(__, __, [300 350], __)` to remove emission data between `300` and `350` nm.<br>
Example: `(__, __, 300, __)` to remove emission data between the first emission wavelengths below and above `300` nm.<br>
Example: `(__, __, [min(data.Em):350], __)` to remove emission data between  the first emission wavelength and `350` nm.


#### ExRange - specify the excitation range for zapping <a name="varargin"></a> <br> Type: numeric
Specify the range of excitation wavelengths to be zapped from `Sample`. The provided range must be within the excitation range of `data`. If only one wavelength is provided (not a range) the function will automatically set the range to two closest neighboring wavelengths around the specified wavelength.<br>

Example: `(__, __, __, [400 410])` to remove data between excitation `400` and `410` nm.<br>
Example: `(__, __, __, 400)` to remove data between the first excitation wavelengths below and above `400` nm.<br>
Example: `(__, __, __, [min(data.Ex):max(data.Ex)])` to remove data between  the first and last excitation wavelengths.

## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, containing the zapped data.
The `history` field of the `dataout` contains a summary of the results of the carried-out zapping, including samples numbers, emission and excitation Range that were successfully zapped. 
If no output argument is specified, the function overwrites the original object in the workspace.

Note: If the function `scalesamples` has been used prior to using the `zapnoise` function, the `zapnoise` will automatically perform the zapping on the unscaled dataset. This will ensure the toolbox works smoothly if the scaling is reverted. For more information see `scalesamples` function.


## See Also ##

<a href="link.com">scalesamples</a> | 
<a href="link.com"> subdataset </a> |
<a href="link.com"> Link3 </a> |


## Topics ##