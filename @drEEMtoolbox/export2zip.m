function export2zip(data,filename)
% <a href = "matlab:doc export2zip">export2zip(data,filename) (click to access documentation)</a>
%
% <strong>INPUTS - Required</strong>
% data (1,1)      {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
% filename (1,:)  {mustBeText}
%
% <strong>EXAMPLE(S)</strong>
%   1. Export sample and blank EEMs, dataset status, history, and
%   processing steps to a zip file including README.txt for upload to data  repository
%       tbx.export2zip(samples,'project_XY_asPublished',char(datetime('today'))]);

arguments
    data (1,1) {mustBeA(data,'drEEMdataset'),drEEMdataset.validate(data)}
    filename (1,:) {mustBeText}
end
rootdir=pwd;
% Take care of pre-export data stuff
% Reverse scaling (if needed)
if contains(lower(data.status.signalScaling),'scaled to')
    data=drEEMtoolbox.scalesamples(data,'reverse');
end
% Add an entry to include the export as an action
idx=height(data.history)+1;
data.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,'exported data to zip file',[],data);


% Digest filename
filename=[char(erase(filename,'.zip')),'.zip'];

% Prepare temp folder for the export
tempfolder='drEEMexportTemporary';
mkdir(tempfolder)

cd(tempfolder)

% Export dataset history
% disp(['<strong> Writing to file: ',filename,'</strong>'])
t=drEEMhistory.convert2table(data.history);
t.backup=[];t.previous=[];

t.Properties.VariableNames={'Date / time','Method name','Function message','details','Comment by analyst'};

t=t(:,[1 2 5 3]);

writetable(t,'dataset_history.csv',...
    "WriteMode","overwrite")

% Export dataset status
flds=fieldnames(data.status);
stat=table;
warning off
for j=1:numel(flds)
    stat.Aspect{j}=flds{j};
    stat.Status{j}=data.status.(flds{j});
end
stat.Step={'Spectral correction';...
    'Inner filter effect correction';...
    'Blank subtraction';...
    'Fluorescence signal calibration';...
    'Scatter treatment';...
    'Fluorescence signal scaling';...
    'Absorbance unit'};
warning on
writetable(stat,'dataset_status.csv',...
    "WriteMode","overwrite")

% Export dataset scatter treatment
scatter_i=drEEMhistory.searchhistory(data.history,'handlescatter','all');

if isempty(scatter_i)
    % Do nothing
else
    start=1:3:3*numel(scatter_i);
    for j=1:numel(scatter_i)
        details=data.history(scatter_i(j)).details;
        warning off
        details=struct(details);
        warning on
        details=struct2table(details);

        details.plot=[];details.plottype=[];
        details.description=['handlescatter executed on ',char(data.history(scatter_i(j)).timestamp)];
        details.Properties.VariableNames=...
            {'Scatter deleted (Ray/Ram 1st/2nd)',...
            'Scatter interpolated (Ray/Ram 1st/2nd)',...
            'Negative fluorescence zero''ed',...
            'Rayleigh 1st (below,above)',...
            'Raman 1st (below,above)',...
            'Rayleigh 2nd (below,above)',...
            'Raman 2nd (below,above)',...
            'nm below Rayleigh 1st zero''ed',...
            'interpolation method',...
            'interpolation approach',...
            'samples',...
            'date / time'};
        varNames=details.Properties.VariableNames;
        for k=1:numel(varNames)
            details.(varNames{k})=num2str(details.(varNames{k}));
        end
        writetable(details,'dataset_scatterRemovalParameters.xlsx',"FileType","spreadsheet",...
            "WriteMode","inplace",...
            "Range",['A',num2str(start(j))],"PreserveFormat",true)

        % writetable(details,'dataset_scatterRemovalParameters.csv',...
        %     "WriteMode","overwrite")

    end
end

% Export optical metadata
warning off
data=drEEMtoolbox.fitslopes(data,quiet=true);
data=drEEMtoolbox.pickpeaks(data,quiet=true);
pl=table;
pl.filelist=data.filelist;
pl=[pl data.opticalMetadata];
writetable(pl,'dataset_opticalIndiciesAndPeakIntensities.csv',...
    "WriteMode","overwrite")
warning on


% Export metadata
warning off
pl=table;
if not(matches(data.metadata.Properties.VariableNames,'filelist'));
    pl.filelist=data.filelist;
    pl=[pl data.metadata];
