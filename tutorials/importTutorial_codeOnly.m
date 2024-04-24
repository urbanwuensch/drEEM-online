%% File import
cd(fileparts(matlab.desktop.editor.getActiveFilename))
clearvars
tbx=drEEMtoolbox;
cd demofiles_AL_HYI\
samples=tbx.importeems('* - Waterfall Plot Sample.dat');
blanks=tbx.importeems('* - Waterfall Plot Blank.dat');
absorbance=tbx.importabsorbance('* - Abs Spectra Graphs.dat');
cd ..

%% Integration of samples, blanks, absorbance into one dataset
[samples,blanks,absorbance]=tbx.alignsamples(samples,blanks,absorbance);
samples.absWave=absorbance.absWave;
samples.abs=absorbance.abs;
tbx.validatedataset(samples);
tbx.addcomment(samples,"transferred absorbance to the sample EEM dataset");
tbx.addcomment(samples,"Just another comment here");
tbx.addcomment(samples,"And I had this other thought too");

clearvars absorbance

%% Metadata integration
samples.filelist=erase(samples.filelist,{' (01)'});
samples=tbx.associatemetadata(samples,"metadata.xlsx",'sampleId');
tbx.addcomment(samples,"Not 100% of samples matched. Here, one can make a comment to tell myself to investigate this.")
tbx.addcomment(samples,"Now here, I really had something interesting to say")


%% All the processing before PARAFAC
samples=tbx.processabsorbance(samples);
tbx.addcomment(samples,"main issue addressed was the absorbance baseline offset")


samples=tbx.ifecorrection(samples);
tbx.addcomment(samples,"minor IFEs, but decided to correct.")

samples=tbx.subtractblanks(samples,blanks);
tbx.addcomment(samples,"Blanks looked fine (no sign of fluorescence). Raman scatter almost gone.")

data=tbx.ramancalibration(samples,blanks);
tbx.addcomment(data,"Calibration Raman scans looked good, integration parameters worked well.")

data=tbx.handlescatter(data,'gui');
% Alternative "old" way
opt=handlescatterOptions; % or opt=handlescatter('options');
opt.ray1 = [30 10];
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
data=tbx.handlescatter(data,opt);
tbx.addcomment(data,"First try of cutting scatter. Seems to work ok.")



data=tbx.rmspikes(data,"details",false,thresholdFactor=15);
tbx.vieweems(data)
tbx.explorevariability(data)

%% Dataset modifications prior to PARAFAC
data=tbx.subdataset(data,[],data.Em<310|data.Em>600,data.Ex>500);
tbx.addcomment(data,"Trimmed the edges of the EEM to focus on sensible areas")


data=tbx.scalesamples(data,1.7);
tbx.addcomment(data,"Scaling of EEMs since main factor is estuarine mixing.")

tbx.displayhistory(data)

data=tbx.scalesamples(data,1.5);
tbx.addcomment(data,"On second thought, I adjusted the scaling option slightly to have more drastic scaling.")


data = tbx.zapnoise(data,5,[350 370],275);
tbx.addcomment(data,"Demonstration of the zapnoise function")


data=tbx.scalesamples(data,1.5);
tbx.addcomment(data,"On second thought, I adjusted the scaling option slightly")

data=tbx.subdataset(data,1,[],[]);
tbx.addcomment(data,"Demonstration that deleting samples will also delete unscaled samples in the backup.")

%% PARAFAC part
data=tbx.fitparafac(data,f=2:6, ...
    starts=2, ...
    convergence=1e-4,...
    parallelization=false, ...
    mode="overall");
tbx.addcomment(data,"Outliertest equivalent")

tbx.viewmodels(data)

data=tbx.subdataset(data,[],[],data.Ex<260);
tbx.addcomment(data,"Deleted short excitation due to noisyness.")

data=tbx.fitparafac(data,f=2:6, ...
    starts=10, ...
    convergence=1e-6,...
    parallelization=false, ...
    mode="overall");

tbx.viewmodels(data)
tbx.addcomment(data,"Models loook fine for demo purpose.")

data=tbx.splitdataset(data);
tbx.addcomment(data,"First try at splitting. Let's see if this works.")

data=tbx.fitparafac(data,f=2:6, ...
    starts=4, ...
    convergence=1e-6,...
    parallelization=false, ...
    mode="split");
tbx.addcomment(data,"Models in all the splits (the overall model is there already).")

tbx.viewmodels(data) % Validation results already visible here

data=tbx.splitvalidation(data,5); % Just for visualization
tbx.addcomment(data,"Validation successful!")

data=tbx.scalesamples(data,'reverse');
tbx.addcomment(data,"Reversed the scaling for export.")

tbx.viewmodels(data)
tbx.viewhistory(data)
tbx.export2openfluor(data,2,'test2openfluor')

save("testSaving.mat","data") % This deletes backups
load("testSaving.mat","data")

tbx.viewhistory(samples)  % No backups available


%% Experimental stuff

% This is a simple version of explorevariability for residual analysis
reportresidualanalysis(data,6,data.metadata.location)
