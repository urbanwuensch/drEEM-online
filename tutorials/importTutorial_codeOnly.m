%% File import
cd(fileparts(matlab.desktop.editor.getActiveFilename))
clearvars
cd demofiles_AL_HYI\
samples=importeems('* - Waterfall Plot Sample.dat');
blanks=importeems('* - Waterfall Plot Blank.dat');
absorbance=importabsorbance('* - Abs Spectra Graphs.dat');
cd ..

%% Integration of samples, blanks, absorbance into one dataset
[samples,blanks,absorbance]=alignsamples(samples,blanks,absorbance);
samples.absWave=absorbance.absWave;
samples.abs=absorbance.abs;
samples.validate(samples);
addcomment(samples,"transferred absorbance to the sample EEM dataset")
clearvars absorbance

%% Metadata integration
samples.filelist=erase(samples.filelist,{' (01)'});
samples=associatemetadata(samples,"metadata.xlsx",'sampleId');

%% All the processing before PARAFAC
samples=processabsorbance(samples);
addcomment(samples,"main issue addressed was the absorbance baseline offset")
test=samples;
addcomment(test,"My 1st comment was bibbidi")
addcomment(test,"My 2nd comment was bob")



samples=ifecorrection(samples);
addcomment(samples,"minor IFEs, but decided to correct.")

samples=subtractblanks(samples,blanks);
addcomment(samples,"Blanks looked fine (no sign of fluorescence). Raman scatter almost gone.")

data=ramancalibration(samples,blanks);
addcomment(data,"Calibration Raman scans looked good, integration parameters worked well.")

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
data=handlescatter(data,opt);
addcomment(data,"First try of cutting scatter. Seems to work ok.")



% data=rmspikes(data);


%% Dataset modifications prior to PARAFAC
data=subdataset(data,[],data.Em<310|data.Em>600,data.Ex>500);
addcomment(data,"Trimmed the edges of the EEM to focus on sensible areas")


data=scalesamples(data,1.7);
addcomment(data,"Scaling of EEMs since main factor is estuarine mixing.")

data = zapnoise(data,5,[350 370],275);
addcomment(data,"Demonstration of the zapnoise function")


data=scalesamples(data,1.5);
addcomment(data,"On second thought, I adjusted the scaling option slightly")

data=subdataset(data,1,[],[]);
addcomment(data,"Demonstration that deleting samples will also delete unscaled samples in the backup.")

%% PARAFAC part
data=fitparafac(data,f=2:6, ...
    starts=2, ...
    convergence=1e-4,...
    parallelization=false, ...
    mode="overall");
addcomment(data,"Outliertest equivalent")

viewmodels(data)

data=subdataset(data,[],[],data.Ex<260);
addcomment(data,"Deleted short excitation due to noisyness.")

data=fitparafac(data,f=2:6, ...
    starts=10, ...
    convergence=1e-8,...
    parallelization=true, ...
    mode="overall");

viewmodels(data)
addcomment(data,"Models loook fine for demo purpose.")

data=splitdataset(data);
addcomment(data,"First try at splitting. Let's see if this works.")

data=fitparafac(data,f=2:6, ...
    starts=10, ...
    convergence=1e-8,...
    parallelization=true, ...
    mode="split");
addcomment(data,"Models in all the splits (the overall model is there already).")

viewmodels(data) % Validation results already visible here

data=splitvalidation(data,5); % Just for visualization
addcomment(data,"Validation successful!")

data=scalesamples(data,'reverse');
addcomment(data,"Reversed the scaling for export.")

viewmodels(data)
viewhistory(data) % All backups still here
export2openfluor(data,2,'test2openfluor')

save("testSaving.mat","data") % This deletes backups
load("testSaving.mat","data")

viewhistory(samples)  % No backups available


%% Experimental stuff

% This is a simple version of explorevariability for residual analysis
reportresidualanalysis(data,6,data.metadata.location)
