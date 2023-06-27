function [picstoSEND,picNUMlist,dBSPLlist]=update_pic_num_list_ABR(picstoSEND,picNUMlist,dBSPLlist,rerunSPLs)
% dBSPLlistOrg=dBSPLlist;

for i=1:length(rerunSPLs)
    
    ind=find(dBSPLlist==rerunSPLs(i));
    
    if ~isempty(ind)
        picstoSEND=picstoSEND(picstoSEND~=picNUMlist(ind));
        picNUMlist=picNUMlist(picNUMlist~=picNUMlist(ind));
        dBSPLlist=dBSPLlist(dBSPLlist~=dBSPLlist(ind));
    end 
end