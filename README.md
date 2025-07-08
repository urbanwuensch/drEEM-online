# drEEM toolbox for MATLAB version 2
MATLAB toolbox aiding the multiway decomposition of fluorescence EEMs into underlying fluorescence components.

## Installation
1. Go to [dreem.openfluor.org](https://dreem.openfluor.org/). In the top right corner of the website, click on "Download latest" and follow the instructions to download from the Matlab File exchange.
2. *Alternative*: In Matlab, click on the HOME tab, then find "Addons" to open the Addon Explorer and search for "drEEM toolbox"
3. Either way, you download an .mlapp file. Run it and follow the GUI instructions to "Download & install" the toolbox. Done.

## Usage
- drEEM version 2 is based on object-oriented programming. To initialize the toolbox, type `tbx = drEEMtoolbox;`.
- Access the toolbox methods by calling e.g. `tbx.importeems(...)`
- To see which methods are available, type `tbx.` followed by hitting the TAB key to get a list of method suggestions.
- For orientation, method names generally refer to an action and an object, e.g. `importeems`, `fitparafac`, `subtractblanks`, `splitdataset`, etc.
- Type `doc drEEM` for for an overview of functions.

## Further reading (peer-reviewed publications)
- [drEEM toolbox](https://doi.org/10.1039/c3ay41160e)
- [N-way toolbox](https://doi.org/10.1016/S0169-7439(00)00071-X)
- [OpenFluor](https://doi.org/10.1039/C3AY41935E)

## Further watching on multiway analysis
- [Lecture series on multiway analysis](https://www.youtube.com/watch?v=_gIb6PzBEc4&list=PL4L59zaizb3E-Pgp-f90iKHdQQi15JJoL)

## Questions, comments , suggestions?
- Email the project team at [dreem@openfluor.net](mailto:dreem@openfluor.net)