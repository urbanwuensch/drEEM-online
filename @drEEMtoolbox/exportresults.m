function exportresults(data,filename,f,name_value)

arguments
    % Required
    data (1,1)
    filename (1,:) {mustBeText}
    f (1,1) {mustBeNumeric}

    % Optional (but important)
    name_value.ExWave ...
        (1,1) {mustBeNumeric} = 350
    name_value.iStart ...
        (1,1) {mustBeNumeric} = 378
    name_value.iEnd ...
        (1,1) {mustBeNumeric} = 424
    name_value.plot ...
        (1,:) {mustBeNumericOrLogical} = true
end
error('not yet implemented. Urban@work')
filename=[pwd,filesep,filename];

writetable(struct2table(data.history),filename,"FileType","spreadsheet",...
    "WriteMode","replacefile","Sheet",'dataset history')

calibrations=unique(data.SignalCalibration.type);

if numel(calibrations)==1
    idx=arrayfun(@(x) matches(x.function,calibrations),data.history);
    message=[calibrations{:},': Settings:: ',data.history(idx).details];
    writematrix(message,filename,"FileType","spreadsheet",...
        "WriteMode","overwritesheet","Sheet",'Signal calibration',...
        "Range","A1")

else
    error('not yet supported')
end
sc=table;
sc.filelist=data.filelist;
sc=[sc data.SignalCalibration];
writetable(sc,filename,"FileType","spreadsheet",...
    "Sheet",'Signal calibration',...
        "Range","A3")



% writetable(data.Smooth,filename,"FileType","spreadsheet",...
%     "WriteMode","overwritesheet","Sheet",'scatter treatment')




warning off
pl=table;
pl.filelist=data.filelist;
pl=[pl pickpeaks(data,plot=false)];
writetable(pl,filename,"FileType","spreadsheet",...
    "WriteMode","overwritesheet","Sheet",'coble peaks')
warning on
end