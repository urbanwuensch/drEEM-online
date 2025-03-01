function dataout = addcomment(data,comment)
% <a href = "matlab:doc addcomment">dataout = addcomment(data,comment) (click to access documentation)</a>
%
% <strong>Add a comment to a drEEMdataset object</strong> to document your analysis process
%
% <strong>INPUTS - Required</strong>
%   data (1,1)    {mustBeA("drEEMdataset"),drEEMdataset.validate}
%   comment (1,:) {mustBeText}
%
% <strong>EXAMPLE(S)</strong>
%   samples = tbx.addcomment(data,'This last modification really made a difference');

arguments
    data (1,1)    {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    comment (1,:) {mustBeText}
end

% Experimental feature; overwrite workspace variable, needs no outputarg check
if drEEMtoolbox.outputscenario(nargout)=="explicitOut"
    nargoutchk(1,1)
end

idx=height(data.history);
dataout=data;
if not(dataout.history(idx).usercomment=="")
    % Solution 2: add a string
    dataout.history(idx).usercomment=...
        [dataout.history(idx).usercomment,string(comment)];

else % New entry
    dataout.history(idx).usercomment=string(comment);
end

if drEEMtoolbox.outputscenario(nargout)=="implicitOut"
    assignin("base",inputname(1),dataout);
    disp(['<strong> "',inputname(1), '" processed. </strong> Since no output argument was provided, the workspace variable was overwritten.'])
    return
end

end