function drawAircraft(uu)
    % process inputs to function
    pn       = uu(1);       % inertial North position     
    pe       = uu(2);       % inertial East position
    pd       = uu(3);       % inertial Down    
    phi      = uu(7);       % roll angle         
    theta    = uu(8);       % pitch angle     
    psi      = uu(9);       % yaw angle     
    t        = uu(13);       % time

    % define persistent variables 
    persistent spacecraft_handle;
    persistent Vertices
    persistent Faces
    persistent facecolors
    
    % first time function is called, initialize plot and persistent vars
    if t==0
        figure(1), clf
        [Vertices, Faces, facecolors] = defineSpacecraftBody;
        spacecraft_handle = drawSpacecraftBody(Vertices,Faces,facecolors,...
                                               pn,pe,pd,phi,theta,psi,...
                                               []);
        title('Aircraft')
        xlabel('East')
        ylabel('North')
        zlabel('-Down')
        view(32,47)  % set the vieew angle for figure
        hold on
    % at every other time step, redraw base and rod
    else 
        drawSpacecraftBody(Vertices,Faces,facecolors,...
                           pn,pe,pd,phi,theta,psi,...
                           spacecraft_handle);
    end
end

%=======================================================================
% drawSpacecraft
%=======================================================================
function handle = drawSpacecraftBody(V,F,patchcolors,...
                                     pn,pe,pd,phi,theta,psi,...
                                     handle)
    V = rotate(V', -phi, -theta, -psi)';  % rotate, rotating inversely
    V = translate(V', pn, pe, pd)';  % translate 
    % transform vertices from NED to XYZ (for matlab rendering)
    R = [...
        0, 1, 0;...
        1, 0, 0;...
        0, 0, -1;...
        ];
    V = V*R;
    
    if isempty(handle)
        handle = patch('Vertices', V, 'Faces', F,...
            'FaceVertexCData',patchcolors,...
            'FaceColor','flat');
    else
        set(handle,'Vertices',V,'Faces',F);
        drawnow
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The rest should be done by students
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from vehicle frame to body frame
function XYZ=rotate(XYZ,phi,theta,psi)
    % define rotation matrix
    % rotation matrix about x-axis
    R_roll = [1 0 0; 0 cos(phi) sin(phi); 0 -sin(phi) cos(phi)];
    % rotation matrix about y-axis
    R_pitch = [cos(theta) 0 -sin(theta); 0 1 0; sin(theta) 0 cos(theta)];
    % rotation matrix about z-axis
    R_yaw = [cos(psi) sin(psi) 0; -sin(psi) cos(psi) 0; 0 0 1];
    % transformation matrix from vechicle frame to the body frame
    R_b_v = R_roll*R_pitch*R_yaw;
    % rotate vertices
    XYZ = R_b_v*XYZ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% translate vertices by pn, pe, pd
% from inertial frame to vehicle frame
function XYZ = translate(XYZ,pn,pe,pd)
    XYZ = XYZ + repmat([pn pe pd]', 1, 16); % 16 vertices for aircraft; translate each vertice one by one
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define spacecraft vertices and faces
function [V,F,colors] = defineSpacecraftBody()
    fuse_l1=1.5; % center of mass to tip of fuselage
    fuse_l2=1; % center of mass to widest part of fuselage
    fuse_l3=5; % center of mass to back of fuselage
    fuse_h=1;
    fuse_w=1;
    wing_l=2; % length of wing along fuselage
    wing_w=6; % wingspan
    tail_h=1;
    tailwing_l=1;
    tailwing_w=3;
    
    % Define the vertices (physical location of vertices
    V = [1.5 0 0; 1 0.5 -0.5; 1 -0.5 -0.5; 1 -0.5 0.5; 1 0.5 0.5; -5 0 0; 0 3 0; -2 3 0; -2 -3 0; 0 -3 0;
        -4 1.5 0; -5 1.5 0; -5 -1.5 0; -4 -1.5 0; -4 0 0; -5 0 -1]; % 16 vertices totally
    
    % define faces as a list of vertices numbered above
    F = [1 2 3 NaN; 1 3 4 NaN; 1 4 5 NaN; 1 2 5 NaN; 2 3 6 NaN; 3 4 6 NaN; 4 5 6 NaN;
        2 5 6 NaN; 7 8 9 10; 11 12 13 14; 6 15 16 NaN];
    
    % define colors for each face    
    myred = [1, 0, 0];
    mygreen = [0, 1, 0];
    myblue = [0, 0, 1];
    myyellow = [1, 1, 0];
    mycyan = [0, 1, 1];
    
    colors = [...
        mygreen;...  % front top
        mycyan;...  % front left
        myblue;...  % front bottom
        mycyan;...  % front right 
        mygreen;...  % main top 
        mycyan;...  % main left
        myblue;...  % main bottom 
        mycyan;...  % main right
        myred;...  % wings
        myred;...  % tailwing
        myyellow;...  % tailfin
        ];
end