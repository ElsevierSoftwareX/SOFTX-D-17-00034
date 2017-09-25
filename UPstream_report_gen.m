% *******************************************************************
% *                        U P S t r e a m                          *
% * Automated Hydraulic Design of Pressurized Water Supply Networks *
% *           (Based on EPANET 2.0 Computational Engine)            *
% *            Stergios Emmanouil and Andreas Langousis             *
% *                Department of Civil Engineering                  *
% *                 University of Patras, Greece                    *
% *******************************************************************
%
% Copyright 2017 Stergios Emmanouil and Andreas Langousis
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
% This script generates the UPstream report file

% generating report and saving new .inp file
calllib(dll_filename,'ENsaveH');
calllib(dll_filename,'ENresetreport');
calllib(dll_filename,'ENsetreport',['FILE ',fullpath.report_UPstream]);
calllib(dll_filename,'ENsetreport','NODES all');
calllib(dll_filename,'ENsetreport','LINKS all');
calllib(dll_filename,'ENsetreport','DIAMETERS yes');
calllib(dll_filename,'ENsetreport','QUALITY no');
calllib(dll_filename,'ENsetreport','ELEVATION yes');
calllib(dll_filename,'ENsetreport','LENGTH yes');
calllib(dll_filename,'ENsetreport','F-FACTOR yes');
calllib(dll_filename,'ENsaveinpfile',fullpath.new_inp);
calllib(dll_filename,'ENreport');
calllib(dll_filename,'ENclose');

% opening file to add content
fid = fopen(fullpath.report_UPstream,'r+');
line(1,:)='******************************************************************';
line(2,:)='*                        U P S t r e a m                         *';
line(3,:)='* Automated Hydraulic Design of Pressurized Water Supply Networks*';
line(4,:)='*           (Based on EPANET 2.0 Computational Engine)           *';
line(5,:)='*            Stergios Emmanouil and Andreas Langousis            *';
line(6,:)='*                Department of Civil Engineering                 *';
line(7,:)='*                 University of Patras, Greece                   *';
line(8,:)='******************************************************************';
for i=1:8
    fprintf(fid,'%s\r\n',line(i,:));
end
fclose(fid);

% adding comments for pressure constraints and possibly unsolvable network
clear line
line='---------------------------------------------------------------------------';
fid = fopen(fullpath.report_UPstream,'a+');
if flag_unsolvable==0
    commentunsolv=sprintf('%s%d%s','Network successfully designed for minimum pressure pmin = ',...
        pmin,' m at all network nodes.');
    fprintf(fid,'%s\r\n',line);
    fprintf(fid,'%s\r\n',' ');
    fprintf(fid,'%s\r\n',commentunsolv);
    fprintf(1,'%s\r\n',commentunsolv);
elseif flag_unsolvable==1
    commentunsolv=sprintf('%s%d%s%d%s','Warning: Maximum number n = ',...
        ittermax,' of successive itterations at node ',i+tanks,' exceeded.');
    commentunsolv1=sprintf('%s','Minimum pressure constraint pmin = 0 at all network nodes is not met.');
    fprintf(fid,'%s\r\n',line);
    fprintf(fid,'%s\r\n',' ');
    fprintf(fid,'%s\r\n',commentunsolv);
    fprintf(fid,'%s\r\n',commentunsolv1);
    fprintf(1,'%s\r\n',commentunsolv);
    fprintf(1,'%s\r\n',commentunsolv1);
else
    commentunsolv=sprintf('%s%d%s%d%s','Warning: Maximum number n = ',...
        ittermax,' of successive itterations at node ',i+tanks,' exceeded.');
    commentunsolv1=sprintf('%s%d%s','Minimum pressure constraint pmin = ',...
        pmin,' m at all network nodes is not met.');
    fprintf(fid,'%s\r\n',line);
    fprintf(fid,'%s\r\n',' ');
    fprintf(fid,'%s\r\n',commentunsolv);
    fprintf(fid,'%s\r\n',commentunsolv1);
    fprintf(1,'%s\r\n',commentunsolv);
    fprintf(1,'%s\r\n',commentunsolv1);
end
fclose(fid);

% adding license boilerplate notice 
clear line
line='------------------------------------------------------------------------------';
fid = fopen(fullpath.report_UPstream,'a+');
fprintf(fid,'%s\r\n',' ');
fprintf(fid,'%s\r\n',line);
fprintf(fid,'%s\r\n',' ');
clear line
line(1,:)='Copyright 2017 Stergios Emmanouil and Andreas Langousis                           ';
line(2,:)='                                                                                  ';
line(3,:)='Licensed under the Apache License, Version 2.0 (the "License");                   ';
line(4,:)='you may not use this file except in compliance with the License                   ';
line(5,:)='You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0';
line(6,:)='Unless required by applicable law or agreed to in writing, software               ';
line(7,:)='distributed under the License is distributed on an "AS IS" BASIS,                 ';
line(8,:)='WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.          ';
line(9,:)='See the License for the specific language governing permissions and               ';
line(10,:)='limitations under the License.                                                    ';
for i=1:8
    fprintf(fid,'%s\r\n',line(i,:));
end
clear line
fclose(fid);


    