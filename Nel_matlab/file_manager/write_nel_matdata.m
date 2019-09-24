function rc = write_nel_matdata(fname,x,save_spikes, save_EP)
% write_nel_data  - writes a standard nel output file in a form of an m-file.
%
%       Usage: rc = write_nel_data(fname,x,save_spikes)
%                   'x' should contain the data to be saved in 'fname'.
%                   'save_spikes' is an optional boolean flag 
%                   (by default save_spikes = 1).
%                   'write_nel_data' returns 1 on success and -1 on failure.
% 
% AF 9/5/01
% Created by SP on 22Jul19
% Org function= write_nel_data
% Writing/saving/loading m-files is inefficient - uses twice memory and
% >100 times slower 
% So saving directly as matfiles

global spikes NelData EPdata

if (exist('save_spikes','var') ~= 1)
   save_spikes = 1;
end
if (exist('save_EP','var') ~= 1)
   save_EP = 0;
end
[~, ~, ext] = fileparts(fname);
if strcmp(ext,'.mat') ~= 1
    if isempty(ext) % if no extension
        fname = [fname '.mat'];
    else % if extension ~= .mat, but something else, like .m
        fname= strrep(fname, ext, 'mat');
    end
end

if save_spikes
    warning('Update logic for saving spikes');
    fprintf('%d -- %d -- %d', length(spikes), length(EPdata), length(NelData));
end

if save_EP
    warning('Update logic for saving EP');
    % Looks like NelData.General.EP should be updated here
    fprintf('%d -- %d -- %d', length(spikes), length(EPdata), length(NelData));
end
data= x; %#ok<NASGU>

try 
    save(fname, 'data');
    rc = 1;
catch
    rc = 0;
end



