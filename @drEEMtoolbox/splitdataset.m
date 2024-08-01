function dataout = splitdataset(data,options)

arguments
    data {drEEMdataset.validate(data)}
    options.bysort ...
        (1,:) {drEEMdataset.mustBeMetadataColumn(data,options.bysort)} = []
    options.numsplit ...
        (1,1) {mustBePositive} = 2
    options.stype ...
        (1,:) {mustBeMember(options.stype,["alternating","random","contiguous",...
        "exact"])} = "alternating"  
end

if matches(options.stype,"exact")&&isempty(options.bysort)
    error(['Illigal combination of options. When "stype" is set to "exact",',...
        ' "bysort" cannot be empty but needs to point at a column in data.metadata'])
end

if not(matches(options.stype,"exact"))&&not(isempty(options.bysort))
    error('Illigal combination of options. When "bysort" is provided, "stype" must be "exact"')
end

% Experimental feature; overwrite workspace variable, needs no outputarg check
if drEEMtoolbox.outputscenario(nargout)=="explicitOut"
    nargoutchk(1,1)
end

splitIdent=repmat((1:options.numsplit)',ceil(data.nSample./options.numsplit),1);
splitIdent=splitIdent(1:data.nSample);
switch options.stype
    case "alternating"
        % splitIdent is already formatted like this
    case "random"
        mixer=randperm(data.nSample);
        splitIdent=splitIdent(mixer);
    case "contiguous"
        splitIdent=sort(splitIdent);
    case "exact"
end
dataout=data;

dataout.split=drEEMdataset; % Overwrite any preexisting split
for j=1:options.numsplit
    out=not(splitIdent==j);
    dataout.split(j,1)=drEEMdataset.rmsamples(data,out);
    dataout.split(j,1).history=...
        drEEMhistory.addEntry(mfilename,'created dataset through splitting',options,drEEMdataset);
    dataout.split(j,1).models=drEEMmodel;
end
idx=height(dataout.history)+1;
dataout.history(idx,1)=...
    drEEMhistory.addEntry(mfilename,'splits of dataset created',options,dataout);

% Will only run if toolbox is set to overwrite workspace variable and user
% didn't provide an output argument
if drEEMtoolbox.outputscenario(nargout)=="implicitOut"
    assignin("base",inputname(1),dataout);
    disp(['<strong> "',inputname(1), '" processed. </strong> Since no output argument was provided, the workspace variable was overwritten.'])
    return
end



% numsplit=options.numsplit;
% stype=options.stype;
% 
% 
% 
% 
% %Fresh splitting operation
% data.Split_Style=stype;
% if ~isempty(bysort)
%     data.splitinformation.bysort=bysort;
%     data.splitinformation.stype=stype;
%     data.splitinformation.scomb=scomb;
% end
% 
% AnalysisData=data;
% 
% if ~isempty(bysort)
%     t=data.metadata.(bysort);
% end
% if isnumeric(t)
%     t=num2str(t);
%     t=cellstr(t);
% end
%     dots=strfind(bysort,'.');
%     if isempty(dots)
%         try
% 
%         catch
%             try
%                 t=data.metadata.(bysort);
%             catch ME
%                 error('splitds:fieldname1','Not a valid field name for bysort')
%             end
%         end
%         if isnumeric(t)
%             t=num2str(t);
%         end
%         tabl=cellstr(t);
%     elseif ~isempty(dots)
%         tabl=cell(size(data.X,1),length(dots));
%         dots=[0 dots length(bysort)+1];
%         for i=1:length(dots)-1
%             b=(['' bysort(dots(i)+1:dots(i+1)-1) '']);
%             try
%                 t=data.(b);
%             catch ME
%                 error('splitds:fieldnameN','Not a valid field name for bysort')
%             end
%             if ~isnumeric(t)
%                 tc=char(t);%pause
%                 nodata=t(strcmp('',t),:);
%                 zees=repmat('*',[1 size(tc,2)]);
%                 repmat(zees,[size(nodata,1),1]);
%                 t(strcmp('',t),:)=cellstr(repmat(zees,[size(nodata,1),1]));%pause
%                 tabl(:,i)=t;
%             end
%         end
%     end
% 
%     col=1:size(tabl,2);
%     [C, iS]=sortrows(tabl,col); %sorted metadata
%     newdata = sub_struct(data,iS); %sorted dataset
% 
%     %Concatenate text of different lengths (replace cell2mat)
%     %aa=cellfun(@length, C)
%     %sum(max(aa)) %maximum text length for nested operations
%     Cstar='';
%     for i=1:size(C,1)
%         g=char(C(i,1)); 
%         for j=2:size(C,2)
%         g=[g char(C(i,j))]; %#ok<AGROW>
%         end
%         Cstar(i,1:size(g,2))=g;
%     end
%     %Cstar,pause  
%     groups=cellstr(unique(Cstar,'rows')); %%%%%%%%%%%%
%     NoGroups=size(groups,1);
% 
%     %Create exact splits
%     if strcmp(stype,'exact')
%         if isempty(numsplit)
%             numsplit=NoGroups;
%         elseif isequal(numsplit,NoGroups)
%         else
%             error('The number of splits specified in exact mode incompatible with no of groups')
%         end
%         for i=1:numsplit
%             class_dat=strcmp(char(groups{i}),cellstr(Cstar));
%             %class_dat=strcmp(char(groups{i}),cellstr(cell2mat(C))) %does not work if metadata varies in length
%             indices=find(class_dat==1);
%             AnalysisData.Split(i)= sub_struct(newdata,indices);
%             AnalysisData.Split(i).nSample= length(indices);
%         end
%     end
% else
%     newdata=data;
% end
% 
% if strcmp(stype,'none')
%     if ~isempty(numsplit)
%         error('Use numsplit=[] with stype = none for sorting without splitting')
%     else
%         AnalysisData=newdata;
%     end
% else
%     if ~strcmp(stype,'combine')
%         if isempty(numsplit)
%             numsplit=4;
%         end
%         if ~strcmp(stype,'exact')
%             %Create non-exact splits
%             indices=(1:newdata.nSample)';
%             indicesP = indices(randperm(size(indices,1)));
%             NperG=floor(length(indices)/numsplit);
%             for i=1:numsplit
%                 if strcmp(stype,'alternating')
%                     class_dat=indices(i:numsplit:end);
%                 else %contiguous, random
%                     istart=1+(i-1)*NperG;
%                     if i==numsplit
%                         istop=length(indices);
%                     else
%                         istop=(i)*NperG;
%                     end
%                     if strcmp(stype,'contiguous')
%                         class_dat=indices(istart:istop);
%                     elseif strcmp(stype,'random')
%                         class_dat=indicesP(istart:istop);
%                     end
%                 end
%                 AnalysisData.Split(i)= sub_struct(newdata,class_dat);
%                 AnalysisData.Split(i).nSample= size(class_dat,1);
%             end
% 
%         end
%         AnalysisData.Split_NumBeforeCombine=numsplit;
%     end
% 
%     if and(~isempty(scomb),~strcmp(stype,'none'))
%         AnalysisData=CombineSplits(AnalysisData,scomb,protected);
%         Split_Style=AnalysisData.Split_Style;
%         AnalysisData=rmfield(AnalysisData,'Split_Style');
%         AnalysisData.Split_Style=[Split_Style ' then combine'];
%         splits2combine=unique(cell2mat(scomb));
%         if isempty(numsplit) %combine only
%             numsplit=AnalysisData.Split_NumBeforeCombine;
%         end
%         splitsleftout=setxor(splits2combine,1:numsplit);
%         if ~isempty(splitsleftout)
%             warning('splitds:Combinations2',['Splits ' num2str(splitsleftout) ' were not used in combine operation...']);
%             warning('splitds:Combinations2','Some samples are not included in any splits!')
%             warning('press any key to continue, or ^C to cancel');
%             pause;
%         end
%         AnalysisData.Split_NumAfterCombine=length(scomb);
%         [p{1:length(scomb)}] = deal(AnalysisData.Split.nSample);
%         AnalysisData.Split_Combinations=cellfun(@num2str,scomb,'UniformOutput',false);
%     else
%         if strcmp(stype,'combine')
%             error('Need to specify which split combinations will be created in variable ''stype''.')
%         elseif strcmp(stype,'none')
%         else
%             [p{1:numsplit}] = deal(AnalysisData.Split.nSample);
%         end
%     end
% 
%     AnalysisData.Split_nSample=cell2mat(p);
% end
% [AnalysisData]=deletemodels(AnalysisData);
% AnalysisData.Ex=data.Ex;
% AnalysisData.Em=data.Em;
% for j=1:numel(AnalysisData.Split)
%     AnalysisData.Split(j).Ex=data.Ex;
%     AnalysisData.Split(j).Em=data.Em;
% end
% 
% idx=height(AnalysisData.history);
% AnalysisData.history(idx+1,1).datetime=char(datetime);
% AnalysisData.history(idx+1,1).function='splitds';
% AnalysisData.history(idx+1,1).details='not yet implemented';
% 
% end
% 
% function newdata = sub_struct(data,sub_by)
% %Obtain subdataset from a dataset structure
% %Copyright: 2013 Kathleen R. Murphy
% 
% F=fieldnames(data);
% % F(matches(F,{'Ex','Em','Abs_wave'}))=[];
% for i=1:size(F,1)
%     fldnm=char(F(i));
%     if ~strcmp(fldnm,'Split_Style')
%         f_i = data.(fldnm);
%         dimf=size(f_i);
%         if size(f_i,1)==size(data.X,1)
%             if length(dimf)==1
%                 f_i = f_i(sub_by);
%             elseif length(dimf)==2
%                 f_i = f_i(sub_by,:);
%             elseif length(dimf)==3
%                 f_i = f_i(sub_by,:,:);
%             elseif length(dimf)>=4
%                 error('Sub_struct functionality limited to data with 3 or fewer dimensions')
%             end
%         end
%         n_i.(fldnm)=f_i;
%     end
% end
% newdata=n_i;
% end
% 
% 
% function newdata=CombineSplits(data,splitnums,pplus)
% %Combine model splits
% %
% %USEAGE
% %      newdata=CombineSplits(data,splitnums,pplus)
% %INPUT
% %      data: A data structure containing splits in data.Split
% % splitnums: splits to be combined, listed as {comb1,...,combn}.
% %          This step is implemented after first sorting and splitting
% %          samples according to other specified input criteria. The splits
% %          present prior to generating combinations are deleted.
% %           e.g. [] - no splits will be combined (default).
% %           eg. {[1 2],[1 2 3],[3],[1 3]} produces 4 new splits
% %                made from different combinations of splits 1,2 and 3.
% %           eg. {[1 2],[3 4]} produces a dataset having 2 splits that
% %                combined prior splits 1&2 and splits 3&4, respectively.
% %     pplus: additional fields to be protected, in a cell structure
% %           e.g. {'wavelength','moreinfo'}
% %
% % Copyright (C) 2013 Kathleen R. Murphy
% % The University of New South Wales
% % Dept Civil and Environmental Engineering
% % Water Research Center
% % UNSW 2052
% % Sydney
% % krm@unsw.edu.au
% 
% MaxComp=20; %Max No. Components in a PARAFAC model;
% newdata=data;
% 
% %t=regexp(splitnums,'(\d+)','match'),t{1},pause
% protected=cellstr(char('Ex','Em','nEx','nEm','backupX','backupEx','backupEm','backupXf','IntensityUnit','Smooth'));
% if ~isempty(pplus)
%     nprot=size(protected,1);
%     for i=1:length(pplus)
%         protected(nprot+i,1)=cellstr(pplus{i});
%     end
% end
% 
% numnewsplits=size(splitnums,2);
% 
% for i=1:numnewsplits
%     %t2=str2num(char(t{i}))',pause %#ok<ST2NM>
%     t2=splitnums{i};
%     try
%         temp=data.Split(t2);
%     catch ME
%         error('Attempted to access (in order to combine) a non-existent split')
%     end
%     names=fieldnames(temp);
%     cellData=cellfun(@(f) {vertcat(temp.(f))},names); %Collect field data into a cell array
%     newdata.Split(i)= cell2struct(cellData,names);  %Convert the cell array into a structure
% 
%     for j=1:size(protected,1)
%         if isfield(temp(1),(char(protected(j,:))))
%             newdata.Split(i).(char(protected(j,:)))=temp(1).(char(protected(j,:)));
%         end
%     end
%     newdata.Split(i).nSample=sum(newdata.Split(i).nSample);
% end
% 
% splitstruc=newdata.Split;
% for j=1:MaxComp
%     m=['Model' num2str(j)]; e=[m '_err'];it=[m '_it'];
%     if isfield(splitstruc,m)
%         splitstruc=rmfield(splitstruc,m); end
%     if isfield(splitstruc,e)
%         splitstruc=rmfield(splitstruc,e); end
%     if isfield(splitstruc,it)
%         splitstruc=rmfield(splitstruc,it); end
% end
% 
% newdata.Split=newdata.Split(1:numnewsplits);
% end
% 
% 
% function [out]=deletemodels(in)
% % Find and delete model information in splits.
% out=in;
% n=[];i=1;for k=1:100;if isfield(in.Split,['Model',num2str(k)]);n(i)=k;i=i+1;end;end
% del=n;
% for ii=1:numel(del)
%     mname=['Model',num2str(del(ii))];
%     try
%         fields={'','err','it','core','source','convgcrit','constraints','initialise','percentexpl','compsize'};
%         for n=1:numel(fields)
%             if isfield(out,[mname,fields{n}])
%                 out.Split=rmfield(out.Split,[mname,fields{n}]);
%             end
%         end
%     catch
% 
%        warning('Found old models in some splits, but could not delete them. ')
%     end
% end
end