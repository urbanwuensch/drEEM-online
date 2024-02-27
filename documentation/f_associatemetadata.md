<img src="top right corner logo.png" width="100" height="auto" align="right"/>
# associatemetadata #
Ammend metadata table with information
## Syntax
### [dataout=associatemetadata(data,pathtofile,metadatakey)](#syntax1) ###

### [dataout=associatemetadata(data,pathtofile,metadatakey,datakey)](#syntax2) ###



## Description ##
[comment]: <> (The description gives an explanation on different function syntax versions above)
### [dataout](#dataout) = associatemetadata([data](#data),[pathtofile](#pathtofile),[metadatakey](#metadatakey)) <a name="syntax1"></a>
Load table and compare column information to `data.filelist` to associate column contents to `data`. The new metadata information is stored in `dataout.metadata`. The function adds columns to the table; it does not replace any columns. New metadata is converted to `numerical` or `categorical` variables. Missing data is represented as `NaN` or `missing`.

### [dataout](#dataout) = associatemetadata([data](#data),[pathtofile](#pathtofile),[metadatakey](#metadatakey),[datakey](#datakey)) <a name="syntax1"></a>
Load table and compare column information to `data.metadata.(datakey)` to associate column contents to `data`. Use the function in this way if `data.filelist` is not suitable for associating the metadata. This can be the case if EEm samples were given numerical names in sequence of the measurement without corresponding to the sample names in the sampling campaign. However, this would require a meaningful column in the metadata table to be present already. The new metadata information is stored in `dataout.metadata`. 



## Input arguments ##
#### data  - drEEMdataset   <a name="data"></a>
### drEEMdataset
Datasets of the class `drEEMdataset` with standardized contents and automated validation methods.



## Output arguments ##
#### dataout  - drEEMdataset <a name="dataout"></a>
Datasets of the class `drEEMdataset` with standardized contents and automated validation methods.











<span style="color:#C95300">associatemetadata</span>
==========

Read in a table containing metadata and associate the metadata with existing EEMs in a dataset.

<br/>Syntax
------


<span style="font-family: Courier;">[[dataout](#dataout)]=associatemetadata([data](#data),[pathtofile](#pathtofile),[datakey](#datakey),[metadatakey](#metadatakey))</span></span>



<br/>Description
-----------

This function matches data identifiers between a drEEM dataset structure and metadata tables and creates fields in the drEEM dataset that contain the metadata given in the table. String matching is rigid-lower case (not case sensitive). Partial matches are treated as not-matching.

<br/>Examples <a name="examples"></a>
-----------

Match table from file with dataset:

	associatemetadata(DS,"C:\Users\urbw\logfile - copy.csv",...)
	'filelist','DataIdentifier')

Match table provided as variable with dataset:

	associatemetadata(DS,metadatatable,...)
		'filelist','DataIdentifier')



<br/>Input Arguments
---------------
**data** - Structure  <a name="data"></a>

The typical [drEEM dataset](doc_drEEM_dataset_object.html). It must contain the required fields (check with [`checkdataset`](f_checkdataset.html)).

**pathtofile** - character vector | string | table (variable). <a name="pathtofile"></a>

`pathtofile` provides either a path to a file to be loaded or a table variable itself. Both table or path to the table file need to contain a column with the name provided in `metadatakey`.


**datakey** -  character <a name="datakey"></a>

Name of the field in `data` that contains the key information that is to be matched to a column in the metadata table. Supported fields are character arrays and `cellstr`.

**metadatakey** -  character <a name="metadatakey"></a>

Name of the field in `pathtofile` that contains the key information that is to be matched to a field in `data`. Supported fields are character arrays and `cellstr`. **Note:** During the table import, Column headers might be renamed for compatibility as `VariableNames` by `readintable`. To avoid issues, it is best to avoid any special characters, remove spaces and to keep column headers simple.

<br/>Output arguments
---------------
**dataout** - Structure  <a name="dataout"></a>

The typical [drEEM dataset](doc_drEEM_dataset_object.html). It must contain the required fields (check with [`checkdataset`](f_checkdataset.html)). If not present, a field called `metadata` will be created that contains the provided metadata in a table format. Each column in `metadata` will either be of the class `double` or `cellstr` (cell array of strings). `datetime` arrays and `string` arrays will be converted to `cellstr` but can be converted back manually (see Matlab documentation for further information).


<br/>Topic
-----
[Data import / export](doc_importexport.html)

Introduced in drEEM 0.6.4