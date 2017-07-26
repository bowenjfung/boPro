function [minPar, fval, exitflag] = fitSET(objT, subT)
% Fits three parameter time perception power function to data. For
% simplicity, the second parameter (shift) can be set to zero.

minFun = @(par) costFun(par, objT, subT);
initial_values = [rand(1,1) 0 0.9];
lowerBounds = [0 0 0];
upperBounds = [Inf 0 1];
options = optimset('display','iter','algorithm','interior-point');
[minPar, fval, exitflag, ~] = fmincon(minFun,initial_values,[],[],[],[],lowerBounds,upperBounds,[],options);

    function [cost] = costFun(par, objT, subT)
        
        muT = par(1).*(objT - par(2)).^par(3);
        
        cost = sum((subT - muT) .^ 2);
        
    end
end
