function exportresults(data,f,filename)
% <a href = "matlab:doc exportresults">exportresults(data,filename,f) (click to access documentation)</a>
%
% <strong>Inputs - Required</strong>
% data (1,1)      {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
% f (1,1)         {mustBeNumeric}
% filename (1,:)  {mustBeText}

arguments
    % Required
    data (1,1)      {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    f (1,1)         {mustBeNumeric}
    filename (1,:)  {mustBeText}
end
fs=drEEMdataset.modelsWithContent(data);
if not(ismember(f,fs))
    error('input to "f" must point to an existing PARAFAC model. Export cancelled.')
end
%%
% Reverse scaling (if needed)
if contains(lower(data.status.signalScaling),'scaled to')
    data=drEEMtoolbox.scalesamples(data,'reverse');
end

% Add an entry to include the export as an action
idx=height(data.history)+1;
data.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,'exported results',[],data);
filename=strsplit(char(filename),'.');
filename=filename{1};
filename=[filename,'.xlsx'];

filename=[pwd,filesep,filename];
disp(' ')
if isfile(filename)
    delete(filename)
end


% Export dataset history
disp(['<strong> Writing to file: ',filename,'</strong>'])
t=drEEMhistory.convert2table(data.history);
t.backup=[];t.previous=[];

t.Properties.VariableNames={'Date / time','Method name','Function message','details','Comment by analyst'};

t=t(:,[1 2 5 3]);

writetable(t,filename,"FileType","spreadsheet",...
    "WriteMode","replacefile","Sheet",'dataset history')
disp('    Finished spreadsheet: dataset history')


% Export dataset status
flds=fieldnames(data.status);
stat=table;
warning off
for j=1:numel(flds)
    stat.Aspect{j}=flds{j};
    stat.Status{j}=data.status.(flds{j});
end
stat.Properties.VariableNames{1}='Step';
stat.Step={'Spectral correction';...
    'Inner filter effect correction';...
    'Blank subtraction';...
    'Fluorescence signal calibration';...
    'Scatter treatment';...
    'Fluorescence signal scaling';...
    'Absorbance unit'};
warning on
writetable(stat,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",'dataset status')
disp('    Finished spreadsheet: dataset status')

% Export dataset scatter treatment
scatter_i=drEEMhistory.searchhistory(data.history,'handlescatter','all');

if isempty(scatter_i)
    writematrix("no scatter treatment found",filename,"FileType","spreadsheet",...
        "WriteMode","overwritesheet","Sheet",'scatter treatment')
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
        
        writetable(details,filename,"FileType","spreadsheet",...
            "WriteMode","inplace","Sheet",'scatter treatment',...
            "Range",['A',num2str(start(j))],"PreserveFormat",true)

    end
end
disp('    Finished spreadsheet: scatter treatment')

% Export optical metadata
warning off
data=drEEMtoolbox.fitslopes(data,quiet=true);
data=drEEMtoolbox.pickpeaks(data,quiet=true);
pl=table;
pl.filelist=data.filelist;
pl=[pl data.opticalMetadata];
writetable(pl,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",'Peaks & indicies')
warning on
disp('    Finished spreadsheet: Peaks & indicies')

% Export models overview
mover=table;
mover.('# of components')=fs(1);
mover=[mover , drEEMmodel.convert2table(data.models(fs(1)))];
mover.loads=[];mover.leverages=[];mover.sse=[];mover.componentContribution=[];
mover.status=string(mover.status);
if fs(1)==f
    mover.("selected for export")="yes";
else
    mover.("selected for export")="no";
end
for j=2:numel(fs)
    mhere=table;
    mhere.('# of components')=fs(j);
    mhere=[mhere , drEEMmodel.convert2table(data.models(fs(j)))];
    mhere.loads=[];mhere.leverages=[];mhere.sse=[];mhere.componentContribution=[];
    mhere.status=string(mhere.status);
    if fs(j)==f
        mhere.("selected for export")="yes";
    else
        mhere.("selected for export")="no";
    end
    mover=[mover;mhere];
end
writetable(mover,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",'PARAFAC model overview')
disp('    Finished spreadsheet: PARAFAC model overview')

% Export splitdataset settings
split_i=drEEMhistory.searchhistory(data.history,'splitdataset','all');
if not(isempty(split_i))
    splitH=data.history(split_i(1));
    splittable=struct2table(splitH.details);
    splittable.Properties.VariableNames={'Split by Variable','Number of splits','Assignment into splits'};
    if isempty(splittable.("Split by Variable"))
        splittable.("Split by Variable")='option not used.';
    end
    splittable.('Date / time created')=splitH.timestamp;
    splittable.('Dataset history entry #')=split_i(1);
    if numel(split_i)>1
        for j=2:numel(split_i)
            splitH=data.history(split_i(j));
            temp=struct2table(splitH.details);
            temp.Properties.VariableNames={'Split by Variable','Number of splits','Assignment into splits'};
            if isempty(temp.("Split by Variable"))
                temp.("Split by Variable")='option not used.';
            end
            temp.('Date / time created')=splitH.timestamp;
            temp.('Dataset history entry #')=split_i(j);
            splittable=[splittable;temp];
        end
    end
    writetable(splittable,filename,"FileType","spreadsheet",...
        "WriteMode","overwritesheet","Sheet",'Split-validation approach')
    disp('    Finished spreadsheet: Split-validation approach')

end
% Model
loads=data.models(f).loads;
scores=loads{1};

FMax=nan(size(scores,1),size(loads{2},2));
for i=1:size(FMax,1)
    FMax(i,:)=(scores(i,:)).*(max(loads{2}).*max(loads{3}));
end
clearvars scores

scoretable=table;
scoretable.sample=data.filelist;
for j=1:size(FMax,2)
    scoretable.(['C',num2str(j)])=FMax(:,j);
end
writetable(scoretable,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",[num2str(f),'C Fl. max.'])

load=table;
load.sample=data.Ex;
for j=1:size(FMax,2)
    load.(['C',num2str(j)])=loads{3}(:,j);
end
writetable(load,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",[num2str(f),'C ex loadings'])

load=table;
load.sample=data.Em;
for j=1:size(FMax,2)
    load.(['C',num2str(j)])=loads{2}(:,j);
end
writetable(load,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",[num2str(f),'C em loadings'])
disp('    Finished spreadsheets for selected PARAFAC model (scores and loadings)')
disp('<strong> Success! Done with result export.</strong>')



end



