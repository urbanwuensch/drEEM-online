function [dataout] = associatemetadata(data,pathtofile,metadatakey,datakey)
arguments
    data(1,1) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    pathtofile
    metadatakey (1,:) {mustBeText}
    datakey (1,:) {mustBeText} = 'filelist';
end

if not(istable(pathtofile))
    try mustBeFile(pathtofile)
    catch
        error([char(pathtofile),' does not exist as a file.'])
    end
elseif istable(pathtofile)
else
    error('Input to "pathtofile" must be of the class string or table')
end

% Validate optional datakey
if not(isfield(data,datakey))
    try drEEMdataset.mustBeMetadataColumn(data,datakey)
    catch ME
        message=['invalid input for optional argument "datakey" #1. ',datakey,' is not a field in the drEEMdataset. #2: ',ME.message];
        error(sprintf(message))
    end
end


% Read in the metadata
if ischar(pathtofile)||isstring(pathtofile)
    warning off % Readtable will complain about Column headers a lot
    md = readtable(pathtofile);
    warning on

    if not(any(matches(md.Properties.VariableNames,metadatakey)))
        disp(md.Properties.VariableNames)
        error(['column header: ',metadatakey,'does not exist in '' imported metadata table.'''])
    end
elseif istable(pathtofile)
    md=pathtofile;
else
    error('Input to ''pathtofile'' can only be a string, character, or table.')
end
% Get the datatypes in the table
type = cell(width(md),1);
for j = 1:width(md)
    try
        type{j,1} = class(md.(md.Properties.VariableNames{j}){1});
    catch
        type{j,1} = class(md.(md.Properties.VariableNames{j})(1));
    end
    
    if matches(type{j},'cell')
        type{j}='char';
    end
    
end

% Convert types to compatible types (Quick fix for 0.6.3 subdataset function)
for j=1:numel(type)
    switch type{j}
        case 'datetime'
            md.(md.Properties.VariableNames{j})=cellstr(md.(md.Properties.VariableNames{j}));
            type{j}='char';
        case 'string'
            if iscell(md.(md.Properties.VariableNames{j}))
                md.(md.Properties.VariableNames{j}) = cellfun(@(x) convertStringsToChars(x),md.(md.Properties.VariableNames{j}),'UniformOutput',false);
            else
                md.(md.Properties.VariableNames{j}) = convertStringsToChars(md.(md.Properties.VariableNames{j}));
            end
        otherwise
            % Nothing yet
    end
end


% Make a new table with the height of data.nSample (space for unmatched
% samples)
warning off
metadata=table('Size',[data.nSample,width(md)],'VariableTypes',type,'VariableNames',md.Properties.VariableNames);
warning on

% Check for non-unique identifiers (these will make trouble during matching)
if numel(unique(lower(data.(datakey))))<data.nSample
    c = categorical(data.(datakey));
    cats=categories(c);
    counts=countcats(c);
    nonunique=cats(counts>1);
    message=['Non-unique identifiers: '];
    for j=1:numel(nonunique)
        message = [message ['\n ',num2str(j),': ',nonunique{j}]];
    end

    message = [message ['\n lower-case filenames in supplied drEEM dataset structure are not unique. Cannot perform meaningful matching.']];
    error(sprintf(message))
end
% Check for non-unique identifiers no2  (these will make trouble during matching)
if numel(unique(lower(md.(metadatakey))))<height(md)
    c = categorical(md.(metadatakey));
    cats=categories(c);
    counts=countcats(c);
    nonunique=cats(counts>1);
    message='Non-unique identifiers: ';
    if ~isempty(nonunique)
        for j=1:numel(nonunique)
            message = [message ['\n ',num2str(j),': ',nonunique{j}]];
        end

        message = [message ['\n lower-case filenames in specified metadata table are not unique. Cannot perform meaningful matching.']];
        error(sprintf(message))

    elseif isempty(nonunique) %in case there is unwanted information in a cell lower down in the spreadsheet
%         message = [message ['\n possible empty rows in metadata file, clear all rows of data underneath the final sample.']];
%         message = [message ['\n rows of metadata imported =' num2str(size(md,1))]];
%         error(sprintf(message))
    end

