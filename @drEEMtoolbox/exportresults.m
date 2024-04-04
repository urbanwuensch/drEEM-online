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
filename=[pwd,filesep,filename];
delete(filename)
% Dataset history
t=drEEMhistory.convert2table(data.history);
t.backup=[];t.previous=[];
writetable(t,filename,"FileType","spreadsheet",...
    "WriteMode","replacefile","Sheet",'dataset history')

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

% Coble peaks
warning off
pl=table;
pl.filelist=data.filelist;
[~,npl]=drEEMtoolbox.pickpeaks(data,plot=false);
pl=[pl npl];
writetable(pl,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",'Peaks & indicies')
warning on


% Models overview
mover=drEEMmodel.convert2table(data.models(fs(1)));
mover.loads=[];mover.leverages=[];mover.sse=[];mover.componentContribution=[];
for j=2:numel(fs)
    mhere=drEEMmodel.convert2table(data.models(fs(j)));
    mhere.loads=[];mhere.leverages=[];mhere.sse=[];mhere.componentContribution=[];
    mover=[mover;mhere];
end
writetable(mover,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",'PARAFAC model overview')

% Model
loads=data.models(f).loads;
scores=loads{1};
scoretable=table;
scoretable.sample=data.filelist;
for j=1:size(scores,2)
    scoretable.(['C',num2str(j)])=scores(:,j);
end
writetable(scoretable,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",[num2str(f),'C scores'])

load=table;
load.sample=data.Ex;
for j=1:size(scores,2)
    load.(['C',num2str(j)])=loads{3}(:,j);
end
writetable(scoretable,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",[num2str(f),'C ex loadings'])

load=table;
load.sample=data.Em;
for j=1:size(scores,2)
    load.(['C',num2str(j)])=loads{2}(:,j);
end
writetable(scoretable,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",[num2str(f),'C em loadings'])



end



