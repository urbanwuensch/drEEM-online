function dataout=subdataset(data,outSample,outEm,outEx)

arguments
    data (1,1) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    outSample (1,:) {mustBeNumericOrLogical} = []
    outEm (1,:) {mustBeNumericOrLogical} = []
    outEx (1,:) {mustBeNumericOrLogical} = []
end
data.validate(data);

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
    previouseem=subdataset(previouseem,outSample,outEm,outEx);
    data.history(idx).previous=previouseem;
end

% Assign output variable
dataout=data;

% Carry out the subsetting. We subset with separate methods in the three
% dimensions with class-specific methods to make it clear what happened.

% NOTE: Any call to one of these functions will delete all existing models.
% They will not be subset (one could do that) because the dataset behind the fit has changed
% and the model is no longer representing the dataset.

if not(isempty(outSample))
    dataout=drEEMdataset.rmsamples(dataout,outSample);
end
if not(isempty(outEm))
    dataout=drEEMdataset.rmemission(dataout,outEm);
end
if not(isempty(outEx))
    dataout=drEEMdataset.rmexcitation(dataout,outEx);
end

% Validate the end result to make sure things are good to go.
dataout.validate(dataout);

end