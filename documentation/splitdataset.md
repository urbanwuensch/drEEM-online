<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# splitdataset #
Split a dataset into multiple subsets for tasks such as cross-validation.



## Syntax
### [dataout = splitdataset(data)](#syntax1) ###
### [dataout = splitdataset( ___ , Name,Value)](#syntax1) ###


## Description ##
### [dataout](#varargout) = splitdataset([data](#varargin)) <a name="syntax1"></a>

The `splitdataset` function creates subsets of `data` and store them in the `split` field of the output argument. If `data.split` contains subsets from previously subsetted data, those `split`s will be overwritten with the new splits.
The function uses default values of input arguments (see Input arguments section) when options are not specified. <br>
An entry will be added to the `history` field of the `data`, detailing the  options used for `splitdataset`. If no output argument is specified, the function will overwrite the original `data` in the workspace.<br>
Example: `splitdataset(data, "numsplit", 3, "stype", "random")`; to split the dataset into 3 subsets using random splitting.
Example: `splitdataset(data, "bysort", "SampleType", "stype", "exact")` to split the dataset exactly according to `SampleType` in metadata.




>
### [dataout](#varargout) = splitdataset([ ___ , Name,Value](#varargin)) <a name="syntax1"></a>

specifies additional options using one or more name-value pair arguments. For example, you can specify number and type of splits. <br>
Example: `splitdataset(data,"numsplit",4, "stype","random")` to randomly split the `data` into `4` subsets. 

## Input arguments ##
#### data - drEEMdataset containing fluorescence data  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods. If `"split"` is used as `mode` option, `data.split` should be non-empty (see `splitdataset`).
If `data` already contains models, the old models will be deleted, keeping only the new models. 

##### Name-Value Arguments  <a name="data"></a>
Specify optional pairs of arguments as `Name1=Value1,...,NameN=ValueN`, where `Name` is the argument name and `Value` is the corresponding value. Name-value arguments must appear after other arguments, `data` in this case, but the order of the pairs does not matter. 


#### bysort - a metadata column  <a name="varargin"></a> <br> Type:  string | character
Specifies a column in `data.metadata` to sort `data` before splitting. Must be a valid metadata column name that exists in `data.metadata`. <br>Note: When `bysort` is provided, the `stype` must be set to `"exact"`. <br>
Default is `[]`.


#### numsplit - specify the number of splits to create from the data   <a name="varargin"></a> <br> Type: numeric
The number of subsets to split the data into. Must be a positive integer. <br>
Default is `2` splits.


#### stype - specify the splitting method   <a name="varargin"></a> <br> Type: string | character
The type of splitting method. Must be one of the following methods:


- `"alternating"`: Samples are alternated between subsets.

- `"random"`: Samples are randomly assigned to subsets.

- `"contigues"`: Samples are divided into contiguous blocks.

- `"exact"`: Splits the dataset exactly according to the sorting column specified by `bysort`. If `stype` is set to `exact`, the `bysort` must be provided.
 
Default split type is `"alternating"`.









## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, containing the splits. The `split` field in `dataout` contains the subsets.<br> 
If no output argument is specified, the function overwrites the original object in the workspace.




## See Also ##

<a href="link.com">fitparafac</a> | 
<a href="link.com"> drEEMdataset </a> |
<a href="link.com"> Link3 </a> |


## Topics ##