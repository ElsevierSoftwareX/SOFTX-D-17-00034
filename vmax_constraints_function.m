function [vmax]=vmax_constraints_function(diameter)
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
% This function sets the maximum velocity constraint as a function of pipe
% diameter
%
% Input:
% diameter: pipe diameter in mm
% vmax: maximum velocity in m/s

% Based on Greek standards/regulations
if diameter<=125                    
    vmax=1.55;
    elseif diameter<=175
        vmax=1.85;
    elseif diameter<=350
        vmax=2.00;
    elseif diameter<=450                    
        vmax=2.10;
    elseif diameter<=600
        vmax=2.20;
    elseif diameter<=800
        vmax=2.30;
    elseif diameter<=1000
        vmax=2.40;
    else
        vmax=2.50;
end
