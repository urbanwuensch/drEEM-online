<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# validatedataset #
Check for the correct dimensions and consistency of various fields within a `drEEMdataset` object, ensuring that the data meets the expected structure required for subsequent analysis.



## Syntax
### [validatedataset(dataset)](#syntax1) ###
###


## Description ##
[comment]: <> (The description gives an explanation on different function syntax versions above)
### validatedataset([dataset](#varargin)) <a name="syntax1"></a>

The validatedataset function performs several validation checks on the dataset object. These checks include:


- MATLAB Version Warning: Issues a warning if the MATLAB version is older than R2022a, as there may be potential compatibility issues.
- Field Consistency: Ensures that the `drEEMdataset` object has all required fields defined in the `drEEMdataset` class.
- Dimension Checks: Verifies that the `X` field has three dimensions and checks its consistency with other related fields (`nSample`, `filelist`, `metadata`, `i`, `Em`, `nEm`, `Ex`, `nEx`, `models`). It also checks that the `abs` field is a 2-dimensional matrix and checks its consistency with relevant fields.
- NaN and Complex Number Checks: Identifies fields containing only `NaN` values or complex numbers.
- Error Reporting: Collects and reports errors if any inconsistencies are found in the dataset. If no errors were found and the function was called from the `drEEMtoolbox`, a success message is displayed.



## Input arguments ##
#### dataset - drEEMdatasets   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset` with standardized contents and automated validation methods. 




## See Also ##

<a href="link.com">Link1</a> | 
<a href="link.com"> Link2 </a> |
<a href="link.com"> Link3 </a> |


## Topics ##