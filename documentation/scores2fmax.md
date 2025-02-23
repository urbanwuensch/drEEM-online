<img src="top right corner logo.png" width="100" height="auto" align="right"/>
# scores2fmax #

Convert model scores to Fmax.

## Syntax

	
###[[Fmax](#Fmax),[scores](#scores)]=scores2fmax([data](#data),[f](#f))###

## Description

Convert model scores to Fmax. While scores have no unit, conversion of scores (A) by multiplication with the maxima in B and C for each component yields their intensities in the units of the original dataset. Depending on the calibration, that could be Raman units, or quinine sulfate equivalents.



## Required Input Arguments

**data** - Dataset structure. <a name="data"></a>

#### data - drEEMdataset  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods.


**f** - numeric scalar, must point to a model. <a name="f"></a>

Number of components to be converted.


## Output Arguments

**Fmax** - Dataset structure. <a name="Fmax"></a>

`nSample x f` matrix with the Fmax values.

**scores** - Dataset structure. <a name="scores"></a>

`nSample x f` matrix with the score values.
