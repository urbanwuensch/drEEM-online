<img src="top right corner logo.png" width="100" height="auto" align="right"/>
# What's new

drEEM version 2 introduces a set of new functionality, workflows, object-oriented programming, visualizations, and graphical user interfaces that aim to make the processing of fluorescence EEMs straightforward for users with limited programming experience. We should not need to be Matlab experts to process fluorescence data.

Please head over to the section [Toolbox setup](dreem_workflow.html) to learn how to work with version 2. If you're used to [DOMFluor](https://doi.org/10.4319/lom.2008.6.572b) or [drEEM 0.1-0.6.x](https://doi.org/10.1039/C3AY41160E), things have changed considerably.

## Version 2.0.0


### New features

* [`drEEMdataset`](dreemdataset.html): A class object that stores fluorescence and absorbance data. Read more in the [documentation](dreemdataset.html)
* Detailed information regarding the status of processing for `drEEMdataset` objects. Loading a dataset from 5 years ago and wondering if IFE corrections had been done? The dataset will tell you from now on.
* [`drEEMhistory`](drEEMhistory.html): A class object that keeps a record of modifications by toolbox functions including their settings, date-time information, and comments if provided. Users can also add comments to the history independent from the toolbox to document the workflow.
* A new PARAFAC engine, courtesy of [Prof. Rasmus Bro](https://scholar.google.com/citations?user=gW_FGdQAAAAJ), that speeds up nonnegative PARAFAC by a factor of 4-5!
* PCA-based data exploration (raw data and residuals. Read more about [`explorevariability`](explorevariability.html).
* Interactive tool to define scatter treatment options. Read more about [`handlescatter`](handlescatter.hmtl).
* New data export functionalities. Open Science is amazing and we are fully committed to supporting those efforts!

### General improvements

* Rewrites of all drEEM functions with `arguments` input validation. For the user, this means smart input argument suggestions and quick and helpful input validation. Hitting the tab-key during scripting is extremely helpful from now.
* EEMs processing steps are implemented as **standalone** functions. No more custom code for vital standard operations (e.g. raman normalization or IFE correction). This also generally reduces the skills required for Matlab.
* Reduction in Addon Product dependencies. We've done our best to cut down the costly additional Matlab products requirements.
* Renamed functions to help occasional users remember / find functionality.