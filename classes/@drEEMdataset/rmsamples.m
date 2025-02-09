function [dataout] = rmsamples(data,index)
arguments
    data  (1,1) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    index {mustBeNumericOrLogical}
end

if isempty(index)|sum(index)==0
    %warning('rmsamples: input "index" was empty. No action taken.')
    dataout=data;
    return
end

drEEMdataset.validate(data)

dataout=data;

if islogical(index)|isnumeric(index)
    dataout.X(index,:,:)=[];
    dataout.i(index)=[];
    dataout.filelist(index)=[];
    dataout.metadata(index,:)=[];
    if not(isempty(dataout.opticalMetadata))
        dataout.opticalMetadata(index,:)=[];
    end
    if not(isempty(dataout.XBlank))
        dataout.XBlank(index,:,:)=[];
    end
    if not(isempty(dataout.abs))
        dataout.abs(index,:)=[];
    end
    dataout.nSample=size(dataout.X,1);
else
    error("input to index must be numeric or logical")
end

f=drEEMdataset.modelsWithContent(dataout);
if not(isempty(f))
    dataout.models=drEEMmodel;
    idx=height(dataout.history)+1;
    dataout.history(idx,1)=...
        drEEMhistory.addEntry(mfilename,...
        'deleted models due to call to rmsamples (likely through subdataset)',[],dataout);
end



if islogical(index)
    index=find(index);
end

ident=data.filelist(index);
if iscolumn(ident)
    ident=ident';
end
if isscalar(ident)
    ident=ident{1};
else
    newident=[];
    for j=1:numel(ident)
        newident=[newident,' ; ',ident{j}];
    end
    ident=newident;clearvars newident;
end


idx=height(dataout.history)+1;
dataout.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,['deleted samples ',ident],[],dataout);
drEEMdataset.validate(dataout)
