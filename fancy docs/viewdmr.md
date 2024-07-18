<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# viewdmr #
Visualize the raw data, modeled data, and residual EEM plots for every sample in each parafac model.



## Syntax
### [viewdmr(data)](#syntax1) ###




## Description ##
### viewdmr([data](#varargin)) <a name="syntax1"></a>
Opens up the `viewdmr` user interface app. The app visualizes the EEMs of raw data (unmodeled data), modeled data, and the residuals of a specified sample and a parafac model. You can go through different models and samples using the `Model` and `Sample` drop-down menus, respectively. You can also navigate through sample using the `prev.` and `next` buttons. Moving through samples will automatically reset the axis view, unless specified otherwise using the `Keep axis view` checkbox.
<br>
To adjust the upper limit of the Residual plot's colorbar, use the `% of max. intensity` input box. Maximum intensity refers to the upper limit of the data or model plots' colorbar.

## Input arguments ##
#### data - drEEMdataset containing parafac models  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods that contains at least one parafac model.







## See Also ##

<a href="link.com">fitparafac</a> | 
<a href="link.com"> vieweems </a> |
<a href="link.com"> viewmodels </a> |


## Topics ##

