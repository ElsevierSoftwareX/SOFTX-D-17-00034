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
% Relevant functions: 
% vmax_constraints_function.m
% change_diameter_function.m

%% %%%%%% Not be altered below, unless needed (experienced users) %%%%%%%%%
% opening input and output/report files
calllib(dll_filename,'ENopen',fullpath.inp,fullpath.report_epanetengine,...
    fullpath.output_bin); 

% counting all nodes/junctions in the network.
nodes=single(0);                                                                
countcode=int32(0);
[errcode,nodes]=calllib(dll_filename,'ENgetcount',countcode,nodes);

% counting all tanks in the network. 
tanks=single(0);
countcode=int32(1);
[errcode,tanks]=calllib(dll_filename,'ENgetcount',countcode,tanks);                            

% counting all links/pipes in the network.
links=single(0);
countcode=int32(2);
[errcode,links]=calllib(dll_filename,'ENgetcount',countcode,links);   

% creating tables that contain the starting (From) and ending (To)
% nodes/junctions of all links/pipes, pipe diameters (D), pipe lengths (L), 
% and hydraulic heads (HH) at nodes/junctions. 
To=zeros(1,links);
From=zeros(1,links);
D=zeros(1,links); 
N=zeros(1,links);
HH=zeros(1,nodes);
L=zeros(1,links);
for i=1:links % filling corresponding tables
    fromnode=int32(0);                                                          
    tonode=int32(0);                                                            
    index=int32(i);
    [errcode,fromnode,tonode]=calllib(dll_filename,'ENgetlinknodes',...
        index, fromnode, tonode);
    From(1,i)=fromnode;
    To(1,i)=tonode;
    N(1,i)=i;
    length=single(0);
    link_index=int32(i);
    paramcode=int32(1);
    [errcode,length]=calllib(dll_filename,'ENgetlinkvalue',link_index,...
        paramcode,length);
    L(1,i)=length;
end

%% Resolving the network using velocity constraints (links)
sum=1;                                
while sum>0
    sum=0;
    % solving the network
    calllib(dll_filename,'ENsolveH');
    min_D=100000; % set initial minimum diameter to a large number
    
    for i=1:links % 2nd loop
        % retrieving diameter of link i
        diameter=single(0);
        index=int32(i);
        paramcode=int32(0);
        [errcode,diameter]=calllib(dll_filename,'ENgetlinkvalue',...
            index,paramcode,diameter);
        
        % calculating maximum velocity as a function of diameter 
        vmax=vmax_constraints_function(diameter);
        
        % retrieving velocity in link i
        velocity=single(0);
        index=int32(i);
        paramcode=int32(9);
        [errcode,velocity]=calllib(dll_filename,'ENgetlinkvalue',index,...
            paramcode,velocity);
        
        % identifying the smallest diameter in the network that does not 
        % meet the maximum velocity constraints
        if (velocity>vmax)&&(diameter<min_D)
           min_D=diameter;
           min_index=i;
           sum=1;
        end
    end
    % increasing the smallest diameter in the network that does not 
    % meet the maximum velocity constraints
    if sum==1 
       diameter=single(0);
       index=int32(min_index);
       paramcode=int32(0);
       [errcode, diameter]=calllib('epanet2','ENgetlinkvalue',index,...
           paramcode, diameter);
       % incremental increase of link/pipe diameter
       diameter_new=change_diameter_function(diameter);
       % updating link diameter
       index=int32(min_index);
       paramcode=int32(0);
       calllib(dll_filename,'ENsetlinkvalue',index,paramcode,...
           diameter_new);
    end
    
