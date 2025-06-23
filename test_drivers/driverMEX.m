% Parameters
N = 100;                             % Number of orbiting particles
center_mass = 1000;                 % Central black hole mass
G = 0.1;                             % Gravitational constant
theta = 0.5;                         % Barnes-Hut opening angle
eps = 0.01;                          % Softening parameter
dt = 0.001;                          % Time step
T = 2.0;                             % Total time
steps = round(T / dt);

% Bounds of simulation
bounds = [-10 10; -10 10];           % [x_min x_max; y_min y_max]
center_pos = [0.001, 0.01];          % Central mass position

% Randomly distribute particles in a disk around center
rng(1); % Reproducibility
radii = 0.1 + 0.3 * sqrt(rand(N,1));
angles = 2 * pi * rand(N,1);
positions = [cos(angles), sin(angles)] .* radii + center_pos;

% Masses of orbiting particles
masses = 1 + rand(N,1);

% Compute initial tangential velocities for circular orbits
rvecs = positions - center_pos;
rnorms = vecnorm(rvecs, 2, 2);
tangents = [-rvecs(:,2), rvecs(:,1)] ./ rnorms;
speeds = sqrt(G * center_mass ./ rnorms);  % ✅ FIXED: no extra scaling
velocities = tangents .* speeds;

% Add central body at the beginning
positions = [center_pos; positions];
masses = [center_mass; masses];
velocities = [0 0; velocities];  % central mass is static

% Set up visualization
figure;
axis equal;
xlim([-1 1]); ylim([-1 1]);
hold on;

% Simulation loop
for step = 1:steps
    % Prepare preset struct for MEX
    preset = struct();
    preset.masses = masses;
    preset.bounds = bounds;
    preset.G = G;
    preset.eps = eps;
    preset.theta = theta;

    % Compute accelerations using Barnes-Hut MEX
    acc = acclFromPos_mex(positions, preset);

    % Euler integration
    velocities = velocities + dt * acc;
    positions = positions + dt * velocities;

    % Plot
    cla;
    scatter(positions(2:end,1), positions(2:end,2), 20, 'b', 'filled'); % orbiting particles
    plot(positions(1,1), positions(1,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % central mass
    title(sprintf('Step %d / %d', step, steps));
    drawnow;
end
