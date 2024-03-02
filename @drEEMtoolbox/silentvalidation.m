function passed = silentvalidation(data,fac)

arguments
    data (1,1) {mustBeNonempty,drEEMdataset.validate(data)}
    fac (1,1) {mustBeNumeric}
end
drEEMdataset.mustBeModel(data,fac)
%% Input argument parsing and initial checks
overallModel=data;
nSplit=numel(data.split);
splitComparisons=nchoosek(1:nSplit,2);
nComparisons=size(splitComparisons,1);
splitNames=cellstr(strcat(repmat("Split ",nSplit,1),int2str((1:nSplit)')));
ignoreerror=false;
mode='tcc';
%% Define some functions and central variables
vec=@(x) x(:); % Function to unfold data
minimumtcc = 0.95; % Criterion for spectral match
minimumssc = 0.95;
passed=true;
message=[];

%% Reorganize models and names into cells

for k=1:nSplit
    cellOfModels{k}=data.split(k);
    cellOfNames{k}=splitNames{k};
end

if isempty(overallModel) % If no overall Model was provided.
    checkedoverall=false;
    for k=1:nSplit
        cellOfModels{k}=data.split(k);
        cellOfNames{k}=splitNames{k};
    end
    comparisons=splitComparisons;
else % If overall Model was provided, it is added as the last cell.
    checkedoverall=true;
    for k=1:nSplit
        cellOfModels{k}=data.split(k);
        cellOfNames{k}=splitNames{k};
    end
    cellOfModels{k+1}=overallModel;
    cellOfNames{k+1}='Overall';
    comparisons=[splitComparisons;[repmat(k+1,nSplit,1) (1:nSplit)']];
end
nComparisons=size(comparisons,1);

% Check if models are all there.
[pass,errmessage]=modelpresence(cellOfModels,cellOfNames,fac);
if ~pass
    error(sprintf([ '\n  <strong>Could not</strong> perform a splitvalidation because: \n' errmessage])) %#ok<*SPERR>
end
%% Step 1: calculate similarities
similarities=calculatesimilarities(cellOfModels,comparisons,fac,mode);

%% Step 2: Check conditions for validity

for k=1:nComparisons
    simiExtract=squeeze(similarities(k,:,:,:)); % Just so it's easier for developing
    % simiExtract: [m1,m2,em ex]
    matchingExEm(:,:,1)=simiExtract(:,:,1)>minimumssc;
    matchingExEm(:,:,2)=simiExtract(:,:,2)>minimumtcc;
    matchingEx{k}=squeeze(matchingExEm(:,:,2));
    matchingEm{k}=squeeze(matchingExEm(:,:,1));
    matchingExAndEm{k}=matchingEx{k}&matchingEm{k}; % Check that both Ex AND Em are similar enough
    
    %C1: Tells us if the model is valid, C2 and C3 will inform the user why a model is not validated.
    %1: Are there as many (or more) Ex&Em matches as components?
    condition1(k)=sum(vec(matchingExAndEm{k}))>=fac;
    %2: Are there as many (or more) Ex matches as components?
    condition2(k)=sum(vec(matchingEx{k}))>=fac;
    %3: Are there as many (or more) Em matches as components?
    condition3(k)=sum(vec(matchingEm{k}))>=fac;
end
%% Step 3: Diagnosis (determine if passed & prepare error messages for user)

if ~all(condition1)
    passed=false;
end
end

function [pass,message]=modelpresence(models,mname,fac)
pass=true;
message=[];
nExnEm=[];
for k=1:numel(models)
    try
        m=models{k}.models(fac).loads;
        nExnEm(k,:)=[size(m{3},1) size(m{2},1)];
        if isempty(m)
            pass=false;
            message=[message '''',mname{k},''' does not contain a model with ',num2str(fac),' components \n'];
        end
    catch
        pass=false;
        message=[message '''',mname{k},''' does not contain a model with ',num2str(fac),' components \n'];
    end
end
if ~isempty(nExnEm)
    if numel(unique(nExnEm))>2
       pass=false;
       message=[message '  Some of the datasets (specifically the models you want to compare) differ in their dataset dimensions (Emission or Excitation).'...
           ' That is not allowed, similarities cannot be calculated for that case. \n'];
    end
end
end

function [simi] = calculatesimilarities(cellofmodels,comparisons,fac,mode)
tcc=@(l1,l2) l1'*l2/(sqrt(l1'*l1)*sqrt(l2'*l2)); % Tucker's congruence coefficient
nComparisons=size(comparisons,1);
for k=1:nComparisons
    m1=cellofmodels{comparisons(k,1)};
    m2=cellofmodels{comparisons(k,2)};
    for l=1:fac
        for o=1:fac
            switch mode
                case 'ssc'
                    simi(k,l,o,:)=[ssc(m1.models(fac).loads{2}(:,l),m2.models(fac).loads{2}(:,o)) ...
                        tcc(m1.models(fac).loads{3}(:,l),m2.models(fac).loads{3}(:,o))];
                case 'tcc'
                    simi(k,l,o,:)=[tcc(m1.models(fac).loads{2}(:,l),m2.models(fac).loads{2}(:,o)) ...
                        tcc(m1.models(fac).loads{3}(:,l),m2.models(fac).loads{3}(:,o))];
                otherwise
                    error('Mode must be either ''ssc'' (default) or ''tcc'' (previous default).')
            end
        end
    end
end
end

function [tcc2,shift_penalty,shape_penalty] = ssc(load1,load2)

load1=load1./norm(load1,1);
load2=load2./norm(load2,1);

load1i=load1./norm(load1,Inf);
load2i=load2./norm(load2,Inf);


[~,ml1i]=max(load1i);
[~,ml2i]=max(load2i);
ml1=trapz(load1i);
ml2=trapz(load2i);
shape_penalty=abs(ml2-ml1)./size(load1,1);
shift_penalty=abs(ml2i-ml1i)./size(load1,1);

tcc=load1'*load2/(sqrt(load1'*load1)*sqrt(load2'*load2));
tcc2=tcc-(shape_penalty+shift_penalty);
end

function [compidx,besttcc] = sortcomponents(ref,models,fac)
tcc=@(l1,l2) l1'*l2/(sqrt(l1'*l1)*sqrt(l2'*l2)); % Tucker's congruence coefficients
compidx=zeros(numel(models),fac);
for k=1:numel(models)
    for l=1:fac
        for o=1:fac
            simi(k,l,o,:)=[tcc(ref.models(fac).loads{2}(:,l),models{k}.models(fac).loads{2}(:,o)) ...
                tcc(ref.models(fac).loads{3}(:,l),models{k}.models(fac).loads{3}(:,o))];
        end
    end
    
    
    simiExtract=squeeze(simi(k,:,:,:)); % Extract, just so it's easier to work with
    % simiExtract: [m1,m2,em ex]
    matchingExEm=simiExtract>0.95; % Express it in logical array
    matchingEx=squeeze(matchingExEm(:,:,2));
    matchingEm=squeeze(matchingExEm(:,:,1));
    matchingExAndEm=matchingEx&matchingEm; % Check that both Ex AND Em are similar enough
    
    for l=1:fac
        ci=[];
        besttcc(k,l)=max(sum(simiExtract(l,:,:),3))/2;
        if numel(find(matchingExAndEm(l,:)))==1 % Uniequivolval match
            ci=find(matchingExAndEm(l,:));
        elseif numel(find(matchingExAndEm(l,:)))>1 % Take the best when multiple are similar
            [~,ci]=max(sum(simiExtract(l,:,:),3)); 
        elseif numel(find(matchingExAndEm(l,:)))==0 % Take the best when none match
            [val,ci]=max(sum(simiExtract(l,:,:),3));
            if val<1
                ci=[];
            end
        end
        if ~isempty(ci)
            compidx(k,l)=ci;
        end
    end
    
    
end


% Fix the missing entries in compidx
if all(sum(compidx==0,2)<=1) % When only one is missing, it's obvious
    for k=1:numel(models)
        if any(compidx(k,:)==0)
            compidx(k,compidx(k,:)==0)=setdiff(1:fac,compidx(k,:));
        end
    end
else % This should not be the case unless the comparisons are terrible
    % Order the components by their emission maxima.
    % This is not perfect, especially when the models are bad.
    for k=1:numel(models)
        compidx(k,:)=orderbyemissionmax(models{k},fac);
    end
end


end
function seq = orderbyemissionmax( model,f )
% Order PARAFAC model components by their emission maxima
[~,idx]=max(model.(['Model' num2str(f)]){2});
[~,seq]=sort(idx);
end