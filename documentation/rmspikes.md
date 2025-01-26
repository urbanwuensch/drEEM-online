<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# rmspikes #
Removes spikes from fluorescence excitation-emission matrix (EEM) data by identifying and interpolating over noisy data points.




## Syntax
### [dataout = rmspikes(data)](#syntax1) ###
### [dataout = rmspikes( ___ , Name,Value)](#syntax1) ###





## Description ##
### [dataout](#varargout) = rmspikes([data](#varargin)) <a name="syntax1"></a>
The function  `rmspikes` automatically extracts the EEM  from `data` and alternatingly deletes parts of the excitation and emission scans. The function then interpolates over the alternatingly-deleted data using `'inpaint'` method. Then calculates differences between the original and interpolated data to identify spikes and according to the default `threshold` removes spikes by setting the corresponding data points to NaN. The function provides warnings if a significant portion of the data is identified as noisy.
`rsmpikes` can optionally interpolate over the removed spikes.



>
### [dataout](#varargout) = rmspikes([ ___ , Name,Value](#varargin)) <a name="syntax1"></a>
specifies additional options using one or more name-value pair arguments. For example, you can specify if `interpoaltion` should be performed or adjust the `thresholdFactor`. <br>
Example: `rmspikes(data, "interpolate",1, "thresholdFactor",100, "details",true, "plot",false)` to remove the spikes using a threshold of `100`, interpolate the removed data, and only plot the `details`. 





## Input arguments ##
#### data - drEEMdataset to remove the spikes from  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods that will be fed to `rmspikes`.



##### Name-Value Arguments  <a name="data"></a>
Specify optional pairs of arguments as `Name1=Value1,...,NameN=ValueN`, where `Name` is the argument name and `Value` is the corresponding value. Name-value arguments must appear after other arguments, `data` in this case, but the order of the pairs does not matter. 

Example: `___,"interpolate",false, "thresholdFactor",40, "details",true` specifies that function is expected to remove spikes with a threshhold factor of `40` without doing an interpolation over the missing values and then plot the `details`. Other arguments will use their default values.


#### thresholdFactor - specify the sensitivity of the function to spikes  <a name="varargin"></a> <br> Type:  numeric
Adjust the sensitivity of the spike detection. A lower values means more sensitivity. Default is `10`. 


#### interpolate - specify if the removed values should be interpolated  <a name="varargin"></a> <br> Type:  numeric | logical
Logical or numeric value to specify if interpolation over removed data points should be performed. Default is `false`.

#### plot - specify if the removal overview plot should be displayed  <a name="varargin"></a> <br> Type:  numeric | logical
Logical or numeric value to specify if a plot showing the results should be generated. The plot shows noise threshold profile along excitation mode and the percentage removal of data in excitation and emission modes.
Default is `true`.

#### details - specify if detailed plots should be displayed  <a name="varargin"></a> <br> Type:  numeric | logical
Logical or numeric value to specify if detailed diagnostic plots should be shown for each sample. This plot depicts original and final EEMs, original EEM with marked removal points and, finally, the difference between original data and smoothed data.
Default is `false`.




## Output arguments (optional)##
#### dataout - drEEMdataset with removed spikes  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, in which the spikes are removed according to the specified options (these `options` are stored in the `history` field of the `dataout`). If no output argument is specified, the function overwrites the original object, `data`, in the workspace.

## Algorithms##


1. **'inpaint'** interpolation method applies del^2 over the entire array, then drops those parts of the array which do not have any contact with NaNs. '`inpaint'` uses a least squares approach, but it does not modify known values. In the case of small arrays, this method is quite fast as it does very little extra work. Extrapolation behavior is linear. See inpaint: Copyright (c) 2017, Damien Garcia.
 
## See Also ##

<a href="link.com">handlescatter</a> | 
<a href="link.com"> Link2 </a> |
<a href="link.com"> Link3 </a> |


## Topics ##