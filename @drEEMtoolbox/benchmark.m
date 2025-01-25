function  [singlescore,multiscore,tsinglecore]=benchmark()

funmode=parallelcomp;

fpath=[drEEMtoolbox.tbxpath,'tutorials',filesep,'benchmarkDataset.mat'];
load(fpath,'data')
X=data.X;
clearvars data
nfac=5;

opthere=struct;
opthere.ConvCrit=1e-6;
opthere.MaxIt = 5000;
disp('single-core non-negative PARAFAC (50 passes) ... ')
tsingle=tic;
for j=1:50
    rs(j)=parafac3w(X,nfac,opthere); %#ok<AGROW>
end
s_its=arrayfun(@(x) x.it/x.tela,rs);
tsingle=toc(tsingle);
if matches(funmode,'parallel')
    disp('multi-core non-negative PARAFAC (100 passes) ... ')
    nc=gcp().NumWorkers;
    tela=tic;
    parfor j=1:100
        rp(j)=parafac3w(X,nfac,opthere);
    end
    tela=toc(tela);
    
    p_its=arrayfun(@(x) x.it/x.tela,rp);
    p_its_overall=sum(arrayfun(@(x) x.it,rp))./tela;
    
    sp=p_its_overall./median(s_its);
end
disp(' ')
disp('................................................................')
disp('<strong>drEEM toolbox PARAFAC CPU Benchmark results</strong>')
disp('................................................................')
disp(' ')
disp('<strong>Scores ...</strong>')
disp(['Single-core score (higher is better):            <strong>',num2str(round(median(s_its))),'</strong>'])
if matches(funmode,'parallel')
    disp(['Multi-core  score (higher is better):            <strong>',num2str(round(p_its_overall)),'</strong>'])
end
disp(' ')
disp('<strong>Other performance indicators ...</strong>')
disp(['Time for single-core passes (lower is better):   <strong>',num2str(round(tsingle,1)),'s</strong>'])
if matches(funmode,'parallel')
    disp(['Multi-core accel. factor (higher is better):     <strong>',num2str(round(sp,1)),' vs. ',num2str(nc),' (theroretical hardware limit)','</strong>'])
end
disp(' ')
disp('................................................................')
disp(' ')

singlescore=round(median(s_its));
if matches(funmode,'parallel')
    multiscore=round(p_its_overall);
else
    multiscore=missing;
end
tsinglecore=tsingle;

end

function funmode=parallelcomp
test=ver;
funmode='sequential';
consoleoutput=false;
if any(contains({test.Name},'Parallel'))
    funmode='parallel';
    try
        initppool(consoleoutput)
    catch
        funmode='sequential';
    end
end
end

function initppool(consoleoutput)
warning off
try
    poolsize=feature('NumCores');
    p = gcp('nocreate'); % If no pool, do not create new one.
    if isempty(p)
        parpool('local',poolsize);
    elseif p.NumWorkers~=poolsize
        if ~strcmp(consoleoutput,'none')
            disp('Found existing parpool with wrong number of workers.')
            disp(['Will now create pool with ',num2str(poolsize),' Workers.'])
        end
        delete(p);
        parpool('local',poolsize);
    else
        if ~strcmp(consoleoutput,'none')
            disp(['Existing parallel pool of ',num2str(p.NumWorkers),' workers found and used...'])
        end
    end
catch ME
    rethrow(ME)
end
warning on
end