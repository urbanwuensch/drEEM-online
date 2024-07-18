<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# subdataset #
Remove samples, emission spectra or excitation spectra from the dataset.



## Syntax

### [dataout = subdataset(data, outSample)](#syntax1) ###
### [dataout = subdataset(data, outSample, outEm)](#syntax1) ###
### [dataout = subdataset(data, outSample, outEm, outEx)](#syntax1) ###

## Description ##
### [dataout](#varargout) = subdataset([data, outSample](#varargin)) <a name="syntax1"></a>
Remove one or more samples, specified by `outsample`, from `data`. 
>
### [dataout](#varargout) = subdataset([data, outSample, outEm](#varargin)) <a name="syntax1"></a>
Remove one emission wavelength or a range of emission wavelengths, specified by `outEm`, from `data`. <br>
Example: `data.Em==450 & data.Em>600` to remove any emission above `600` nm and also to remove the emission wavelength at `450` nm.
<br>
Note:The input arguments are **not** Name-Value pairs. In the case of using the function to remove `outEm`, this means all the input arguments before `outEm` must be provided for the function. You can use `[]` for `outSample` if you don't want to remove any samples.
>
### [dataout](#varargout) = subdataset([data, outSample, outEm, outEx](#varargin)) <a name="syntax1"></a>
Remove one excitation wavelength or a range of excitation wavelengths, specified by `outEx`, from `data`. <br>
Example: `data.Ex<250 & data.Ex>500` to remove any excitation wavelength below and above `250` and `500` nm, respectively.
<br>
Note:The input arguments are **not** Name-Value pairs. In the case of using the function to remove `outEx`, this means all the input arguments before `outEm` must be provided for the function. You can use `[]` for `outSample` and `outEm` if you don't want to remove any samples or emission wavelengths.

## Input arguments ##
#### data - drEEMdataset for association  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods. 

Note: If `data` contains parafac models in `data.models`, the models will be deleted as they will no longer correspond to the models obtained from the modified `data`.



#### outSample - specify which samples to remove  <a name="varargin"></a> <br> Type:  numeric | logical
Specify the indices of samples to be excluded from the dataset. Must be less than or equal to the total number of samples in the `data` (`data.nSample`).
If a logical array is provided, the length of the array should match the number of samples in the `data`.
Default value is `[]`, removing no samples.<br>
Example: `subdataset(data, [1 5])` to remove the first and fifth samples.<br>
Example: `subdataset(data, contains(data.filelist,'kf'))` to remove samples that their name in the `filelist` field contains character `'kf'`.


#### outEm - specify which emission spectra to remove <a name="varargin"></a> <br> Type: numeric | logical
Specify indices of emission wavelengths to be excluded from the dataset. Length of the input logical array must be less than or equal to the total number of emission wavelengths in the dataset (`data.nEm`). Default is `[]`.<br>
Note: Wavelengths themselves should not be provided, only their indices.<br>
Example: `subdataset(data, [], data.Em==450)` to remove emission spectrum at emission wavelength `450` nm.<br>
Example: `subdataset(data, [], data.Em==450 & data.Em>600)` to remove emission spectrum at emission wavelength `450` nm and all the emission spectra with wavelengths greater than `600` nm.




#### outEx - specify which excitation spectra to remove <a name="varargin"></a> <br> Type: numeric | logical
Specify indices of excitation wavelengths to be excluded from the dataset. Length of the input logical array must be less than or equal to the total number of excitation wavelengths in the dataset (`data.nEx`). Default is `[]`.<br>
Note: Wavelengths themselves should not be provided, only their indices.<br>
Example: `subdataset(data, [], [], data.Ex==325)` to remove excitation spectrum at excitation wavelength `325` nm.<br>
Example: `subdataset(data, [], [], data.Ex<325 & data.Ex>500)` to remove excitation spectra with wavelengths less than `325` nm and all the excitation spectra with wavelengths greater than `500` nm.

## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, containing the subsetted dataset with specified samples, emission, and excitation wavelengths removed.
The `history` field of the `dataout` contains a summary of the results of the carried-out subsetting, including which sample, emission and excitation wavelengths were successfully removed. 
If no output argument is specified, the function overwrites the original object in the workspace.

Note: If the function `scalesamples` has been used prior to using the `subdataset`, the `subdataset` will automatically perform the subsetting on the unscaled dataset. This will ensure the toolbox works smoothly if the scaling is reverted. For more information see `scalesamples` function.


## See Also ##

<a href="link.com">scalesamples</a> | 
<a href="link.com"> drEEMdataset </a> |
<a href="link.com"> Link3 </a> |


## Topics ##