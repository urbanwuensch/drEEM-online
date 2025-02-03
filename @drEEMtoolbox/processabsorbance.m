function dataout = processabsorbance(data,options)
% <a href = "matlab:doc processabsorbance">dataout = processabsorbance(data,options) (click to access documentation)</a>
%
% <strong>Inputs - Required</strong>
% data (1,:) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data),drEEMdataset.sanityCheckAbsorbance(data)}%
%
% <strong>Inputs - Optional</strong>
% correctBase (1,:)     {mustBeNumericOrLogical} = true
% baseWave (1,:)        {mustBeNumeric,mustBeGreaterThan(options.baseWave,580)} = 595
% zero (1,:)            {mustBeNumericOrLogical} = false
% extrapolate (1,:)     {mustBeNumericOrLogical} = true


arguments
    % Required
    data (1,:) {mustBeNonempty,mustBeA(data,"drEEMdataset"),...
        drEEMdataset.validate(data),drEEMdataset.sanityCheckAbsorbance(data)}

    % Optional
    options.correctBase (1,:)   {mustBeNumericOrLogical} = true
    options.baseWave (1,:)      {mustBeNumeric,mustBeGreaterThan(options.baseWave,580)} = 595
    options.zero (1,:)          {mustBeNumericOrLogical} = false
    options.extrapolate (1,:)   {mustBeNumericOrLogical} = true
end
mv=ver;
stool=any(contains({mv(:).Name},'Statistics and Machine Learning'));
if options.extrapolate&&not(stool)
    options.extrapolate=false;
    warning('Statistics and Machine Learning Toolbox not installed. CDOM spectra extrapolation disabled.')
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
    f=drEEMtoolbox.dreemuifig;
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
if max(dataout.absWave)>=580
    blcor_allowed=true;
else
    warning('CDOM coverage does not allow baseline correction (needs to be > 580 nm). Option disabled.')
    blcor_allowed=false;
end

% Baseline possible, wanted, and no extrapolation necessary
% Otherwise, the baseline subtraction is done later.
if blcor_allowed&&options.correctBase&&not(options.extrapolate)
    i=dataout.absWave>=options.baseWave;
    if not(any(i))
        warning('Please double-check the baseline correction wavelength. Could not perform the baseline correction.')
    else
        bl=mean(dataout.abs(:,i),2,'omitmissing');
        dataout.abs=dataout.abs-bl;
    end
end

%% Stitch-on (if needed)
if max([dataout.Ex;dataout.Em])>max(dataout.absWave)
    disp('EEMs were measured at wavelengths longer than CDOM spectra.')
    % The extrapolation bit
    if options.extrapolate
        disp('Extrapolation of CDOM spectra will avoid the automatic deletion of EEM data during IFE correction.')
        abswave=dataout.absWave(drEEMtoolbox.mindist(dataout.absWave,300):end);
        absspec=dataout.abs(:,drEEMtoolbox.mindist(dataout.absWave,300):end)';

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
            blcor_allowed=true;
        else
            blcor_allowed=false;
        end
        
        if blcor_allowed&&options.correctBase
            i=dataout.absWave>options.baseWave;
            bl=mean(dataout.abs(:,i),2,'omitnan');
            dataout.abs=dataout.abs-bl;
        end
        
    else
        disp('The EEMs will be cut automatically when IFE corrections are carried out.')
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
