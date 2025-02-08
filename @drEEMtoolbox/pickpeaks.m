function [ dataout,picklist,metadata ] = pickpeaks( data,options)
% <a href = "matlab:doc pickpeaks">[dataout,picklist,metadata] = pickpeaks( data,options) (click to access documentation)</a>
%
% <strong>Inputs - Required</strong>
% data (1,1)    {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
% 
% <strong>Inputs - Optional</strong>
% plot          {mustBeNumericOrLogical} = true
% details       {mustBeNumericOrLogical} = false

arguments
    data (1,1) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
    options.plot {mustBeNumericOrLogical} = true
    options.details  {mustBeNumericOrLogical} = false
    options.quiet {mustBeNumericOrLogical} = false
end
% Experimental feature; overwrite workspace variable, needs no outputarg check
if drEEMtoolbox.outputscenario(nargout)=="explicitOut"
    nargoutchk(1,3)
end
Xname = 'X';
if options.quiet
    options.plot = false;
    options.details = false;
end

plt = options.plot;
diagn = options.details;
dataout=data;


%% Definition of peaks: B, T, A, M, C, D, E, N.
peaks(1).name=cellstr('B');
peaks(1).Em=num2cell(305);
peaks(1).Ex=num2cell(275);
peaks(2).name=cellstr('T');
peaks(2).Em=num2cell(340);
peaks(2).Ex=num2cell(275);
peaks(3).name=cellstr('A');
peaks(3).Em=num2cell(400:460);
peaks(3).Ex=num2cell(260);
peaks(4).name=cellstr('M');
peaks(4).Em=num2cell(370:410);
peaks(4).Ex=num2cell(290:310);
peaks(5).name=cellstr('C');
peaks(5).Em=num2cell(420:460);
peaks(5).Ex=num2cell(320:360);
peaks(6).name=cellstr('D');
peaks(6).Em=num2cell(509);
peaks(6).Ex=num2cell(390);
% peaks(7).name=cellstr('E');
% peaks(7).Em=num2cell(521);
% peaks(7).Ex=num2cell(455);
peaks(7).name=cellstr('N');
peaks(7).Em=num2cell(370);
peaks(7).Ex=num2cell(280);

%% Define anon. functs

vec=@(x) x(:);

%% Change resolution of EEMs to 1nm in order to properly calculate and extract peaks and indicies
Exint=1;
Emint=1;
Ex_i=round(data.Ex(1)):Exint:round(data.Ex(end));
Em_i=(round(data.Em(1)):Emint:round(data.Em(end)))';
nEx_i=size(Ex_i,2);
nEm_i=size(Em_i,1);
Xi=zeros(data.nSample,size(Em_i,1),size(Ex_i,2));

if mean(diff(data.Ex))>5
    if not(options.quiet)
        warning('Excitation increment>5nm. The performed interpolation might introduce significant biases!')
        pause(2)
    end
end
if mean(diff(data.Em))>10
    if not(options.quiet)
        warning('Emission increment>10nm. The performed interpolation might introduce significant biases!')
        pause(2)
    end
end


for i=1:data.nSample
    eem=squeeze(data.(Xname)(i,:,:));
    Xi(i,:,:) = interp2(data.Ex,data.Em,eem,Ex_i,Em_i);
end
data.(Xname)=Xi;
data.nEm=nEm_i;
data.nEx=nEx_i;
data.Ex=Ex_i';
data.Em=Em_i;


%% Check if distance between fluorescence peaks and dataset Ex and Em is too big

if ~any(data.Ex==254)
    if not(options.quiet)
        warning('Humification index cannot be calculated due to dataset limitations')
    end
    HIX_excl=true;
else
    HIX_excl=false;
end

distEx=nan(1,numel(peaks));
distEm=nan(1,numel(peaks));
for n=1:numel(peaks)
    [~,distEx(n)] = mindist( data.Ex,peaks(n).Ex{1});
    [~,distEm(n)] = mindist( data.Em,peaks(n).Em{1});
end

if any(distEx>=5)
    if not(options.quiet)
        warning('Distance between some peak definitions and Dataset-wavelengths >=5nm: Excitation');
    end
end
if any(distEm>=5)
    if not(options.quiet)
        warning('Distance between some peak definitions and Dataset-wavelengths >=10nm: Emission');
    end
end


%% Peak picking
Cpeak=nan(data.nSample,numel(peaks));
md=struct;
for i=1:data.nSample
    % Running through different scenarios
    % #1: Ex/Em pair
    for n=1:size(peaks,2)
        if isscalar(peaks(n).Em)&&isscalar(peaks(n).Ex)
            Cpeak(i,n)=data.(Xname)(i,mindist(data.Em,peaks(n).Em{1}),mindist(data.Ex,peaks(n).Ex{1}));
            % #2: Specific Ex, but Em range
        elseif isscalar(peaks(n).Ex)&&numel(peaks(n).Em)~=1
            tempEm=data.(Xname)(i,mindist(data.Em,peaks(n).Em{1}):mindist(data.Em,peaks(n).Em{end}),mindist(data.Ex,peaks(n).Ex{1}));
            Cpeak(i,n)=max(tempEm,[],'omitnan');
            % #3: Ex and Em range-peaks
        else
            x1=mindist(data.Ex,peaks(n).Ex{1});
            x2=mindist(data.Ex,peaks(n).Ex{end});
            y1=mindist(data.Em,peaks(n).Em{1});
            y2=mindist(data.Em,peaks(n).Em{end});
            mat=squeeze(data.(Xname)(i,y1:y2,x1:x2));
            [Cpeak(i,n),idxmax]=max(vec(mat),[],'omitnan');
            [empos, expos] = ind2sub(size(mat), idxmax);
            ex=data.Ex(x1:x2);
            em=data.Em(y1:y2);
            md.Ex(i,n)=ex(expos);
            md.Em(i,n)=em(empos);
        end
    end
end

%% Indices
FI=nan(1,data.nSample);
FrI=nan(1,data.nSample);
BIX=nan(1,data.nSample);
HIX=nan(1,data.nSample);
if diagn
    dfig=drEEMtoolbox.dreemfig;
    set(dfig,'units','normalized','pos',[0.1344    0.2537    0.7625    0.3194])
    set(dfig,'name','pickPeaks.m - raw vs. smoothed fluorescence for indicies')
end
for i=1:data.nSample
    try
        % Fluorescence index
        EmScan370=data.(Xname)(i,:,mindist(data.Ex,370));
        if all(isnan(EmScan370))
            error('Nothing there')
        end
        EmScan370=naninterp(EmScan370,'PCHIP');
        if diagn
            subplot(1,3,1)
            hold on
            h1=plot(data.Em,EmScan370,'LineStyle','none','Marker','+','Color','k');hold on;
            h2=plot(data.Em,smoothdata(EmScan370,21,'sgolay',2),'LineWidth',1.7);
            axis tight
            cylim=get(gca,'YLim');
            ylim([0 cylim(2)])
            cylim=get(gca,'YLim');
            plot([470 470],cylim,'r','LineStyle','--')
            plot([520 520],cylim,'r','LineStyle','--')
            title('em at ex = 370 (Fl.index)')
            legend([h1 h2],{'raw','smoothed'},'location','best')
            box on
        end
        EmScan370 = smoothdata(EmScan370,21,'sgolay',2);
    
        Val1=EmScan370(mindist(data.Em,470));
        Val2=EmScan370(mindist(data.Em,520));
        FI(i)=Val1/Val2;
    catch
         FI(i)=nan;
    end
    try
        % Freshness index
        EmScan310=data.(Xname)(i,:,mindist(data.Ex,310));
        if all(isnan(EmScan310))
            error('Nothing there')
        end
        
        EmScan310=naninterp(EmScan310,'PCHIP');
        if diagn
            subplot(1,3,2)
            hold on
            plot(data.Em,EmScan310,'LineStyle','none','Marker','+','Color','k');
            hold on
            plot(data.Em,smoothdata(EmScan310,21,'sgolay',2),'LineWidth',1.7)
            axis tight
            cylim=get(gca,'YLim');
            ylim([0 cylim(2)])
            cylim=get(gca,'YLim');
            plot([380 380],cylim,'r','LineStyle','--')
            y = [cylim(1) cylim(2) cylim(2) cylim(1)];
            x = [420 420 435 435];
            patch(x,y,'red','FaceAlpha',0.5)
            title('em at ex = 310 (Freshness index)')
            box on
        end
        EmScan310 = smoothdata(EmScan310,21,'sgolay',2);
        
        Val1=EmScan310(mindist(data.Em,380));
        Val2=max(EmScan310(mindist(data.Em,420):mindist(data.Em,435)),[],'omitnan');
        FrI(i)=Val1/Val2;
    catch
        FrI(i)=nan;
    end
    try
        % Humification index
        if ~HIX_excl
            EmScan254=data.(Xname)(i,:,mindist(data.Ex,254));
            if all(isnan(EmScan254))
                error('Nothing there')
            end
            
            EmScan254=naninterp(EmScan254,'PCHIP');
            if diagn
                subplot(1,3,3)
                hold on
                plot(data.Em,EmScan254,'LineStyle','none','Marker','+','Color','k');
                hold on
                plot(data.Em,smoothdata(EmScan254,21,'sgolay',2),'LineWidth',1.7)
                axis tight
                cylim=get(gca,'YLim');
                ylim([0 cylim(2)])
                cylim=get(gca,'YLim');
                y = [cylim(1) cylim(2) cylim(2) cylim(1)];
                x = [435 435 480 480];
                patch(x,y,'red','FaceAlpha',0.5)
                
                y = [cylim(1) cylim(2) cylim(2) cylim(1)];
                x = [300 300 345 345];
                patch(x,y,'red','FaceAlpha',0.5)

                title('em at ex = 254 (HIX)')
                box on
            end
            EmScan254 = smoothdata(EmScan254,21,'sgolay',2);
            Val1=sum(EmScan254(mindist(data.Em,435):mindist(data.Em,480)),'omitnan');
            Val2=sum(EmScan254(mindist(data.Em,300):mindist(data.Em,345)),'omitnan')+...
                sum(EmScan254(mindist(data.Em,435):mindist(data.Em,480)),'omitnan');
            HIX(i)=Val1/Val2;
            
        end
    catch
        HIX(i)=NaN;
    end
    
        if diagn
            disp(['Spectrum ',num2str(i),' of ',num2str(data.nSample),...
                '. Press any key to continue or Ctrl + C to cancel.'])
            pause
            subplot(1,3,1),cla,subplot(1,3,2),cla,subplot(1,3,3),cla,box on
        end
        try
            
        % BIX
        Val1=EmScan310(mindist(data.Em,380));
        Val2=EmScan310(mindist(data.Em,430));
        BIX(i)=Val1/Val2;
        catch
            BIX(i)=nan;
        end
end


%% Results
VarName=[peaks.name]';
VarName{end+1}='FluI';VarName{end+1}='FrI'; VarName{end+1}='BIX'; VarName{end+1}='HIX';

metadata=table;
metadata.C=[md.Ex(:,5) md.Em(:,5)];
metadata.M=[md.Ex(:,4) md.Em(:,4)];
if ~HIX_excl
    picklist=array2table([Cpeak FI' FrI' BIX' HIX'],...
        'VariableNames',VarName);
else
    picklist=array2table([Cpeak FI' FrI' BIX'],...
        'VariableNames',VarName(1:end-1));
end

if plt
    if data.toolboxdata.uifig
        f=drEEMtoolbox.dreemuifig;
    else
        f=drEEMtoolbox.dreemfig;
    end
    f.Name='drEEM: processabsorbance.m';

    set(f,'units','normalized','Name','pickPeaks: Extracted intensities of predefined fluorescence peaks','pos',[0.2594    0.2296    0.4448    0.5130])
    t=tiledlayout(f);
    ax=nexttile(t);
    hold(ax,'on')
    for n=1:numel(peaks)
        plot(ax,Cpeak(:,n),'LineWidth',1.5)
    end
    legend(ax,[peaks.name]','location','bestoutside');
    title(ax,'Fluorescence peaks')
    xlabel(ax,'# of sample in dataset')
    axis(ax,'tight')

    ax=nexttile(t);
    hold(ax,'on')
    plot(ax,FI,'LineWidth',1.5)
    plot(ax,FrI,'LineWidth',1.5)
    plot(ax,BIX,'LineWidth',1.5)
    if ~HIX_excl
        plot(ax,HIX,'LineWidth',1.5)
        legend(ax,'Fluorescence index','Freshness index' ,'Biological index','Humification index', ...
            'location','bestoutside')
    else
        legend(ax,'Fluorescence index','Freshness index','Biological index', ...
            'location','bestoutside')
    end
    title(ax,'Fluorescence indicies')
    xlabel(ax,'# of sample in dataset')
    hold(ax,'off')
    axis(ax,'tight')
end
[C,ia,ib]=intersect(dataout.opticalMetadata.Properties.VariableNames, ...
    picklist.Properties.VariableNames);
dataout.opticalMetadata(:,ia)=[];
dataout.opticalMetadata=[dataout.opticalMetadata,picklist];

idx=height(dataout.history)+1;
dataout.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,'Bulk fluorescence peaks extracted.',options,dataout);

dataout.validate(dataout);


% Will only run if toolbox is set to overwrite workspace variable and user
% didn't provide an output argument
if drEEMtoolbox.outputscenario(nargout)=="implicitOut"
    assignin("base",inputname(1),dataout);
    disp(['<strong> "',char(inputname(1)), '" processed. </strong> Since no output argument was provided, the workspace variable was overwritten.'])
    return
end

end


function [idx,distance] = mindist( vec,value)
[distance,idx]=min(abs(vec-value));
end

function X = naninterp(X,method)
% Interpolate over NaNs
X(isnan(X)) = interp1(find(~isnan(X)), X(~isnan(X)), find(isnan(X)),method);
end