function rc = Trigcheck

global Trigger RP

trig_tags = cat(1,fieldnames(Trigger.params_in),fieldnames(Trigger.params));
actual_tags = RPtag_names(Trigger);

rc = 1;
for i = 1:length(trig_tags)
   if (isempty(strmatch(trig_tags{i}, actual_tags)))
      rconame = RP(Trigger.RP_index).rco_file;
      nelerror(['''' rconame ''' Loaded to RP(' int2str(Trigger.RP_index) ...
            ') Does not contain the Tag ''' trig_tags{i} ''' which is needed for the Trigger.' ...
            ' Please load the rco to the other available RP''s']);
      rc = 0;
      break;
   end
end
