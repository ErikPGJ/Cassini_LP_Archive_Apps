%
% Automatic test code for keep_incrementing_values.
%
% Created 2018-05-14 by Erik P G Johansson.
%
function keep_incrementing_values___ATEST
    argsList    = {};
    resultsList = {};

    argsList{end+1}    = {[1,2,3,4,5,6,5,6,7, 8, 9]};
    %resultsList{end+1} = {[1,2,3,4,5,6,    9,10,11]};
    resultsList{end+1} = {logical([1,1,1,1,1,1,0,0,1, 1, 1])};

    argsList{end+1}    = {        [-3,-4,-3,-2, 0,10,-1,-2,10,11,12]};
    %resultsList{end+1} = {[ 1,       4, 5, 6,         10,11]};
    resultsList{end+1} = {logical([ 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1])};

    argsList{end+1}    = {[]};
    %resultsList{end+1} = {zeros(1,0)};
    resultsList{end+1} = {logical([])};

    argsList{end+1}    = {[-3]};
    %resultsList{end+1} = {[ 1]};
    resultsList{end+1} = {logical([1])};

    argsList{end+1}    = {        [-3,-1, 1,10,100]};
    %resultsList{end+1} = {[ 1, 2, 3, 4,  5]};
    resultsList{end+1} = {logical([ 1, 1, 1, 1,  1])};

    %argsList{end+1}    = {};
    %resultsList{end+1} = {};

    %argsList{end+1}    = {};
    %resultsList{end+1} = {};

    %argsList{end+1}    = {};
    %resultsList{end+1} = {};

    %argsList{end+1}    = {};
    %resultsList{end+1} = {};

    for i = 1:numel(argsList)
        args = argsList{i};
        res = keep_incrementing_values(args{:});
        exp = resultsList{i}{1};

        if ~isequal(res, exp)
            i
            res
            exp
            error('FAIL')
        end
        disp('OK')
    end

end
