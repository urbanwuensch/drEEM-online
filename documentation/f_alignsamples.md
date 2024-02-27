<img src="top right corner logo.png" width="100" height="auto" align="right"/>
# alignsamples #
Compare sample names between datasets and reduce to overlapping samples
## Syntax
### [varargout=alignsamples(varargin)](#syntax1) ###


## Description ##
[comment]: <> (The description gives an explanation on different function syntax versions above)
### [varargout](#varargout) = alignsamples([varargin](#varargin)) <a name="syntax1"></a>
Match sample names between multiple datasets to ensure that the output structures contain the same samples in the same sequence.



## Input arguments ##
#### varargin  - drEEMdataset   <a name="varargin"></a>
### drEEMdataset
Datasets of the class `drEEMdataset` with standardized contents and automated validation methods. `alignsamples` will use the `filelist` field in each dataset to compare sample names between all provided datasets. The function will then align sample names and delete any samples that did not occur in all provided datasets.


## Output arguments ##
#### varargout  - drEEMdataset <a name="varargout"></a>
Datasets of the class `drEEMdataset` with standardized contents and automated validation methods.