function dataout = processabsorbance(data,options)
arguments
        % Required
        data ...
            (1,:) {mustBeNonempty,mustBeA(data,"drEEMdataset"),...
            drEEMdataset.validate(data),drEEMdataset.sanityCheckAbsorbance(data)}
        
        % Optional
        options.correctBase (1,:) {mustBeNumericOrLogical} = true
        options.baseWave (1,:) {mustBeNumeric} = 590
        options.zero (1,:) {mustBeNumericOrLogical} = false
        options.extrapolate (1,:) {mustBeNumericOrLogical} = true
end

% Check if the function has already been run
idx=drEEMhistory.searchhistory(data.history,'processabsorbance','first');
if not(isempty(idx))
    warning(['"processabsorbance has already been run before.' ...
        ' It is recommended to chose appropriate settings and only' ...
        ' run this function once."'])
    optionsbefore=data.history(idx).details;
    
    if isequal(options,optionsbefore)
        error('Identical options to a previous execution detected. Exiting...')
    end
   
end

% Experimental feature; overwrite workspace variable, needs no outputarg check
if drEEMtoolbox.outputscenario(nargout)=="explicitOut"
    nargoutchk(1,1)
end

% Assign the output variable
dataout=data;

% The function creates a result figure. The dataset setting determines if
% it's a uifigure (somewhat cleaner & simple) or figure (much faster)
if data.toolboxdata.uifig
    f=dreemuifig;
else
    f=drEEMtoolbox.dreemfig;
end
f.Name='drEEM: processabsorbance.m';

% Show the original data
t=tiledlayout(f,"flow");
ax=nexttile(t);
plot(ax,data.absWave,data.abs,Color=[0 0 0 0.5])
yline(ax,0,LineStyle="-",Color='b')
xlabel(ax,'Wavelength (nm)')
ylabel(ax,'Absorbance')
title(ax,'Absorbance prior to any correction')
%% Baseline correction (if possible and wanted)
% It's only allowed if there's plenty of long-wl information though
if max(dataout.absWave)>580
    blcor=true;
else
    blcor=false;
end

% Baseline possible, wanted, and no extrapolation necessary
if blcor&&options.correctBase&&not(options.extrapolate)
    i=dataout.absWave>options.baseWave;
    bl=mean(dataout.abs(:,i),2,'omitnan');
    dataout.abs=dataout.abs-bl;
end

%% Stitch-on (if needed)
if max([dataout.Ex;dataout.Em])>max(dataout.absWave)
    disp(['Absorbance and fluoresence cover different wavelength areas. The EEM will be cut during the IFE correction unless ' ...
        'absorbance is extrapolated. This should only be done if CDOM absorbance was measured, as extrapolation is possible ' ...
        'due to the featureless properties of CDOM absorbance at high wavelengths.'])
    % The extrapolation bit
    if options.extrapolate
        abswave=dataout.absWave(mindist(dataout.absWave,300):end);
        absspec=dataout.abs(:,mindist(dataout.absWave,300):end)';

        % This bit sets options for a non-linear exponential CDOM spectra
        % fit and carries it out ( (c) Stedmon 2001)
        opts=statset;
        opts.MaxIter=2500;
        % Anonymous function to fit data to the model afteer parameters
        % were found
        afit=@(b1,b2,b3,lambda) b1*exp(b2/1000*(350-lambda))+b3;
        ewstep=round(mean(diff(dataout.absWave)));
        extrawave=(dataout.absWave(end)+ewstep:ewstep:ceil(max([dataout.Ex;dataout.Em])))';
        new=zeros(data.nSample,numel([abswave;extrawave]));
        beta=nan(data.nSample,3);
        % Carry out the non-linear fit to find the CDOM exponential slope
        % parameters
        warning off
        for n=1:size(absspec,2)
            try
                beta(n,:) = nlinfit(abswave,absspec(:,n),@CDOMexp_K,[mean(absspec(:,n)); 18; 0],opts);
                new(n,:)=afit(beta(n,1),beta(n,2),beta(n,3),[abswave;extrawave]);
            catch
                new(n,:)=0;
            end
        end
        warning on
        % if a350 is too small, set it to zero
        new(beta(:,2)<1,:)=0;
        new=new(:,size(abswave,1)+1:end);

        % find and eliminate offset between measured and modelled data
        off=data.abs(:,end)-new(:,1);
        new=new+off;
        
        % show results
        ax=nexttile(t);
        plot(ax,data.absWave,data.abs,Color=[0 0 0 0.5])
        hold(ax,'on')
        plot(ax,extrawave,new,Color=[1 0 0 0.5])
        xlabel(ax,'Wavelength (nm)')
        ylabel(ax,'Absorbance')
        title(ax,'Given (black) and extrapl. data (red)')
        yline(ax,0,LineStyle="-",Color='b')
        
        % Assign the extrapolated data to the output
        dataout.abs=horzcat(dataout.abs,new);
        dataout.absWave=vertcat(dataout.absWave,extrawave);
        
        % Now let's try the baseline correction again. Same code as above
        if max(dataout.absWave)>580
            blcor=true;
        else
            blcor=false;
        end
        
        if blcor&&options.correctBase
            i=dataout.absWave>options.baseWave;
            bl=mean(dataout.abs(:,i),2,'omitnan');
            dataout.abs=dataout.abs-bl;
        end
        

    end
end



%% <0 = 0 correction (if needed and wanted)
if any(dataout.abs(:)<0)&&options.zero
    dataout.abs(dataout.abs<0)=0;
end
% Show the final output
ax=nexttile(t);
plot(ax,dataout.absWave,dataout.abs,Color=[0 0 0 0.5])
xlabel(ax,'Wavelength (nm)')
ylabel(ax,'Absorbance')
title(ax,'Final output')
yline(ax,0,LineStyle="-",Color='b')


%% drEEMhistory entry
message=[...
    'baseWave = ',num2str(options.baseWave),...
    ', correctBase = ', char(string(options.correctBase)),...
    ', extrapolate = ',char(string(options.extrapolate)),...
    ', extrapolate = ',char(string(options.zero))];
idx=height(dataout.history)+1;
dataout.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,message,options,dataout);

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

function [idx,distance] = mindist( vec,value)
[distance,idx]=min(abs(vec-value));
end
