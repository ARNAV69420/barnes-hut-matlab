function drawTree(node)
    if isempty(node)
        return;
    end

    % Draw the bounding box
    x_min = node.bounds(1,1);
    x_max = node.bounds(1,2);
    y_min = node.bounds(2,1);
    y_max = node.bounds(2,2);
    rectangle('Position', [x_min, y_min, x_max - x_min, y_max - y_min], ...
              'EdgeColor', 'k');

    % Recursively draw children
    for i = 1:4
        if ~isempty(node.children{i})
            drawTree(node.children{i});
        end
    end
end


% Constants
N = 100;                            % Number of orbiting particles
G = 1e-2;                           % Gravitational constant
dt = 0.001;                          % Time step
T = 5;                              % Total simulation time
steps = round(T/dt);
theta = 0.5;                        % Barnes-Hut opening angle
eps = 1e-2;                         % Softening factor

center = [0.5, 0.5];
bh_mass = 1000;                     % Central massive body
bounds = [0 1; 0 1];                % Simulation region

% Central black hole particle (ID 0)
particles = [center, 0, 0, bh_mass, 0];

% Circular particle distribution
rng(1);
radii = 0.05 + 0.4 * sqrt(rand(N,1));           % Concentrated near center
angles = 2 * pi * rand(N,1);
positions = center + [cos(angles), sin(angles)] .* radii;

% Tangential velocities for circular orbit
r_vec = positions - center;
r_norm = vecnorm(r_vec, 2, 2);
tangent = [-r_vec(:,2), r_vec(:,1)] ./ r_norm;
speeds = sqrt(G * bh_mass ./ (r_norm + eps));
velocities = tangent .* speeds;

% Add orbiting particles
masses = 0.5 + rand(N,1);  % Small body masses
ids = (1:N)';
particles = [particles; [positions, velocities, masses, ids]];

% Set up figure
figure;
axis equal;
xlim([0 1]); ylim([0 1]);
hold on;

for t = 1:steps
    clf;
    axis equal;
    xlim([0 1]); ylim([0 1]);
    hold on;

    % Build Barnes-Hut tree
    root = BHTreeNode(bounds);
    for i = 1:size(particles,1)
        root.insert(particles(i,[1,2,5,6]));
    end

    % Update each particle except black hole
    for i = 2:size(particles,1)
        body = particles(i,[1,2,5,6]); % [x y mass id]
        F = root.computeForceOn(body, theta, G, eps);

        a = F / body(3); % acceleration
        particles(i,3:4) = particles(i,3:4) + a * dt;           % update velocity
        particles(i,1:2) = particles(i,1:2) + particles(i,3:4) * dt; % update position
    end

    % Draw all particles
    scatter(particles(1:end,1), particles(1:end,2), 10, 'r', 'filled'); % stars

    drawTree(root);
    drawnow;
end
