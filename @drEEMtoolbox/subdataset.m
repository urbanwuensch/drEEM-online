function dataout=subdataset(data,options)
% <a href = "matlab:doc subdataset">dataout=subdataset(data,options) (click to access documentation)</a>
%
% <strong>Inputs - Required</strong>
% data (1,1) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
% 
% <strong>Inputs - Optional</strong>
% options.outSample (1,:)   {mustBeNumericOrLogical(options.outSample)} = false
% options.outEm (1,:)       {mustBeA(options.outEm,'logical')} = false
% options.outEx (1,:)       {mustBeA(options.outEx,'logical')} = false
%
% <strong>EXAMPLE(S)</strong>
%   1. Delete sample based on name
%       samples = tbx.subdataset(samples,outSample=matches(samples.filelist,'LCEP23 (01)'));
%   2. Delete sample based identifier
%       samples = tbx.subdataset(samples,outSample=samples.i==2);
%   3. Delete emission ranges
%       samples = tbx.subdataset(samples,outEm=samples.Em<300|samples.Em>700);
%   4. Delete excitation ranges
%       samples = tbx.subdataset(samples,outEx=samples.Ex<240|samples.Ex>450);
%   5. Delete specific excitation
%       samples = tbx.subdataset(samples,outEx=samples.Ex==275);
%   6. drEEM ships with a <strong>nearest neighbor function</strong>: isNearest, use it if wavelengths have many decimals
%       samples = tbx.subdataset(samples,outEm=tbx.isNearest(samples.Em,349));
arguments
    data (1,1) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    options.outSample (1,:) {mustBeNumericOrLogical(options.outSample)} = false
    options.outEm (1,:) {mustBeA(options.outEm,'logical')} = false
    options.outEx (1,:) {mustBeA(options.outEx,'logical')} = false
end
% Experimental feature; overwrite workspace variable, needs no outputarg check
if drEEMtoolbox.outputscenario(nargout)=="explicitOut"
    nargoutchk(1,1)
end
outSample=options.outSample;
outEm=options.outEm;
outEx=options.outEx;
% Validation of outSample input (not possible in the arguments block)
try 
    mustBeLessThanOrEqual(outSample,data.nSample)
catch ME
    error(['outSample: ',ME.message])
end

% Validation of outEx input (not possible in the arguments block)
try 
    mustBeLessThanOrEqual(outEx,data.nEx)
catch ME
    error(['outEx: ',ME.message,' Do not provide wavelengths.'])
end
% Validation of outEm input (not possible in the arguments block)
try 
    mustBeLessThanOrEqual(outEm,data.nEm)
catch ME
    error(['outEm: ',ME.message,' Do not provide wavelengths.'])
end

% Find first unscaled dataset and subset it as well (otherwise, errors occur
% during scaling reversion)
idx=drEEMhistory.searchhistory(data.history,'scalesamples','first');
if not(isempty(idx))
    previouseem=data.history(idx).previous;
    previouseem=drEEMtoolbox.subdataset(previouseem,...
        outSample=outSample,outEm=outEm,outEx=outEx);
    data.history(idx).previous=previouseem;
end

% Assign output variable
dataout=data;
if not(isempty(dataout.split))
    splitChange=true;
else
    splitChange=false;
end
% Carry out the subsetting. We subset with separate methods in the three
% dimensions with class-specific methods to make it clear what happened.

% NOTE: Any call to one of these functions will delete all existing models.
% They will not be subset (one could do that) because the dataset behind the fit has changed
% and the model is no longer representing the dataset.

if any(outSample)
    dataout=drEEMdataset.rmsamples(dataout,outSample);
    if not(isempty(dataout.split))
        for j=1:numel(dataout.split)
            s_outSample=ismember(dataout.split(j).i,data.i(outSample));
            dataout.split(j)=drEEMdataset.rmsamples(dataout.split(j),s_outSample);
        end
    end
end
if any(outEm)
    dataout=drEEMdataset.rmemission(dataout,outEm);
    if not(isempty(dataout.split))
        for j=1:numel(dataout.split)
            dataout.split(j)=drEEMdataset.rmemission(dataout.split(j),outEm);
        end
    end
end
if any(outEx)
    dataout=drEEMdataset.rmexcitation(dataout,outEx);
    if not(isempty(dataout.split))
        for j=1:numel(dataout.split)
            dataout.split(j)=drEEMdataset.rmexcitation(dataout.split(j),outEx);
        end
    end
end

% Validate the end result to make sure things are good to go.
dataout.validate(dataout);
if splitChange
    % disp('subdataset operation was also applied to split datasets!')
end
% Will only run if toolbox is set to overwrite workspace variable and user
% didn't provide an output argument
if drEEMtoolbox.outputscenario(nargout)=="implicitOut"
    assignin("base",inputname(1),dataout);
    disp(['<strong> "',inputname(1), '" processed. </strong> Since no output argument was provided, the workspace variable was overwritten.'])
    return
end

end