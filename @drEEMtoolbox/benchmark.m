function  [singlescore,multiscore]=benchmark()

funmode=parallelcomp;

fpath=[drEEMtoolbox.tbxpath,'tutorials',filesep,'benchmarkDataset.mat'];
nc=gcp().NumWorkers;
load(fpath,'data')
X=data.X;
clearvars data

opthere=struct;
opthere.ConvCrit=1e-6;
opthere.MaxIt = 2500;
disp('single-core non-negative PARAFAC (50 passes)... ')
for j=1:50
    rs(j)=parafac3w(X,5,opthere); %#ok<AGROW>
end

s_its=arrayfun(@(x) x.it/x.tela,rs);

disp('multi-core non-negative PARAFAC (100 passes)... ')
tela=tic;
parfor j=1:100
    rp(j)=parafac3w(X,5,opthere);
end
tela=toc(tela);

p_its=arrayfun(@(x) x.it/x.tela,rp);
p_its_overall=sum(arrayfun(@(x) x.it,rp))./tela;

sp=p_its_overall./median(s_its);

% f=drEEMtoolbox.dreemfig;
% f.Name='drEEM: benchmark';
% t=tiledlayout(f,"flow");
% nexttile(t);
% 
% histogram(s_its,50,FaceColor='k',EdgeColor='k',Normalization='probability')
% ylabel('Probability')
% xlabel('Single-core score (iterations per second)')
% title(['Single-core performance score:',num2str(round(median(s_its)))])
% 
% 
% nexttile(t)
% histogram(p_its,50,FaceColor='k',EdgeColor='k',Normalization='probability')
% title(['Multi-core performance score:',num2str(round(median(p_its)))])
disp(' ')
disp('................................................................')
disp('<strong>drEEM toolbox PARAFAC CPU Benchmark results</strong>')
disp('................................................................')
disp(' ')
disp(['Single-core score (higher is better): <strong>',num2str(round(median(s_its))),'</strong>'])
disp(['Multi-core  score (higher is better):  <strong>',num2str(round(p_its_overall)),'</strong>'])

disp(['Multi-core enhancement factor (higher is better): <strong>',num2str(round(sp,1)),' vs. ',num2str(nc),' (theroretical)','</strong>'])
disp(['Multicore overhead penalty (lower is better):     <strong>',num2str(round(((nc./sp)-1).*100),1),'%','</strong>'])
disp('................................................................')
disp(' ')

singlescore=round(median(s_its));
multiscore=round(p_its_overall);

end

function funmode=parallelcomp(consoleoutput)
test=ver;
funmode='sequential';
if any(contains({test.Name},'Parallel'))
    funmode='parallel';
    try
        initppool(consoleoutput)
    catch
        funmode='sequential';
    end
end
end