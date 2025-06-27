function videoPath = main(args)
% MAIN Run Barnes-Hut simulation using provided args and return video path
% args - struct with fields:
%   SimType (string): Random (1 galaxy) / One Galaxy / Two Galaxies
%   Galaxy1Particles, Galaxy2Particles (int)
%   BlackHole1, BlackHole2 (int)
%   SimulationTime (int)
%   Backend (string): C++ MEX / MATLAB / Simulink StateFlow
%   ViewBoxes (logical)

% Set random seed for reproducibility
rng('shuffle');

% Create a unique filename for output
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
videoName = sprintf('BarnesHut_%s_%s.mp4', args.Backend, timestamp);
videoPath = fullfile(tempdir, videoName);

% Save a global video writer so each driver can access
global videoWriter
videoWriter = VideoWriter(videoPath, 'MPEG-4');
videoWriter.FrameRate = 60;
open(videoWriter);

% Set simulation parameters globally for driver access
global simArgs
simArgs = args;

% Dispatch to backend
switch lower(strrep(args.Backend, ' ', ''))
    case 'c++mex'
        driverMEX;
    case 'matlab'
        driverMATLAB;
    case 'simulinkstateflow'
        driverSimulink;
    otherwise
        error('Unsupported backend: %s', args.Backend);
end

close(videoWriter);
end
