function data = importabsorbance(filePattern,options)

arguments
        % Required
        filePattern (1,:) {mustBeText}
        
        % Optional
        options.waveColumn (1,:) {mustBeNumeric} = 1
        options.absColumn (1,:) {mustBeNumeric} = 10
        options.NumHeaderLines (1,1) {mustBeNumeric}= 0
end
nargoutchk(1,1)

% Find files & throw error when none are found
files=dir(filePattern);
if isempty(files)
    error('File pattern not found. Check input and current directory.')
end


% Extract & diagnose wavelengths
disp('Checking wavelength integrity of data set')
sz=nan(numel(files),2);
for j=1:numel(files)
    x=readmatrix(files(j).name,...
        NumHeaderLines=options.NumHeaderLines);
    % Find size for diagnosis step
    sz(j,:)=size(x);
end
% Sizes need to be the same across the files for the function to work.
if numel(unique(sz(:,1)))>1
    error('Absorbance spectra in directory have inconsistent number of rows')
end
if numel(unique(sz(:,2)))>1
    error('Absorbance spectra in directory have inconsistent number of columns')
end
% Create the drEEMdataset (fills in session-specific information)
data=drEEMdataset.create;
% Actual import run
cnt=1; % successful import counter.
for j=1:numel(files)
    tc=tic;
    % read in file
    x=readmatrix(files(j).name,...
        NumHeaderLines=options.NumHeaderLines);
    wave=x(:,options.waveColumn);
    abso=x(:,options.absColumn);

    

    % Sort ascending
    [ ~ ,iRow] = sort(wave,"ascend");
    abso=abso(iRow);
    wave=wave(iRow);
    del=isnan(abso)|isnan(wave);
    abso(del)=[];
    wave(del)=[];

    wave4Check{j}=wave;
    % Check wavelengths against first version. Same assumptions as in
    % importeems.m, check that function to learn more.
    if not(isequal(wave4Check{1},wave))
        warning(['File ',files(j).name,': Missmatch in the absorbance wavlengths (compared to 1st file). Skipped...'])
        continue
    else
        data.abs(cnt,:)=abso;
        data.filelist{cnt,1}=erase(files(j).name,erase(filePattern,'*'));
        data.i(cnt,1)=j; % this will leave a hint if an import did not work
        cnt=cnt+1;

        % message (optional, could be deleted)
        tc=toc(tc);
        ttl=num2str(numel(files));
        remain=num2str(round(tc.*(numel(files)-j),2));
        disp([num2str(j),'/',ttl,': ',data.filelist{j,1},...
            ' (',remain,' sec. remaining)'])
    end
end
% Assign the final fields and finish up
data.absWave=rcvec(wave,'column');
data.nSample=size(data.abs,1);
data.metadata.i=data.i;
data.metadata.filelist=data.filelist;

% Validate the dataset
data.validate(data);

% Make the drEEMhistory entry
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