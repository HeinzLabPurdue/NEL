% RDD - restore data directory to its value at the last cdd call

% SP on 10/17/2019: made cdd a function (was a script before), so made rdd a function too

function rdd()
global SaveDirXYZ

cd(SaveDirXYZ)

