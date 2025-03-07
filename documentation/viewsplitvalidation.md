<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# viewsplitvalidation
Visualize a split validation on a specific model present in data.



## Syntax

[`dataout = viewsplitvalidation(data, fac)`](#syntax1)

## Description

The `viewsplitvalidation` function visualizes the split validation on a provided dataset by checking the similarities of excitation and emission spectral loading between different subsets. Two spectra are sufficiently similar if the Tucker congruence coefficient is greater than `0.95`.

> ***The actual split validation is already performed after a call to `fitparafac` with the option `mode='split'`. There, the results are shown as console output but no plots are shown. Use this function to find out how well the validation worked or where it did not succeed.***
 
The function checks if the model specified by the number of components `fac` is validated across different splits and the model obtained from all of the data, `"overall"` (see `fitparafac` function for options `"overall"` and `"split"`).

If validation check is passes, the function plots the validated models, displaying their loadings and contours, and provides diagnostic plots if validation fails. 

The function includes detailed error messages to help diagnose why a validation might have failed.

`viewsplitvalidation` checks for the presence of the `"overall"` model and splits. If `"overall`" does not exist the validation will only be performed across splits. But if the `splits` is empty, the function won't be able to perform any validation test and will cause an error.


## Input arguments
<details>
    <summary><b>`data` - dataset with PARAFAC models</b></summary>
    <i>drEEMdataset</i>
        
A dataset of the class `drEEMdataset` that passes the validation function `data.validate(data)`. 

PARAFAC models should be present in the overall dataset and all splits for full functionality.



</details>


<details open>
    <summary><b>`fac` - number of PARAFAC compoents in the validated model</b></summary>
    <i>numeric</i>
        
Specifies the number of components in the model you wish to validate.



</details>