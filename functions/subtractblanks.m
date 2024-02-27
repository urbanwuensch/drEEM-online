function [dataout] = subtractblanks(samples,blanks)

arguments
    samples (1,1) {mustBeNonempty,drEEMdataset.validate(samples),...
        drEEMdataset.sanityCheckBlankSubtraction(samples)}
    blanks (1,1) {mustBeNonempty,drEEMdataset.validate(blanks),...
        drEEMdataset.sanityCheckBlankSubtraction(blanks)}
end

% First off: Let's make sure the blank and sample datasets cover the same
% wavelengths. Differences can come easily duing the IFEcorrection method
% when some parts are deleted due to lacking CDOM coverage. This bit makes
% sure that the blank will also be cut to be compatible.

% Excitation comparisons
C=intersect(samples.Ex,blanks.Ex,"stable");
s_ex=setdiff(samples.Ex,C);
b_ex=setdiff(blanks.Ex,C);

% Emission comparisons
C=intersect(samples.Em,blanks.Em,"stable");
s_em=setdiff(samples.Em,C);
b_em=setdiff(blanks.Em,C);

% subdataset call (will not do anything if wavelengths were identical)
samples_mod=subdataset(samples,[],ismember(samples.Em,s_em),ismember(samples.Ex,s_ex));
blanks_mod=subdataset(blanks,[],ismember(blanks.Em,b_em),ismember(blanks.Ex,b_ex));

% Carry out the subtraction, but only if final dimension check was passed.
if all(size(samples_mod.X)==size(blanks_mod.X))
    dataout=samples_mod;
    dataout.status=...
        drEEMstatus.change(dataout.status,"blankSubtraction","applied by toolbox");

    dataout.X=samples_mod.X-blanks_mod.X;

    % drEEMhistory entry
    idx=height(dataout.history)+1;
    dataout.history(idx,1)=...
        drEEMhistory.addEntry(mfilename,'Blanks successfully subtracted',[],dataout);
    dataout.validate(dataout);

else
    error('subtractblanks: Dimension missmatch. Cannot perform blank subtraction.')
end

% Finally let's make some plots to allow the user to see if blanks were
% clean and how well the subtraction worked for the elimitation of scatter.
mindist=@(vec,val) find(ismember(abs(vec-val),min(abs(vec-val))));
if samples.toolboxdata.uifig
    f=dreemuifig;
else
    f=dreemfig;
end
f.Name='drEEM: subtractblanks.m';
t=tiledlayout(f,"flow");

sam = inputname(1); % Show base workspace variable names in the plots
bla = inputname(2); % Show base workspace variable names in the plots
% Excitation 275 (for protein + humic fl).
ex=samples.Ex(mindist(samples.Ex,275));
ram1=1*10^7*((1*10^7)/(ex)-3382)^-1; % predicted raman 1st order
ram2=(1*10^7*((1*10^7)/(ex)-3382)^-1)*2;  % predicted raman 2nd order
ray1=ex;  % predicted rayleigh 1st order
ray2=ex*2;  % predicted rayleigh 2nd order

% Plot everything
ax=nexttile(t);
plot(ax,samples.Em,squeeze(samples.X(:,:,mindist(samples.Ex,275))))
xline(ax,ray1,'Color','r')
xline(ax,ray2,'Color','r')
xline(ax,ram1,'Color','b')
xline(ax,ram2,'Color','b')

title(ax,{sam})
xlabel(ax,'Emission (nm)')
ylabel(ax,'Fluorescence intensity')


ax=nexttile(t);
plot(ax,blanks.Em,squeeze(blanks.X(:,:,mindist(blanks.Ex,275))))
xline(ax,ray1,'Color','r')
xline(ax,ray2,'Color','r')
xline(ax,ram1,'Color','b')
xline(ax,ram2,'Color','b')

title(ax,{bla})
xlabel(ax,'Emission (nm)')
ylabel(ax,'Fluorescence intensity')

ax=nexttile(t);
plot(ax,dataout.Em,squeeze(dataout.X(:,:,mindist(dataout.Ex,275))))
xline(ax,ray1,'Color','r')
xline(ax,ray2,'Color','r')
xline(ax,ram1,'Color','b')
xline(ax,ram2,'Color','b')
title(ax,{[sam,' - ',bla]})
xlabel(ax,'Emission (nm)')
ylabel(ax,'Fluorescence intensity')
title(t,'Emission spectra closest to Ex = 275 nm')
end