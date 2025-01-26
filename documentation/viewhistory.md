<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# viewhistory #
View and export a summary of the functions carried out on data and their details.


## Syntax

### [viewhistory(data)](#syntax1) ###

## Description ##
### viewhistory([data](#varargin)) <a name="syntax1"></a>
The function `viewhistory` opens up the drEEM viewhistory app that contains a summary of the drEEM functions that have been run on the data, along with their details and the comments added by the user during the process.
Functions are color coded for easier navigation through the list.
Hovering over any cell will show the detailed content of the cell if their length exceed the cell's space.<br>
Use the `Save list as spreadsheet` button to export the history in `.ods` (OpenDocument Spreadsheet) file format. The exported spreadsheet will contain all the history fields, timestamps, function names, user comments, and function messages.<br>
By clicking on any of the functions (in drEEM function column) that accept some options as input, the two `View selected options` and `Transfer options to workspace` buttons will be enabled. Use the former to see the options associated with the selected function in a new window, and the latter to export the options to the workspace in a variable called `restoredOptions`.


>

## Input arguments ##
#### data - drEEMdataset  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods.<br>
Note: the function does not accept any output argument.



## See Also ##

<a href="link.com"> Link1 </a> | 
<a href="link.com"> drEEMdataset </a> |
<a href="link.com"> Link3 </a> |


## Topics ##