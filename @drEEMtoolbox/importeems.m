function data = importeems(filePattern,options)
%% Description:
%   Import excitation-emission-matrices
%
%   
%% Syntax:
%   data = importeems(filePattern,options)
%
%% Input:
%   filePattern - string or character array [1 x :]
%     specifies the name pattern for import (e.g. "*SEM.dat")
%   options - Name,Value arguments
%
%% Output:
%   drEEMdataset
%

arguments
        % Required
        filePattern (1,:) {mustBeText}
        
        % Optional
        options.colWave (1,:) {mustBeNumericOrLogical} = true
        options.rowWave (1,:) {mustBeNumericOrLogical} = true
        options.columnIsEx (1,:) {mustBeNumericOrLogical}= true
        options.NumHeaderLines (1,1) {mustBeNumeric}= 0
end

% Find files & throw error when none are found
files=dir(filePattern);
if isempty(files)
    error('Found no files that it the pattern. Check input and current directory.')
end

% Extract axis values if not given in files
if isnumeric(options.colWave)
    colAxis=options.colWave;
end
if isnumeric(options.rowWave)
    rowAxis=options.rowWave;
end

% Extract & diagnose wavelengths
disp('Checking wavelength integrity of data set')
sz=nan(numel(files),2);
for j=1:numel(files)
    x=readmatrix(files(j).name,NumHeaderLines=options.NumHeaderLines);
    xorg=x;

    % extract axes
    if options.rowWave==true
        rowAxis=xorg(:,1);
        x=x(:,2:end);
    end
    if options.colWave==true
        colAxis=xorg(1,:);
        x=x(2:end,:);
    end
    
    % remove empty cell
    colAxis(isnan(colAxis))=[];
    rowAxis(isnan(rowAxis))=[];

    % Check if sizes match (rows and columns)
    if not(size(x,1)==numel(rowAxis))
        error(['file: ',files(j).name,' size of EEM inconsistent with row axis information'])
    end
    if not(size(x,2)==numel(colAxis))
        error(['file: ',files(j).name,' size of EEM inconsistent with column axis information'])
    end
    
    % Store the size for later use.
    sz(j,:)=size(x);

end
% Check that all stored sizes in the prelim. analysis match (row + column)
if numel(unique(sz(:,1)))>1
    error('EEMs in directory have inconsistent number of rows')
end
if numel(unique(sz(:,2)))>1
    error('EEMs in directory have inconsistent number of columns')
end

% All checks passed, now move on to import
data=drEEMdataset.create; % Create a drEEMdataset (fills in machine-specific info)
data.status=drEEMstatus; % Initiate the status field with the proper class
cnt=1; % Counter for successful imports.
for j=1:numel(files)
    tc=tic;
    
    % read in file
    x=readmatrix(files(j).name,NumHeaderLines=options.NumHeaderLines);
    xorg=x;

    % extract axes
    if options.rowWave==true
        rowAxis=xorg(:,1);
        x=x(:,2:end);
    end
    if options.colWave==true
        colAxis=xorg(1,:);
        x=x(2:end,:);
    end
    
    % remove empty cell
    colAxis(isnan(colAxis))=[];
    rowAxis(isnan(rowAxis))=[];

    % Sort ascending
    [ ~ ,iCol] = sort(colAxis,"ascend");
    [ ~ ,iRow] = sort(rowAxis,"ascend");
    x=x(iRow,iCol);
    colAxis=colAxis(iCol);
    rowAxis=rowAxis(iRow);

    % Make sure the matrix is rotated as expected (requires user expertise)
    if options.columnIsEx==true
        ex=colAxis;
        em=rowAxis;
    else
        em=colAxis;
        ex=rowAxis;
        x=x';
    end
    
    % Store the wavelength information for double-check of axis info
    ex4Check{j}=ex;
    em4Check{j}=em;

    % Check the current axis against the first to troubleshoot
    % Assumption: 1st file is not corrupt. Import will essentially fail if
    % the first file is the/a bad one. Could be made better, but should be
    % ok for 99.9% of users. Could add another layer of checking to select
    % those files that will result in the largest number of imported
    % samples.

    if not(isequal(ex4Check{1},ex))
        warning(['File ',files(j).name,': Missmatch in the excitation wavlengths (compared to 1st file). Skipped...'])
        continue
    end
    if not(isequal(em4Check{1},em))
        warning(['File ',files(j).name,': Missmatch in the emission wavlengths (compared to 1st file). Skipped...'])
        continue
    end
    
    % Fill the dataset with the info now that all checks passed.
    data.X(cnt,:,:)=x;
    data.filelist{cnt,1}=erase(files(j).name,erase(filePattern,'*'));
    data.i(cnt,1)=j;
    cnt=cnt+1; % +1 on the counter for a successful import.

    % message (nice to have, could be deleted).
    tc=toc(tc);
    ttl=num2str(numel(files));
    remain=num2str(round(tc.*(numel(files)-j),2));
    disp([num2str(j),'/',ttl,': ',data.filelist{j,1},...
        ' (',remain,' sec. remaining)'])
end

% Final dataset variables can now be assigned.
data.Ex=rcvec(ex,'column');
data.Em=rcvec(em,'column');
data.nEx=numel(data.Ex);
data.nEm=numel(data.Em);
data.nSample=size(data.X,1);
data.metadata.i=data.i;
data.metadata.filelist=data.filelist;

% Validate the dataset to make sure it's good to go (class-specific method)
data.validate(data);

% User needs to tell the toolbox what the status of the dataset is.
handle=setstatus(data,'data');
waitfor(handle,"finishedHere",true);
try
    data=handle.data;
    delete(handle)
catch
    error('setstatus closed before save & exit button was pushed.')
end

% Final step: Make the drEEMhistory entry.
idx=1;
data.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,'created dataset',options,data);


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