<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# export2openfluor  #
Export a parafac model to text file formatted for OpenFluor.



## Syntax

### [export2openfluor (data, f, filename)](#syntax1) ###

## Description ##
### export2openfluor ([data, f, filename](#varargin)) <a name="syntax1"></a>
The `export2openfluor` function exports the excitation and emission loadings of a parafac model, specified by the number of components, `f`, from `data.models` to a text file formatted for OpenFluor. If wavelengths are not whole numbers (integers) the function ensures the data is interpolated using a spline method to fit the new wavelength ranges. The function ensures the data properly formatted before writing it to the specified `filename`.

Example: `export2openfluor(data, 5, 'mymodel.txt')` or `export2openfluor(data, 5, 'mymodel')` to export the 5-component model from `data` to text file `mymodel.txt`.
<br>



## Input arguments ##
#### data - drEEMdataset containing the specified parafac model  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods. `data` must contain the specified parafac model (`f` for the number of components in the model).<br>
Note: only the parafac models that are created in the `"overall"` mode in `firparafac` will be exported. To export a parafac model from a `split` use the `data.split(n,1)` as input argument to access the models in the `nth` split.



#### f - represents the number of components in the targeted model <a name="varargin"></a> <br> Type:  numeric

Specify the number of parafac components in the model that you want to export.

#### filename - name of the exported file<a name="varargin"></a> <br> Type:  string | character

The name of the output file. It should be a text and will be saved with a `.txt` extension.
Note: any extension at the end of the `filename` will be changed to `.txt`.

## See Also ##

<a href="link.com"> export2netcdf </a> | 
<a href="link.com"> exportresults </a> |
<a href="link.com"> Link3 </a> |


## Topics ##