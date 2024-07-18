<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# upgradedataset  #
Upgrade a given dataset to a newer format compatible with the new version of drEEM toolbox (2.0.0).



## Syntax

### [dataout = upgradedataset (data)](#syntax1) ###
### [dataout = upgradedataset (data, atypicalFieldnames)](#syntax1) ###




## Description ##
### [dataout](#varargout) = upgradedataset ([data](#varargin)) <a name="syntax1"></a>
The `upgradedataset` function upgrades a given dataset to a newer format compatible with the drEEM toolbox. The functions assumes that `data` is a typical dreem data structure built by previous versions of the toolbox. Hence, it expects the fields  `'X', 'Ex', 'Em','nEm',` `'nEx', 'filelist', 'i', 'nSample', 'Abs_wave', 'Abs'` to be present in the `data`. Other fields in the `data` that have compatible size will be transferred to the `metadata` field of the `dataout`. If compatible models are present in the `data` they will be transferred to the `models` field. For more information about model transfer, see Model Transfer in  the topics section.

### [dataout](#varargout) = upgradedataset ([data, atypicalFieldnames](#varargin)) <a name="syntax1"></a>
If the information in `data` is stored in fields that differ from the typical field names, use `atypicalFieldnames` to identify those fields. For example, use `atypicalFieldnames={'EEM','X'}` if the information that the function expects to find as `X` is stored in field `EEM` inside `data`. 



## Input arguments ##
#### data - data structure containing the typical fields expected by drEEMtoolbox <a name="varargin"></a> <br> Type: struct
Dataset to be upgraded. The `data` should contain the fields that are common in a fluorescence data structure, namely: `'X', 'Ex', 'Em','nEm','nEx', 'filelist', 'i', 'nSample', 'Abs_wave', 'Abs'`. If field names are different from those specified above, they should be explicitly defined in `atypicalFieldnames`.




#### atypicalFieldnames - names of non-typical fields and their corresponding new field names<a name="varargin"></a> <br> Type:  cell array

A cell array of size N x 2. Each row should contain a pair of field names where the first column is the old field name (should exist in `data`), and the second column is the new field name (should exist in drEEMdataset class object, see `drEEMdataset` for more information). <br>Default is `[]`.


## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, compatible with the new version of the drEEM toolbox (2.0.0).
If no output argument is specified, the function overwrites the original object in the workspace.



## See Also ##

<a href="link.com"> drEEMdataset </a> | 
<a href="link.com"> Link2 </a> |
<a href="link.com"> Link3 </a> |


## Topics ##
**Model Transfer**:<br>
Models should be stored in the `Model1`, `Model2`, `Model3` and `ModelN` fields in the `data`.<br>
Loadings are taken from `data.Model1`, `data.Model2`, ..., and `data.ModelN`, and assigned to `dataout.models(1,1).loads`, ..., `dataout.models(N,1).loads`.<br>
Leverages are calculated for each element in loads and assigned to `dataout.models(1,1).leverages`, ..., `dataout.models(N,1).leverages`.<br>
Sum of Squared Errors (SSE) are computed for different modes (samples, emission, excitation) and assigned to `dataout.models(1,1).sse`, ..., `dataout.models(N,1).sse`.<br>
Model's status is set to `'transferred from old dataset. status unknown'`.<br>
Percentage Explained is calculated as the percentage of variance explained by the model and assigned to `dataout.models(N,1).percentExplained`.<br>
Core Consistency is calculated and assigned to `dataout.models(N,1).core`.<br>
Percentage Unconverged is set to `NaN`.<br>
Component Contribution is calculated for each component and assigned to `dataout.models(N,1).componentContribution`.
`Initialization` is set to `'random'`.<br>
`Starts` is set to `NaN`.
`Convergence` is retrieved from `data`, if it exists, otherwise is set to `NaN`.
`Constraints` is retrieved from `data`, if it exists, otherwise is set to `'unknown'`.
`Toolbox` is set to `'nway'` by default.


