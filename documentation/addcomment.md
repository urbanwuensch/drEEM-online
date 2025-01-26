<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# addcomment #
Add a comment to the history field of a `drEEMdataset` object.



## Syntax
### [dataout = addcomment(data, comment)](#syntax1) ###
### [addcomment(data, comment)](#syntax1) ###


## Description ##
[comment]: <> (The description gives an explanation on different function syntax versions above)
### [dataout](#varargout) = addcomment([data, comment](#varargin)) <a name="syntax1"></a>

The `addcomment` function adds a `comment` to the `history` field of a `drEEMdataset` object. The function returns the modified object as `dataout`. If the latest `history` entry in `data` already has a `usercomment`, the new `comment` is appended to `usercomment` as a string.



<br>
### addcomment([data, comment](#varargin)) <a name="syntax1"></a>

If no output argument is specified, the function overwrites the original object in the workspace.



## Input arguments ##
#### data - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, to which the comment will be added.

#### comment - text to add as comment   <a name="varargin"></a> <br> Type: char | string
A text comment to be added to the the `history` field of the specified `drEEMdataset`


## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, to which the comment is added.



## See Also ##

<a href="link.com">Link1</a> | 
<a href="link.com"> Link2 </a> |
<a href="link.com"> Link3 </a> |


## Topics ##