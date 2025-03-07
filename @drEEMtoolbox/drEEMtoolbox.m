classdef drEEMtoolbox < handle
% <a href = "matlab:doc dreem">Documentation of the drEEM toolbox</a>
%
% <strong>EXAMPLE(S)</strong>
%   1. Make a class instance to call methods (highly recommended)
%       tbx = drEEMtoolbox;
%   2. Call a method from the class directly
%       samples=drEEMtoolbox.processabsorbance(samples);
%       
    properties (Constant = true, Hidden = false)
        version = "2.0.0"
        url = "GitLab URL for release goes here"
        requiredVersion = 'R2022a'
        rootfolder = drEEMtoolbox.tbxpath;
        options=drEEMtoolbox.defaultOptions;
    end

    % These are not meant for the general public, Origin Pro is required.
    methods (Hidden = true,Static = true)
        Xout = aqualogimport(workingpath,selector,deselector)
        dataout = sampleQimport(workingpath,data)
        [DS,DSb] = processHJYdata(Xin,opt)
    end

    % This is hidden because it's only ever used for install
    methods (Hidden = true,Static = true)
        function out=defaultOptions
            out.plotByDefault = true;
            out.OvrWrteUnless = false;
            out.uifig = true;

        end
        function versionRequires
            if isMATLABReleaseOlderThan(drEEMtoolbox.requiredVersion)
                error(['You need Matlab ',drEEMtoolbox.requiredVersion,' or newer to use this version of drEEM.'])
            end
            mallver=ver;
            tbs={'Statistics and Machine Learning Toolbox' 'Parallel Computing Toolbox'};
            isthere=zeros(1,numel(tbs));
            for n=1:numel(tbs)
                isthere(n)=any(~cellfun(@isempty,strfind({mallver.Name},tbs{n})));
            end
            if all(isthere)
                % No action or information needed.
            else
                warning(['Missing toolbox(es):',tbs{~isthere},'. Some toolbox functionality will not be available.'])
            end

        end
    end

    % These are not really needed to be visible to the user
    methods (Hidden = true,Static=true)
        [ modelout,neworder] = reordercomponents( model,varargin )
        passed = silentvalidation(data,fac)

        function out=tbxpath
            out=fileparts(which('drEEMtoolbox.m'));
            out=erase(out,"@drEEMtoolbox");
        end

        function [idx,distance] = mindist(vec,value)
            if isscalar(value)
                [distance,idx]=min(abs(vec-value));
            else
                for j=1:numel(value)
                    [distance(j,1),idx(j,1)]=min(abs(vec-value(j)));
                end
            end

        end

        function out = isNearest(vec,value)
            if isscalar(value)
                [distance,idx]=min(abs(vec-value));
            else
                error('value must be scalar')
            end
            out=vec==vec(idx);
            
        end

        f=dreemfig(fighandlein)
        f=dreemuifig

    end

    % These are toolbox internal, would just be confusing if visible
    methods (Static = true, Hidden = true)
        function methodEnd(dataout,name)
            if drEEMtoolbox.OvrWrteUnless
                assignin("base",dataout,name)
            end
        end

        function scenario=outputscenario(n_in)

            if n_in ~= 0 && not(drEEMtoolbox.options.OvrWrteUnless)
                % User wants explicit assignments & toolbox agrees
                scenario=categorical({'explicitOut'});
            end
            if drEEMtoolbox.options.OvrWrteUnless && n_in==0
                % User wants workspace variable to be overwritten  & toolbox agrees
                scenario=categorical({'implicitOut'});
            end
            if drEEMtoolbox.options.OvrWrteUnless && n_in~=0
                % User wants explicit assignments but toolbox disagrees
                scenario=categorical({'explicitOut'});
            end
            if not(drEEMtoolbox.options.OvrWrteUnless) && n_in==0
                % Toolbox is set to make explicit assignments, but user didn't give output args
                scenario=categorical({'explicitOut'});
            end
        end
    end

    methods (Static = true , Access = public)

        % import functions
        data = importeems(filePattern,options)
        data = importabsorbance(filePattern,options)
        dataout = associatemetadata(data,pathtofile,metadatakey,datakey)
        dataout=upgradedataset(data,atypicalFieldnames)


        % Status-specific functions
        dataout=changestatus(data)

        % History-specific functions
        data = addcomment(data,comment)
        function validatedataset(data)
            drEEMdataset.validate(data)
        end
        % function [dataout] = undolast(data)
        %     arguments
        %         data {mustBeA(data,"drEEMdataset"),drEEMdataset.validate(data)}
        %     end
        %     n=numel(data.history);
        %     if n==1
        %         error('Nothing to undo')
        %     end
        %
        %     temp=data.history(n-1).backup;
        %     temp=drEEMbackup.convert2dataset(temp);
        %     temp.history=data.history(1:n-1);
        %     %temp.toolboxdata=data.toolboxdata;
        %
        %     if nargout==0
        %         assignin("base",inputname(1),temp);
        %         disp(['<strong> Last step (',num2str(n-1),') in dataset "',inputname(1), '" undone. </strong> Since no output argument was provided, the workspace variable was overwritten.'])
        %         return
        %     else
        %         dataout=temp;
        %     end
        %
        % end
        % function restore(data,whichone)
        %     drEEMhistory.restore(data,whichone)
        % end
        function displayhistory(data)
            drEEMdataset.displayhistory(data)
        end

        % Benchmark the system performance
        [singlescore,multiscore]=benchmark
        
        % Data processing
        varargout = alignsamples(varargin)
        dataout = processabsorbance(data,options)
        [dataout,emout,exout] = ifecorrection(data)
        dataout = subtractblanks(samples,blanks)
        dataout = spectralcorrection(data,options)
        dataout = ramancalibration(samples,blanks,options)
        dataout = handlescatter(data,varargin)
        dataout = subdataset(data,options)
        dataout = zapnoise(data,sampleIdent,emRange,exRange)
        dataout = scalesamples(data,option)
        dataout = rmspikes(data,name_value)

        % Slopes, peaks, indicies
        dataout = fitslopes(data,options)
        dataout = pickpeaks( data,options)

        % PARAFAC
        dataout = fitparafac(data,options)
        dataout = splitdataset(data,options)
                  splitvalidation(data,fac)
        fmax = scores2fmax(data,f)

        % Data export
        export2openfluor(data, f, filename)
        export2zip(data,filename)
        %export2netcdf(data,filename)
        exportresults(data,filename,f,name_value)
        % fhandle = reportresidualanalysis(data,ftarget,mdfield)

        % Visualization (incl. app workarounds)
        viewspectralvariance(data)
        function vieweems(data)
            vieweems(data)
        end
        function viewmodels(data)
            viewmodels(data)
        end
        function viewdmr(data)
            viewdmr(data)
        end
        function viewcompcorr(data)
            viewcompcorr(data)
        end
        function viewhistory(data)
            viewhistory(data)
        end
        % function explorevariability(data)
        %     explorevariability(data)
        % end
        function viewscatter(data)
            viewscatter(data)
        end
        function viewabsorbance(data)
            viewabsorbance(data)
        end
        [summary,M]  =  viewopenfluormatches(filename)

    end

end