function dataout = upgradedataset(data,atypicalFieldnames)
% <a href = "matlab:doc subdataset">dataout=subdataset(data,options) (click to access documentation)</a>
%
% <strong>Inputs - Required</strong>
% data (1,1) {mustBeA(data,'struct')}
%
% <strong>Inputs - Optional</strong>
% atypicalFieldnames (:,2) cell = {}

arguments
    data (1,1) {mustBeA(data,'struct')}
    atypicalFieldnames (:,2) cell = {}
end

dataout=drEEMdataset.create;


flds=[{'X','Ex','Em','nEm','nEx','filelist','i','nSample','Abs_wave','Abs'},atypicalFieldnames(:,1)'];
newflds=[{'X','Ex','Em','nEm','nEx','filelist','i','nSample','absWave','abs'},atypicalFieldnames(:,2)'];

for j=1:numel(flds)
    if not(isfield(data,flds{j}))
        warning(['field "',flds{j},'" does not exist in old dataset' ...
            ' Consider using input "atypicalFieldnames" or modifying the' ...
            ' structure before executing this function (e.g. create' ...
            ' the variable / field beforehand).'])
    else
        try
            dataout.(newflds{j})=data.(flds{j});
        catch
            warning(['field "',flds{j},'" could not be transferred.'])
        end
    end
end

dataout.metadata.i=dataout.i;
dataout.validate(dataout);

ssz=dataout.nSample;
flds=fieldnames(data);

for j=1:numel(flds)
    if ssz==size(data.(flds{j}),1)&&size(data.(flds{j}),2)==1
        dataout.metadata.(flds{j})=data.(flds{j});
    end
end

dataout.metadata = metadataconverter(dataout.metadata);

for j=1:100
    if isfield(data,['Model',num2str(j)])
        loads=data.(['Model',num2str(j)]);
        pass=true;
        for k=1:3
            if not(size(dataout.X,k)==size(loads{k},1))
                pass=false;
                warning([num2str(j),'-component model had an inconsistent size. Not transferred.'])
            end
        end
        if not(pass)
            continue
        end
        dataout.models(j,1)=drEEMmodel;
        dataout.models(j,1).loads=loads;
        for n=1:numel(loads)
            lev=diag(loads{n}*(loads{n}'*loads{n})^-1*loads{n}');
            dataout.models(j,1).leverages(1,n)={lev};
        end

        E=dataout.X-nmodel(loads);
        E_ex = squeeze(sum(sum(E.^2,1,'omitnan'),2,'omitnan'));
        E_em = squeeze(sum(sum(E.^2,1,'omitnan'),3,'omitnan'))';
        E_sample = squeeze(sum(sum(E.^2,2,'omitnan'),3,'omitnan'));
        dataout.models(j,1).sse={E_sample E_em E_ex};
        dataout.models(j,1).status='transferred from old dataset. status unknown';

        e=sum(E(:).^2,"omitmissing");

        dataout.models(j,1).percentExplained=...
            100 * (1 - e / sum(dataout.X(:).^2,'omitnan') );
        dataout.models(j,1).core=corcond(dataout.X,loads,[],0);
        dataout.models(j,1).percentUnconverged=NaN;

        sizeF=nan(1,size(loads{1},2));
        for l=1:size(loads{1},2)
            modelledH=nmodel([{loads{1}(:,l)} {loads{2}(:,l)} {loads{3}(:,l)}]);
            sizeF(l)=100 * (1 - (sum((dataout.X(:) - modelledH(:)).^2,'omitnan')) / sum(dataout.X(:).^2,'omitnan'));
        end
        dataout.models(j,1).componentContribution=sizeF;
        dataout.models(j,1).initialization='random'; %assumed
        dataout.models(j,1).starts=NaN;
        if isfield(data,['Model',num2str(j),'convgcrit'])
            dataout.models(j,1).convergence=data.(['Model',num2str(j),'convgcrit']);
        else
            dataout.models(j,1).convergence=NaN;
        end
        if isfield(data,['Model',num2str(j),'constraints'])
            dataout.models(j,1).constraints=data.(['Model',num2str(j),'constraints']);
        else
            dataout.models(j,1).constraints='unknown';
        end
        dataout.models(j,1).toolbox='nway'; %assumed.

    end
end
dataout.validate(dataout);


%%%%% IMPLEMENT SPLITS!!!!
% User needs to tell the toolbox what the status of the dataset is.
handle=setstatus(dataout,'data');
waitfor(handle,"finishedHere",true);
try
    dataout=handle.data;
    delete(handle)
catch
    error('setstatus closed before save & exit button was pushed.')
end

idx=1;
dataout.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,'dataset conversion from older drEEM version',[],dataout);

dataout.validate(dataout);

end



function mdnew = metadataconverter(metadata)
    mdnew=table;
    for j=1:numel(metadata.Properties.VariableNames)
        here=metadata.Properties.VariableNames{j};
        md=metadata.(here);
        try
            if numel(unique(md))==1
                continue
            end
        catch
            % different data types (nogo)
            continue
        end
        type=class(md);
        switch type
            case 'cell'
                alltype=cellfun(@(x) class(x),md,'UniformOutput',false);
                celltypes=unique(alltype);
                if numel(celltypes)>1
                    warning(['Variable "',here,'" consists of different datatypes and will not be included for plotting'])
                    continue
                else
                    celltypes=celltypes{1};
                end
                switch celltypes
                    case 'char'
                        mdconv=categorical(md);
                    case 'datetime'
                        mdconv=categorical(md);
                    case 'duration'
                        mdconv=double(md);
                    case 'categorical'
                        mdconv=md;
                    case 'numeric'
                        mdconv=md;
                    otherwise
                        error('Metadata type: cell, subtype not accounted for.')

                end
            case 'numeric'
                mdconv=md;
            case 'datetime'
                mdconv=categorical(md);
            case 'duration'
                mdconv=double(md);
            case 'double'
                    mdconv=md;
            case 'categorical'
                mdconv=md;
            otherwise
                error('Metadata type not accounted for.')
        end
        mdnew.(here)=mdconv;
    end
end