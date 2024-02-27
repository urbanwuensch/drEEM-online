function [dataout] = rmexcitation(data,index)
arguments
    data  (1,1) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    index {mustBeNumericOrLogical}
end

if isempty(index)|sum(index)==0
    %warning('rmexcitation: input "index" was empty. No action taken.')
    dataout=data;
    return
end

drEEMdataset.validate(data)

dataout=data;

if islogical(index)|isnumeric(index)
    dataout.X(:,:,index)=[];
    dataout.Ex(index)=[];
    dataout.nEx=size(dataout.X,3);
else
    error("input to index must be numeric or logical")
end

f=drEEMdataset.modelsWithContent(dataout);
if not(isempty(f))
    dataout.models=drEEMmodel;
    disp('A call to subdataset with pre-existing models results in their deletion.')
end


if islogical(index)
    index=find(index);
end

ident=data.Ex(index);
if iscolumn(ident)
    ident=ident';
end

idx=height(dataout.history)+1;
dataout.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,...
    ['deleted excitation wavelengths ',num2str(ident)],[],dataout);

drEEMdataset.validate(dataout)
