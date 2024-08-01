function dataout = scalesamples(data,option)
%
arguments
    data (1,1) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    option (1,:) 
end

% Experimental feature; overwrite workspace variable, needs no outputarg check
if drEEMtoolbox.outputscenario(nargout)=="explicitOut"
    nargoutchk(1,1)
end


%% Define some functions and stuff.
tens2mat=@(x,sz1,sz2,sz3) reshape(x,sz1,sz2*sz3);

if isnumeric(option)
    mustBePositive(option)
    mustBeLessThanOrEqual(option,50)
    opmode='apply';
elseif ischar(option)|isstring(option)
    mustBeMember(option,["reverse","help"])
    if matches(option,'reverse')
        opmode='reverse';
    elseif matches(option,'help')
        opmode='help';
    else
        error('Input to ''intensity'' (second input) must be a number, ''reverse'' or ''help''.')
    end
else
    error('Input to ''intensity'' (second input) must be a number or ''reverse''.')
end

% If scaling operation is repeated (i.e. dataset was already scaled),
% restore the backup and scale that version (it is up to date!).
pidx=drEEMhistory.searchhistory(data.history,"scalesamples","first");
lastidx=drEEMhistory.searchhistory(data.history,"scalesamples","last");
if not(isempty(pidx))&&not(isempty(lastidx))
    lastmessage=data.history(lastidx).fmessage;
    if not(isempty(pidx))&&matches(opmode,'apply')&&not(contains(lastmessage,'reversed'))
        unscaled=data.history(pidx).previous;
        data.X=unscaled.X;
        
        % But let's document what happened!
        idx=height(data.history)+1;
        data.history(idx,1)=...
            drEEMhistory.addEntry(mfilename,...
            'Repeated scaling; restored unscaled .X',[],data,unscaled);
        warning('FYI, repeated scaling detected. Original was restored and used for this call.')
    end
end

