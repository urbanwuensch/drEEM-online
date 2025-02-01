function installdreem(scenario)
arguments
    scenario {mustBeMember(scenario,["clean install", "outdated", "up-to-date"])} = 'clean install'
end
mustBeOnline % Check right away whether the instance can access www


displayall=false; % Debugging / if needed or wanted

%% Backups
pathlist = path;


%% Detect which scenario is found
if displayall,disp('Detecting install scenario'),end %#ok<*UNRCH>
existing=fetchExisting; % This assumes modern drEEM (proper Contents.m)
online=fetchRepository;
if isempty(existing)
    if displayall,disp('No pre-existing drEEM installation ... '),end
    scenario='clean';
elseif isscalar(existing)
    if displayall,disp('One pre-existing drEEM installation ... '),end
    scenario=compareVersions(existing,online);
elseif length(existing)>1
    if displayall,disp('Multiple installations found ... '),end
    scenario=compareVersions(existing,online);
end

if matches(scenario,'up-to-date')
    disp('drEEM is up to date')
    return
end

% scenario = {}
%% Uninstall
if not(isempty(existing)) 
    disp('Uninstalling old versions by removing them from the path ... ')
    uninstall
end
%% Download
if matches(scenario,{'clean install','outdated'})
    %folder=downloadAndUnpackToolbox(online.url{1});
    
end
%% Install
% Dummy during development
folder='/Users/urban/Documents/MATLAB/drEEM-2.0';
installroutine(folder,pathlist)
disp('Success ... ')

end

function mustBeOnline
if ispc
    C = evalc('!ping -n 1 8.8.8.8');    
elseif isunix
    C = evalc('!ping -c 1 8.8.8.8');        
end

if contains(C,{'No route to host','unreachable'})
    error('Can''t reach google.com');  
end

end

function repro = fetchRepository
directory='https://gitlab.com/dreem/drEEM/raw/master/versions.txt';
vhist=webread(directory);
cellvhist=textscan(vhist,'%s%s','Delimiter',';');

repro=table;
repro.version=cellvhist{1};
repro.url=cellvhist{2};
end

function versionout = fetchExisting
versionout=ver;
versionout=versionout(arrayfun(@(x) contains(x.Name,'drEEM'),versionout));
versionout=rmfield(versionout,{'Date','Release','Name'});
end

function outcome=compareVersions(existing,online)
ov=online.version{1}; % latest online version
ev={existing.Version}; % installed version(s)

% digest version numbers
ov=cellfun(@(x) str2double(x),strsplit(ov,'.'));
for j=1:length(ev)
    evd(j,:)=cellfun(@(x) str2double(x),strsplit(ev{j},'.'));
end

% Compare versions
update=true;
for j=1:height(evd)
    if ov(1)>=evd(j,1)
        if ov(2)>=evd(j,2)
            if ov(3)>evd(j,3)
                update(j)=true;
            else
                update(j)=false;
            end
        else
            update(j)=false;
        end
    else
        update(j)=false;
    end
end

if any(update)
    outcome='outdated';
else
    outcome='up-to-date';
end
end

function uninstall
%%
% Current path list (cell array)
curPath = path;
curPath=textscan(curPath,'%s','delimiter',pathsep);
curPath=curPath{:};
% The subset with dreem (all lower) in the path
foldermatches=contains(lower(curPath),'dreem');
dreemFolders=curPath(foldermatches);

% Make a table with the drEEM folders
listing=table;
for j=1:numel(dreemFolders)
    files=dir(dreemFolders{j});
    listing=[listing;struct2table(files)];
end

% In case this there are no folders, just exit
if isempty(listing)
    return
end
listing(listing.isdir==1,:)=[]; % deletes the directory entries

% These three m-files target drEEM-2, drEEM > 0.4 and drEEM < 0.4
targetMfiles={'viewmodels.mlapp','randinitanal.m','nmodel.m'};

% subset the listing to the folders that contain the entries
listing=listing(matches(listing.name,targetMfiles),:);

% Now, isolate the root folder of each installation. This is done assuming 
% that each m-file is one up from the root and the last folder is deleted 
% from each path
for j=1:height(listing)
    temp=strsplit(listing.folder{j},filesep); % Split the path with filesep
    temp=temp(1:end-1); % delete the last folder
    temp(cellfun(@(x) isempty(x),temp))=[]; % delete empty cells
    temp=cellfun(@(x) [filesep,x],temp,uni=false); % fuse the path back together
    listing.folder{j}=[temp{:}]; % paste it back in
end
% Isolate the unique paths (there will be multiples for each) and then prepare
% for the deletion
deleteThese=curPath(contains(curPath,unique(listing.folder)));
% delete the drEEM toolboxes
rmpath(deleteThese{:})  % This removes old drEEM folders

end

function tbPath=downloadAndUnpackToolbox(url)
    disp(['Downloading toolbox (',userpath,filesep,temp,filesep,')'])   
    clearvars temp
    try
        unzip(tvhist.URL{urlselected},userpath)
    catch
        try
            o = weboptions('CertificateFilename','');
            websave('dreemtemp',tvhist.URL{urlselected},o);
            unzip('dreemtemp.zip',userpath);
            delete('dreemtemp.zip')
        catch
            error('Could not download the requested version of drEEM. Contact support if the issue persists.')
        end
    end
    disp('Success.')
    tbPath=strsplit(tvhist.URL{urlselected},{'/'});
    tbPath=tbPath{end};
    tbPath=strsplit(tbPath,'.zip');
    tbPath=tbPath{1};

end



function installroutine(folder,backup)
p=genpath(folder);
addpath(p)
try
    savepath
catch
    warning('Could not save the current searchpath. You will have to reinstall drEEM after restarting Matlab.')
end

try
    drEEMtoolbox.versionRequires
catch ME
    restoredefaultpath
    path(backup)
    rethrow(ME)
end
end