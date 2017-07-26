dataMatrix = [];
m = [58,92,93,94];
c = 1;
for x = 1:120
    if ismember(x,m)
        continue;
    end
    try
        oldcd = cd('/Users/Bowen/Desktop/TIMEDEC/behavioural data');
        name = sprintf('%.0f_*', x);
        loadname = dir(name);
        load(loadname.name,'TD');
        cd(oldcd);
    catch
        continue;
    end
    fprintf('Completed participant %.0f.\n', x);    
    
    id(1:size(TD.time1,1)) = x;
    objT = TD.time1(:,1);
    subT = TD.time1(:,6);
    
    dataMatrix = cat(1,dataMatrix,[id', objT, subT]);
    
    [minParTD(c,1:3),~,~] = fitSET(objT, subT);
    
    c = c + 1;
    clearvars -except x m c dataMatrix minParTD
end