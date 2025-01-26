function doc(functionname)
% drEEM-specific function for displaying custom formatted documentation
% (c) Urban Wuensch, 2019
%% Function init
% This bit is for cleanup
currentdirectory = pwd;
c = onCleanup(@() cd(currentdirectory));

rtpath=matlabroot;
doclocs = which('doc','-all');
restoredoc_i=contains(doclocs,rtpath);

if numel(doclocs)>2
%     wanring(sprintf(['\n\n   Multiple versions of ''doc'' found. drEEM has it''s own function with this name.\n' ...
%         '   Under the current conditions, doc.m would not stop running. If you are unsure what this means:\n\n' ... 
%         '    1. Please <strong>delete your copy of drEEM from your hard disk.</strong> \n' ... 
%         '    2. Download the latest verison from dreem.openfluor.org \n' ... 
%         '    3. Install drEEM again.\n']))
end
% Database of published function docs
try functionname=lower(functionname);end %#ok<TRYNC>

% helpdatabase=retreivefileinfo;


% Catch users that just want to see the start page of doc 
if nargin==0
    cd(fileparts(doclocs{restoredoc_i}));
    help
    return
end

% Search for existing documentation based on entries in "functiondirectory"
try
    web([char(functionname),'.html'], '-notoolbar','-new');
    return
catch
    % If nothing was found, just display the default MATLAB output
    cd(fileparts(doclocs{restoredoc_i}));
    help(functionname);
    warning('didn''t find the fancy doc html page')
end
end