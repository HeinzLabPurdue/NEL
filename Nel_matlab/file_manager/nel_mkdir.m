function varargout = nel_mkdir(varargin)
%MKDIR Make directory. (Matlab's 'mkdir' that was patched by AF 11/28/01).
%   MKDIR('DIRNAME') will create the directory DIRNAME in the current
%   directory.
%
%   MKDIR('PARENTDIR','NEWDIR') will create the directory NEWDIR in the
%   already existing directory PARENTDIR.
%
%   STATUS = MKDIR(...) will return 1 if the new directory is created
%   successfully, 2 if it already exists, and 0 otherwise.
%
%   [STATUS,MSG] = MKDIR(...) will return a non-empty error
%   message string if an error occurred.
%
%   See also COPYFILE.

%   Loren Dean
%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 1.21 $ $Date: 2001/04/15 11:59:25 $

error(nargchk(1,2,nargin))

Status = 1;
if nargin==1,
  DirName = pwd;
  NewDirName = varargin{1};
  
elseif nargin == 2,
  DirName = varargin{1};
  NewDirName = varargin{2};

end % if nargin

NewDirectory = fullfile(DirName, NewDirName);

%% Check to see if the parent directory exists
if ~exist(DirName,'dir'), 
 % The directory does not exist
 Status = -1;
  
else,
  
  %% Check to see if the directory to be created exists as a
  %% directory or file
  Files = dir(DirName);
  if any(strcmp({Files.name},NewDirName)),
    if ~any(strcmp({Files([Files.isdir]).name},NewDirName)),
      Status=-2;
    else,
      Status = 2;
    end
  end
  
end % if ~exist

% if Status is 1 then everything is good up to this point.
if Status == 1,
  c=computer;
  if isunix ,
    [Status, result] = unix(['mkdir ' fullfile(DirName,NewDirName)]);
    
  elseif ispc
      % This is to check and see if the dos command is working.  In Win95
      % if the current directory is a deeply nested directory or sometimes
      % for TAS served file systems, the output pipe does not work.  The 
      % solution is to make the current directory safe, %windir% and put it back
      % when we are done.  The test is the cd command. There are four possible
      % cases:
      %
      % case 1:  dos causes no error and result is not empty. Does not
      %          trip the try.
      % case 2:  dos causes no error and result is empty. Does not trip
      %          the try.
      % case 3:  dos causes an error and result is not empty. No message
      %          is produced, but it trips the try. This shouldn't happen.
      % case 4:  dos causes an error and result is still empty. It trips
      %          the try. Before adding the try there was a fatal error.
      %
      % The try/catch now allows case 4. This fixed the problem when
      % the current directory is a UNC path. The rest of the other cases
      % should be unchanged.
      %
      
      result = [];
      try
        [Status, result] = dos('cd');
      catch
      end
      if isempty(result)
        OldDir = pwd;
        cd(getenv('windir'))
      else
        OldDir = [];
      end
      
      % DOS returns a zero status if the shell executed successfully which does
      % not necessarily mean that the command given to DOS was successful.  The
      % better indicate of the success of the MKDIR command is the second output
      % argument to DOS which is the result.  We should use RESULT to determine 
      % status of MKDIR on the PC instead of relying on STATUS.
      
      result = '';
      [Status, result] = dos(['mkdir "' fullfile(DirName,NewDirName) '"']);
      if ~isempty(OldDir)
          cd(OldDir);
      end
      
      if (~isempty(result))
          if (~isempty(findstr(result, ...
                  ['A subdirectory or file ' fullfile(DirName, NewDirName) ' already exists'])))
              Status = 2;
          elseif (~isempty(result))
              Status = 1;
          else
              Status = 0;
          end        
      end              
      
  end % if computer type
  
  % A Status of 0 indicates success for the UNIX and PC operating systems and
  % therefore, this status has to be flipped to 1 to mean success in MATLAB.
  % However, a non-zero number indicates failure on UNIX (not PC) so we need
  % to preserve the failure status to have MKDIR return the correct result on
  % the PC and therefore using "Status = (Status==0)" does not always do the
  % "right" thing on the PC.
  
  if (Status == 0)
      Status = 1;
  elseif (Status == 1)
      Status = 0;
  end
    
end % if Status == 1


% Check to see if output arguments are to be returned.  If an arg.
% is not returned then cause errors if necessary.
ErrMsg='';
switch Status,
  case -2,
    ErrMsg = ['Cannot make directory ' NewDirName ' because a file ' ...
	      'in ' DirName ' already exists by that name.'];
  case -1,
    ErrMsg = ['Cannot make directory ' NewDirName ' because ' DirName ...
	      ' does not exist.'];
      
  case 0,
    ErrMsg = ['Cannot make directory ' NewDirName '.'];
    
  case 2,
    ErrMsg = ['Directory or file ' NewDirName ' already exists in ' ...
	       DirName];
    
end % if Status checking
  
if nargout == 0,
  error(ErrMsg)
  
else,
  if Status==-1|Status==-2,Status=0;end
  varargout{1} = Status;
  varargout{2} = ErrMsg;
  
end % if nargout
