classdef drEEMbackup < drEEMdataset
    properties
    end
    methods (Static=true)
        function backup = convert2backup(data)
            flds=fieldnames(data);
            flds(cellfun(@(x) matches(x,"toolboxdata"),flds))=[];
            backup=drEEMbackup;
            for j=1:numel(flds)
                backup.(flds{j}) = data.(flds{j});
            end
            backup.history=drEEMhistory;
        end
        function backup = convert2dataset(data)
            flds=fieldnames(data);
            flds(cellfun(@(x) matches(x,"toolboxdata"),flds))=[];
            backup=drEEMdataset;
            for j=1:numel(flds)
                backup.(flds{j}) = data.(flds{j});
            end
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end