end

% Make sure key and lock are the same class
a=lower(data.(datakey));
b=lower(md.(metadatakey));
ca=class(a);
cb=class(b);

if matches(ca,'char')
    a=cellstr(a);
    ca=class(a);
end
if matches(cb,'char')
    b=cellstr(b);
    cb=class(b);
end

if not(matches(ca,cb))
    error(['data.',datakey,' and metadata.',metadatakey,'are not of the same class. Please convert one or both and try again.'])
end
    


% Find the intersect between the key variables
[~,ia,ib] = intersect(a,b,'stable');


% Fill the emtpy table with matches from the comparison (leaves unmatched
% empty)
metadata(ia,:) = md(ib,:);

% Fill the rest of numeric data with missing data (ensure proper missing values)
for j = 1:width(metadata)
    if matches(type{j},'double')
        metadata.(metadata.Properties.VariableNames{j})(setdiff(1:data.nSample,ia))=missing;
    elseif matches(type{j},'char')
        try
            metadata.(metadata.Properties.VariableNames{j})(setdiff(1:data.nSample,ia))='missing';
        catch
            metadata.(metadata.Properties.VariableNames{j})(setdiff(1:data.nSample,ia))={'missing'};
        end
    end
end


% Make a new structure with all the metadata fields
dataout=data;
% vars = metadata.Properties.VariableNames;
% for j=1:numel(vars)
%     dataout.(['md_',vars{j}])=metadata.(vars{j});
% end

% Support for metadata table (forward compatibility, not yet enabled due to
% subdataset).
% Find common variables or stick tables together.
[C,iat,ibt]=intersect(dataout.metadata.Properties.VariableNames, ...
    metadata.Properties.VariableNames);
if not(isempty(C)) % There are common variables (merging needed)
    dataout.metadata(ia,iat)=metadata(ia,ibt);
    metadata(:,matches(metadata.Properties.VariableNames,C))=[];
end
% Not in common, just stick them together
dataout.metadata=[dataout.metadata metadata];

% Ensure from here that the columns are either categorical or numerical.
dataout.metadata=metadataconverter(dataout.metadata);

%% Metrics at the end
eem_matched=round(numel(ia)./dataout.nSample*100);
md_matched=round(numel(ib)./height(md)*100);
disp('')
disp(array2table([dataout.nSample height(md);numel(ia) numel(ib);eem_matched,md_matched], ...
    "VariableNames",{'drEEMdataset','imported metadata table'}, ...
    "RowNames",{'No. samples','Total matched','% matched'}))
disp('')

idx=height(dataout.history)+1;
dataout.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,"Metadata associated (look at data.metadata)",[],dataout);
dataout.validate(dataout);


end


function mdnew = metadataconverter(metadata)
    mdnew=table;
    for j=1:numel(metadata.Properties.VariableNames)
        here=metadata.Properties.VariableNames{j};
        md=metadata.(here);
        try
            if numel(unique(md))==1
                continue
            end
        catch
            % different data types (nogo)
            continue
        end
        type=class(md);
        switch type
            case 'cell'
                alltype=cellfun(@(x) class(x),md,'UniformOutput',false);
                celltypes=unique(alltype);
                if numel(celltypes)>1
                    warning(['Variable "',here,'" consists of different datatypes and will not be included for plotting'])
                    continue
                else
                    celltypes=celltypes{1};
                end
                switch celltypes
                    case 'char'
                        mdconv=categorical(md);
                    case 'datetime'
                        mdconv=categorical(md);
                    case 'duration'
                        mdconv=double(md);
                    case 'categorical'
                        mdconv=md;
                    case 'numeric'
                        mdconv=md;
                    otherwise
                        error('Metadata type: cell, subtype not accounted for.')

                end
            case 'numeric'
                mdconv=md;
            case 'datetime'
                mdconv=categorical(md);
            case 'duration'
                mdconv=double(md);
            case 'double'
                    mdconv=md;
            case 'categorical'
                mdconv=md;
            otherwise
                error('Metadata type not accounted for.')
        end
        mdnew.(here)=mdconv;
    end
end
