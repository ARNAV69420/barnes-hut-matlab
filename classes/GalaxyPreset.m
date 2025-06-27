classdef GalaxyPreset
    properties
        G double
        eps double
        theta double

        positions double   % [x, y]
        velocities double  % [vx, vy] for each non-central particle
        masses double      % star masses
        bounds double      % [xmin xmax; ymin ymax]
    end

    methods (Static)
        function preset = loadpreset(name)
            switch lower(name)
                case {'1g', 'single'}
                    preset = GalaxyPreset.singleGalaxy();
                case {'2g', 'double'}
                    preset = GalaxyPreset.doubleGalaxy();
                otherwise
                    error("Unknown preset: %s", name);
            end
        end

        function preset = singleGalaxy()
            preset = GalaxyPreset();
            preset.G = 0.5;
            preset.eps = 0.05;
            preset.theta = 0.5;
        
            N = 100;
            r_min = 2;   % Inner gap
            r_max = 5;   % Outer edge of the ring
        
            % Random radial distances and angles for a ring
            radius = sqrt(rand(N, 1) * (r_max^2 - r_min^2) + r_min^2);  % Uniform area distribution
            angle = 2 * pi * rand(N, 1);
        
            % Convert to cartesian positions
            x = radius .* cos(angle);
            y = radius .* sin(angle);
            preset.positions = [0 0;x, y];  % +1 central massive body
        
            % Circular velocity magnitude: v = sqrt(G * M / r) (we'll scale it)
            v = sqrt(preset.G * 1000 ./ radius);  % orbiting central mass (roughly)
            vx = -v .* sin(angle);
            vy = v .* cos(angle);
            preset.velocities = [0 0; vx, vy];
        
            preset.masses = [1000; ones(N, 1)];  % small stars + big central mass
            preset.bounds = [-50 50; -50 50];    % adjust view limits as needed 
        end

        function preset = doubleGalaxy()
            preset = GalaxyPreset();
            preset.G = 0.5;
            preset.eps = 0.05;
            preset.theta = 0.6;
        
            N = 100;
            r_min = 1.5;
            r_max = 3.5;
            centre1 = [0, 0];
            centre2 = [15, 10];
        
            % ---- First Galaxy ----
            radius1 = sqrt(rand(N, 1) * (r_max^2 - r_min^2) + r_min^2);
            angle1 = 2 * pi * rand(N, 1);
            x1 = radius1 .* cos(angle1);
            y1 = radius1 .* sin(angle1);
            pos1 = [x1, y1] + centre1;  % ✔️ Shift to galaxy 1 center
            v1_mag = sqrt(preset.G * 1000 ./ radius1);
            vx1 = -v1_mag .* sin(angle1);
            vy1 = v1_mag .* cos(angle1);
            vel1 = [vx1, vy1];
        
            % ---- Second Galaxy ----
            radius2 = sqrt(rand(N, 1) * (r_max^2 - r_min^2) + r_min^2);
            angle2 = 2 * pi * rand(N, 1);
            x2 = radius2 .* cos(angle2);
            y2 = radius2 .* sin(angle2);
            pos2 = [x2, y2] + centre2;  % ✔️ Shift to galaxy 2 center
            v2_mag = sqrt(preset.G * 1000 ./ radius2);
            vx2 = -v2_mag .* sin(angle2);
            vy2 = v2_mag .* cos(angle2);
            vel2 = [vx2, vy2];
        
            % ---- Central Bodies ----
            posCenter = [centre1; centre2];
            velCenter = [0, 0; 0, 0];
            massCenter = [1000; 1000];
        
            % ---- Combine All ----
            preset.positions = [posCenter; pos1; pos2];
            preset.velocities = [velCenter; vel1; vel2];
            preset.masses = [massCenter; ones(2*N, 1)];
            preset.bounds = [-2000 2000; -2000 2000];  % Adjusted bounds to match galaxy layout
        end
    end
end
