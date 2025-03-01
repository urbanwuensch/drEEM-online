<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# scalesamples #
Scale the samples in a dataset.



## Syntax

### [dataout = scalesamples(data, option)](#syntax1) ###


## Description ##
>
### [dataout](#varargout) = scalesamples([data, option](#varargin)) <a name="syntax1"></a>
The `scalesamples` function is used for scaling or revert-scaling the samples in `data` based on the provided `option`. This function performs scaling if `option` is a number between `1` and `50`, carries out reverse scaling if `option` is `'reverse'`, and provides help information for the scaling process if the `option` is set to`'help'`.


## Input arguments ##
#### data - drEEMdataset for scaling  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods. If `data` is already scaled and the user calls a new scaling process, the function will first obtain the unscaled data and use the original unscaled data for rescaling. This ensures that scaling is applied on the original data each time. A warning message will be displayed, informing the user of the issue and the undertaken process to resolve it.


#### option - specify the scaling option  <a name="varargin"></a> <br> Type:  numeric | character

If a numeric value, it must be a positive number less than or equal to `50`, indicating the scaling intensity. The function scales the data based on the standard deviation of the samples, using the `option` as the root value.
If a character vector, it must be either `'reverse'` to reverse the scaling process and obtain the unscaled data or `'help'` to provide help information. `help` will show a diagnosis plot that depicts the peak distributions (for Peaks C, D, M, and T) for different normalization parameters.  

Example: `scalesamples(data, 1.7)` to normalize data to 1.7th root.<br>
Example: `scalesamples(data, 'reverse')` to obtain the original data with no scaling.<br>
Example: `scalesamples(data, 'help')` to see the  the peak distributions for different normalization parameters.

## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, containing the scaled or unscaled dataset.
The `history` field of the `dataout` contains a summary of the used `option`. 
If no output argument is specified, the function overwrites the original object in the workspace.

Note: If the functions `subdataset` or `zapnoise` are used after using the `scalesamples`, the `subdataset` or `zapnoise` will automatically perform the subsetting/zapping on the unscaled dataset. This will ensure the toolbox works smoothly if the scaling is reverted after `subdataset` or `zapnoise` have been called. For more information see `subdataset` and `zapnoise`.


## See Also ##

<a href="link.com">subdataset</a> | 
<a href="link.com"> drEEMdataset </a> |
<a href="link.com"> Link3 </a> |


## Topics ##