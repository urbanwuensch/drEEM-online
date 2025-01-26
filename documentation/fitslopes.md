<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# fitslopes #
Fit slopes to the CDOM absorbance data in a drEEMdataset object.



## Syntax
### [dataout, slopes, metadata, model = fitslopes(data)](#syntax1) ###
### [dataout, slopes, metadata, model = fitslopes( ___ , Name,Value)](#syntax1) ###


## Description ##
### [dataout, slopes, metadata, model](#varargout) = fitslopes([data](#varargin)) <a name="syntax1"></a>

The function `fitslopes` fits slopes to the CDOM absorbance data in `data`. The function returns the processed `data`, `slopes`, `metadata`, and `model` fitting information. The function uses default values of input arguments (see Input arguments section) when options are not specified. <br>
An entry will be added to the `history` field of the `dataout`, detailing the  options used for `fitslopes`. If no output argument is specified, the function will overwrite the original `data` in the workspace.


>
### [dataout, slopes, metadata, model](#varargout) = fitslopes([ ___ , Name,Value](#varargin)) <a name="syntax1"></a>

Specifies additional options using one or more name-value pair arguments. For example, you can specify the Wavelength range for long-range exponential slope fitting using `LongRange` or turn plotting options on or off. <br>
Example: `fitslopes(data,  'plot',false, LongRange=[300 700], rsq=0.9)` to fit slopes using the specified options.

## Input arguments ##
#### data - drEEMdataset containing absorbance data  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods that contains absorbance data.

##### Name-Value Arguments  <a name="data"></a>
Specify optional pairs of arguments as `Name1=Value1,...,NameN=ValueN`, where `Name` is the argument name and `Value` is the corresponding value. Name-value arguments must appear after other arguments, `data` in this case, but the order of the pairs does not matter. 


#### LongRange - specify the range to use for extrapolation   <a name="varargin"></a> <br> Type:  (1,2) numeric
Numeric array specifying Wavelength range for long-range exponential slope fitting. Default is `[300 600]`.


#### rsq - specify R-squared threshold   <a name="varargin"></a> <br> Type: numeric
A scalar numeric specifying R-squared threshold for linear fits. `rsq` must be numeric and less than or equal to `1`.
Default is `0.95`.


#### plot - Flag to plot the results <a name="varargin"></a> <br> Type: numeric | logical
Logical or numeric value to specify if a plot showing the results should be generated. The plot shows an overview of slopes for all sample in `data`.
Default is `true`.



#### details - specify if diagnostics plots should be shown<a name="varargin"></a> <br> Type: numeric | logical
Logical or numeric value to specify if detailed diagnostic plots should be shown for each sample. Each plot will show the raw, modeled, and residual data if a fit was possible.<br>
Default is `false`.


#### quiet - suppress the command window output <a name="varargin"></a> <br> Type: numeric | logical
Flag to suppress command window outputs. Default is `false`.



## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
A drEEMdataset object with updated metadata including the fitted slopes. If no output argument is specified, the function overwrites the original object, `data`, in the workspace.<br> 

#### slopes - a table with the slopes for each sample   <a name="varargin"></a> <br> Type: table
Table containing the slope fitting results with the following columns:

- `exp_slope_microm`: Long-range exponential slope.
- `S_275_295`: Slope for the range `275`-`295` nm.
- `S_350_400`: Slope for the range `350`-`400` nm.
- `Sr`: Ratio of slopes `S_275_295` to `S_350_400`.


#### slopes - a table with fitting details   <a name="varargin"></a> <br> Type: table
Table containing metadata with fitting details, including:

- `Exp_rsq`: R-squared of exponential fit.
- `Exp_a350_model`: Modeled absorbance at `350` nm.
- `Exp_offset`: Offset of exponential fit.
- `log_275_Rsq`: R-squared of linear fit for `275`-`295` nm.
- `log_350_Rsq`: R-squared of linear fit for `350`-`400` nm.

#### model - absorbance modeled data   <a name="varargin"></a> <br> Type: matrix
Matrix containing the modeled absorbance data for each sample.


## Fitting algorithm
The function fits slopes to the data using three ranges:<br>
1. Long range exponential slope fitting (specified by `options.LongRange`).<br>
2.  Linear slope fitting for the wavelength range `275`-`295` nm.<br>
3.  Linear slope fitting for the wavelength range `350`-`400` nm.<br>
The fitting process includes handling of NaN values, ensuring robust fits, and logging any fitting issues.


## See Also ##

<a href="link.com">Link1</a> | 
<a href="link.com"> Link2 </a> |
<a href="link.com"> Link3 </a> |


## Topics ##