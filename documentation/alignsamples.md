<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# alignsamples #
Compare sample names across `drEEMdataset` class objects and remove the unmatched samples


## Syntax
### [dsout1, __, dsoutN = alignsamples(dsin1, __, dsinN)](#syntax1) ###
### [alignsamples(dsin1, __, dsinN)](#syntax2) ###


## Description ##
>
### [dsout1, __, dsoutN](#varargout) = alignsamples([dsin1, __, dsinN](#varargin)) <a name="syntax1"></a>

Match sample names across multiple datasets (`N≥2`) and remove the unmatched samples to ensure that the output datasets contain only the same samples in the same sequence. Number and order of the output should match the input.

>
### alignsamples([dsin1, __, dsinN](#varargin)) <a name="syntax2"></a>

Runs the function in diagnostic mode. Without output arguments, the function will run as always, but no output arguments are assigned. Use this notation for testing. This gives the chance to fix issues with filenames.

## Input arguments ##
#### dsin1, __, dsinN  - drEEMdatasets   <a name="varargin"></a> <br> Type: drEEMdataset class object
Datasets of the class `drEEMdataset` with standardized contents and automated validation methods. `alignsamples` will use the `filelist` field in each dataset to compare sample names between all provided datasets. The function will then align sample names and delete any samples that did not occur in all provided datasets.

Example: `(samples, blanks, absorbance)`<br>

## Output arguments ##
#### dsout1, __, dsoutN  - drEEMdatasets <a name="varargout"></a> <br> Type: drEEMdataset class object
Datasets of the class `drEEMdataset` with matching `filelist` field and standardized contents and automated validation methods.

## See Also ##

<a href="link.com">importeems</a> | 
<a href="link.com"> importabsorbance </a> |
<a href="link.com"> Link3 </a> |


## Topics ##