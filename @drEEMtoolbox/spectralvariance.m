function [cdom,fdom] = spectralvariance(data)
%
% <strong>Syntax</strong>
%   [cdom,fdom] = <strong>spectralvariance</strong>(data)
%
% <a href="matlab: doc spectralvariance">help for spectralvariance</a> <- click on the link



% Plot the spectral variability of CDOM and FDOM to explore raw data
% The function scales all data to unit variance in the sample mode to give
% each sample equal weighting.
%
% [cdom,fdom] = spectralvariance(data)
%
%INPUT VARIABLES: 
% data:        One data structures to be plotted.
%
%EXAMPLES
% 1.   [cdom,fdom] = spectralvariance(data)
%
% Notice:
% This mfile is part of the drEEM toolbox. Please cite the toolbox
% as follows:
%
% Murphy K.R., Stedmon C.A., Graeber D. and R. Bro, Fluorescence
%     spectroscopy and multi-way techniques. PARAFAC, Anal. Methods, 2013, 
%     DOI:10.1039/c3ay41160e. 
%
% spectralvariance: Copyright (C) 2019 Urban J. Wuensch
% Chalmers University of Technology
% Sven Hultins Gata 6
% 41296 Gothenburg
% Sweden
% $ Version 0.1.0 $ March 2019 $ First Release

%%


if isfield(data,'X')&&isfield(data,'Abs')
    pltcase=1;
elseif isfield(data,'X')&&~isfield(data,'Abs')
    pltcase=2;
elseif isfield(data,'Abs')&&~isfield(data,'X')
    pltcase=3;
else
    pltcase=10;
end

if pltcase==10
   error('Refer to function help. Could not find necessary fields in the dataset.')
end



if pltcase==1||pltcase==2
    [X,~,fscales]=nprocess(data.X,[0 0 0],[1 0 0],[],[],1,-1);
    fdom=squeeze(std(X,'omitnan'));
    mfdom=squeeze(mean(X,'omitnan'));
end
if pltcase==1||pltcase==3
    [Y,~,~]=nprocess(data.Abs,[0 0],[1 0],[],[],1,-1);
    cdom=std(Y,'omitnan');
end
fscales{1}(isinf(fscales{1}))=nan;
if any(fscales{1}>5*median(fscales{1}))
    warning('Some samples have very little signal (e.g. blanks) and thus likely negatively impact the the spectralvariance plots')
    disp(['Consider removing the sample(s):  ',num2str(find(fscales{1}>5*median(fscales{1},2)))])
    disp('If no blanks (or similar) samples are present, the issue may be samples with high fluorescence values instead.')
end

%% Figure setup
hf=dreemfig; 
set(hf,'unit','normalized');
pos=get(hf,'Position');
set(hf,'Position',[pos(1:2) 0.5 0.3]);
movegui('center');
pos=[0.13,0.44,0.28,0.48;0.45,0.44,0.12,0.48;0.62,0.44,0.28,0.48;0.62,0.13,0.28,0.17];
ax = gobjects(size(pos,1),1);
for n=1:size(pos,1)
    ax(n)=axes('pos',pos(n,:));
end
ax([3 2])=ax(2:3);


% CDOM absorbance
for n=1:numel(ax)
    hold(ax(n),'on')
end
if pltcase==1||pltcase==3
    yyaxis(ax(1),'left'),set(ax(1),'YColor',[1 .2 .2 0.5])
    ylabel(ax(1),'Unit scaled absorbance')
    h1=plot(ax(1),data.Abs_wave,Y,'Color',[1 .2 .2 0.5],'LineWidth',1,'LineStyle','-','Marker','none');%./sum(Y,2)
    yyaxis(ax(1),'right'),set(ax(1),'YColor',[0 0 0 0.8])
    h2=plot(ax(1),data.Abs_wave,cdom,'Color',[0 0 0 0.8],'LineWidth',2,'LineStyle','-','Marker','none');
    legend(ax(1),[h1(1), h2],{'All spectra (unit scaled)','Standard deviation'})
end
axis(ax(1),'tight')
xlabel(ax(1),'Absorbance wavelength (nm)')
ylabel(ax(1),'Std. dev. absorbance')
title(ax(1),'CDOM absorbance')

% FDOM EEMs
if pltcase==1||pltcase==2
    pltdata=squeeze(fdom);%./squeeze(mfdom);
    pltdata(pltdata==0)=nan;
    contourf(ax(2),data.Ex,data.Em,pltdata,100,'LineStyle','none')
    contour(ax(2),data.Ex,data.Em,pltdata,15,'Color','k')
end
c=colorbar(ax(2));
ylabel(c,'Std. dev. fluorescence')
title(ax(2),'FDOM fluorescence')
set(ax(2),'units','pixel')
set(ax(2),'YTickLabel','','XTickLabel','')
refylim=get(ax(2),'YLim');
refxlim=get(ax(2),'XLim');

if pltcase==1||pltcase==2
    pltvec=squeeze(sum(X,3,'omitnan'));
    normvec=(mean(max(squeeze(nansum(X,3))))*2);
    pltvec=pltvec./normvec;
    pltvec(pltvec==0)=nan;
    
    plot(ax(3),pltvec,data.Em,'Color',[1 .2 .2 0.5],'LineWidth',1)
    hold(ax(3),'on')
    plot(ax(3),nansum(fdom,2)./max(nansum(fdom,2)),data.Em,'Color','k','LineWidth',2)
end
set(ax(3),'XDir','reverse')
set(ax(3),'units','pixel')
refpos=get(ax(2),'pos');
pos1=get(ax(3),'pos');
ylim(ax(3),refylim)
set(ax(3),'XTickLabel','')

offs=refpos(1)-(pos1(1)+pos1(3));
set(ax(3),'pos',[pos1(1)+offs refpos(2) pos1(3) refpos(4)])
ylabel(ax(3),'Emission (nm)')

% ax4=subplot(4,5,[19 20]);
if pltcase==1||pltcase==2
    pltvec=squeeze(nansum(X,2))./(mean(max(squeeze(nansum(X,2))))*2);
    pltvec(pltvec==0)=nan;
    
    plot(ax(4),data.Ex,pltvec,'Color',[1 .2 .2 0.5],'LineWidth',1)
    hold(ax(4),'on')
    plot(ax(4),data.Ex,nansum(fdom)./max(nansum(fdom)),'Color','k','LineWidth',2)
end
set(ax(4),'units','pixel')
xlim(ax(4),refxlim)
set(ax(4),'YTickLabel','')
refpos=get(ax(2),'pos');
pos2=get(ax(4),'pos');
offs=refpos(2)-(pos2(2)+pos2(4));
set(ax(4),'pos',[refpos(1) pos2(2)+offs refpos(3) pos2(4)])
xlabel(ax(4),'Excitation (nm)')

pos2=get(ax(4),'pos');
height2=pos2(4);
pos1=get(ax(3),'pos');
height1=pos1(3);
diff=height1-height2;
set(ax(3),'pos',[pos1(1)+diff pos1(2) pos1(3)-diff pos1(4)])

for n=1:4
    set(ax(n),'units','normalized')
    box(ax,'on')
end

linkaxes([ax(2),ax(3)],'y')
linkaxes([ax(2),ax(4)],'x')

dreemfig(hf);