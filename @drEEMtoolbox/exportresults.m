function exportresults(data,filename,f)

arguments
    % Required
    data (1,1)  {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    filename (1,:) {mustBeText}
    f (1,1) {mustBeNumeric}
end
fs=drEEMdataset.modelsWithContent(data);
if not(ismember(f,fs))
    error('input to "f" must point to an existing PARAFAC model. Export cancelled.')
end
%%
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
    disp('    Attempted to delete an existing file at the specified location.')
end
% Dataset history
disp(['<strong> Writing to file: ',filename,'</strong>'])
t=drEEMhistory.convert2table(data.history);
t.backup=[];t.previous=[];
writetable(t,filename,"FileType","spreadsheet",...
    "WriteMode","replacefile","Sheet",'dataset history')
disp('    Finished spreadsheet: dataset history')
% Dataset status
stat=struct;
flds=fieldnames(data.status);
stat=table;
warning off
for j=1:numel(flds)
    stat.Step{j}=flds{j};
    stat.Value{j}=data.status.(flds{j});
end
warning on
writetable(stat,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",'dataset status')
disp('    Finished spreadsheet: dataset status')

% Dataset scatter treatment
sci=drEEMhistory.searchhistory(data.history,'handlescatter','all');

if isempty(sci)
    writematrix("no scatter treatment found",filename,"FileType","spreadsheet",...
        "WriteMode","overwritesheet","Sheet",'scatter treatment')
else
    start=1:14:14*numel(sci);
    for j=1:numel(sci)
        det=data.history(sci(j)).details;
        flds=fieldnames(det);
        warning off
        sct=table;
        for k=1:numel(flds)
            sct.option{k}=flds{k};
            sct.Value{k}=det.(flds{k});
        end
        warning on
        writetable(sct,filename,"FileType","spreadsheet",...
            "WriteMode","inplace","Sheet",'scatter treatment',...
            "Range",['A',num2str(start(j))])

    end
end
disp('    Finished spreadsheet: scatter treatment')

% Coble peaks
warning off
pl=table;
pl.filelist=data.filelist;
[~,npl]=drEEMtoolbox.pickpeaks(data,plot=false);
pl=[pl npl];
writetable(pl,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",'Peaks & indicies')
warning on
disp('    Finished spreadsheet: Peaks & indicies')

% Models overview
mover=drEEMmodel.convert2table(data.models(fs(1)));
mover.loads=[];mover.leverages=[];mover.sse=[];mover.componentContribution=[];
mover.status=string(mover.status);
for j=2:numel(fs)
    mhere=drEEMmodel.convert2table(data.models(fs(j)));
    mhere.loads=[];mhere.leverages=[];mhere.sse=[];mhere.componentContribution=[];
    mhere.status=string(mhere.status)
    mover=[mover;mhere];
end
writetable(mover,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",'PARAFAC model overview')
disp('    Finished spreadsheet: PARAFAC model overview')

% Model
loads=data.models(f).loads;
scores=loads{1};

if contains(lower(data.status.signalCalibration),'scaled to')
    warning(['<strong> Your data is still scaled and thus scores (and component fl. maxima) reflect' ...
        ' qualitative and not quantitative changes. </strong>' ...
        ' If this is undesired, please reverse scaling by calling "scalesamples(data,''reverse'').' ...
        ' Press any key to acknowledge and continue. '])
    waitforbuttonpress
end

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



