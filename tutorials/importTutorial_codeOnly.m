%% File import
cd(fileparts(matlab.desktop.editor.getActiveFilename))
clearvars
dr=drEEMtoolbox;
cd demofiles_AL_HYI\
samples=dr.importeems('* - Waterfall Plot Sample.dat');
blanks=dr.importeems('* - Waterfall Plot Blank.dat');
absorbance=dr.importabsorbance('* - Abs Spectra Graphs.dat');
cd ..

%% Integration of samples, blanks, absorbance into one dataset
[samples,blanks,absorbance]=dr.alignsamples(samples,blanks,absorbance);
samples.absWave=absorbance.absWave;
samples.abs=absorbance.abs;
dr.validatedataset(samples);
dr.addcomment(samples,"transferred absorbance to the sample EEM dataset")
dr.addcomment(samples,"Just another comment here")

clearvars absorbance

%% Metadata integration
samples.filelist=erase(samples.filelist,{' (01)'});
samples=dr.associatemetadata(samples,"metadata.xlsx",'sampleId');

%% All the processing before PARAFAC
samples=dr.processabsorbance(samples);
dr.addcomment(samples,"main issue addressed was the absorbance baseline offset")


samples=dr.ifecorrection(samples);
dr.addcomment(samples,"minor IFEs, but decided to correct.")

samples=dr.subtractblanks(samples,blanks);
dr.addcomment(samples,"Blanks looked fine (no sign of fluorescence). Raman scatter almost gone.")

data=dr.ramancalibration(samples,blanks);
dr.addcomment(data,"Calibration Raman scans looked good, integration parameters worked well.")

opt=handlescatterOptions; % or opt=handlescatter('options');
opt.ray1 = [30 15];
opt.ram1 = [5 5];
opt.ray2 = [15 15];
opt.ram2 = [5 5];
opt.cutout = [1 1 1 1];
opt.interpolate = [0 0 0 0];
opt.d2zero = 30;
opt.negativetozero = true;
opt.samples = 'all';
opt.iopt =  "normal";
opt.plot = false;
opt.imethod = 'inpaint';
data=dr.handlescatter(data,opt);
dr.addcomment(data,"First try of cutting scatter. Seems to work ok.")



% data=rmspikes(data);

%% Dataset modifications prior to PARAFAC
data=dr.subdataset(data,[],data.Em<310|data.Em>600,data.Ex>500);
dr.addcomment(data,"Trimmed the edges of the EEM to focus on sensible areas")


data=dr.scalesamples(data,1.7);
dr.addcomment(data,"Scaling of EEMs since main factor is estuarine mixing.")

dr.displayhistory(data)
dr.undolast(data)

data=dr.scalesamples(data,1.5);
dr.addcomment(data,"On second thought, I adjusted the scaling option slightly to have more drastic scaling.")


data = dr.zapnoise(data,5,[350 370],275);
dr.addcomment(data,"Demonstration of the zapnoise function")


data=dr.scalesamples(data,1.5);
dr.addcomment(data,"On second thought, I adjusted the scaling option slightly")

data=dr.subdataset(data,1,[],[]);
dr.addcomment(data,"Demonstration that deleting samples will also delete unscaled samples in the backup.")

%% PARAFAC part
data=dr.fitparafac(data,f=2:6, ...
    starts=2, ...
    convergence=1e-4,...
    parallelization=false, ...
    mode="overall");
dr.addcomment(data,"Outliertest equivalent")

dr.viewmodels(data)

data=dr.subdataset(data,[],[],data.Ex<260);
dr.addcomment(data,"Deleted short excitation due to noisyness.")

data=dr.fitparafac(data,f=2:6, ...
    starts=10, ...
    convergence=1e-6,...
    parallelization=false, ...
    mode="overall");

dr.viewmodels(data)
dr.addcomment(data,"Models loook fine for demo purpose.")

data=dr.splitdataset(data);
dr.addcomment(data,"First try at splitting. Let's see if this works.")

data=dr.fitparafac(data,f=2:6, ...
    starts=4, ...
    convergence=1e-6,...
    parallelization=false, ...
    mode="split");
dr.addcomment(data,"Models in all the splits (the overall model is there already).")

dr.viewmodels(data) % Validation results already visible here

data=dr.splitvalidation(data,5); % Just for visualization
dr.addcomment(data,"Validation successful!")

data=dr.scalesamples(data,'reverse');
dr.addcomment(data,"Reversed the scaling for export.")

dr.viewmodels(data)
dr.viewhistory(data) % All backups still here
dr.export2openfluor(data,2,'test2openfluor')

save("testSaving.mat","data") % This deletes backups
load("testSaving.mat","data")

dr.viewhistory(samples)  % No backups available


%% Experimental stuff

% This is a simple version of explorevariability for residual analysis
reportresidualanalysis(data,6,data.metadata.location)
