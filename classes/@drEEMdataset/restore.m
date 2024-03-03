function [dataout] = restore(data,whichone)
arguments
    data {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    whichone (1,1) {mustBeNumeric}
end
try
    mustBeLessThanOrEqual(whichone,numel(data.history))
catch
    error(['2nd input must be less than or equal to ',num2str(numel(data.history)),'.'])
end

temp=data.history(whichone).backup;
temp=drEEMbackup.convert2dataset(temp);
temp.history=data.history(1:whichone);
temp.toolboxdata=data.toolboxdata;

if nargout==0
    assignin("base",inputname(1),temp);
    disp(['<strong> State ',num2str(whichone),' in "',inputname(1), '" restored. </strong> Since no output argument was provided, the workspace variable was overwritten.'])
    return
else
    dataout=temp;
end


end