<img src="top right corner logo.png" width="100" height="auto" align="right"/>

# handlescatter #
Excise and treat Excitation-Emission Matrix (EEM) scatter and optionally interpolate between missing values.



## Syntax
### [dataout = handlescatter(data)](#syntax1) ###
### [dataout = handlescatter(data, 'gui')](#syntax1) ###
### [dataout = handlescatter(data, options)](#syntax1) ###
### [opts = handlescatter('options')](#syntax1)###



## Description ##
### [dataout](#varargout) = handlescatter([data](#varargin)) <a name="syntax1"></a>
The function `handlescatter` handles primary and secondary Rayleigh and Raman scatter, by either replacing the values around the scatter with NaNs or interpolation. Additionally, it can set values to `zero` at a specified distance below the 1st order Rayleigh scatter line (where Emission wavelength equals Excitation wavelength). The function also offers optional plotting to compare the raw, cut and final EEMs for quality check. When no `options` is provided as input, the function will use the default `options` for its processing. That include cutting out all the four scatters from all samples and no interpolation. See Input arguments section for `options` default values.


>
### [dataout](#varargout) = handlescatter([data, 'gui'](#varargin)) <a name="syntax1"></a>
Running `handlescatter` with `gui` options opens up the `viewscatter`'s user interface app. The interface allows users to apply settings for treating 1st and 2nd order Rayleigh and Raman scatter and visualize the results in real-time.<br>
Interface Components include:<br>

<strong>Control Panel:<br></strong>

- `Test On`: Select the sample to view the plots for. Use the arrow buttons to navigate through different samples in `data`.
- `Apply`: Apply the current scatter treatment settings to the whole `data`.
- `Save Settings`: Save the settings used for `handlescatter` in a variable called `scatteroptions` in the workspace.
- `Apply & Close`: Apply the current settings and close the interface.
- `Plot`: Toggle between `raw` and `treated` data visualization.

<strong>Scatter Treatment Settings:<br></strong>

- `Cut`: Enable or disable the cut option for the chosen scatter.
- `Int.`: Enable or disable the interpolation option for the chosen scatter.
- `Below`: Set the nm distance below the center of the chosen scatter for  scatter cut. Adjusting this value will automatically be reflected on the plots with red bars around the center of the scatter.
- `Above`: Set the nm distance above the center of the chosen scatter for scatter cut. Adjusting this value will automatically be reflected on the plots with red bars around the center of the scatter.


<strong>Miscellaneous Settings:<br></strong>

- `Set Negative Fluorescence Values to Zero`: Enable this option to set all negative fluorescence values to zero.
- `nm Distance to Zero`: Specify the nm distance from the center of the 1st order Rayleigh scatter below which all values will be set to zero.
- `Interpolation method`: Toggle between `vector` and `inpaint` interpolation for the scatter treatment.

<strong>Visualization:<br></strong>


- `Scatter-Centered Spectra`: this tab displays the scatter-centered spectra for 1st and 2nd order Rayleigh and Raman scatter. Red bars indicate the chosen settings using `below` and `above` in the `scatter treatment settings` panel.
- `Excitation-Emission Matrix`: This tab visualizes the `raw` or `treated` excitation-emission matrix after applying the scatter removal settings.

>
### [dataout](#varargout) = handlescatter([data, options](#varargin)) <a name="syntax1"></a>
`handlescatter` can obtain and process the scatter handling using user customized `options` supplied as a single structure. Default values are obtained by calling `options = handlescatter('options')`. the fields in `options` can be modified and passed out to the function. See Input arguments section for the fields of `options`.<br>
Example:<br> 
`options = handlescatter('options')` to obtain the default options. <br> `options.ray1 = [25 15]` to change the lower and upper distance from the center for 1st order Rayleigh scatter cut, <br> `options.ram1 = [10 12]` to change the lower and upper distance from the center for 1st order Raman scatter cut, <br>
`options.interpolate = [0 0 0 1]` to turn off interpolation for all scatters except the 2nd order Raman scatter, <br>
`dataout = handlescatter(data, options)` to run the function using the above-modified `options`.

>
### [opts](#varargout) = handlescatter(['options'](#varargin)) <a name="syntax1"></a>
Obtains the default `options` of the function and save them in `opts`. These can be modified and later passed down to function by calling `handlescatter(data, opts)`.



## Input arguments ##
#### data - drEEMdataset for handling scatters  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods that the `handlescatter` will act on it.