end

    
%% Resolving the network for zero pressure constraint at all nodes 
sum=0;
indexnode_break=[0,0];
flag_unsolvable=0; 
while sum<nodes
    sum=0;
    maxtan=-1000;
    % solving the network
    calllib(dll_filename,'ENsolveH');

    % creating table of hydraulic heads
    for i=1:nodes
        head=single(0);
        node_index=int32(i);
        paramcode=int32(10);
        [errcode,head]=calllib(dll_filename,'ENgetnodevalue',node_index,...
            paramcode,head);
        HH(1,i)=head;
    end

    % When node i exhibits negative pressure, change those links ending
    % at i, starting with those displaying the largest hydraulic head 
    % gradient
    for i=1:nodes
        pressure=single(0);
        node_index=int32(i);
        paramcode=int32(11);
        [errcode, pressure]=calllib('epanet2','ENgetnodevalue',node_index, paramcode, pressure);
        if pressure<0
            maxtan=-1000;
            for k=1:links
                to_index=To(1,k);
                from_index=From(1,k);                
                h_from=HH(1,from_index);              
                h_to=HH(1,to_index);                
                flow=single(0);
                index=int32(k);
                paramcode=int32(8);
                [errcode, flow]=calllib('epanet2','ENgetlinkvalue',index, paramcode, flow);
                if ((To(1,k)==i)&&(flow>=0))||((From(1,k)==i)&&(flow<=0))
                    length=L(1,k);                        
                    head_tan=abs((h_from-h_to)/length);
                    if head_tan>maxtan
                        link_index=k;                   
                        maxtan=head_tan;
                    end
                end
            end

            % retrieving diameter of link i
            diameter=single(0);
            index=int32(link_index);
            paramcode=int32(0);
            [errcode, diameter]=calllib(dll_filename,'ENgetlinkvalue',...
                index,paramcode,diameter);

            % incremental increase of link/pipe diameter
            diameter_new=change_diameter_function(diameter);
            % updating link diameter
            index=int32(link_index);
            paramcode=int32(0);
            calllib(dll_filename,'ENsetlinkvalue',index,...
                paramcode,diameter_new);
            
            % checking maximum number of successive iterrations
            if indexnode_break(1,1)==i
               indexnode_break(1,2)=indexnode_break(1,2)+1;
               if indexnode_break(1,2)>ittermax
                   % flag for unsolvable network for zero pressures
                   flag_unsolvable=1; 
               end
            else
                indexnode_break=[i,1];
            end
            break
        else
            sum=sum+1;
        end
    end
    if flag_unsolvable==1;
        break
    end
end

%% Resolving the network in case of minimum pressure requirement pmin>0
if pmin>0 && flag_unsolvable==0 
    sum=0;
    indexnode_break=[0,0];
    % isolating reservoirs and tanks, where node pressure==0
    while sum<(nodes-tanks) 
        sum=0;
        maxtan=-1000;
        % solving the network
        calllib(dll_filename,'ENsolveH');

        % creating table of hydraulic heads
        for i=1:nodes
            head=single(0);
            node_index=int32(i);
            paramcode=int32(10);
            [errcode,head]=calllib(dll_filename,'ENgetnodevalue',node_index,...
                paramcode,head);
            HH(1,i)=head;
        end

        % When node i exhibits pressure<pmin, change those links ending
        % at i, starting with those displaying the largest hydraulic head 
        % gradient
        for i=1:(nodes-tanks)
            pressure=single(0);
            node_index=int32(i);
            paramcode=int32(11);
            [errcode, pressure]=calllib('epanet2','ENgetnodevalue',node_index, paramcode, pressure);
            if pressure<pmin
                maxtan=-1000;
                for k=1:links
                    to_index=To(1,k);
                    from_index=From(1,k);                
                    h_from=HH(1,from_index);              
                    h_to=HH(1,to_index);                
                    length=L(1,k);                        
                    head_tan=abs((h_from-h_to)/length);
                    flow=single(0);
                    index=int32(k);
                    paramcode=int32(8);
                    [errcode, flow]=calllib('epanet2','ENgetlinkvalue',index, paramcode, flow);
                    if ((To(1,k)==i)&&(flow>=0))||((From(1,k)==i)&&(flow<=0))
                        length=L(1,k);                        
                        head_tan=abs((h_from-h_to)/length);
                        if head_tan>maxtan
                            link_index=k;                   
                            maxtan=head_tan;
                        end
                    end
                    if (From(1,k)==i)&&(flow<=0)
                        if head_tan>maxtan
                            link_index=k;                   
                            maxtan=head_tan;
                        end
                    end
                end

                % retrieving diameter of link i
                diameter=single(0);
                index=int32(link_index);
                paramcode=int32(0);
                [errcode, diameter]=calllib(dll_filename,'ENgetlinkvalue',...
                    index,paramcode,diameter);

                % incremental increase of link/pipe diameter
                diameter_new=change_diameter_function(diameter);
                % updating link diameter
                index=int32(link_index);
                paramcode=int32(0);
                calllib(dll_filename,'ENsetlinkvalue',index,...
                    paramcode,diameter_new);
         
                % checking maximum number of successive iterrations
                if indexnode_break(1,1)==i
                   indexnode_break(1,2)=indexnode_break(1,2)+1;
                   if indexnode_break(1,2)>ittermax
                       % flag for unsolvable network for pmin pressures
                       flag_unsolvable=2; 
                   end
                else
                    indexnode_break=[i,1];
                end
                break
            else
                sum=sum+1;
            end
        end
        if flag_unsolvable==2;
            break
        end
    end
end
