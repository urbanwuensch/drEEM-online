<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# changestatus #
Change one or more fields of status in data to keep a record of the changes.



## Syntax
### [changestatus(data)](#syntax1) ###




## Description ##
### changestatus([data](#varargin)) <a name="syntax1"></a>
The `changestatus` function opens up the `setstatus` user interface app that allows user to see or change the status of the data in one or more of the available fields.
The fields consist of:

- `spectral correction`
- `inner filter effect correction`
- `blank subtraction`
- `signal calibration`
- `scatter treatment`
- `signal scaling`

<br>
Note: The toolbox automatically updates the status fields when relevant function are run, e.g, `subtractblanks`, `ifecorrection`, so that the user does not need to manually update the status. However, in cases when user desires to change a status field manually, the app provides the opportunity. 
<br>
Note: The `setstatus` app is called automatically every time functions `importeems` and `importabsorbance` are run, to set the initial status of the data.

## Input arguments ##
#### data - drEEMdataset <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods.
<br>
Note: the function does not accept any output arguments. 



## See Also ##

<a href="link.com"> importeems</a> | 
<a href="link.com"> Link2 </a> |
<a href="link.com"> Link3 </a> |


## Topics ##

