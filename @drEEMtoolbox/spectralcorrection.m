function [dataout] = spectralcorrection(data,options)

arguments (Input)
    data (1,1) {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data),...
        drEEMdataset.sanityCheckSpectralCorrection(data)}
    options.XCor (:,2) {mustBeNumeric}
    options.MCor (:,2) {mustBeNumeric}
    options.plot (1,1) {mustBeNumericOrLogical} = data.toolboxOptions.plotByDefault;
end
arguments (Output)
    dataout (1,1) {mustBeA(dataout,"drEEMdataset"),drEEMdataset.validate(dataout)}
end

% Experimental feature; overwrite workspace variable, needs no outputarg check
if drEEMtoolbox.outputscenario(nargout)=="explicitOut"
    nargoutchk(1,1)
end
% assign output variable
dataout=data;

if options.MCor(1,1)>dataout.Em(1)||options.MCor(end,1)<dataout.Em(end)
    delEm=options.MCor(1,1)>dataout.Em|options.MCor(end,1)<dataout.Em;
else
    delEm=false(dataout.nEm,1);
end
if options.XCor(1,1)>dataout.Ex(1)||options.XCor(end,1)<dataout.Ex(end)
    delEx=options.XCor(1,1)>dataout.Ex|options.XCor(end,1)<dataout.Ex;
else
    delEx=false(dataout.nEx,1);
end
if any(delEx)||any(delEm)
    warning('<strong>Dataset trimmed. </strong>Spectral correction factors did not cover the entire EEM.')
    dataout=drEEMtoolbox.subdataset(dataout,outEm=delEm,outEx=delEx);
end

emcor_i=interp1(options.MCor(:,1),options.MCor(:,2),dataout.Em);
excor_i=interp1(options.XCor(:,1),options.XCor(:,2),dataout.Ex);


corfac(1,:,:)=excor_i'.*emcor_i;

sanityCheckCorrectionMatrix(squeeze(corfac))

dataout.X=dataout.X.*corfac;
dataout.status=drEEMstatus.change(dataout.status,'spectralCorrection','applied by toolbox');

% drEEMhistory entry
idx=height(dataout.history)+1;
dataout.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,'Spectral correction performed',options,dataout);

if options.plot
    % final plots
    if dataout.toolboxOptions.uifig
        f=drEEMtoolbox.dreemuifig;
    else
        f=drEEMtoolbox.dreemfig;
    end
    f.Name='drEEM toolbox: Spectral correction overview';
    movegui(f,'center')
    t=tiledlayout(f,"flow");
    ax=nexttile(t);
    plot(ax,dataout.Ex,excor_i,DisplayName='Excitation')
    hold(ax,'on')
    plot(ax,dataout.Em,emcor_i,DisplayName='Emission')
    legend(ax)
    ax=nexttile(t);
    mesh(ax,dataout.Ex,dataout.Em,squeeze(corfac))

end
end

function sanityCheckCorrectionMatrix(corfac)

l_corfac=isnan(corfac);

if any(l_corfac(:))
    warning(['<strong>Spectral correction matrix contains NaN (missing numbers).</strong>./n' ...
        'The correction will effectively whole parts of the EEM. '])
end

end