#### options - specify the options to be used for the scatter handling  <a name="varargin"></a> <br> Type: structure
The default setting in the structure are obtained by calling `options = handlescatter('options')`. The `options` has various fields that can be modified based on the user's needs. The fields include:<br>


- <strong>cutout:</strong> Specify which scatter to cut from the data in the following order: [Ray1 Ram1 Ray2 Ram2]. To cut choose `1` and to leave out choose `0`. Default values are `[1 1 1 1]` 
<br>
<br>
- <strong>interpolate:</strong> Specifies whether to interpolate over the cut scatter regions. `1` indicates interpolation, `0` indicates no interpolation over the specified scatter in the following order for scatters:[Ray1 Ram1 Ray2 Ram2]. Default values are `[0 1 1 1]`
<br>
<br>
- <strong>ray1:</strong> Specifies the range around the 1st Rayleigh scatter peak to cut (and interpolate, if chosen). Format: [below, above] in nanometers (nm) from the center of the scatter peak. Default is `[10 10]`.
<br>
<br>
- <strong>ram1:</strong> Specifies the range around the 1st Raman scatter peak to cut (and interpolate, if chosen). Format: [below, above] in nanometers (nm) from the center of the scatter peak. Default is `[15 15]`.
<br>
<br>
- <strong>ray2:</strong> Specifies the range around the 2nd Rayleigh scatter peak to cut (and interpolate, if chosen). Format: [below, above] in nanometers (nm) from the center of the scatter peak. Default is `[5 5]`.
<br>
<br>
- <strong>ram2:</strong> Specifies the range around the 2nd Raman scatter peak to cut (and interpolate, if chosen). Format: [below, above] in nanometers (nm) from the center of the scatter peak. Default is `[5 5]`.
<br>
<br>
- <strong>d2zero:</strong> Specifies the distance in nm below Ray1 below which the emission values are forced to `zero`. Default value is `60` nm.
<br>
<br>
- <strong>iopt:<br></strong> Specifies the method for handling overlapping `NaN` regions during interpolation. `'normal'` means standard interpolation, `'conservative'` means leaving `NaN`s uninterpolated. Default is `'normal'`.
<br>
<br>
- <strong>imethod:</strong> Specifies the interpolation method to use for filling cut scatters.`'inpaint'` uses an inpainting algorithm, `'fillmissing'` uses MATLAB's fillmissing function. '`inpaint'` applies del^2 over the entire array, then drops those parts of the array which do not have any contact with NaNs. '`inpaint'` uses a least squares approach, but it does not modify known values. In the case of small arrays, this method is quite fast as it does very little extra work. Extrapolation behavior is linear. See inpaint: Copyright (c) 2017, Damien Garcia. `fillmissing` options fills missing values using Shape-preserving piecewise cubic spline interpolation. For any missing values at the ends of the array, it uses the nearest non-missing value. This ensures that data is completed with a smooth and shape-preserving interpolation method, while boundary gaps are filled with adjacent values. Default method used in `handlescatter` is `inpaint`.
<br>
<br>
- <strong>negativetozero:</strong> Specifies whether to convert all negative values in the data to `zero`. It is useful for ensuring non-negative data values. Default is `'on'`.
<br>
<br>
- <strong>plot:</strong> Specifies whether to plot the raw, cut, and final Excitation-Emission Matrices (EEMs). `'on'` enables plotting, `'off'` disables it. NOTE: Plots will always be shown for all samples, but simply closing the window will terminate plotting and return the smoothed data.
<br>
<br>
- <strong>samples:</strong> Specifies which samples to process. `'all'` means process all samples. A numeric vector specifies which samples to process, for example `[2 3 4 5]`, will only apply the function on samples `2` to `5`. Default is `'all'`..
<br>
<br>
- <strong>plottype:</strong> Specifies the type of plot to display when plotting is enabled. Options are `'mesh'`, `'surface'`, or `'contourf'`. Default is `mesh`.








## Output arguments (optional)##
#### dataout - drEEMdataset with handled scatters  <a name="varargin"></a> <br> Type: drEEMdataset class object
Dataset of the class `drEEMdataset`, with standardized contents and automated validation methods, in which the scatters are treated according to the specified options (these `options` are stored in the `history` field of the `dataout`). If no output argument is specified, the function overwrites the original object, `data`, in the workspace.




## See Also ##

<a href="link.com">Link1</a> | 
<a href="link.com"> Link2 </a> |
<a href="link.com"> Link3 </a> |


## Topics ##