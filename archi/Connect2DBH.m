%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Connect to ISDAT DBH using new matlab interfaces
% 
% Author: Reine Gill
% Input:  Host name
%         and list of ports to try!
%
% Return code: DB > 0 if successfull 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DB=Connect2DBH(name,ports)
DB=0;  
pind=1;
 % Connect to ISDAT dbh 
 % Open data base, trying first port
 clear lasterr;
 disp(['Connecting to ISDAT dbh on host:',name]);
 disp(['Using port:',num2str(ports(pind))]);
 try
   DB = Mat_DbOpen([name,':',num2str(ports(pind))]);
 catch
   lasterr
 end

 % Trying orther ports
 while(strcmp(lasterr,'MAT_DBOPEN error.') && pind<length(ports))
   pind=pind+1;
   disp(['Connecting to ISDAT dbh on host:',name]);
   disp(['Using port:',num2str(ports(pind))]);
   % Open data base
   try
     DB = Mat_DbOpen([name,':',num2str(ports(pind))]);
   catch
     lasterr
   end
 end
 
 if(strcmp(lasterr,'MAT_DBOPEN error.'))
   disp('Failed to connect to dbh');
   exit;
 end

