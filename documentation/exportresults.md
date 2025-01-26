<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# exportresults  #
Export history, status, scatter treatment, Coble peaks, model overview, and loadings of a specific PARAFAC model to an Excel spreadsheet



## Syntax

### [exportresults (data, filename, f)](#syntax1) ###

## Description ##
### exportresults ([data, filename, f](#varargin)) <a name="syntax1"></a>
The `exportresults` function takes a drEEMdataset object, `data`, a `filename`, and a PARAFAC model index, `f`, and exports relevant data and results, including history, status, scatter treatment, Coble peaks and indicies, chosen parafac model overview, fluorescence maxima of samples, and excitation and emission loadings, to an Excel file. The function ensures the specified PARAFAC model exists within the `data` and organizes the data into several sheets within the spreadsheet.<br>
Note: The function deletes any existing file with the same name before writing the new data.

Example: `exportresults(data, 5, 'mymodel.xlsx')` or `exportresults(data, 5, 'mymodel')` to export the 5-component model from `data` to Excel spreadsheet `mymodel.xlsx`.
<br>



## Input arguments ##
#### data - drEEMdataset containing the specified parafac model  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods. `data` must contain the specified parafac model (`f` for the number of components in the model).<br>
Note: only the parafac models that are created in the `"overall"` mode in `firparafac` will be exported. To export a parafac model from a `split` use the `data.split(n,1)` as input argument to access the models in the `nth` split.<br>
Example: `exportresults(data.split(2,1), 5, 'mysplittedmodel')` to export the 5-component model from the second split in `data`.

#### filename - name of the exported file<a name="varargin"></a> <br> Type:  string | character

The name of the output file. It should be a text and will be saved with a `.xlsx` extension.
Note: any extension at the end of the `filename` will be changed to `.xlsx`.


#### f - represents the number of components in the targeted model <a name="varargin"></a> <br> Type:  numeric

Specify the number of parafac components in the model that you want to export.


## See Also ##

<a href="link.com"> export2netcdf </a> | 
<a href="link.com"> export2openfluor </a> |
<a href="link.com"> Link3 </a> |


## Topics ##