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
% In this script:
% 1) The user specifies the name of the input file of the pipe network 
%    (e.g. example1), the minimum pressure requirement (pmin in m) at all 
%    network's nodes, and the maximum permissible number of successive 
%    itterations (ittermax) at each a node.
% 2) Saves the file.
% 3) Executes "UPStream_configure_and_execute.m" from MatLab's Command Window

clear % clearing workspace
%% To be set by the user
filename_inp='example2'; % name of the .inp file of the network
pmin=12; % minimum pressure requirement (in m) at all network's nodes
ittermax=20; % maximum permissible number of successive itterations at each 
             % node. If exceeded,the network is flagged as unsolvable, the 
             % program stops, and a message is placed on screen and at the 
             % end of the UPStream report file. The user should properly  
             % modify the network, or change the pmin constraint, and try
             % again.


%% %%%%%% Not be altered below, unless needed (experienced users) %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Setting paths and folders%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path_inp_root = './'; %main root path
folder_epanet_engine='epanet_engine'; %folder with epanet library
dll_filename='epanet2'; %filename of dll library
h_filename='epanet2.h'; % .h filename

% setting relevant paths
path_folder_out=[path_inp_root,filename_inp,'_UPStream'];
fullpath.inp=sprintf('%s%s%s',path_inp_root,filename_inp,['.inp']); %full path of the .inp input file
fullpath.dll=sprintf('%s%s%s%s',path_inp_root,folder_epanet_engine,['/'],dll_filename); %full path of the .dll file
fullpath.h=sprintf('%s%s%s%s',path_inp_root,folder_epanet_engine,['/'],h_filename); %full path of the .h file
fullpath.output_bin=sprintf('%s%s%s%s',path_folder_out,['/'],filename_inp,['_output.bin']); %full path of the .bin file (output)
fullpath.report_epanetengine=sprintf('%s%s%s%s',path_folder_out,['/'],filename_inp,['_report_EPAengine.txt']); %full path of the epanet engine report (output)
fullpath.report_UPstream=sprintf('%s%s%s%s',path_folder_out,['/'],filename_inp,['_report_UPStream.txt']); %full path of the UPstream report (output)
fullpath.new_inp=sprintf('%s%s%s%s',path_folder_out,['/'],filename_inp,['_new.inp']); %full path of the exported .inp file (output)
fullpath.UPstream_mat=sprintf('%s%s%s%s',path_folder_out,['/'],filename_inp,['_workspace.mat']); %full path of the exported .mat file (output)


% loading Epanet library
warning('off','MATLAB:loadlibrary:TypeNotFound') % setting dummy warning (i.e. not affecting execution) to state 'off'
loadlibrary(fullpath.dll,fullpath.h); 

%% creating new folder for output files
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(path_folder_out);

%% Executing UPstream main source code
UPstream_engine

%% generating UPstream report file
UPstream_report_gen

%% unloading library
unloadlibrary(dll_filename)

%% saving workspace
save(fullpath.UPstream_mat)
clear




