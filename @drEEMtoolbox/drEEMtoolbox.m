classdef drEEMtoolbox < handle
    properties (Constant = true, Hidden = false)
        version = "2.0.0"
        url = "https://gitlab.com/dreem/dreem-2.0"
    end
    
    % These are not meant for the general public, Origin Pro is required.
    methods (Hidden = true,Static = true)
         Xout = aqualogimport(workingpath,selector,deselector)
         dataout = sampleQimport(workingpath,data)
         [DS,DSb] = processHJYdata(Xin,opt)
    end
    
    % These are not really needed to be visible to the user
    methods (Hidden = true,Static=true)
        [ modelout,neworder] = reordercomponents( model,varargin )
        passed = silentvalidation(data,fac)

    end

    methods (Static = true , Access = public)
        % import functions
        data = importeems(filePattern,options)
        data = importabsorbance(filePattern,options)
        dataout = associatemetadata(data,pathtofile,metadatakey,datakey)
        
        % Status-specific functions
        changestatus(data)

        % History-specific functions
        addcomment(data,comment)
        function validatedataset(data)
            drEEMdataset.validate(data)
        end
        function undolast(data)
            drEEMdataset.undo(data)
        end
        function restore(data,whichone)
            drEEMdataset.restore(data,whichone)
        end
        function displayhistory(data)
            drEEMdataset.displayhistory(data)
        end

        % Data processing
        varargout = alignsamples(varargin)
        dataout = processabsorbance(data,options)
        [dataout,emout,exout] = ifecorrection(data)
        dataout = subtractblanks(samples,blanks)
        dataout = ramancalibration(samples,blanks,options)
        dataout = handlescatter(data,varargin)
        dataout = subdataset(data,outSample,outEm,outEx)
        dataout = zapnoise(data,sampleIdent,emRange,exRange)
        dataout = scalesamples(data,option)
        dataout = rmspikes(data,name_value)

        % Slopes, peaks, indicies
        [dataout,slopes,metadata,model] = fitslopes(data,options)
        [dataout,picklist,metadata] = pickpeaks( data,options)

        % PARAFAC stuff
        dataout = fitparafac(data,options)
        dataout = splitdataset(data,options)
        dataout = splitvalidation(data,fac)
        
        % Data export
        export2openfluor(data, f, filename)
        

        % Visualization (incl. app workarounds)
        f=dreemfig
        f=dreemuifig
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
        function explorevariability(data)
            explorevariability(data)
        end
        function viewscatter(data)
            diagscatter(data)
        end

        
        
    end
end