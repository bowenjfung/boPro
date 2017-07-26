
dataMatrix = [];

c = 1;
for x = [1,3:4,6:8,10:15]
    try
        oldcd = cd('/Users/Bowen/Desktop/EDT Time Data/Bisection');
        name = sprintf('%.0f_*', x);
        loadname = dir(name);
        load(loadname.name,'bisection');
        cd(oldcd);
    catch
        cd(oldcd);
        continue;
    end
    if x == 1
        trialLog = bisection;
        clearvars bisection
        bisection.trialLog = trialLog;
    end
    
    fprintf('Loaded participant %.0f.\n', x);
    
    for t = 1:size(bisection.trialLog,2)
        id(t,1) = x;
        objT(t,1) = bisection.trialLog(t).delay / 2;
        if isempty(bisection.trialLog(t).rawbisect)
            subT(t,1) = NaN;
        else
            subT(t,1) = bisection.trialLog(t).rawbisect + objT(t);
        end
    end
    
    
    dataMatrix = cat(1,dataMatrix,[id, objT, subT]);
    
    [minPar(c,1:3),~,~] = fitSET(objT, subT);
    
    fprintf('Completed fit for participant %.0f.\n', x);
    
    c = c + 1;
    clearvars -except x m c dataMatrix minPar oldcd
end