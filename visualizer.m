% Load data
data = load('data/1grun.mat');
ts = data.ans;

positions = ts.Data;  % [51 x 2 x 7632]
time = ts.Time;       % [7632 x 1]

% Parameters
fps = 60;                      % desired playback frame rate
dt_uniform = 1 / fps;          % uniform time step
time_uniform = (time(1):dt_uniform:time(end))';  % resampled timeline

numParticles = size(positions, 1);
numUniform = length(time_uniform);

% Preallocate interpolated positions
interpPos = zeros(numParticles, 2, numUniform);

% Interpolate each (x,y) for each particle
for i = 1:numParticles
    x = squeeze(positions(i,1,:));  % [7632 x 1]
    y = squeeze(positions(i,2,:));
    interpPos(i,1,:) = interp1(time, x, time_uniform, 'linear');
    interpPos(i,2,:) = interp1(time, y, time_uniform, 'linear');
end

redIndices = [1];  % example: particles 1, 3, and 5 are red
numParticles = size(positions, 1);

% Create color matrix: default all blue
colors = repmat([0 0 1], numParticles, 1);  % RGB for blue

% Set specific particles to red
colors(redIndices, :) = repmat([1 0 0], length(redIndices), 1);  % RGB for red

% --- Initial plot
figure;
b = 19;
c = [5,5];
h = scatter(interpPos(:,1,1), interpPos(:,2,1), 20, colors, 'filled');
axis equal;
xlim(c + [-b b]);
ylim(c + [-b b]);

% --- Animation loop
for t = 2:numUniform
    h.XData = interpPos(:,1,t);
    h.YData = interpPos(:,2,t);
    title(sprintf('Time: %.3f s', time_uniform(t)));
    pause(dt_uniform);
end