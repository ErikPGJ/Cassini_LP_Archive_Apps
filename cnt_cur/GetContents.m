%
% Wrapper around isContentLiteWrapper, with last argument strings empty.
%
function [s,d]=GetContents(SC)

[s,d] = isGetContentLiteWrapper(SC.DBH,SC.PRO,SC.MEM,SC.INS,'','','',''); % Get contents

end