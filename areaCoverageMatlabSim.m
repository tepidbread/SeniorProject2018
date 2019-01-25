%function areaCoverageAdJo_V2()
close all
clear 
clc

area = [0,5,5,0;
        0, 0, 5,5];  % [m]; vertices of area 
agents = [1,   4, 3.25;
          2.5, 3, 0.75]; % [m] agents position in cm
      
gridSize = 0.05; % [m]; grid size of the area 
 
t = 0;  % [s] Time variable
Ts = 0.5; % [s] Simulation time 
Tf = 20; % [s] Final Simulation time
Ti = Tf/Ts; % Time used in indexing
Vk = 0.25; % [m/s] Velocity of agents - NOTE: the speed is much higher than it 
%                                          will be in implementation for 
%                                          simulation purposes

% %%=================== 3D video of risk density function =================%%
% vid = VideoWriter('videos/3DPhi.avi');
% vid.Quality = 100;
% vid.FrameRate = 5;
% open(vid);
% %%=======================================================================
%%=========================================================================
q = 1; % Variables used to index in for loops
r = 1;
s = 1;

yy = min(area(2,:)):gridSize:max(area(2,:));
xx = min(area(1,:)):gridSize:max(area(1,:));

sigma = 0.35; % Density factor 
n = 3; % number of agents
alpha = 5; % Scaling variable used in sensor function
beta = 0.5; % Scaling variable used in sensor function

qBar = [2.5, 4,    1.5; 
        4,   0.75, 1];    

positions(1,:) = [agents(1,1), agents(2,1)];
positions(2,:) = [agents(1,2), agents(2,2)];
positions(3,:) = [agents(1,3), agents(2,3)];

