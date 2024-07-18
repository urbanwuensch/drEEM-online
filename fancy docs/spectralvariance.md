<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# spectralvariance #
Visualize and analyze the spectral variability in fluorescence and absorbance data.



## Syntax
### [[cdom, fdom] = spectralvariance(data)](#syntax1) ###




## Description ##
### [[cdom, fdom]](#varargout) = spectralvariance([data](#varargin)) <a name="syntax1"></a>
The `spectralvariance` function plots the spectral variability of absorbance and fluorescence data. The function scales all data to unit variance in the sample mode, giving each sample equal weighting.
<br>
The function identifies samples with very low signals and will generate a warning regarding the impact of those samples. 




## Input arguments ##
#### data - drEEMdataset containing either of fluorescence or absorbance data <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods that contains fluorescence and/or absorbance data.

## Output arguments ##
#### cdom - Standard deviation of the absorbance spectra <a name="varargin"></a> <br> Type: numeric
`cdom` contains the standard deviation of absorbance data (for each wavelength).


#### fdom - Standard deviation of the fluorescence spectra <a name="varargin"></a> <br> Type: numeric
`fdom` contains the standard deviation of fluorescence data for both excitation and emission modes.




## See Also ##

<a href="link.com">Link1</a> | 
<a href="link.com"> Link2 </a> |
<a href="link.com"> Link3 </a> |


## Topics ##

