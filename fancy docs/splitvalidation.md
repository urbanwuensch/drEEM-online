<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# splitvalidation #
Perform split validation on a specific model present in data.



## Syntax

### [dataout = splitvalidation(data, fac)](#syntax1) ###

## Description ##
### [dataout](#varargout) = splitvalidation([data, fac](#varargin)) <a name="syntax1"></a>
The `splitvalidation` function performs split validation on a provided dataset by checking the similarities of excitation and emission spectral loading between different subsets. Two spectra are similar if the similarity index is greater than `0.95`. 
The function checks if the model specified by the number of components `fac` is validated across different `split`s and the model obtained from all of the data, `"overall"` (see `fitparafac` function for options `"overall"` and `"split"`).<br>
If validation check is passes, the function plots the validated models, displaying their loadings and contours, and provides diagnostic plots if validation fails. The function includes detailed error messages to help diagnose why a validation might have failed.

Note: `splitvalidation` checks for the presence of the `"overall"` model and splits. If `"overall`" does not exist the validation will only be performed across splits. But if the `splits` is empty, the function won't be able to perform any validation test and will cause an error.
>

## Input arguments ##
#### data - drEEMdataset for scaling  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods. `data` must contain `splits` and their associated models, obtained from `fitparafac` function with `split` option. However, the presence of the `overall` model for the selected number of components is optional, but recommended.



#### fac - represents the number of components in the model for validation test <a name="varargin"></a> <br> Type:  numeric

Specify the number of parafac components in the model tested for validation.

## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods and updated `history` field if validation is successful. 
If no output argument is specified, the function overwrites the original object in the workspace.


## See Also ##

<a href="link.com">fitparafac</a> | 
<a href="link.com"> drEEMdataset </a> |
<a href="link.com"> Link3 </a> |


## Topics ##