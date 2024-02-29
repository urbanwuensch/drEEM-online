function dataout=zapnoise(data,sampleIdent,emRange,exRange)

arguments
    data (1,1) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    sampleIdent {mustBeNonempty,mustBeNumericOrLogical}
    emRange (1,:) {mustBeNumeric,mustBeNonempty,drEEMdataset.mustBeInRangeEm(data,emRange)}
    exRange (1,:) {mustBeNumeric,mustBeNonempty,drEEMdataset.mustBeInRangeEx(data,exRange)}

end

% Secondary input validation (stuff that's not possible in the argument block)
try 
    mustBeLessThanOrEqual(sampleIdent,data.nSample)
catch ME
    error(['outSample: ',ME.message])
end


% Anonymous function, finds the clostest match to the provided wavelengths
% Similar to knnsearch, but does not require any toolboxes.
mindist=@(vec,val) find(ismember(abs(vec-val),min(abs(vec-val))));

%% Function execution

% Find first unscaled dataset and zap it as well. That's not strickly
% speaking needed (no dimension error), but it's a safe choice to avoid big
% differences in fits (excessive noise that zapnoise might remove).
idx=drEEMhistory.searchhistory(data.history,'scalesamples','first');
if not(isempty(idx))
    previouseem=data.history(idx).previous;
    previouseem=zapnoise(previouseem,sampleIdent,emRange,exRange);
    data.history(idx).previous=previouseem;
end

% Assign output variable
dataout=data;


% two equal blocks for em and ex. If one input, find the closest match, if
% two make a vector of indices from start to end.
if isnumeric(emRange)
    for j=1:numel(emRange)
        emRange(j)=mindist(data.Em,emRange(j));
    end
    if numel(emRange)==2
        emRange=emRange(1):emRange(end);
    end
end
if isnumeric(exRange)
    for j=1:numel(exRange)
        exRange(j)=mindist(data.Ex,exRange(j));
    end
    if numel(exRange)==2
        exRange=exRange(1):exRange(end);
    end
end


% The actual zapping
dataout.X(sampleIdent,emRange,exRange)=NaN;

% Final validation (just in case)
dataout.validate(dataout);

% Finishing up: Write the drEEMhistory entry
message=['SampleIdent = ',num2str(rcvec(find(sampleIdent),'row')),...
    ';  EmRange = ',num2str(rcvec(find(emRange),'row')),...
    ';  ExRange = ',num2str(rcvec(find(exRange),'row'))];
idx=height(dataout.history)+1;
dataout.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,message,[],dataout);

end

function [vout] = rcvec(v,rc)
% Make row or column vector
% v: vector
% rc: either 'row' ([1:5])or 'column' ([1:5]')
sz=size(v);
if ~any(sz==1)
    error('Input is not a vector')
end

switch rc
    case 'row'
        if ~[sz(1)<sz(2)]
            vout=v';
        else
            vout=v;
        end
    case 'column'
        if ~[sz(1)>sz(2)]
            vout=v';
        else
            vout=v;
        end
    otherwise
            error('Input ''rc'' not recognized. Options are: ''row'' and ''column''.')
end


end