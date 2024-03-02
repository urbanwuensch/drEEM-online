classdef drEEMhistory
    properties
        timestamp (1,1) datetime
        fname (1,:) {mustBeText} = ""
        fmessage (1,:) {mustBeText} = ""
        usercomment(1,:) {mustBeText} = ""

    end
    % Hidden properties for toolbox-internal use only (not visible to user)
    properties (Hidden=true)
        details % <- Option structure or a text giving details.
        backup (1,1)  % <- the dataout version at the end of call
        previous (1,1)  % <- for restoring the input variable of a call (currently only used for scaling)
    end
    methods (Static=true)
        function obj=addEntry(caller,message,details,backup,prev)
            arguments
                caller {mustBeText}
                message {mustBeText}
                details = ""
                backup drEEMdataset = drEEMdataset.create
                prev drEEMdataset = drEEMdataset.create
            end
            obj=drEEMhistory;
            obj.timestamp=datetime("now");
            obj.fname=caller;
            obj.fmessage=message;
            obj.details=details;
            
            if backup.nSample~=0
                backup=drEEMbackup.convert2backup(backup);
            end
            obj.backup=backup;

            if prev.nSample~=0
                prev=drEEMbackup.convert2backup(prev);
            end
            obj.previous=prev;
        end

        function idx = searchhistory(history,fname,firstLast)
            arguments
                history {mustBeA(history,"drEEMhistory")}
                fname {mustBeText}
                firstLast {mustBeMember(firstLast,["first","last","all"])}
            end

            idx=arrayfun(@(x) matches(x.fname,fname),history);
            if isempty(firstLast)
                firstLast="first";
            end
            if matches(firstLast,"all")
                idx=find(idx);
            else
                idx=find(idx,1,firstLast);
            end
        end

        function tableout=convert2table(history)
            mustBeA(history,"drEEMhistory")
            flds={'timestamp','fname','fmessage','details','backup','previous','usercomment'};
            
            conv=struct;
            for j=1:numel(flds)
                for k=1:height(history)
                    conv(k).(flds{j})=history(k).(flds{j});
                end
            end
            tableout=struct2table(conv);

        end
    end
end