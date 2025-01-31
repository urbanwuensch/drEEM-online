function dreeminstall(toolboxDir)
arguments
    toolboxDir {mustBeFolder(toolboxDir)}
end
currentDir=pwd; % For restoring
cd(toolboxDir)
%% Initial check before anything else
% Check if the highest priority dreeminstall is in the current folder & if
% this specific function being executed is also the one in the current
% path.
if all([~strcmp(fileparts(which('dreeminstall.m')),pwd),~strcmp(fileparts(mfilename('fullpath')),pwd)])
    error('You must change the MATLAB directory to the one containing ''dreeminstall'' in order to correctly install drEEM')
end

% commithist=webread('https://gitlab.com/dreem/drEEM/commits/master?feed_token=_T6Ybe8-Fscb4Drzxqz-&format=atom');
% update=strfind(commithist,'<updated>');
% versdate=commithist(update(1)+9:update(1)+18);
% THIS NEXT LINE NEEDS CHANGING FOR EACH RELEASE!!!
vers='2.0.0';
versdate='Month Year';
clearvars commithist update

%% Welcome messages
disp(' ')
disp(' ')
disp('-----------------------------------------------------')
disp(['drEEM toolbox 2 (',vers,', last update ',versdate,')'])
disp('-----------------------------------------------------')
disp(' ')
disp('Installation routine')
disp(['Installing drEEM stored in: ',pwd])
disp(' ')
pause(2)

%% STEP 1
disp('Step 1/5: Checking your MATLAB version and installed MATLAB products');pause(0.2)

if isMATLABReleaseOlderThan("R2022a")
    warning('With Matlab older than R2022a, <strong>you will encounter errors</strong>. Continue at your own risk.')
    pause(5)
end
mallver=ver;
tbs={'Statistics and Machine Learning Toolbox' 'Parallel Computing Toolbox' 'Curve Fitting Toolbox','Image Processing Toolbox','Signal Processing Toolbox'};
isthere=zeros(1,numel(tbs));
for n=1:numel(tbs)
    isthere(n)=any(~cellfun(@isempty,strfind({mallver.Name},tbs{n})));
end
if all(isthere)
    disp('          Success.')
else
    warning(['Missing toolbox(es):',tbs{~isthere},'. Some functions may not work as intended.'])
    disp('Press any key to acknowledge.')
    pause
end


%% STEP 2
disp('Step 2/5: Checking for old drEEM versions.');pause(0.2)
pbackup=path;


% Method:
% 1) Obtain matlabpath
% 2) Obtain list of functions contained in current drEEM toolbox
% 3) Cycle through all matlabpath entries, check for existing functions
%    that are part of the toolbox. If number of hits is > 50% of number of functions
%    flag that folder for removal.
% 4) Any flagged folder is removed.
CurPath = path;CurPath=textscan(CurPath,'%s','delimiter',pathsep);CurPath=CurPath{:};
queries={'drEEM_fun','nway','dreemroot','tutdemo'};
isold=false(numel(CurPath),1);
for n=1:numel(queries)
    funct=returnmfilesOld(queries{n});
    for i=1:numel(CurPath)
        list=dir(CurPath{i});
        list={list(:).name};
        sumhit=0;
        for k=1:numel(funct)
            if ~isempty(find(strcmp(list,funct{k})))
                sumhit=sumhit+1;
            end
        end
        if sumhit/numel(funct)>=.5
        isold(i)=true;
        end
    end
end

if any(isold)
    disp('          Other version of drEEM is currently installed.')
    disp('          These folders will now be removed from the MATLAB path.')
    disp('          They are NOT deleted, just not searchable in MATLAB anymore.')
    disp('          These folders are:')
    disp('  ')
    i=find(isold);
    for n=1:sum(isold)
        disp(['            ',CurPath{i(n)}])
    end
    disp('  ')
    pause(2)
    rmpath(CurPath{isold})  % This removes old drEEM folders
    disp('          Old drEEM folders removed from MATLAB path.')
else
    disp('          No previous version of drEEM found.')
end
%% STEP 3
disp('Step 3/5: Adding the new toolbox (make sure you changed the current directory)');pause(0.2)
fd=which('dreeminstall');
p=genpath(fd(1:end-14));
warning off
addpath(p)
try
    savepath
    disp('          drEEM toolbox was permanently added to the Matlab searchpath and will be available after restarting Matlab.')
