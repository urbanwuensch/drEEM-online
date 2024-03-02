function [slopes,metadata,model] = slopefit(data,varargin)
%
% <strong>Syntax</strong>
%   <strong>slopefit</strong>(DS,varargin)
%   <strong>slopefit</strong>(DS,'Name','Value')
%
% <a href="matlab: doc slopefit">help for slopefit</a> <- click on the link

% Fit spectral slopes in three different areas of the CDOM absorbance
% spectrum
% NOTICE: This function uses the Statistics and Machine Learning toolbox
%         and requires Matlab 2016a or higher. If your Matlab is older, the 
%         plotting functions will be surpressed, but the function will still
%         produce the desired slopes.
% USEAGE:
%           [slopes,metadata,model] = slopefit(data,Name,value)
%
% INPUTS:
%           data:             drEEM-conform datset structure.
%           (optional):       Name,value: Parameter name followed by option
%           LongRange :       Wavelength range for the long wavelength slope.
                                      % Default: [300 600]
%           rsq               R^2 for quality control. If below Rsq, NaN is returned.
%                                     Default: 0.95
%           plot:             if false, results are not  shown  in a plot
%                                     Default: true
%           details:          if true, fitting and residual data for each sample will be shown
%                                     Default: false
%           samples:          if details==true, select samples to be inspected via plots
%                             (if lot's of samples are fit, this can be helpful
%                                     Default: [1:data.nSample] , ie all samples.
%
% 
% Exponential model: y = a350*exp(S/1000*(350-lamda))+k
%
% OUTPUTS:
%           slopes:     Table with slope information (see column headers)
%           metadata:   Table with metadata (see column headers)
%                       Exp_rsq:        R^2 of the exponential model
%                       Exp_a350_model: a350 in exp. model equation
%                       Exp_offset:     k in exp. model equation
%                       log_275_Rsq:    R^2 of the log-linear model (275-295)
%                       log_350_Rsq:    R^2 of the log-linear model (350-400)
%           model:      modeled data (exponential model)
% EXAMPLES:
%        1. [slopes,metadata,model] = slopefit(EEMcor,'LongRange',[300 600],'rsq',0.5,'plot',true,'details',true) 
%           Use to diagnose fits and plot results
%        2. [slopes] = slopefit(EEMcor) 
%           Use to just calculate slopes and store results in table
% 
% 
% 
% REFERENCES:
% 
% S275-S295: J. R. Helms, A. Stubbins, J. D. Ritchie, E. C. Minor, D. J. Kieber and K. Mopper, Limonology Oceanogr., 2008, 53, 955ÿ969. doi: 10.4319/lo.2008.53.3.0955
% S_long: 1 C. A. Stedmon and S. Markager, Limnol. Oceanogr., 2001, 46, 2087ÿ2093. doi:10.4319/lo.2001.46.8.2087
%
% NOTICE:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
%
% slopefit.m: Copyright (C) 2019 Urban J Wuensch
% Chalmers University of Technology
% Sven Hultins Gata 6
% 41296 Gothenburg, Sweden
% Version 3, April 2019. Small fixes and improvements. UJW
% Version 2, January 2019. Refinement of function inputs. UJW
% Version 1, July 2018 initial draft, based on code from Colin Stedmon
%% Function initialization
lastwarn('')
if nargin==0
    help slopefit
end

params = inputParser;
params.addParameter('LongRange', [300 600], @isnumeric);
params.addParameter('rsq', 0.95, @isnumeric);
params.addParameter('plot', true, @islogical);
params.addParameter('details', false, @islogical);
params.addParameter('quiet', false, @islogical);
params.addParameter('samples', 1:data.nSample, @isnumeric);

params.parse(varargin{:});
LRange  = params.Results.LongRange;
Rsq = params.Results.rsq;
diagn   = params.Results.details;
plt   = params.Results.plot;
samples   = params.Results.samples;
quiet   = params.Results.quiet;


mv=ver;
stool=false;
for n=1:numel(mv)
    if strcmp(mv(n).Name,'MATLAB')
        mver=mv(n).Version;
    end
    if strfind(mv(n).Name,'Statistics')
        stool=true;
    end
end

if ~stool
    error('slopefit.m requires the Statistics and Machine Learning Toolbox.')
end

mver=str2double(mver);
if mver<=9.0
    diagn=false;
    plt=false;
    warning('Matlab is too old for some features regarding plots of this function. All plots surpressed to avoid errors.')
end
    
%% Extract data

if any(~isfield(data,{'nSample','Abs','Abs_wave'}))
   error('One of the required fields is missing: .Abs, .Abs_wave, .nSample.')
end

a=data.Abs;
w=data.Abs_wave;
   

if data.nSample~=size(a,1)
    error('Inconsistent number of sampels vs. number of rows in absorbance data.')
end

if numel(w)~=size(a,2)
    error('Inconsistent sizes of wavelength vector and absorbance data.')
end

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

opts=statset;
opts.MaxIter=2500;
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
                    warning off
                    beta = nlinfit(waveSel{n},absSel{n}(:,i),@CDOMexp_K,[(mean(absSel{n}(1,i))); 18; 0],opts);
                    warning on
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
                        shortfit{i}= fitlm(waveSel{n},absSel{n}(i,:)','robustopts','off');
                    catch
                        shortfit{i}= fitlm(waveSel{n},real(absSel{n}(i,:)'),'robustopts','off');
                    end
                    warning on
                    if strcmp(lastwarn,'Iteration limit reached.')
                        disp(['Sample ',num2str(i),': Limit of fitting iterations reached (S275-295)'])
                        lastwarn('')
                    end
                    if shortfit{i}.Rsquared.Adjusted>Rsq
                        p_short=shortfit{i}.Coefficients{2,1};
                    else
                        p_short=NaN;
                    end
                else
                    shortfit{i}.Rsquared.Adjusted=nan;
                end
                Coef2([1 2],i)=[p_short.*-1E3;shortfit{i}.Rsquared.Adjusted];
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
                        longfit{i}= fitlm(waveSel{n},absSel{n}(i,:)','robustopts','off');
                    catch
                        longfit{i}= fitlm(waveSel{n},real(absSel{n}(i,:)'),'robustopts','off');
                    end
                    warning on
                    if strcmp(lastwarn,'Iteration limit reached.')
                        disp(['Sample ',num2str(i),': Limit of fitting iterations reached (S350-400)'])
                        lastwarn('')
                    end
                    if longfit{i}.Rsquared.Adjusted>Rsq
                        p_long=longfit{i}.Coefficients{2,1};
                    else
                        p_long=NaN;
                    end
                else
                    longfit{i}.Rsquared.Adjusted=nan;
                end
                Coef3([1 2],i)=[p_long*-1E3;longfit{i}.Rsquared.Adjusted];
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
    warning(' Exponential fit terms contained complex numbers. Output converted to real()')
    Coef1=real(Coef1);
end
if any([~isreal(Coef2),~isreal(Coef3),~isreal(Sr)])
    warning(' log-transformed linear fit terms contained complex numbers. Output converted to real()')
    Coef2=real(Coef2);
    Coef3=real(Coef3);
    Sr=real(Sr);
end
slopes=table(Coef1(2,:)',Coef2(1,:)',Coef3(1,:)',Sr','VariableNames',{'exp_slope_microm','S_275_295','S_350_400','Sr'});
metadata=table(Coef1(4,:)',Coef1(1,:)',Coef1(3,:)',Coef2(2,:)',Coef3(2,:)','VariableNames',{'Exp_rsq','Exp_a350_model','Exp_offset','log_275_Rsq','log_350_Rsq'});
if not(quiet)
    delete(wb)
end
%% Diagnosis plots if desired.
switch diagn
    case true
        close gcf
        fig2=dreemfig;
        set(fig2,'units','normalized')
        set(fig2,'pos',[0.1365    0.2926    0.6490    0.2852])
        movegui('center')
        disp('Showing raw, modeled, and residual data for selected samples. Press any key to continue or Ctrl + C to cancel.')
        for n=samples
            set(gcf,'Name',['Slopefit.m: Data vs. modeled data. Spectrum ',num2str(n),' of ',num2str(data.nSample)])
            try
                subplot(1,3,1)
                yyaxis left
                cla
                set(gca,'YColor','k')
                plot(data.Abs_wave,data.Abs(n,:),'LineWidth',0.5,'Color',[0.5 0.5 0.5]),hold on
                plot(waveSel{1},absSel{1}(:,n),'Color','k','LineStyle','-','LineWidth',1.5)
                plot(waveSel{1},model(n,:),'Color',lines(1),'LineStyle','-')
                ylabel('Absorbance'),xlabel('Wavelength (nm)')
                xlim([LRange(1)-20 LRange(2)+20])
                yyaxis right
                cla
                set(gca,'YColor', [1       0.663       0.094] )
                plot(waveSel{1},(absSel{1}(:,n)-model(n,:)')./nanmax(absSel{1}(:,n)),'Color', [1       0.663       0.094] ,'Marker','none','LineStyle','-')
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
                plot(data.Abs_wave,data.Abs(n,:),'LineWidth',0.5,'Color',[0.5 0.5 0.5]),hold on
                plot(waveSel{2},exp(absSel{2}(n,:)),'Color','k','LineStyle','-','LineWidth',1.5),hold on
                plot(waveSel{2},exp(feval(shortfit{n},waveSel{2})),'Color',lines(1),'Marker','none','LineStyle','-')
                xlim([250 320])
                ylabel('Absorbance'),xlabel('Wavelength (nm)')

                yyaxis right
                cla
                set(gca,'YColor',[1       0.663       0.094])
                plot(waveSel{2},(exp(absSel{2}(n,:))-exp(feval(shortfit{n},waveSel{2})))./max(exp(absSel{2}(n,:))),'Color',[1       0.663       0.094],'Marker','none','LineStyle','-')
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
                plot(data.Abs_wave,data.Abs(n,:),'LineWidth',0.5,'Color',[0.5 0.5 0.5]);hold on
                plot(waveSel{3},exp(absSel{3}(n,:)),'Color','k','LineStyle','-','LineWidth',1.5);hold on
                plot(waveSel{3},exp(feval(longfit{n},waveSel{3})),'Color',lines(1),'Marker','none','LineStyle','-');
                xlim([310 450])
                ylabel('Absorbance'),xlabel('Wavelength (nm)')
                yyaxis right
                cla
                set(gca,'YColor',[1       0.663       0.094])
                plot(waveSel{3},(exp(absSel{3}(n,:))-exp(feval(longfit{n},waveSel{3})))./max(exp(absSel{3}(n,:))),'Color',[1       0.663       0.094],'Marker','none','LineStyle','-');
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
            dreemfig(fig2);
            pause
        end
end
%% Plotting of results
switch plt
    case true

    fig1=dreemfig;
    set(fig1,'units','normalized','Name','slopefit: CDOM spectral slopes','pos',[0.3542    0.3648    0.2917    0.2000])

    plot(1:data.nSample,slopes.exp_slope_microm,'Color','k')
    xlabel('# Sample'),ylabel(['S_{',num2str(LRange(1)),'-',num2str(LRange(2)),'}'])
    yyaxis right
    plot(1:data.nSample,slopes.S_275_295,'Color',lines(1)),hold on
    plot(1:data.nSample,slopes.S_350_400,'Color','b','LineStyle','-','Marker','none')
    xlabel('# Sample'),ylabel('S_{275-295} & S_{350-400}')
    set(gca,'YColor','b')
    title('CDOM spectral slopes')
    xlim([0 data.nSample])
    legend(['S_{',num2str(LRange(1)),'-',num2str(LRange(2)),'nm}'],'S_{275-295nm}','S_{350-400nm}','location','eastoutside')
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
