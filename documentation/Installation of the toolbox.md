<img src="top right corner logo.png" width="100" height="auto" align="right"/>
# Installation of the toolbox

The installation of the drEEM toolbox is straightforward and there are software routines to help ensure proper functionality and updating on demand.

## Download and installation

1. Go to [dreem.openfluor.org](https://dreem.openfluor.org/). In the top right corner of the website, click on "Download latest" and follow the instructions to download.
2. *Alternative*: In Matlab, click on the HOME tab, then find "Addons" to open the Addon Explorer and search for "drEEM toolbox"
3. Either way, you download an .mlapp file. Run it and follow the GUI instructions to "Download & install" the toolbox. Done.


## Requirements
The drEEM toolbox requires the [Statistics and Machine Learning Toolbox](https://www.mathworks.com/products/statistics.html) to calculate exponential CDOM slopes. Such fits are used to to calculate the long wavelength range CDOM slope and to extrapolate CDOM absorbance data in cases where the measured fluorescence emission exceeds the coverage of absorbance data. If you don't require these features, drEEM will run fine without the toolbox.

Considerable speed advantages can be achieved if the [Parallel Processing Toolbox](https://www.mathworks.com/products/parallel-computing.html) is installed. This toolbox is needed to take advantage of modern multi-core CPUs. However, the toolbox is designed to run without the toolbox as well.

drEEM can take advantage of algorithm refinements that have taken place over recent years via the [PLS_toolbox](https://eigenvector.com/software/pls-toolbox/). However, this requires PLS_toolbox to be purchased and installed. This toolbox is by no means required since drEEM ships with the free [N-Way toolbox](https://doi.org/10.1016/S0169-7439(00)00071-X).