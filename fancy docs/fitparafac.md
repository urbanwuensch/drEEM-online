<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# fitparafac #
Create PARAFAC models for fluorescence data (works with MATLAB 2022a or newer)



## Syntax
### [dataout = fitparafac(data)](#syntax1) ###
### [dataout = fitparafac( ___ , Name,Value)](#syntax1) ###


## Description ##
### [dataout](#varargout) = fitparafac([data](#varargin)) <a name="syntax1"></a>

The `fitparafac` function performs Parallel Factor Analysis (PARAFAC) on the provided `data`. The models are saved in `data.models`. The function supports various configurations, including different constraints, convergence criteria, initialization methods, and etc.
The function can also run in parallel for improved performance on multi-core systems. The function uses default values of input arguments (see Input arguments section) when options are not specified. <br>
An entry will be added to the `history` field of the `data`, detailing the  options used for `fitparafac`. If no output argument is specified, the function will overwrite the original `data` in the workspace.


>
### [dataout](#varargout) = fitparafac([ ___ , Name,Value](#varargin)) <a name="syntax1"></a>

specifies additional options using one or more name-value pair arguments. For example, you can specify the number of components for models, constraints, initialization and parallelization options. <br>
Example: `fitparafac(data,f=2:6, starts=2, convergence=1e-4,  parallelization=false)` to fit parafac models with `2` to `6` components using with `2` random starts and a convergence criteria of `0.0001`, and turning off the parallelization option.

## Input arguments ##
#### data - drEEMdataset containing fluorescence data  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods. If `"split"` is used as `mode` option, `data.split` should be non-empty (see `splitdataset`).
If `data` already contains models, the old models will be deleted, keeping only the new models. 

##### Name-Value Arguments  <a name="data"></a>
Specify optional pairs of arguments as `Name1=Value1,...,NameN=ValueN`, where `Name` is the argument name and `Value` is the corresponding value. Name-value arguments must appear after other arguments, `data` in this case, but the order of the pairs does not matter. 


#### f - specify the number of components  <a name="varargin"></a> <br> Type:  numeric
Numeric array specifying the number of components to use in the PARAFAC  models. Default is `[2, 3, 4, 5, 6, 7]`.


#### mode - specify if data should be treated as whole or splits   <a name="varargin"></a> <br> Type: string | character
A text specifying the mode of operation. Can be set to `"overall"` for analyzing the whole dataset in `data` or `"split"` for analyzing subsets of the data obtained from `data.splits`. Subsets of `data` should be previously created using `splitdataset` function. Default is "overall"


#### constraints - specify the constraints for PARAFAC   <a name="varargin"></a> <br> Type: string | character
Specify the constraints to apply to the models. You can choose from: <br>


- `"unconstrained"`: there are no restrictions on the values that the elements of the factor matrices can take. They can be positive, negative, or zero. While this option provides greater flexibility in fitting the data, the resulting factors might be harder to interpret, especially where negative values do not make sense (e.g., physical quantities like concentrations or intensities). 

- `"nonnegativity"`: Nonnegativity constraints ensure that all the elements in the factor matrices are greater than or equal to zero.
This option can sometimes make it harder to achieve the best possible fit to the data because the model is less flexible but is particularly useful in where the factors represent quantities that cannot be negative.
- `"unimodnonneg"`:T his constraint ensures that the factor matrices are both nonnegative and unimodal. A factor is unimodal if it has a single peak or mode, meaning it increases to a maximum value and then decreases. This constraint can help in obtaining more realistic and interpretable factors, while, meantime, making it more challenging to achieve the best fit to the data. 
 
Default constraint is `"nonnegativity"`.



#### starts - specify the number of random starts<a name="varargin"></a> <br> Type: numeric
Number of random starts for the algorithm refers to initializing the factor matrices with random values and running the algorithm multiple times. Default is `40`.


#### convergence - specify the convergence criteria for models<a name="varargin"></a> <br> Type: numeric
Convergence criterion. If the change in errors falls below a `convergence` threshold, the algorithm is considered to have converged and will stop running. Default is `1e-6`.


#### MaxIteration - specify the maximum number of iteration if convergence criteria is not met <a name="varargin"></a> <br> Type: numeric
Specify the maximum number of iterations for the algorithm. If the convergence criteria, `convergence`, is not met before the specified maximum number of iteration the algorithm will stop running.
Default is `3000` iterations.


#### initialization - specify the initialization method<a name="varargin"></a> <br> Type: string | character
Specify the method used to set the starting values for the factor matrices. you can choose from:

- `"random"`: Factor matrices are initialized with random values.
- `"svd"`: Factor matrices are initialized using Singular Value Decomposition (SVD) often leading to faster convergence compared to random initialization. SVD computation can be expensive for very large datasets.
- `"multiplesmall"`: multiple small-scale models are fitted first, and their results are combined to initialize the full-scale factor matrices.

Default initialization method is `"random"`.



#### parallelization - turn on/off parallel computing<a name="varargin"></a> <br> Type: numeric | Logical
Enable or disable parallelization. If enabled can dramatically decrease the time required for the analysis. Default is `true`.


#### consoleoutput - specify the level of details displayed in the console output<a name="varargin"></a> <br> Type: string | character
Specify the level of console output during execution. You can choose from:

- `"all"`: displays all the information during the process. 
- `"minimum"`: minimizes the level of displayed information to only highly important ones.
- `"none"`: does not display anything on the console.

Default is `"minimum"`.



#### toolbox - specify which toolbox to use for creating PARAFAC models<a name="varargin"></a> <br> Type: string | character

Specify the toolbox to use for the PARAFAC algorithm. You can choose from:

- `"parafac3w"`
- `"nway"`
- `"pls"`: Note:  `PLS_toolbox` should be installed. 
 
 
Default is `"parafac3w"`.




## Output arguments (optional)##
#### dataout - drEEMdataset   <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, in which the parafac models are stored in `dataout.models`. To visualize and analyze the models use one of the following functions: `viewmodels`, `viewcomcorr`.<br> 
If no output argument is specified, the function overwrites the original object in the workspace.




## See Also ##

<a href="link.com">splitdataset</a> | 
<a href="link.com"> drEEMdataset </a> |
<a href="link.com"> Link3 </a> |


## Topics ##