% % % % fid = fopen(fname,'wt+');
% % % % if (fid < 0)
% % % %    rc = -1;
% % % %    return;
% % % % end
% % % % [~, filename] = fileparts(fname);
% % % % fprintf(fid,'function x = %s\n', filename);
% % % % mat2text(x,fid);
% % % % 
% % % % AddExtractorFunction = 0;
% % % % if (save_spikes || save_EP)
% % % %    FirstBlockWritten = 0;
% % % %    if (save_spikes)
% % % %       for i = 1:length(spikes.times) % length(spikes.times) == nChannels
% % % %          % Code for initializing the spike matrix
% % % %          fprintf(fid, '\nx.spikes{%d} = zeros(%d,%d);\n', i, spikes.last(i), size(spikes.times{i},2));
% % % %          % Code for self-extracting the data stored in the file comments.
% % % %          if (FirstBlockWritten==0)
% % % %             fprintf(fid, '[x.spikes{%d},fid] = fill_marked_val(which(mfilename),''%%%d'',x.spikes{%d});\n', i,i,i);
% % % %             FirstBlockWritten = 1;
% % % %          else
% % % %             fprintf(fid, '[x.spikes{%d},fid] = fill_marked_val(fid,''%%%d'',x.spikes{%d});\n', i,i,i);
% % % %          end
% % % %       end
% % % %    end
% % % %    if (save_EP)
% % % %       for i_ep = 1:length(x.EP) % length(x.EP) == EP_nChannels
% % % %          % Code for initializing the EP "ave" vectors.  Added by GE 03Jul2002.
% % % %          fprintf(fid, '\nx.EP(%d).aveY = zeros(1,%d);\n', i_ep, NelData.General.EP(i_ep).lineLength);
% % % %          % Code for self-extracting the data stored in the file comments.
% % % %          if (FirstBlockWritten==0)
% % % %             fprintf(fid, '[x.EP(%d).aveY,fid] = fill_marked_val(which(mfilename),''%%EPV%d'',x.EP(%d).aveY);\n', i_ep,i_ep,i_ep);
% % % %             FirstBlockWritten = 1;
% % % %          else
% % % %             fprintf(fid, '[x.EP(%d).aveY,fid] = fill_marked_val(fid,''%%EPV%d'',x.EP(%d).aveY);\n', i_ep,i_ep,i_ep);
% % % %          end
% % % %          
% % % %          if (NelData.General.EP(i_ep).saveALLtrials == 1)
% % % %             % Code for initializing the EP "all" matrix
% % % %             if (NelData.General.EP(i_ep).decimate == 1) % added by GE, 16May2003.
% % % %                lineLen = size(decimate(EPdata(i_ep).allY(1,:), NelData.General.EP(i_ep).decimateFactor), 2);
% % % %             else
% % % %                lineLen = NelData.General.EP(i_ep).lineLength;
% % % %             end
% % % % %             fprintf(fid, '\nx.EP(%d).allY = zeros(%d,%d);\n', i_ep, ...
% % % % %                NelData.General.EP(i_ep).lastN, NelData.General.EP(i_ep).lineLength);
% % % %             fprintf(fid, '\nx.EP(%d).allY = zeros(%d,%d);\n', i_ep, ...
% % % %                NelData.General.EP(i_ep).lastN, lineLen);  % modified by GE 16May2003.
% % % %             % Code for self-extracting the data stored in the file comments.
% % % %             if (FirstBlockWritten==0)
% % % %                fprintf(fid, '[x.EP(%d).allY,fid] = fill_marked_val(which(mfilename),''%%EP%d'',x.EP(%d).allY);\n', i_ep,i_ep,i_ep);
% % % %                FirstBlockWritten = 1;
% % % %             else
% % % %                fprintf(fid, '[x.EP(%d).allY,fid] = fill_marked_val(fid,''%%EP%d'',x.EP(%d).allY);\n', i_ep,i_ep,i_ep);
% % % %             end
% % % %          end
% % % %       end
% % % %    end
% % % %    fprintf(fid, 'fclose(fid);');
% % % %    if (save_spikes)
% % % %       % Writing the spike data as comments to the data mfile.
% % % %       for i = 1:length(spikes.times)
% % % %          fprintf(fid, '\n%%%d\n',i);
% % % %          fmt = ['%%' int2str(i) ' %8d %4.10f \n'];
% % % %          fprintf(fid,fmt,spikes.times{i}(1:spikes.last(i),:)');
% % % %       end
% % % %       fprintf(fid,'\n');
% % % %    end
% % % %    if (save_EP)
% % % %       % Writing the EP data as comments to the data mfile.
% % % %       
% % % %       % averaged EP data
% % % %       for i_ep = 1:length(x.EP)
% % % %          fprintf(fid, '\n%%EPV%d\n',i_ep);
% % % %          fprintf(fid, '%%EPV%d', i_ep);
% % % %          fprintf(fid, ' %4.10f', EPdata(i_ep).aveY(:));
% % % %          fprintf(fid, '\n');
% % % %       end
% % % %    end
% % % %    
% % % %    % all lines of EP data, if requested
% % % %    for i_ep = 1:length(x.EP)
% % % %       if (NelData.General.EP(i_ep).saveALLtrials == 1)
% % % %          fprintf(fid, '\n%%EP%d\n',i_ep);
% % % %          for j = 1:NelData.General.EP(i_ep).lastN
% % % %             fprintf(fid, '%%EP%d', i_ep);
% % % %             if (NelData.General.EP(i_ep).decimate == 1) % added by GE, 16May2003.
% % % %                lineData = decimate(EPdata(i_ep).allY(j,:), NelData.General.EP(i_ep).decimateFactor);
% % % %             else
% % % %                lineData = EPdata(i_ep).allY(j,:);
% % % %             end
% % % % %             fprintf(fid, ' %4.10f', EPdata(i_ep).allY(j,:));
% % % %             fprintf(fid, ' %4.10f', lineData(:));    % modified by GE 16May2003.
% % % %             fprintf(fid, '\n');
% % % %          end
% % % %       end
% % % %    end
% % % %    NelData.General.EP(i_ep).lastN = 0;   % reset to 0 after writing the data.
% % % %    fprintf(fid,'\n');
% % % %    
% % % % AddExtractorFunction = 1;
% % % % end
% % % % 
% % % % if (AddExtractorFunction)
% % % %    % Add the source code for the subfunction 'fill_marked_val' to the data file.
% % % %    subfunc_file = textread(which('fill_marked_val'),'%s','delimiter','\n','whitespace','');
% % % %    fprintf(fid,'%s\n',subfunc_file{:});
% % % % end
% % % % 
% % % % fclose(fid);
% % % % rc = 1;