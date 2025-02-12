function [dataout,slopes,metadata,model] = fitslopes(data,options)
% <a href = "matlab:doc fitslopes">[dataout,slopes,metadata,model] = fitslopes(data,options) (click to access documentation)</a>
%
% <strong>Inputs - Required</strong>
% data (1,1)              {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
%
% <strong>Inputs - Optional</strong>
% LongRange (1,2) {mustBeNumeric} = [300 600]
% rsq (1,1)       {mustBeNumeric,mustBeLessThanOrEqual(options.rsq,1)} = 0.95
% options.plot (1,1) {mustBeNumericOrLogical} = data.toolboxOptions.plotByDefault;
% details         {mustBeNumericOrLogical} = false


arguments
    data (1,1)              {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    options.LongRange (1,2) {mustBeNumeric} = [300 600]
    options.rsq (1,1)       {mustBeNumeric,mustBeLessThanOrEqual(options.rsq,1)} = 0.95
    options.plot (1,1) {mustBeNumericOrLogical} = data.toolboxOptions.plotByDefault;
    options.details         {mustBeNumericOrLogical} = false
    options.quiet         {mustBeNumericOrLogical} = false
end

% Experimental feature; overwrite workspace variable, needs no outputarg check
if drEEMtoolbox.outputscenario(nargout)=="explicitOut"
    nargoutchk(1,4)
end

if options.quiet
    options.plot = false;
    options.details = false;
end

LRange  = options.LongRange;
Rsq = options.rsq;
diagn   = options.details ;
plt   = options.plot;
samples   = 1:data.nSample;
quiet   = options.quiet;


mv=ver;
stool=any(contains({mv(:).Name},'Statistics and Machine Learning'));
if ~stool
    warning('Statistics and Machine Learning Toolbox not installed. No exponential slopes will be calculated.')
end

%% Extract data

if isempty(data.abs)
    error('fitslopes fits CDOM absorbance slopes and requires data to do so. data.abs is empty.')
end

a=data.abs;
w=data.absWave;

w=rcvec(w,'row');

%% Extract data for fits
% Find indcies
if not(isempty(LRange)) 
    wlr(1,:)=LRange;
else
    wlr(1,:)=[nan nan];
end
wlr(2,:)=[275 295];
wlr(3,:)=[350 400];

idx=nan(size(wlr,1),2);
absSel=cell(1,size(wlr,1));
waveSel=cell(1,size(wlr,1));

for n=1:size(wlr,1)
    for i=1:2
        [val,idx(n,i)]=min(abs(w-wlr(n,i)));
        if val~=0
            if ~strcmp(lastwarn,'Wavelength missmatch.')
                warning('Wavelength missmatch.');
            end
            
            disp([num2str(wlr(n,i)),'nm, picked for fitting slopes: ',num2str(w(idx(n,i)))]);
        end
    end
    absSel{n}=a(:,idx(n,1):idx(n,2));
    waveSel{n}=w(:,idx(n,1):idx(n,2));
end
%% Fitting

Coef1=nan(4,data.nSample);
model=nan(data.nSample,numel(waveSel{1}));
Coef2=nan(2,data.nSample);
Coef3=nan(2,data.nSample);
shortfit=cell(data.nSample,1);
longfit=cell(data.nSample,1);
if stool
    opts=statset;
    opts.MaxIter=2500;
end
if not(quiet)
    wb=waitbar(0,'Fitting spectral slopes...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');cnt=0;
    setappdata(wb,'canceling',0);
end
for n=1:3
    switch n
        case 1 % Long range exponential slope
            if isempty(LRange)
                continue
            end
            absSel{n}=absSel{n}';
            if ~iscolumn(waveSel{n})
                waveSel{n}=waveSel{n}';
            end
            for i=1:data.nSample
                if all(isnan(absSel{n}(:,i)'))
                    disp(['Sample ',num2str(i),' only contains nans'])
                    continue
                end
                if sum(isnan(absSel{n}(:,i)))>0.7*numel(absSel{n}(:,i))
                    disp(['Sample ',num2str(i),' contains more than 70% NaNs'])
                    continue
                end
                try
                    if stool
                    warning off
                    beta = nlinfit(waveSel{n},absSel{n}(:,i),@CDOMexp_K,[(mean(absSel{n}(1,i))); 18; 0],opts);
                    warning on
                    else
                        beta=[nan nan nan]';
                    end

                catch
                    warning(['Could not calculate the exponential slope for sample',num2str(i)])
                    beta=[nan nan nan]';
                end
                if strcmp(lastwarn,'Iteration limit exceeded.  Returning results from final iteration.')
                    disp(['Sample ',num2str(i),': Limit of fitting iterations reached (exponential slope)'])
                    lastwarn('')
                end
                model(i,:)=CDOMexp_K(beta,waveSel{n});
                fit=sum(model(i,:).^2)/sum(absSel{n}(:,i).^2);
                Coef1(:,i)=[beta; fit];
                if not(quiet)
                    if ~getappdata(wb,'canceling')
                        
                        cnt=cnt+1;waitbar(cnt./(data.nSample*2),wb,'Fitting spectral slopes... (long-range S)');
                    else
                        delete(wb)
                        error('Operation terminated by user during slopefit.m')
                    end
                end
            end
        case 2 % S275-295
            for i=1:data.nSample
                absSel{n}(i,:)=log(absSel{n}(i,:));
                
                if sum(isnan(absSel{n}(i,:)))>0.7*numel(absSel{n}(i,:))
                    disp(['Sample ',num2str(i),' contains more than 70% NaNs'])
                    continue
                end
                
                if ~all(isnan(absSel{n}(i,:)))
                    warning off
                    try
                        %shortfit{i}= fitlm(waveSel{n},absSel{n}(i,:)','robustopts','off');
                        shortfit{i} = customlmfit(waveSel{n}',absSel{n}(i,:)');
                    catch
                        %shortfit{i}= fitlm(waveSel{n},real(absSel{n}(i,:)'),'robustopts','off');
                        shortfit{i}= customlmfit(waveSel{n}',real(absSel{n}(i,:)'));
                    end
                    warning on
                    if strcmp(lastwarn,'Iteration limit reached.')
                        disp(['Sample ',num2str(i),': Limit of fitting iterations reached (S275-295)'])
                        lastwarn('')
                    end
                    if shortfit{i}.Rsquared>Rsq
                        p_short=shortfit{i}.Coefficients{2,1};
                    else
                        p_short=NaN;
                    end
                else
                    shortfit{i}.Rsquared=nan;
                end
                Coef2([1 2],i)=[p_short.*-1E3;shortfit{i}.Rsquared];
                if not(quiet)
                    if ~getappdata(wb,'canceling')
                        cnt=cnt+1;waitbar(cnt./(data.nSample*2),wb,'Fitting spectral slopes... (short-range S)');
                    else
                        delete(wb)
                        error('Operation terminated by user during slopefit.m')
                    end
                end
            end
        case 3 % S350-400
            for i=1:data.nSample
                absSel{n}(i,:)=log(absSel{n}(i,:));
                
                if sum(isnan(absSel{n}(i,:)))>0.7*numel(absSel{n}(i,:))
                    disp(['Sample ',num2str(i),' contains more than 70% NaNs'])
                    continue
                end
                
                if ~all(isnan(absSel{n}(i,:)))
                    warning off
                    try
                        longfit{i} = customlmfit(waveSel{n}',absSel{n}(i,:)');
                    catch
                        longfit{i} = customlmfit(waveSel{n}',real(absSel{n}(i,:)'));
                    end
                    warning on
                    if strcmp(lastwarn,'Iteration limit reached.')
                        disp(['Sample ',num2str(i),': Limit of fitting iterations reached (S350-400)'])
                        lastwarn('')
                    end
                    if longfit{i}.Rsquared>Rsq
                        p_long=longfit{i}.Coefficients{2,1};
                    else
                        p_long=NaN;
                    end
                else
                    longfit{i}.Rsquared=nan;
                end
                Coef3([1 2],i)=[p_long*-1E3;longfit{i}.Rsquared];
                if not(quiet)
                    if ~getappdata(wb,'canceling')
                        cnt=cnt+1;waitbar(cnt./(data.nSample*2),wb,'Fitting spectral slopes... (short-range S)');
                    else
                        delete(wb)
                        error('Operation terminated by user during slopefit.m')
                    end
                end
            end
    end
end
Sr=Coef2(1,:)./Coef3(1,:);

%% Transfer results into table
if ~isreal(Coef1)
    %warning(' Exponential fit terms contained complex numbers. Output converted to real()')
    Coef1=real(Coef1);
end
if any([~isreal(Coef2),~isreal(Coef3),~isreal(Sr)])
    %warning(' log-transformed linear fit terms contained complex numbers. Output converted to real()')
    Coef2=real(Coef2);
    Coef3=real(Coef3);
    Sr=real(Sr);
end
slopes=table(Coef1(2,:)',Coef2(1,:)',Coef3(1,:)',Sr','VariableNames',{'exp_slope_microm','S_275_295','S_350_400','Sr'});
metadata=table(Coef1(4,:)',Coef1(1,:)',Coef1(3,:)',Coef2(2,:)',Coef3(2,:)','VariableNames',{'Exp_rsq','Exp_a350_model','Exp_offset','log_275_Rsq','log_350_Rsq'});
if not(quiet)
    delete(wb)
end

dataout=data;

[C,ia,ib]=intersect(dataout.opticalMetadata.Properties.VariableNames, ...
    slopes.Properties.VariableNames);
dataout.opticalMetadata(:,ia)=[];

dataout.opticalMetadata=[dataout.opticalMetadata,slopes];

idx=height(dataout.history)+1;
dataout.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,'CDOM slopes determined',options,dataout);

dataout.validate(dataout);


%% Diagnosis plots if desired.
switch diagn
    case true
        if data.toolboxOptions.uifig
            fig2=drEEMtoolbox.dreemuifig;
        else
            fig2=drEEMtoolbox.dreemfig;
        end
        set(fig2,'units','normalized')
        set(fig2,'pos',[0.1365    0.2926    0.6490    0.2852])
        movegui(fig2,'center')
        disp('Showing raw, modeled, and residual data for selected samples. Press any key to continue or Ctrl + C to cancel.')
        for n=samples
            set(fig2,'Name',['Slopefit.m: Data vs. modeled data. Spectrum ',num2str(n),' of ',num2str(data.nSample)])
            try
                subplot(1,3,1)
                yyaxis left
                cla
                set(gca,'YColor','k')
                plot(data.absWave,data.abs(n,:),'LineWidth',0.5,'Color',[0.5 0.5 0.5]),hold on
                plot(waveSel{1},absSel{1}(:,n),'Color','k','LineStyle','-','LineWidth',1.5)
                plot(waveSel{1},model(n,:),'Color',lines(1),'LineStyle','-')
                ylabel('Absorbance'),xlabel('Wavelength (nm)')
                xlim([LRange(1)-20 LRange(2)+20])
                yyaxis right
                cla
                set(gca,'YColor', [1       0.663       0.094] )
                plot(waveSel{1},(absSel{1}(:,n)-model(n,:)')./max(absSel{1}(:,n),"omitmissing"),'Color', [1       0.663       0.094] ,'Marker','none','LineStyle','-')
                ylabel('Relative residual'),xlabel('Wavelength (nm)')
                hold off
                title(['S_{',num2str(LRange(1)),'-',num2str(LRange(2)),'} exp. model vs. fitted & residuals'])
            catch
                subplot(1,3,1)
                yyaxis right
                cla
                yyaxis left
                cla
                line(nan,nan)
                legend('No fit possible')
            end

            try
                subplot(1,3,2)
                yyaxis left
                cla
                set(gca,'YColor','k')
                plot(data.absWave,data.abs(n,:),'LineWidth',0.5,'Color',[0.5 0.5 0.5]),hold on
                plot(waveSel{2},exp(absSel{2}(n,:)),'Color','k','LineStyle','-','LineWidth',1.5),hold on
                plot(waveSel{2},exp(polyval(shortfit{n}.fit,waveSel{2})),'Color',lines(1),'Marker','none','LineStyle','-')
                xlim([250 320])
                ylabel('Absorbance'),xlabel('Wavelength (nm)')

                yyaxis right
                cla
                set(gca,'YColor',[1       0.663       0.094])
                plot(waveSel{2},(exp(absSel{2}(n,:))-exp(polyval(shortfit{n}.fit,waveSel{2})))./max(exp(absSel{2}(n,:))),'Color',[1       0.663       0.094],'Marker','none','LineStyle','-')
                hold off
                title('S_{275-295} model vs. fitted & residuals')
                ylabel('Relative residual'),xlabel('Wavelength (nm)')
            catch
                subplot(1,3,2)
                yyaxis right
                cla
                yyaxis left
                cla
                line(nan,nan)
                legend('No fit possible')
            end

            try
                subplot(1,3,3)
                yyaxis left
                cla
                set(gca,'YColor','k')
                plot(data.absWave,data.abs(n,:),'LineWidth',0.5,'Color',[0.5 0.5 0.5]);hold on
                plot(waveSel{3},exp(absSel{3}(n,:)),'Color','k','LineStyle','-','LineWidth',1.5);hold on
                plot(waveSel{3},exp(polyval(longfit{n}.fit,waveSel{3})),'Color',lines(1),'Marker','none','LineStyle','-');
                xlim([310 450])
                ylabel('Absorbance'),xlabel('Wavelength (nm)')
                yyaxis right
                cla
                set(gca,'YColor',[1       0.663       0.094])
                plot(waveSel{3},(exp(absSel{3}(n,:))-exp(polyval(longfit{n}.fit,waveSel{3})))./max(exp(absSel{3}(n,:))),'Color',[1       0.663       0.094],'Marker','none','LineStyle','-');
                ylabel('Relative residual'),xlabel('Wavelength (nm)')
                hold off
                title('S_{350-400} model vs. fitted & residuals')
                [ h ] = leg(4,[0.5 0.5 0.5;0 0 0;lines(1);1 0.663 0.094],gca);
                legend1=legend(h,{'Raw','selected','fitted','residual'},'location','eastoutside');
                legend1.Position=[0.9104    0.4407    0.0746    0.1867];
                try
                    disp(['Spectrum ',num2str(n),' of ',num2str(numel(samples)),':  ',data.filelist{samples(n)}])
                catch
                    disp(['Spectrum ',num2str(n),' of ',num2str(numel(samples)),'. Sample no.=',samples(n)])
                end
            catch
                subplot(1,3,3)
                yyaxis right
                cla
                yyaxis left
                cla
                line(nan,nan)
                legend('No fit possible')
            end
            
            pause
        end
end
%% Plotting of results
switch plt
    case true
    if data.toolboxOptions.uifig
        fig1=drEEMtoolbox.dreemuifig;
    else
        fig1=drEEMtoolbox.dreemfig;
    end
    set(fig1,'units','normalized','Name','slopefit: CDOM spectral slopes','pos',[0.3542    0.3648    0.2917    0.2000])
    ax=nexttile(tiledlayout(fig1));
    plot(ax,1:data.nSample,slopes.exp_slope_microm,'Color','k')
    xlabel(ax,'# Sample')
    ylabel(ax,['S_{',num2str(LRange(1)),'-',num2str(LRange(2)),'}'])
    yyaxis(ax,"right")
    plot(ax,1:data.nSample,slopes.S_275_295,'Color',lines(1)),hold(ax,"on")
    plot(ax,1:data.nSample,slopes.S_350_400,'Color','b','LineStyle','-','Marker','none')
    xlabel(ax,'# Sample'),ylabel(ax,'S_{275-295} & S_{350-400}')
    set(ax,'YColor','b')
    title(ax,'CDOM spectral slopes')
    xlim(ax,[0 data.nSample])
    legend(ax,['S_{',num2str(LRange(1)),'-',num2str(LRange(2)),'nm}'],'S_{275-295nm}','S_{350-400nm}','location','eastoutside')
end

% Will only run if toolbox is set to overwrite workspace variable and user
% didn't provide an output argument
if drEEMtoolbox.outputscenario(nargout)=="implicitOut"
    assignin("base",inputname(1),dataout);
    disp(['<strong> "',char(inputname(1)), '" processed. </strong> Since no output argument was provided, the workspace variable was overwritten.'])
    return
end


end

function yhat = CDOMexp_K(beta,x)
%CDOM exponential abs model.
%   YHAT = CDOMexp(BETA,X) gives the predicted values of the
%   reaction rate, YHAT, as a function of the vector of 
%   parameters, BETA, and the matrix of data, X.
%   BETA must have ? elements and X must have three
%   columns.
%
%   y = a350*exp(S/1000*(350-lamda))+k
% (c) Colin Stedmon

b1 = beta(1); %a350
b2 = beta(2); %S
b3 = beta(3); %K

x = x(:,1); %lamda


yhat = b1*exp(b2/1000*(350-x))+b3;

end



function [vout] = rcvec(v,rc)
% (c) Urban Wuensch. Produce row or colum vector, regardless of input
% Make row or column vector
% v: vector
% rc: either 'row' ([1:5])or 'column' ([1:5]')
sz=size(v);
if ~any(sz==1)&&numel(sz)>2
    error('Input is not a vector')
end

switch rc
    case 'row'
        if ~(sz(1)<sz(2))
            vout=v';
        else
            vout=v;
        end
    case 'column'
        if ~(sz(1)>sz(2))
            vout=v';
        else
            vout=v;
        end
    otherwise
            error('Input ''rc'' not recognized. Options are: ''row'' and ''column''.')
end


end

function [ h ] = leg( numPlots,col,ax)
h = gobjects(numPlots, 1);
for n=1:numPlots
    hold on;
    h(n) = line(ax,NaN,NaN,'Marker','o','MarkerSize',5,'MarkerFaceColor',col(n,:),'MarkerEdgeColor','k','LineStyle','none');
end
end

function results = customlmfit(x,y)
% out=fit(x,y,'poly1');
% 
% sum_of_squares = sum((y-mean(y)).^2);
% sum_of_squares_of_residuals = sum((y-feval(out,x)).^2);
% Rsquared = 1 - sum_of_squares_of_residuals/sum_of_squares;
% 
% results=struct;
% results.Coefficients=table;
% results.Coefficients.Estimate(1)=out.p2;
% results.Coefficients.Estimate(2)=out.p1;
% results.Rsquared=Rsquared;
% results.fit=out; % store that stuff for later feval

% results=fitlm(x,y,RobustOpts='off');

[out,S] = polyfit(x,y,1);
sum_of_squares = sum((y-mean(y)).^2);
sum_of_squares_of_residuals = sum((y-polyval(out,x)).^2);
Rsquared = 1 - sum_of_squares_of_residuals/sum_of_squares;

results=struct;
results.Coefficients=table;
results.Coefficients.Estimate(1)=out(2);
results.Coefficients.Estimate(2)=out(1);
results.Rsquared=Rsquared;
results.fit=out; % store that stuff for later polyval

end