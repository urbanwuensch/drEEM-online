function [dataout] = undo(data)
arguments
    data {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
end
n=numel(data.history);
if n==1
    error('Nothing to undo')
end

temp=data.history(n-1).backup;
temp=drEEMbackup.convert2dataset(temp);
temp.history=data.history(1:n-1);
temp.toolboxdata=data.toolboxdata;

if nargout==0
    assignin("base",inputname(1),temp);
    disp(['<strong> Last step (',num2str(n-1),') in dataset "',inputname(1), '" undone. </strong> Since no output argument was provided, the workspace variable was overwritten.'])
    return
else
    dataout=temp;
end

end