else
    pl=data.metadata;
end
writetable(pl,'dataset_metadata.csv',...
    "WriteMode","overwrite")
warning on

% Export toolbox data
pl=struct2table(data.toolboxdata);
try pl.matlabToolboxes=[];end %#ok<*TRYNC>
try pl.settings=[];end
try pl.uifig=[];end

writetable(pl,'drEEM_versionInformation.csv',...
    "WriteMode","overwrite")


% Make readme
T=["The contents of this file was created with the drEEM toolbox for Matlab",newline,...
    newline,...
    "FOLDER INFORMATION",newline,...
    "The folder 'EEMs' contains fluorescence EEMs with emission wavelengths as rows and excitation wavelengths as columns.",newline,...
    "If blank EEMs were subtracted by the toolbox (and only then), these will be provided as an additional file, same filename with an '_blank' added before the '.csv'.",newline,...
    "The folder 'absorbance' spectra contains wavelengths in column 1 and absorbance data in column 2. The unit is specified in column 2 header.",newline,...
    "",newline,...
    "PROCESSING / STATUS INFORMATION",newline,...
    "Any processing of the data done by the toolbox is documented in the file 'dataset_history.csv'",newline,...
    "If scatter was removed by the toolbox, the settings for the removal are stored in the file 'dataset_scatterRemovalParameters.csv'",newline,...
    "The general status of the dataset (signal calibration, spectral correction, and more) is provided in the file 'dataset_status.csv'",newline,...
    "",newline,...
    "ENVIRONMENTAL / OPTICAL METADATA",newline,...
    "The DOM-specific optical indicies, peaks, and CDOM slopes are provided in the file 'dataset_opticalIndiciesAndPeakIntensities.csv'",newline,...
    "If provided, other metadata is stored in the file 'dataset_metadata.csv'",newline,...
    "",newline,...
    "OTHER",newline,...
    "For convenience of Matlab users, the dataset is also provided as .mat file 'dataset_dreem.mat'",newline,...
    "Information regarding the version of Matlab used and the drEEM toolbox is stored in 'drEEM_versionInformation.csv'",newline,...
    "",newline...
    "THIS IS THE END OF THIS FILE."]; 
FN = 'README.txt';  % better to use fullfile(path,name) 
fid = fopen(FN,'w');    % open file for writing (overwrite if necessary)
fprintf(fid,'%s',T);          % Write the char array, interpret newline as new line
fclose(fid);                  % Close the file (important)

% export dataset as mat file.
warning off
temp=struct(data);
temp2=rmfield(temp,{'history','models'});
for j=1:numel(temp.history)
    temp2.history(j,1)=struct(temp.history(j));
end
for j=1:numel(temp.models)
    temp2.models(j,1)=struct(temp.models(j));
end
warning on
dataExported=temp2;
clearvars temp temp2
save("dataset_dreem.mat","dataExported")

% export EEMs as csv's
mkdir('EEMs')
cd('EEMs')
for j=1:data.nSample

    eem=squeeze(data.X(j,:,:));

    eem=[data.Em,eem];
    eem=[nan,data.Ex';eem];
    writematrix(eem,[data.filelist{j},'.csv'],"Delimiter",',','WriteMode','overwrite')

    if not(isempty(data.XBlank))
        eem=squeeze(data.XBlank(j,:,:));

        eem=[data.Em,eem];
        eem=[nan,data.Ex';eem];
        writematrix(eem,[data.filelist{j},'_blank.csv'],"Delimiter",',','WriteMode','overwrite')
    end

end
cd ..

% export Absorbance as csv's
if not(isempty(data.abs))
    mkdir('absorbance spectra')
    cd('absorbance spectra')
    for j=1:data.nSample
    
        absData=data.abs(j,:)';
    
        absData=[data.absWave,absData];
        absData=array2table(absData,"VariableNames",{'wavelength',data.status.absorbanceUnit});
        writetable(absData,[data.filelist{j},'.csv'],"Delimiter",',','WriteMode','overwrite')
    end
cd ..
zip(filename,{'absorbance spectra','EEMs','*.csv','*.mat','*.txt'});
movefile([pwd,filesep,filename],[rootdir,filesep,filename])
cd(rootdir)
rmdir("drEEMexportTemporary",'s')

end