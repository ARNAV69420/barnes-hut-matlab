% Generate Single Galaxy preset and save as '1g.mat'

G = 0.01;
dt = 0.0001;
T = 0.01;
eps = 0.01;
theta = 0.5;
N = 50;

bh_mass = 1000;
bh_pos = [0.5, 0.5];
bh_id = 0;
particles = [bh_pos, bh_mass, bh_id];  % ID = 0

rng(1);
radii = 0.1 + 0.4 * sqrt(rand(N,1));
angles = 2 * pi * rand(N,1);
positions = [cos(angles), sin(angles)] .* radii + bh_pos;

masses = 1 + 9 * rand(N,1);
ids = (1:N)';

r_vec = positions - bh_pos;
r_norm = vecnorm(r_vec, 2, 2);
tangent = [-r_vec(:,2), r_vec(:,1)] ./ r_norm;
speeds = sqrt(G * bh_mass ./ r_norm);
velocities = tangent .* speeds;

particles = [particles; [positions, masses, ids]];
velocities = [0 0; velocities];  % Add black hole velocity explicitly

preset1 = GalaxyPreset();
preset1.G = G;
preset1.dt = dt;
preset1.T = T;
preset1.eps = eps;
preset1.theta = theta;
preset1.particles = particles;
preset1.velocities = velocities;
preset1.masses = [bh_mass; masses];  % Optional if you want masses aligned

GalaxyPreset.save(preset1, 'data/1g.mat');
%%
G = 0.01;
dt = 0.0001;
T = 0.01;
eps = 0.01;
theta = 0.5;

N1 = 50;     % Smaller galaxy
N2 = 100;    % Bigger galaxy

% Center positions — placed diagonally
galaxy1_center = [5, 15];  % top-left
galaxy2_center = [15, 5];  % bottom-right

bh_mass1 = 500;
bh_mass2 = 1000;

% Central black holes
particles = [
    galaxy1_center, bh_mass1, 0;
    galaxy2_center, bh_mass2, -1;
];

rng(2);

% Galaxy 1
radii1 = 0.5 + 1.5 * sqrt(rand(N1,1));
angles1 = 2 * pi * rand(N1,1);
pos1 = [cos(angles1), sin(angles1)] .* radii1 + galaxy1_center;

masses1 = 1 + 4 * rand(N1,1);
ids1 = (1:N1)';
rvec1 = pos1 - galaxy1_center;
rnorm1 = vecnorm(rvec1, 2, 2);
tangent1 = [-rvec1(:,2), rvec1(:,1)] ./ rnorm1;
speeds1 = sqrt(G * bh_mass1 ./ rnorm1);
vel1 = tangent1 .* speeds1;

% Galaxy 2
radii2 = 0.5 + 1.5 * sqrt(rand(N2,1));
angles2 = 2 * pi * rand(N2,1);
pos2 = [cos(angles2), sin(angles2)] .* radii2 + galaxy2_center;

masses2 = 1 + 4 * rand(N2,1);
ids2 = (N1+1:N1+N2)';
rvec2 = pos2 - galaxy2_center;
rnorm2 = vecnorm(rvec2, 2, 2);
tangent2 = [-rvec2(:,2), rvec2(:,1)] ./ rnorm2;
speeds2 = sqrt(G * bh_mass2 ./ rnorm2);
vel2 = tangent2 .* speeds2;

% Add diagonal approach velocities
dir = galaxy2_center - galaxy1_center;
dir = dir / norm(dir);
approach_speed = 0.05;
vel1 = vel1 + dir * approach_speed;
vel2 = vel2 - dir * approach_speed;

% Assemble everything
all_pos = [pos1; pos2];
all_masses = [masses1; masses2];
all_ids = [ids1; ids2];
all_velocities = [vel1; vel2];

particles = [particles; [all_pos, all_masses, all_ids]];

preset = GalaxyPreset();
preset.G = G;
preset.dt = dt;
preset.T = T;
preset.eps = eps;
preset.theta = theta;
preset.particles = particles;
preset.velocities = [0 0; 0 0; all_velocities];  % include 2 BHs
preset.masses = [bh_mass1; bh_mass2; all_masses];

GalaxyPreset.save(preset, 'data/2g.mat');


%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