switch opmode
    case 'apply'
        
        if not(option>=1&option<=50)
            error('''intensity'' should be a number between 1 (close to unit variance) and 50 (close to no scaling)')
        end
        
        dataout=data;
        if not(option==1)
            dataout.status=drEEMstatus.change(dataout.status,...
                "signalScaling",...
                ['Scaled to ',num2str(option),'th root of standard deviation in sample mode']);
        else
            dataout.status=drEEMstatus.change(dataout.status,...
                "signalScaling",'Scaled to unit variance in sample mode');
        end
        scalefac=1./nthroot(std(...
            tens2mat(dataout.X,dataout.nSample,dataout.nEm,dataout.nEx)...
            ,0,2,'omitnan'),option);
        
        if any(isnan(scalefac))
            error('Some scaling factors are NaN!')
        end
        
        dataout.X=dataout.X.*scalefac;
        message=['scaling applied nth root of std, n = ',num2str(option)];
        idx=height(dataout.history)+1;
        dataout.history(idx,1)=...
            drEEMhistory.addEntry(mfilename,message,[],dataout,data);

    case 'reverse'
        dataout=data;
        f=drEEMdataset.modelsWithContent(dataout);
        idx=drEEMhistory.searchhistory(data.history,'scalesamples','first');

        if isempty(idx)
            error('It appears that this dataset has not been scaled before. Exiting...')
        end
        Xnotscaled=data.history(idx).previous.X;
        dataout.X=Xnotscaled;
        for n=1:numel(f)
            loads=data.models(f(n)).loads;
            cc=data.models(f(n)).convergence;
            const=data.models(f(n)).constraints;
            if matches(const,'unconstrained') %no constraints
                constr=[0 0 0];
            elseif matches(const,'nonnegativity') %all non-negative
                constr=[2 2 2];
            elseif matches(const,'unimodnonneg') %unimodal emission
                constr=[2 3 2];
            else
                error(['unknown constraint: ',char(const)])
            end

            
            
            forced=nwayparafac(Xnotscaled,f(n),[cc 2 0 -1 0 5000],constr,...
                {rand(data.history(idx).backup.nSample,f(n));loads{2};loads{3}},[0 1 1]);
            dataout.models(f(n)).loads = forced;
           
        end
        disp('Scaling reversed.')
        dataout.status=drEEMstatus.change(dataout.status,...
                "signalScaling","reversed");
        idx=height(dataout.history)+1;
        dataout.history(idx,1)=...
            drEEMhistory.addEntry(mfilename,'scaling reversed',[],dataout);

        
    case 'help'
        if isfield(data,'Xnotscaled')
            disp('Data appear to be scaled already. Performing diagnosis on the unscaled data.')
            temp=data;
            temp.X=temp.Xnotscaled;
            scaleeemdiag(temp,[1 3])
        else
            scaleeemdiag(data,[1 3])
        end
        return
    otherwise
        error('Input to ''intensity'' (second input) not understood.')
end

% Will only run if toolbox is set to overwrite workspace variable and user
% didn't provide an output argument
if drEEMtoolbox.outputscenario(nargout)=="implicitOut"
    assignin("base",inputname(1),dataout);
    disp(['<strong> "',inputname(1), '" processed. </strong> Since no output argument was provided, the workspace variable was overwritten.'])
    return
end

end



function scaleeemdiag(data,nthrootlim)
% plot peak distributions for different normalization parameters

%% Functions % definitions
mindist  = @(vec,val) find(ismember(abs(vec-val),min(abs(vec-val))),1,'first');
tens2mat = @(x,sz1,sz2,sz3) reshape(x,sz1,sz2*sz3);

nthrootspec=linspace(nthrootlim(1),nthrootlim(2),200);
ploc=[442.5 340;...
    510 390;...
    390 300;...
    345 275];
peakletter={'C';'D';'M';'T'};

%% Calculations
peak=table;
dist=table;

% Distribtions (within peak)
xtemp=data.X./std(tens2mat(data.X,data.nSample,data.nEm,data.nEx),0,2,'omitnan');
for i=1:numel(peakletter)
    dist.(peakletter{i})(:,1)=xtemp(:,mindist(data.Em,ploc(i,1)),mindist(data.Ex,ploc(i,2)));
    peak.(peakletter{i})(:,1)=dist.(peakletter{i})(:,1)./max(dist.(peakletter{i})(:,1),[],1,'omitnan');
end


for n=1:numel(nthrootspec)
    xtemp=data.X./nthroot(std(tens2mat(data.X,data.nSample,data.nEm,data.nEx),0,2,'omitnan'),nthrootspec(n));
    for i=1:numel(peakletter)
        dist.(peakletter{i})(:,n+1)=xtemp(:,mindist(data.Em,ploc(i,1)),mindist(data.Ex,ploc(i,2)));
        peak.(peakletter{i})(:,n+1)=dist.(peakletter{i})(:,n+1)./max(dist.(peakletter{i})(:,n+1),[],1,'omitnan');
    end
end

% xtemp=data.X;
% for i=1:numel(peakletter)
%     dist.(peakletter{i})(:,n+1)=xtemp(:,mindist(data.Em,ploc(i,1)),mindist(data.Em,ploc(i,2)));
%     peak.(peakletter{i})(:,n+1)=dist.(peakletter{i})(:,n+1)./max(dist.(peakletter{i})(:,n+1),[],1,'omitnan');
% end

% Distribtions (across peak)
reldist=table('Size',[(numel(nthrootspec)+1) 4],'VariableTypes',{'double','double','double','double'});

for n=1:size(dist.(peakletter{1}),2)
    reldist.('MT')(n,1)=median(dist.('M')(:,n),'omitnan')./median(dist.('T')(:,n),'omitnan');
    reldist.('CM')(n,1)=median(dist.('C')(:,n),'omitnan')./median(dist.('M')(:,n),'omitnan');
    reldist.('CD')(n,1)=median(dist.('C')(:,n),'omitnan')./median(dist.('D')(:,n),'omitnan');
    reldist.('TD')(n,1)=median(dist.('T')(:,n),'omitnan')./median(dist.('D')(:,n),'omitnan');
end


% Correlations
r=table('Size',[(numel(nthrootspec)+1) 4],'VariableTypes',{'double','double','double','double'});
for n=1:(numel(nthrootspec)+1)
    r.('MT')(n,1)=corr(peak.('M')(:,n),peak.('T')(:,n),'Rows','complete');
    r.('CM')(n,1)=corr(peak.('C')(:,n),peak.('M')(:,n),'Rows','complete');
    r.('CD')(n,1)=corr(peak.('C')(:,n),peak.('D')(:,n),'Rows','complete');
    r.('TD')(n,1)=corr(peak.('T')(:,n),peak.('D')(:,n),'Rows','complete');
end

%% Plotting
% Distribtions (within peak)DS=(DS-nanmin(DS))/(nanmax(DS)-nanmin(DS))
% scaling = @(x) (x-min(x,[],'omitnan'))/(max(x,[],'omitnan')-min(x,[],'omitnan'));
% strength=logspace(1,0,numel(nthrootspec)+1);
% strength=scaling(strength)*100;
strength=[1 nthrootspec];

close all
fig=drEEMtoolbox.dreemfig;
tiledlayout(3,4,'padding','tight','TileSpacing','tight')
for i=1:numel(peakletter)
    nexttile
    hold on
    plot(strength,1-median(peak.(peakletter{i}),'omitnan'),'LineWidth',2,'Color','k')
    title(peakletter{i})
end


% Distribtions (across peak)

target={'MT','CM','CD','TD'};

for n=1:numel(target)
    nexttile
    scatter(strength,reldist.(target{n}),'filled','k')
    title([target{n}(1),' / ',target{n}(2)])
end


% Correlations
target={'MT','CM','CD','TD'};

for n=1:numel(target)
    nexttile
    scatter(strength,r.(target{n}),'filled','k')
    yline(0,'-','Color','r')
    title([target{n}(1),' vs. ',target{n}(2)])
    ylim([-1 1])
end
ax=flipud(findall(fig,'type','axes'));
for n=1:numel(ax)
    grid(ax(n),'on')
end

t=sgtitle('scaleeem: scaling diagnosis');
t.FontWeight='bold';
t.FontName='Arial';
ylabel(ax(1),'Median distance from max.')
ylabel(ax(5),'Median distance')
ylabel(ax(9),'Correlation (r)')
for n=9:12,xlabel(ax(n),'n^{th} root');end

end