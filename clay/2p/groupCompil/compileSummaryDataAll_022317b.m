function compileSummaryDataAll(mouseFolderList)




% This is a script to go through all data from a mouseFolderList and
% extract out useful summary data

mouseName = mouseFolderList{i,1};

mouseFolderPath = mouseFolderList{i,2};

cd(mouseFolderPath);

mouseDir = dir;

% go through mouse dir

for mouseDirNum = 1:length(mouseDir)

    [sessSummStruc] = calcSummaryData();


end  % end FOR loop for all folders in mouseDir

