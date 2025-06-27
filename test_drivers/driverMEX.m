% % Parameters
% preset = GalaxyPreset().loadpreset('2g');                         
% dt = 0.001;                          % Time step
% T = 2.0;                             % Total time
% steps = round(T / dt);
% positions = preset.positions;
% velocities = preset.velocities;
% 
% % Set up visualization
% figure;
% axis equal;
% % xlim([-1 1]); ylim([-1 1]);
% hold on;
% 
% % Simulation loop
% for step = 1:steps
%     % Prepare preset struct for MEX
%     pre = struct();
%     pre.masses = preset.masses;
%     pre.bounds = preset.bounds;
%     pre.G = preset.G;
%     pre.eps = preset.eps;
%     pre.theta = preset.theta;
% 
%     % Compute accelerations using Barnes-Hut MEX
%     acc = acclFromPos_mex(positions, pre);
% 
%     % Euler integration
%     velocities = velocities + dt * acc;
%     positions = positions + dt * velocities;
% 
%     % Plot
%     cla;
%     scatter(positions(2:end,1), positions(2:end,2), 20, 'b', 'filled'); % orbiting particles
%     plot(positions(1,1), positions(1,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % central mass
%     plot(positions(2,1), positions(2,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % central mass
%     title(sprintf('Step %d / %d', step, steps));
%     drawnow;
% end
function driverMEX
% DRIVERMEX Run simulation using Barnes-Hut MEX backend
global simArgs videoWriter

% Load preset
switch simArgs.SimType
    case 'Random (1 galaxy)'
        preset = GalaxyPreset.singleGalaxy();  % fall back to default
    case 'One Galaxy'
        preset = GalaxyPreset.singleGalaxy();
    case 'Two Galaxies'
        preset = GalaxyPreset.doubleGalaxy();
end

dt = 0.001;
T = simArgs.SimulationTime;  % in seconds
steps = round(T / dt);
positions = preset.positions;
velocities = preset.velocities;

% Plot setup
figure('Visible','off');
axis equal;
hold on;

for step = 1:steps
    
    pre = struct();
    pre.masses = preset.masses;
    pre.bounds = preset.bounds;
    pre.G = preset.G;
    pre.eps = preset.eps;
    pre.theta = preset.theta;

    acc = acclFromPos_mex(positions, pre);

    velocities = velocities + dt * acc;
    positions = positions + dt * velocities;
   

    cla;
    scatter(positions(2:end,1), positions(2:end,2), 20, 'b', 'filled');
    plot(positions(1,1), positions(1,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    if size(positions,1) > 2
        plot(positions(2,1), positions(2,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    end
    title(sprintf('Step %d / %d', step, steps));
    frame = getframe(gcf);
    writeVideo(videoWriter, frame);
end
close(gcf);
end
