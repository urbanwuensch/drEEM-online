function installdreem(scenario)
arguments
    scenario {mustBeMember(scenario,["clean install", "outdated", "up-to-date"])} = 'clean install'
end
mustBeOnline % Check right away whether the instance can access www


displayall=true; % Debugging / if needed or wanted

%% Detect which scenario is found
if displayall,disp('Detecting install scenario'),end
existing=fetchExisting; % This assumes modern drEEM (proper Contents.m)
online=fetchRepository;
if isempty(existing)
    if displayall,disp('No pre-existing drEEM installation'),end
    scenario='clean';
elseif isscalar(existing)
    if displayall,disp('One pre-existing drEEM installation'),end
    scenario=compareVersions(existing,online);
elseif length(existing)>1
    if displayall,disp('A mess of installations'),end
    scenario=compareVersions(existing,online);
end

if matches(scenario,'up-to-date')
    disp('Version up to date. Exiting')
    return
end

% scenario = {}
%% Uninstall (needs to be implemented)
if not(isempty(existing)) 
    disp('uninstall')
end
%% Download
if matches(scenario,{'clean install','outdated'})
    folder=downloadAndUnpackToolbox(online.url{1});
    dreeminstall(folder)
end
%% Install




disp('Success. ')
% cellvhist=textscan(vhist,'%s%s','Delimiter',';');
% tvhist=cell2table([cellvhist{:}],'VariableNames',{'Version','URL'});
% 
% if exist('developer','var')
%     disp(' ')
%     disp('--- Available versions -----------')
%     message=strcat(num2str((1:height(tvhist))'),repmat(" : ",height(tvhist),1),tvhist.Version);
%     for n=1:size(message,1)
%         disp(message(n,:))
%     end
%     disp('----------------------------------')
%     disp(' ')
%     ui=input(['Enter number of the desired release (',num2str(1:2),' ... ):  '],'s');
%     reqver=tvhist.Version{str2double(ui)}; 
% else
%     reqver=tvhist.Version{strcmp(tvhist.Version,'latest released (same as first entry)')};
% end
% 
% urlselected=find(strcmp(tvhist.Version,reqver));


    dreeminstall
    cd(olddir)
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

if all(update)
    outcome='outdated';
else
    outcome='up-to-date';
end
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
    disp('Success. ')
    tbPath=strsplit(tvhist.URL{urlselected},{'/'});
    tbPath=tbPath{end};
    tbPath=strsplit(tbPath,'.zip');
    tbPath=tbPath{1};

end

function uninstall
%%
curPath = path;curPath=textscan(curPath,'%s','delimiter',pathsep);curPath=curPath{:};
foldermatches=contains(lower(curPath),'dreem');

dreemFolders=curPath(foldermatches);
listing=table;
for j=1:numel(dreemFolders)
    files=dir(dreemFolders{j});
    listing=[listing;struct2table(files)];
end
listing(listing.isdir==1,:)=[];

targetMfiles={'viewmodels.mlapp','randinitanal.m','nmodel.m'};

listing=listing(matches(listing.name,targetMfiles),:);
for j=1:height(listing)
    temp=strsplit(listing.folder{j},filesep);
    temp=temp(1:end-1);
    temp(cellfun(@(x) isempty(x),temp))=[];
    temp=cellfun(@(x) [filesep,x],temp,uni=false);
    listing.folder{j}=[temp{:}];
end
end