catch
    disp('          Could not save the current searchpath. You will have to reinstall drEEM after restarting Matlab.')
end



warning on
disp('          Success.')
%% STEP 4

disp('Step 4/5: Checking for conflicting function names...');pause(0.2)
try
    mfiles=dir("*/*.m");
    message=[];
    for j=1:numel(mfiles)
        a=which(mfiles(j).name);
        if isempty(a)
            message=[message,[mfiles(j).name,' no found.\n']];
        elseif iscell(a)&&numel(a)>1
            if strcmp(fileparts(a{1}),[pwd,filesep,f])
            else
                message=[message,...
                    [mfilesstock{n},': Multiple functions with the same name & the installed one is not prioritized.\n']];
            end
        end
    end
    if not(isempty(message))
        error(sprintf(message))
    else
        disp('          Success.')
    end
catch ME
    matlabpath(pbackup)
    rethrow(ME)
end


%% STEP 5
disp('Step 5/5: Initializing a few things (this could take a minute).');pause(0.2)
try
    gcp;
catch
end
% The first plots can be a bit slow, this is just calling and closing one.
fig1=figure;
plot(nan,nan)
close(fig1)
%% END
disp('-----------------------------------------------------')
disp(' ')
disp('Installation complete.')


end


function mlist=returnmfilesOld(tbx)

switch tbx
    case 'drEEM_fun'
        mlist={'assembledataset.m';'checkdataset.m';'classinfo.m';...
            'compare2models.m';'comparespectra.m';'compcorrplot.m';...
            'coreandvar.m';'describecomp.m';'diffeem.m';'dreemfig.m';...
            'eemreview.m';'eemview.m';'errorsandleverages.m';...
            'fdomcorrect.m';'fingerprint.m';'loadingsandleverages.m';...
            'lookforconflicts.m';'handlescatter.m';'matchsamples.m';'metadata.m';...
            'modelexport.m';'modelout.m';'normeem.m';'nwayparafac.m';...
            'openfluor.m';'openfluormatches.m';'outliertest.m';'pickpeaks.m';...
            'ramanintegrationrange.m';'randinitanal.m';'readineems.m';...
            'readinscans.m';'readlogfile.m';'relcomporder.m';...
            'scanview.m';'scores2fmax.m';'slopefit.m';'smootheem.m';...
            'specsse.m';'spectralloadings.m';'spectralvariance.m';...
            'splitanalysis.m';'splitds.m';'splitvalidation.m';...
            'subdataset.m';'undilute.m';'zap.m'};
    case 'nway'
        mlist={'calcore.m';'ckron.m';'cmatrep.m';'complpol.m';'contents.m';...
            'corcond.m';'coredian.m';'coreswdn.m';'corevarn.m';'demos.m';'derdia3.m';...
            'derswd3.m';'dervar3.m';'dtld.m';'eemtimize.m';'explcore.m';'fac2let.m';...
            'fastnnls.m';'fnipals.m';'fnnls.m';'getindxn.m';'gram.m';'gsm.m';'ini.m';...
            'inituck.m';'kr.m';'krb.m';'maxdia3.m';'maxswd3.m';'maxvar3.m';'missmean.m';...
            'missmult.m';'misssum.m';'monreg.m';'ncosine.m';'ncrossdecomp.m';'ncrossdecompn.m';...
            'ncrossreg.m';'neye.m';'nident.m';'nmodel.m';'nonneg.m';'normit.m';'npls.m';'npred.m';...
            'nprocess.m';'nsetdiff.m';'nshape.m';'ntimes.m';'parademo.m';'pfls.m';...
            'pfplot.m';'pftest.m';'plotfac.m';'ppp.m';'refold3.m';'setnans1.m';'setopts.m';...
            'stdnan.m';'t3core.m';'tuckdemo.m';'tucker.m';'tucker2.m';'tucktest.m';'two2n.m';...
            'ulsr.m';'unimodal.m';'unimodalcrossproducts.m'};
    case 'dreemroot'
        mlist={'dreeminstall.m';'getdreem.m';'Contents.m'};
    case 'tutdemo'
        mlist={'drEEM_dataImport.m';'drEEM_dataImport_AL.m';'drEEM_parafac_tutorial_portSurvey.m';'drEEM_parafac_tutorial_wuensch.m';'drEEM_scattertreatment_tutorial_wuensch.m';'readme.md'};
    otherwise
        error('Strange... This folder / toolbox is unknown.')
end
end