gridArray = zeros(1,2);
for i=1:length(xx)
    gridArray = [gridArray;repmat(xx(i),length(yy),1),yy'];     
end

gridArray = gridArray(2:end,:);

phi = getDensity(gridArray,qBar,sigma); % Phi function to calculate density

gridArrayDensity = [gridArray phi];

figure (1) %Plotting the Coverage metric
xlabel('Time [s]','Interpreter','latex','fontsize',14);
ylabel('Coverage','Interpreter','latex','fontsize',14);
hold on


figure (2) %Plotting the agents moving to modified centroids

for t = 0:Ts:Tf % Main timing loop 
   
    agents = [positions(1,1), positions(2,1), positions(3,1);
              positions(1,2), positions(2,2), positions(3,2)];
    
    %======================================================================
    %======================================================================
    for i=1:size(gridArray,1)
        dist2Agent1(i) = sqrt(((gridArray(i,1) - agents(1,1))^2) + ((gridArray(i,2) - agents(2,1))^2));
        dist2Agent2(i) = sqrt(((gridArray(i,1) - agents(1,2))^2) + ((gridArray(i,2) - agents(2,2))^2));
        dist2Agent3(i) = sqrt(((gridArray(i,1) - agents(1,3))^2) + ((gridArray(i,2) - agents(2,3))^2)); 
        
        %For V1
        if ((dist2Agent1(i) < dist2Agent2(i)) && (dist2Agent1(i) < dist2Agent3(i))) 
            index(i) = 1; 
            tempPointsV1(i,:) = gridArray(i,:);
        end
        %For V2
        if ((dist2Agent2(i) < dist2Agent1(i)) && (dist2Agent2(i) < dist2Agent3(i))) 
            index(i) = 2;
            tempPointsV2(i,:) = gridArray(i,:);
        end     
        %For V3
        if ((dist2Agent3(i) < dist2Agent1(i)) && (dist2Agent3(i) < dist2Agent2(i))) 
            index(i) = 3;
            tempPointsV3(i,:) = gridArray(i,:);
        end     
                      
    end
    %======================================================================
    %======================================================================
    for i = 1:size(tempPointsV1)
        %==================================================================
        if (index(i) == 1)
           r_i_1(q) = sqrt(((gridArrayDensity(i,1) - agents(1,1))^2) + ((gridArrayDensity(i,2) - agents(2,1))^2));
           f_r1(q) = alpha * exp(-beta*(r_i_1(q)^2));
           pointDensityV1(q,:) = gridArrayDensity(i,:);
           q = q+1;
        end
    end 
    for i = 1:size(tempPointsV2)
        %==================================================================
        if (index(i) == 2)
           r_i_2(r) = sqrt(((gridArrayDensity(i,1) - agents(1,2))^2) + ((gridArrayDensity(i,2) - agents(2,2))^2));
           f_r2(r) = alpha * exp(-beta*(r_i_2(r)^2));
           pointDensityV2(r,:) = gridArrayDensity(i,:);
           r = r+1;
        end
    end
    for i = 1:size(tempPointsV3)
        %==================================================================
        if (index(i) == 3)
           r_i_3(s) = sqrt(((gridArrayDensity(i,1) - agents(1,3))^2) + ((gridArrayDensity(i,2) - agents(2,3))^2));
           f_r3(s) = alpha * exp(-beta*(r_i_3(s)^2));
           pointDensityV3(s,:) = gridArrayDensity(i,:);
           s = s+1;
        end
    end 
    q = 1; % Resetting looping variables 
    r = 1;
    s = 1;
    %======================================================================
    %======================================================================
    phiV1 = pointDensityV1(:,3);
    phiV2 = pointDensityV2(:,3);
    phiV3 = pointDensityV3(:,3);
    %======================================================================
    Mv_1 = sum(phiV1);
    Mv_2 = sum(phiV2);
    Mv_3 = sum(phiV3);
    %For V1
    xCv_1 = sum(pointDensityV1(:,1) .* phiV1)/(Mv_1);
    yCv_1 = sum(pointDensityV1(:,2) .* phiV1)/(Mv_1);
    %For V2
    xCv_2 = sum(pointDensityV2(:,1) .* phiV2)/(Mv_2);
    yCv_2 = sum(pointDensityV2(:,2) .* phiV2)/(Mv_2);
    %For V3
    xCv_3 = sum(pointDensityV3(:,1) .* phiV3)/(Mv_3);
    yCv_3 = sum(pointDensityV3(:,2) .* phiV3)/(Mv_3);

    cent1 = [xCv_1, yCv_1];
    cent2 = [xCv_2, yCv_2];
    cent3 = [xCv_3, yCv_3];

    %======================================================================
    %======================================================================  
        
    H1 = sum((f_r1) * phiV1);
    H2 = sum((f_r2) * phiV2);
    H3 = sum((f_r3) * phiV3);
    Hk = H1+H2+H3; % Total coverage at time instant 't'

    figure (1)
        plot(t, Hk, 'r.')
         xlim([0 Tf])
         ylim([0 4500]) 
    %======================================================================
    %====================================================================== 
    
    [directions(1,1), positions(1,:)] = moveAgent(positions(1,:),Ts, Vk, cent1);
    [directions(1,2), positions(2,:)] = moveAgent(positions(2,:),Ts, Vk, cent2);
    [directions(1,3), positions(3,:)] = moveAgent(positions(3,:),Ts, Vk, cent3);
   
    %======================================================================
    %====================================================================== 
    
    figure (2)
        %directions = zeros(1,n);
        %set(gca,'Color',[0.8,0.8,0.8]); % figure's background color
        xlabel('X [m]','Interpreter','latex','fontsize',14);
        ylabel('Y [m]','Interpreter','latex','fontsize',14);
        colormap(flipud(gray))
        caxis([0 1]);
        colorbar;
    
    %======================================================================
    %====================================================================== 
    
        %Plotting density points in time
        hold on
        scatter(gridArrayDensity(:,1), gridArrayDensity(:,2),10,gridArrayDensity(:,3),'filled');

        %Plotting the modified centroids in time
        plot(xCv_1, yCv_1,'bo')
        plot(xCv_2, yCv_2,'bo')
        plot(xCv_3, yCv_3,'bo')

        %Plotting the Voronoi regions in time
        regions = voronoi_andrew(area,agents);
        drawRegions(area,regions,directions);
       
    pause(Ts); % Outside range of real time operation already
    
    if (t < Tf)
        clf(2) %Clearing figure 2
    end
end

% aviobj = avifile('OUT/3DPhi.avi','compression','None','fps',10);%Address
% fig = figure;


% for var = 1:1:Ti
%     clf
%     contour3(gridArrayDensity(:,1),gridArrayDensity(:,2),gridArrayDensity(:,:,var),80)
%     axis ([min(x) max(x) min(y) max(y) 0 1.5])
%     xlabel('X [m]','Interpreter','latex','fontsize',14);
%     ylabel('Y [m]','Interpreter','latex','fontsize',14);
%     zlabel('Risk Density','Interpreter','latex','fontsize',14);
%     %colormap(cool(64)); % in cool colorbar
%     colormap(flipud(gray))
%     caxis([0 1]);
%     colorbar
%     F = getframe(fig);
%     writeVideo(vid,F);
% %     aviobj = addframe(aviobj,F);
%     
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%       FUNCTIONS USED IN CODE          %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function regionData = voronoi_andrew(bounds, points)
    % VORONOI   ordinary Voronoi partition generator
    %   VORONOI will take in a bounding region along with a set of generator
    %   points and produce the ordinary Voronoi partition defined by
    %       |q - p_i| <= |q - p_j|
    %   for all j ~= i.
    %
    %   ***** Inputs *****
    %   bounds - a 2 x n_b array specifying the positively oriented bounding
    %       polygon in 2D
    %   points - the 2 x n_p array specifying generator points.
    %
    %   ***** Outputs *****
    %   regionData - a n x 3 cell with:
    %       -- the {i,1} element containing generator point information, 
    %       -- the {i,2} element containing the arc information. For the
    %          ordinary Voronoi partition, this is always empty.
    %       -- the {i, 3} element containing edge segments. These are 
    %          oriented, and each row represents a segment:
    %          [x1, y1, x2, y2]
    %          And the region is always to the left of the vector from (x1, y1)
    %          to (x2, y2).

    n = size(points, 2);
    regionData = cell(n, 3);

    for i = 1:n
        p1 = points(:,i);
        regionData{i, 1} = p1;

        vi = bounds;
        for j = 1:n
            if (j ~= i)
                p2 = points(:, j);
                [s1, s2] = bisectPlane(p1, p2);
                vi = intersect_andrew(vi, s1(1:2), s2(1:2));
            end
        end

        % Create the edges from the polygon data
        edges = zeros(size(vi, 2), 4);
        vi = [vi, vi(:, 1)]';
        for j = 1:size(edges, 1)
            edges(j, :) = [vi(j, :), vi(j+1, :)];
        end
        regionData{i, 2} = [];
        regionData{i, 3} = edges;
    end
end
% Helper function to determine the bisection plane
function [segStart, segEnd] = bisectPlane(p1, p2)
    d = p2 - p1;
    c = [-d(2); d(1)];
    segStart = 0.5 * d + p1;
    segEnd = segStart + c;
end
function vertices = intersect_andrew(polygon, b0, b1)

    % INTERSECT    Geometric intersection of a polygon and halfplane
    %   ***** Inputs *****
    %   polygon - a 2 x n array defining the vertices of a polygon in 2D
    %   b0 - a point on the dividing line
    %   b1 - a second point on the dividing line.  The vector b1-b0 defines the
    %       intersecting halfplane.  The intersection of the ray with the
    %       polygon would define a new positvely oriented edge.  If the polygon
    %       is to the left of the ray, the intersection is the entire polygon.
    %       If the polygon is to the right of the ray, the intersection is the
    %       null set.
    %
    %   ***** Outputs *****
    %   vertices - the vertices of the intersection

    b0 = b0(:);
    b1 = b1(:);
    n = size(polygon, 2);
    if (n == 0)
        vertices = [];
        return;
    end

    % Determine which segments the halfplane intersects
    intersections = zeros(n, 1);
    newPoints = zeros(2, 1, n);
    for i = 1:n
        a0 = polygon(:, i);
        if (i == n)
            a1 = polygon(:, 1);
        else
            a1 = polygon(:, i+1);
        end
        [bool, pt] = isIntersect(a0, a1, b0, b1);
        if (bool)
            intersections(i) = 1;
            newPoints(:,:,i) = pt;
        end
    end

    % Now figure out which half of the polygon to cut.
    if (max(intersections) == 1)    % if the halfplane cuts thru the polygon
        intersectIndex = [0, 0]';
        ctr = 1;
        for i = 1:n
            if (intersections(i) == 1)
                intersectIndex(ctr) = i;
                ctr = ctr + 1;
            end
        end
        % Check positive orientation of the intersected points
        p1 = newPoints(:,:,intersectIndex(1));
        p2 = newPoints(:,:,intersectIndex(2));
        vec = p2 - p1;
        if ((vec' * (b1 - b0)) < 0) % in the wrong direction
            p1 = p2;
            p2 = newPoints(:,:,intersectIndex(1));
            temp = intersectIndex(1);
            intersectIndex(1) = intersectIndex(2);
            intersectIndex(2) = temp;
        end
        % Begin definition of new polygon starting with the cutting segment
        vertices = [p1, p2];
        polygon = circshift(polygon, [0, -intersectIndex(2)]);
        if (intersectIndex(2) > intersectIndex(1))
            cutSize = intersectIndex(2) - intersectIndex(1);
        else
            cutSize = intersectIndex(2) - intersectIndex(1) + n;
        end
        vertices(:, end+1:end+n-cutSize) = polygon(:, 1:n-cutSize);
    else
        % no intersection with polygon, but depending on orientation, the 
        % halfplane will either include or exclude the polygon.  Check using
        % cross-product.
        v1 = b1 - b0;
        for i = 1:n
            p = polygon(:,i) - b0;
            % c = cross(v1, p);
            c = v1(1)*p(2) - v1(2)*p(1);
            if (c < 0)
                vertices = [];
                return
            end
        end
        vertices = polygon;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function to detect intersection of a segment u0->u1 with a line
% v0->v1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bool, pt] = isIntersect(u0, u1, v0, v1)
    a1 = u1(1) - u0(1);
    a2 = u1(2) - u0(2);
    b1 = v1(1) - v0(1);
    b2 = v1(2) - v0(2);
    c1 = v0(1) - u0(1);
    c2 = v0(2) - u0(2);
    D = a2*b1 - a1*b2;
    if (D == 0)     % parallel lines
        bool = 0;
        pt = NaN;
        return;
    end
    t = -b2*c1/D + b1*c2/D;
    % s = -a2*c1/D + a1*c2/D
    % deal with numerical precision
    if (t < -eps(10) || t > 1 + eps(10))
        bool = 0;
        pt = 0;
    elseif (0<=t && t<=1)
        bool = 1;
        pt = u0 + (u1 - u0)*t;
    elseif (abs(t) <= eps(10))
        bool = 1;
        pt = u0;
    elseif (abs(1-t) <= eps(10))
        bool = 1;
        pt = u1;
    end
end 
function drawRegions(bounds, regionData, orientations)
    % DRAWREGIONS   Voronoi graphical realization
    %   This function will take in a set of generator points and regions and
    %   will draw the associated graph
    %   
    %   ***** Inputs *****
    %   bounds - the bounding positively oriented polygon
    %   regionData - the regions are a nx3 cell array with the {i,1} element 
    %       containing generator point information, the {i,2} element 
    %       containing the arc information, and the {i,3}
    %       containing edge segments (from intersections with the boundary)
    %
    %   Author: Andrew Kwok, University of California at San Diego
    %   Date: 17 August 2009

    n = size(regionData, 1);

    %hold on     %COMMENTED OUT 6/5/2018
    % Define agent label position
    delta = max(max(bounds(1,:)) - min(bounds(1,:)), ...
        max(bounds(2,:)) - min(bounds(2,:))) / 60;
    for i = 1:n
        pt = regionData{i, 1};
        arcs = regionData{i, 2};
        edges = regionData{i, 3};

        % Draw arcs and edges
        for j = 1:size(arcs, 1)
            drawArc(arcs(j, 1:2), arcs(j, 3), arcs(j, 4), arcs(j, 5));
        end
        for j = 1:size(edges, 1)
            line(edges(j, [1, 3]), edges(j, [2, 4]));
        end    
        % Plot the agent position
        [Xa,Ya] = plotUnicycle([pt;orientations(i)],axis(gca)); % DDMR => Differential drive mobile robot
        fill(Xa,Ya,'r');
        % lblintcpt = plot(pt(1), pt(2), 'r.', 'MarkerSize', 16);
        % Label the agent
        label = strcat(num2str(i));
        text(pt(1)+delta, pt(2)+delta, label);
    end

    % Plot the bounding polygon
    bounds(:, end+1) = bounds(:,1);
    lblbounds = plot(bounds(1,:), bounds(2,:), 'r', 'LineWidth', 2);

    % axis equal
    axis square
    xlim([min(bounds(1,:)-0.5),max(bounds(1,:)+0.5)]);
    ylim([min(bounds(2,:)-0.5),max(bounds(2,:)+0.5)]);
    xlabel('X [km]');
    ylabel('Y [km]');


    % legend([lblintcpt lblbounds], 'Interceptor', 'harbour boundary');
    grid on
    %axis off
    %hold off
end
function [X,Y] = plotUnicycle(Q,AX)
    % PLOT_UNICYCLE   Function that generates lines for plotting a unicycle.
    %
    %    PLOT_UNICYCLE(Q,AX) takes in the axis AX = axis(gca) and the unicycle
    %    configuration Q and outputs lines (X,Y) for use, for example, as:
    %       fill(X,Y,'b')
    %    This must be done in the parent script file.

    x     = Q(1);
    y     = Q(2);
    theta = Q(3);

    l1 = 0.02*max([AX(2)-AX(1),AX(4)-AX(3)]);
    X = [x,x+l1*cos(theta-2*pi/3),x+l1*cos(theta),x+l1*cos(theta+2*pi/3),x];
    Y = [y,y+l1*sin(theta-2*pi/3),y+l1*sin(theta),y+l1*sin(theta+2*pi/3),y];
end
function [newAgentDirection, newAgentPosition] = moveAgent(position,Ts, Vk, centroid)
    %This is a function that calculates the next position of an agent...
    %given the current pose of the agent and the corresponding centroid...
    %for the voronoi region.
    
    %centroid = centroid that the agent will move to [x y] [m]
    %Ts = time step of the simulation [s]
    %direction = current azimuth of the agent [rad] -pi:pi
    %position = current position of the agent [x y] [m]

    newAgentPosition = position + (Ts*Vk*((centroid - position)/norm(centroid - position)));
    newAgentDirection = atan2((centroid(2) - position(2)), (centroid(1) - position(1)));
    
end
function phi = getDensity(gridArray,qBar,sigma)

    phi = zeros(size(gridArray,1),1);
    dist = zeros(size(gridArray,1),2,size(qBar,2));
    tmp = zeros(size(gridArray,1),1,size(qBar,2));
        for i = 1:size(qBar,2)
        
        dist(:,:,i) = gridArray-qBar(:,i)';
        end
        
        for j = 1:size(qBar,2)
            for i = 1:size(gridArray,1)
                tmp(i,1,j) = exp((-0.5 * (norm(dist(i,:,j))/sigma)^2));
            end
        end
        phi = sum(tmp,3);
    
end
