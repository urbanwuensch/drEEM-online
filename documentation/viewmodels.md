<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# viewmodels #
Visualize, evaluate the performance, and compare different aspects of the PARAFAC models.





## Syntax
### [viewmodels(data)](#syntax1) ###




## Description ##
### viewmodels([data](#varargin)) <a name="syntax1"></a>

The function `vieweems` opens up the "Diagnose PARAFAC Models" app that is designed for diagnosing and analyzing PARAFAC models built in using `firparafac` function. This app provides multiple tabs to evaluate the performance, see validation status, and visualize different aspects of the PARAFAC models.<br>
Note: The app does not accept any output arguments!

The app consists of several tab including:<br>

<strong>Overview:<br></strong> 
This tab provides a summary of the PARAFAC models including:

 - Number of components
 - Model status
 - Percentage of explained variance
 - Sum of Squared Errors (SSE)
 - Core consistency
 - Percentage of unconverged components
 - Initialization method
 - Number of starts
 - Convergence criteria
 - Constraints
 - Toolbox used

 The bottom section of this tab includes:

 - A plot for Core Consistency vs. Number of components
 - A plot for Explained Variance vs. Number of components



<strong>Scores & Loadings:<br></strong>
 This tab provides scores and loadings visualizations for each model:

 - Scores plots for each model
 - Loadings plots for each model (Emission and Excitation spectra)



<strong>Spectral Loadings:<br></strong>

This tab provides spectral loadings plots for each component in each model separately:
Note: each row of plots correspond to one model.




<strong>Loadings & Leverages:<br></strong>

This tab provides plots of scores for samples, excitation and emission loadings for each wavelength and leverages in each mode (samples, excitation, emission) to visualize the influence of each data point on the model. You can go through different models by using the drop-down menu button on top of the plots.
 


<strong>Errors & Leverages:<br></strong>

To visualize the sum of squared error against leverages in each mode (samples, excitation, emission). You can go through different models by using the drop-down menu button on top of the plots.
 



<strong>Fingerprint Plots:<br></strong>

Use this tab to plot Excitation Emission Matrix (EEM) of each component in each model. Go through different models by using the drop-down menu button on top of the plots.



<strong>SSE:<br></strong>

To visualize the sum of squared error for each mode (samples, excitation, emission). This can be helpful to identify which samples or wavelength impose the biggest errors on the model.
You can go through different models by using the drop-down menu button on top of the plots.



<strong>Score Correlation:<br></strong>

This tab plots a heatmap of correlations between different components in each model. This provides insights into the relationships between different components.
Left-clicking on the `view correlations vs. metadata` button opens a new app, in which score correlation plots are generated as scatter plots and datapoints are color-labeled based on the information in metadata columns.

## Input arguments ##
#### data - drEEMdataset containing parafac models  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, that contains parafac models.




## See Also ##

<a href="link.com">firparafac</a> | 
<a href="link.com"> Link2 </a> |
<a href="link.com"> Link3 </a> |


## Topics ##