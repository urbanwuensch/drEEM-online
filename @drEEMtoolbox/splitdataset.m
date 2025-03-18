function dataout = splitdataset(data,splitType,options)
% <a href = "matlab:doc splitdataset">dataout = splitdataset(data,options) (click to access documentation)</a>
%
% <strong>Split dataset into subsets</strong> for split-validation of PARAFAC models
%
% <strong>INPUTS - Required</strong>
% data {drEEMdataset.validate}
% 
% <strong>INPUTS - Optional</strong>
% splitType (1,:) {mustBeMember(["blind","byMetadata"])}
% options.blindType (1,:)     {mustBeMember(["alternating","random","contiguous"])} = "alternating"
% options.metadataColumn (1,:)    {drEEMdataset.mustBeMetadataColumn} = []
% options.numsplit (1,1)  {mustBePositive} = 2
%
% <strong>EXAMPLE(S)</strong>
%   1. The <strong>DOMfluor-type</strong> split (two splits, alternating split assignment)
%       samples = splitdataset(samples);
%   2. Four splits with random sample assignment
%       samples = splitdataset(samples,splitType='blind',blindType='random',numSplit=4);
%   3. Split dataset according to metadata variable "origin" (must exist, needs to be adopted to your dataset)
%       samples = splitdataset(samples,splitType='byMetadata',metadataColumn='origin');

% Copyright (C) 2025 Urban J. Wuensch - wuensch@chalmers.se
% Chalmers University of Technology
% Department of Architecture and Civil Engineering
% Sven Hultins Gata 6
% 41296 Gothenburg (Sweden)
arguments
    data {drEEMdataset.validate(data)}
    splitType (1,:) {mustBeText,mustBeMember(splitType,["blind","byMetadata"])} = "blind"
    options.blindType (1,:)     {mustBeMember(options.blindType,["alternating","random","contiguous"]),optValBT(splitType,options.blindType)} = "alternating"  
    options.metadataColumn (1,:)    {drEEMdataset.mustBeMetadataColumn(data,options.metadataColumn),optValMC(splitType,options.metadataColumn)} = string.empty
    options.numSplit (1,1)  {mustBePositive} = 2
    
end


% Experimental feature; overwrite workspace variable, needs no outputarg check
if drEEMtoolbox.outputscenario(nargout)=="explicitOut"
    nargoutchk(1,1)
end

% This bit is doing the splitting
switch splitType
    case "blind"
        % #1 Create an alternating-type split allocation by repeating 1:nSplit
        % until number of samples is exceeded.
        % This can be used by several methods
        splitIdent=repmat((1:options.numSplit)',ceil(data.nSample./options.numSplit),1);
        % #2 since nSample can be exceeded, truncate the identity vector to nSample
        splitIdent=splitIdent(1:data.nSample);
    case "byMetadata"
        groups = categorical(data.metadata.(options.metadataColumn));
        grps=categories(groups);
        splitIdent=nan(data.nSample,1);
        for j=1:numel(grps)
            idx=groups==grps{j};
            splitIdent(idx,1)=j;
        end
        options.numSplit=numel(grps);
end

% If blind case, and an option other than alternating (default) was specified, do that!
if matches(splitType,'blind')
    switch options.blindType
        case "random"
            mixer=randperm(data.nSample);
            splitIdent=splitIdent(mixer);
        case "contiguous"
            splitIdent=sort(splitIdent);
    end
end
dataout=data;

dataout.split=drEEMdataset; % Overwrite any preexisting split
for j=1:options.numSplit
    out=not(splitIdent==j);
    dataout.split(j,1)=drEEMdataset.rmsamples(data,out);
    dataout.split(j,1).history=...
        drEEMhistory.addEntry(mfilename,'created dataset through splitting',options,drEEMdataset);
    dataout.split(j,1).models=drEEMmodel;
end
idx=height(dataout.history)+1;
dataout.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,['dataset split with split-type: "',char(splitType),'"'],options,dataout);

% Will only run if toolbox is set to overwrite workspace variable and user
% didn't provide an output argument
if drEEMtoolbox.outputscenario(nargout)=="implicitOut"
    assignin("base",inputname(1),dataout);
    disp(['<strong> "',inputname(1), '" processed. </strong> Since no output argument was provided, the workspace variable was overwritten.'])
    return
end


end


function optValBT(splitType,option)
% %option is blindType
% if not(matches(splitType,'blind'))&&not(isempty(option))
%     warning('<strong>Conflicting inputs: </strong>splitType", takes precedent over specifying input to "metadataColumn".')
% end
% 
% if matches(splitType,'byMetadata')&&isempty(option)
%     error(['<strong>Invalid input: </strong> When specifying splitType="byMetadata",' ...
%         ' option "metadataColumn" cannot be empty.'])
% end



end


function optValMC(splitType,option)
%option is metadataColumn
if matches(splitType,'blind')&&not(isempty(option))
    warning('<strong>Conflicting inputs: </strong>splitType", takes precedent over specifying input to "metadataColumn".')
end
end