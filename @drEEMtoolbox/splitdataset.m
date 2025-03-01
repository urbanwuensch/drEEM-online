function dataout = splitdataset(data,options)
% <a href = "matlab:doc splitdataset">dataout = splitdataset(data,options) (click to access documentation)</a>
%
% <strong>Split dataset into subsets</strong> for split-validation of PARAFAC models
%
% <strong>INPUTS - Required</strong>
% data {drEEMdataset.validate}
% 
% <strong>INPUTS - Optional</strong>
% options.splitType (1,:) {mustBeMember(["blind","byMetadata"])} = "blind"
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


arguments
    data {drEEMdataset.validate(data)}
    options.splitType (1,:) {mustBeText,mustBeMember(options.splitType,["blind","byMetadata"])} = "blind"
    options.blindType (1,:)     {mustBeMember(options.blindType,["alternating","random","contiguous"])} = "alternating"  
    options.metadataColumn (1,:)    {drEEMdataset.mustBeMetadataColumn(data,options.metadataColumn)} = []
    options.numsplit (1,1)  {mustBePositive} = 2
    
end

if matches(options.splitType,'byMetadata')&&isempty(options.metadataColumn)
    error(['Invalid option combination. When specifying splitType="byMetadata",' ...
        ' option "metadataColumn" cannot be empty and must point to a column of the metadata table'])
end

if matches(options.splitType,"blind")&&not(isempty(options.metadataColumn))
    warning('Ignoring input to "metadataColumn" since splitType="blind".')
end

% Experimental feature; overwrite workspace variable, needs no outputarg check
if drEEMtoolbox.outputscenario(nargout)=="explicitOut"
    nargoutchk(1,1)
end

% This bit is doing the splitting
switch options.splitType
    case "blind"
        % #1 Create an alternating-type split allocation by repeating 1:nSplit
        % until number of samples is exceeded.
        % This can be used by several methods
        splitIdent=repmat((1:options.numsplit)',ceil(data.nSample./options.numsplit),1);
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
        options.numsplit=numel(grps);
end

% If blind case, and an option other than alternating (default) was specified, do that!
if matches(options.splitType,'blind')
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
for j=1:options.numsplit
    out=not(splitIdent==j);
    dataout.split(j,1)=drEEMdataset.rmsamples(data,out);
    dataout.split(j,1).history=...
        drEEMhistory.addEntry(mfilename,'created dataset through splitting',options,drEEMdataset);
    dataout.split(j,1).models=drEEMmodel;
end
idx=height(dataout.history)+1;
dataout.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,'splits of dataset created',options,dataout);

% Will only run if toolbox is set to overwrite workspace variable and user
% didn't provide an output argument
if drEEMtoolbox.outputscenario(nargout)=="implicitOut"
    assignin("base",inputname(1),dataout);
    disp(['<strong> "',inputname(1), '" processed. </strong> Since no output argument was provided, the workspace variable was overwritten.'])
    return
end


end


