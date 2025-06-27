% Load data
data = load('data/2grun.mat');
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

for i = 1:numParticles
    x = squeeze(positions(i,1,:));
    y = squeeze(positions(i,2,:));
    interpPos(i,1,:) = interp1(time, x, time_uniform, 'linear');
    interpPos(i,2,:) = interp1(time, y, time_uniform, 'linear');
end

% Color setup
redIndices = [1, 2];  % mark specific particles red
colors = repmat([0 0 1], numParticles, 1);  % default: blue
colors(redIndices, :) = repmat([1 0 0], numel(redIndices), 1);  % red

% Create video writer
video = VideoWriter('galaxy_simulation.mp4', 'MPEG-4');
video.FrameRate = fps;
open(video);

% Setup figure
figure;
b = 19;
c = [5,5];
h = scatter(interpPos(:,1,1), interpPos(:,2,1), 20, colors, 'filled');
axis equal;
xlim(c + [-b b]);
ylim(c + [-b b]);

% --- Animation & Recording ---
for t = 2:numUniform
    h.XData = interpPos(:,1,t);
    h.YData = interpPos(:,2,t);
    title(sprintf('Time: %.3f s', time_uniform(t)));

    drawnow;  % Update figure
    frame = getframe(gcf);
    writeVideo(video, frame);
end

% Close video
close(video);

 