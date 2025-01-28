function installdreem(developer) %#ok<*INUSD>


%% Initialize
directory='https://gitlab.com/dreem/drEEM/raw/master/versions.txt';
olddir=pwd;

iaccess=checkonlinestatus;
if ~iaccess
    error('Cannot reach ''google.com''. Your computer must have internet access for this function to work as intended.')
elseif iaccess
    error('Internet connection established, but cannot download from Gitlab. Contact drEEM user support.')
end


disp('---------------------------------------------------------------------------')
disp('   drEEM toolbox - decomposition routines for Excitation-Emission Matrices ')
disp('---------------------------------------------------------------------------')
disp('Fetching repository table of contents ...')
try
    vhist=webread(directory);
catch
    try
        o = weboptions('CertificateFilename','');
        vhist=webread(directory,o);
    catch

    end
end
disp('Success. ')
cellvhist=textscan(vhist,'%s%s','Delimiter',';');
tvhist=cell2table([cellvhist{:}],'VariableNames',{'Version','URL'});

if exist('developer','var')
    disp(' ')
    disp('--- Available versions -----------')
    message=strcat(num2str((1:height(tvhist))'),repmat(" : ",height(tvhist),1),tvhist.Version);
    for n=1:size(message,1)
        disp(message(n,:))
    end
    disp('----------------------------------')
    disp(' ')
    ui=input(['Enter number of the desired release (',num2str(1:2),' ... ):  '],'s');
    reqver=tvhist.Version{str2double(ui)}; 
else
    reqver=tvhist.Version{strcmp(tvhist.Version,'latest released (same as first entry)')};
end

urlselected=find(strcmp(tvhist.Version,reqver));


if isempty(urlselected)
    error('Something went wrong when trying to download drEEM \n%s',...
        '   Visit: https://gitlab.com/dreem/drEEM or: dreem.openfluor.org')
else
    temp=strsplit(tvhist.URL{urlselected},'/');temp=temp{end};temp=strsplit(temp,'.z');temp=temp{1};
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
    folder=strsplit(tvhist.URL{urlselected},{'/'});
    folder=folder{end};
    folder=strsplit(folder,'.zip');
    folder=folder{1};
    cd([userpath,filesep,folder])
    disp('Installing toolbox ... ')
    disp(' ')
    disp(' ')

    dreeminstall
    cd(olddir)
end

end

function access = checkonlinestatus
if ispc
    C = evalc('!ping -n 1 8.8.8.8');    
elseif isunix
    C = evalc('!ping -c 1 8.8.8.8');        
end

if ~contains(C,'unreachable')
    access=true;
else
    access=false;
end

end