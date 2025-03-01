<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# associatemetadata #
Associate a metadata file with a `drEEMdataset`



## Syntax
### [dataout = associatemetadata(data, filename, metadatakey)](#syntax1) ###
### [dataout = associatemetadata(data, filename, metadatakey, datakey)](#syntax1) ###
### [associatemetadata(data, filename, metadatakey, datakey)](#syntax2) ###


## Description ##
### [[dataout, md]](#varargout) = associatemetadata([data, filename, metadatakey](#varargin)) <a name="syntax1"></a>

The `associatemetadata` function reads metadata information from a  file or table specified by `filename` and associates it with `data` based on specified key in metadata using `metadatakey` . The function by default uses `filelist` field in `data` as identifier key for `drEEMdataset`. 
 The function ensures that the identifiers in both the `data` and the metadata exist, are of the same class and are unique, then performs necessary type conversions to limit the associated data to be of type `char` or `double`. The `metadata` field entries for the unmatched samples  are filled with `missing` or `NaN` values.
If no output argument is specified, the function overwrites the original object in the workspace.

Example: `data = associatemetadata(samples,tbl,'sampleID')` read metadata from the loaded `tbl` and use sampleID column in the `tbl`as the `metadatakey`. <br>

Example: `data = associatemetadata(samples,"c:\data\metadata.xlsx",'sampleID')` read metadata from the path specified in `filename` and  use sampleID column in the metadata file as the `metadatakey`. <br>

>
### [[dataout, md]](#varargout) = associatemetadata([data, filename, metadatakey, datakey](#varargin)) <a name="syntax1"></a>

Change the default identifier key (`filelist`) in the `data` to a new key using `datakey`.

Example: `data = associatemetadata(samples,"c:\data\metadata.xlsx",'sampleID','i')` to use `i` field in the `data` as the `datakey`

>
### associatemetadata(data, filename, metadatakey, datakey) <a name="syntax2"></a>

Runs the function in diagnostic mode. Without output arguments, the function will run as always, but no output arguments are assigned. Use this notation for testing. This gives the chance to fix issues with sample names.

## Input arguments ##
#### data - drEEMdataset for association  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, to which the associated metadata will be added.

#### filename - metadata file name  <a name="varargin"></a> <br> Type: table | char | string
If a `table`, it should be a metadata table already loaded into MATLAB workspace. The `table` should contain a column header as specified by `metadatakey`.<br>
If a `string` or `character array`, it should be a path to a file containing the metadata. For local files, `filename` can be a full path that contains a filename and file extension. FILENAME can also be a relative path to the current folder, or to a folder on the MATLAB path.
The following extensions are supported: `.txt`, `.dat`, `.csv`, `.log`,`.text`, `.dlm`, `.xls`, `.xlsx`, `.xlsb`, `.xlsm`, `.xltm`, `.xltx`, `.ods`.



#### metadatakey - identifier key in metadata   <a name="varargin"></a> <br> Type: char | string
The name of the column in the metadata file that contains the identifiers to match with the `data`.

#### datakey - identifier key in data (optional)   <a name="varargin"></a> <br> Type: char | string

The name of the field in the `data` object that contains the identifiers to match with the metadata.
Default is `filelist`

## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, in which the `metadata` field is updated with the associated data from the metadata. Unmatched samples in the `data` are filled with `missing` or `NaN` values in the `metadata` field. If no output argument is specified, the function overwrites the original object in the workspace.




## See Also ##

<a href="link.com">readtable</a> | 
<a href="link.com"> drEEMdataset </a> |
<a href="link.com"> Link3 </a> |


## Topics ##