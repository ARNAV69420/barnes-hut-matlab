classdef GalaxyPreset
    properties
        G double
        dt double
        T double
        eps double
        theta double

        particles double   % [x, y, mass, id]
        velocities double  % [vx, vy] for each non-central particle
        masses double      % star masses (excluding black hole)
    end

    methods (Static)
        function preset = loadpreset(name)
            switch lower(name)
                case {'1g', 'single'}
                    preset = GalaxyPreset.load('data/1g.mat');
                case {'2g', 'double'}
                    preset = GalaxyPreset.load('data/2g.mat');
                case {'random'}
                    preset = GalaxyPreset.generateRandom();
                otherwise
                    error("Unknown preset: %s", name);
            end
        end

        function save(preset, filename)
            data = struct();
            data.G = preset.G;
            data.dt = preset.dt;
            data.T = preset.T;
            data.eps = preset.eps;
            data.theta = preset.theta;
            data.particles = preset.particles;
            data.velocities = preset.velocities;
            data.masses = preset.masses;
            save(filename, '-struct', 'data');
        end

        function preset = load(filename)
            data = load(filename);
            preset = GalaxyPreset();
            preset.G = data.G;
            preset.dt = data.dt;
            preset.T = data.T;
            preset.eps = data.eps;
            preset.theta = data.theta;
            preset.particles = data.particles;
            preset.velocities = data.velocities;
            preset.masses = data.masses;
        end

        function preset = generateRandom()
            % Simulation parameters
            G = 0.01;
            dt = 0.0001;
            T = 5;
            eps = 0.01;
            theta = 0.5;
        
            N = 50;  % Number of particles
        
            % Black hole (central particle, can be low mass here)
            bh_pos = [0.5, 0.5];
            bh_mass = 1000;
            bh_id = 0;
            particles = [bh_pos, bh_mass, bh_id];
        
            % Random particle positions, velocities, masses
            rng('shuffle');
            positions = rand(N, 2);              % [0,1] positions
            masses = 1 + 9 * rand(N,1);          % masses in [1,10]
            velocities = 0.5 * (rand(N,2) - 0.5);% small random velocities
            ids = (1:N)';
        
            % Append to particles matrix
            particles = [particles; [positions, masses, ids]];
        
            % Construct preset object
            preset = GalaxyPreset();
            preset.G = G;
            preset.dt = dt;
            preset.T = T;
            preset.eps = eps;
            preset.theta = theta;
            preset.particles = particles;
            preset.velocities = velocities;
            preset.masses = masses;
        end
    end
end