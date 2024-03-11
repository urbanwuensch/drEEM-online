function varargout = alignsamples(varargin)

arguments (Repeating)
    varargin (1,1) {mustBeA(varargin,"drEEMdataset"),drEEMdataset.validate(varargin)}
end
% Optional feature; overwrite workspace variable, needs no outputarg check
if drEEMtoolbox.outputscenario(nargout)=="explicitOut"
    nargoutchk(numel(varargin),numel(varargin))
end
% Get the dataset names for messages
for j=1:numel(varargin)
    name(j,1)=string(inputname(j));
end

% Find all comparisons between the input datasets for all comparisons
combs=nchoosek(1:numel(varargin),2);

% cmn = common. Preallocate this cell
cmn=cell(size(combs,1),1);

% Comparison of filenames across all the combinations of datasets
for j=1:size(combs,1)
    % This compares the filenames between two datasets
    C = intersect(varargin{combs(j,1)}.filelist,...
        varargin{combs(j,2)}.filelist);
    % Store the common names for later
    cmn{j}=C;
    % Store the names of the comparison (could be useful, not used atm).
    comparison(j,1)=categorical(cellstr([char(name(combs(j,1))),' vs. ',char(name(combs(j,2)))]));
end

% A bit of transformation to obtain the filenames that occur
% numel(varargin) times across all the comparisons.
cmn=vertcat(cmn{:});
cmn=cmn(:);
cmn=categorical(cmn);
cmn=cmn(countcats(cmn)==numel(varargin));

% This loop sorts the files and deletes missing samples
for j=1:numel(varargin)
    % This one finds the indices of the common files
    [~,~,idx] = intersect(cmn,varargin{j}.filelist);

    % Convert that into the ones that should be deleted
    deleted=setdiff(1:numel(varargin{j}.filelist),idx);

    % Now delete the sample information in all fields of interest.
    flds=fieldnames(varargin{j});
    flds(matches(flds,{'history','Ex','Em','Abs_wave'}))=[]; % These won't be touched
    sel=[];cnt=1;
    for k=1:numel(flds)
        if size(varargin{j}.(flds{k}),1)==varargin{j}.nSample
            % If the field matches in the sample dimension, it gets marked
            % for deletion
            sel(cnt)=k;
            cnt=cnt+1;
        end
        
    end
    % Subset the fieldnames for those that are marked for sample deletion
    flds=flds(sel);
    
    % Execute the deletion
    for k=1:numel(flds)
        % This try-catch solution is not pretty, but for now it works.
        try % 3 way tensors
            varargin{j}.(flds{k})=varargin{j}.(flds{k})(idx,:,:);
        catch % tables & matrices
            varargin{j}.(flds{k})=varargin{j}.(flds{k})(idx,:);
        end
    end
    
    % Now assign the modified dataset as an output argument
    varargout{j}=varargin{j};
    varargout{j}.nSample=varargout{j}.nSample-numel(deleted);

 
    
    % Gather information for user.
    if isempty(deleted)
        message='No action necessary. All files between supplied datasets had same names.';
    else
        message=['removed ',num2str(numel(deleted)),' samples with the previous .i: ',num2str(deleted)];
    end
    
    % Make drEEMhistory entry with message information
    idx=height(varargout{j}.history)+1;
    varargout{j}.history(idx,1)=...
        drEEMhistory.addEntry(mfilename,message,[],varargout{j});
    
    % Also display the message in the command window
    disp([char(name(j)),': ',message])
    
    %Final validation of the dataset
    drEEMdataset.validate(varargout{j});
end

if drEEMtoolbox.outputscenario(nargout)=="implicitOut"
    for j=1:numel(varargout)
        assignin("base",varargout{j},name(j))
        disp(['<strong> ',name(j), '" processed. </strong> Since no output argument was provided, the workspace variable was overwritten.'])
                
    end
    return
end
