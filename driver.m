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

    % Draw the body if it exists
    if ~isempty(node.body)
        plot(node.body(1), node.body(2), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
    end

    % Recursively draw children
    for i = 1:4
        if ~isempty(node.children{i})
            drawTree(node.children{i});
        end
    end
end



% Constants
N = 50;                     % Number of particles
bounds = [-100 100; -100 100];        % Simulation region
G = - 1;                      % Gravitational constant
dt = 0.01;                  % Time step
T = 2.0;                    % Total simulation time
steps = round(T/dt);
theta = 0.5;                % Barnes-Hut opening angle
eps = 1e-3;                 % Softening factor to avoid singularities

% Initialize particles: [x y vx vy mass id]
positions = rand(N,2);
velocities = 0.001 * (rand(N,2) - 0.5);
masses = 0.5 + rand(N,1);  % Between 0.5 and 1.5
ids = (1:N)';
particles = [positions, velocities, masses, ids];


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
    for i = 1:N
        root.insert(particles(i,[1,2,5,6]));
    end

    % Update each particle
    for i = 1:N
        body = particles(i, [1,2,5,6]); % [x y mass id]
        F = root.computeForceOn(body, theta, G, eps);

        a = F / body(3); % acceleration
        particles(i,3:4) = particles(i,3:4) + a * dt;           % update velocity
        particles(i,1:2) = particles(i,1:2) + particles(i,3:4) * dt; % update position
    end

    % Draw particles
    scatter(particles(:,1), particles(:,2), 10, 'r', 'filled');

    % Optional: draw tree
    drawTree(root);

    drawnow;
end
