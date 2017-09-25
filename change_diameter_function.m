function [D_new]=change_diameter_function(D_old)
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
% This function substitutes a selected pipe diameter by the next available
% one, in case the velocity or pressure constraints are not met
%
% Input:
% D_old: old pipe diameter in mm
% D_new: maximum velocity in mm/s

% incremental change by 10mm 
% (can be substituted by a table of market diameters)
D_new=D_old+10;


