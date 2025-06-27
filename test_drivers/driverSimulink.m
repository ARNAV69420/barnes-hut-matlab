preset = GalaxyPreset().loadpreset('1g');
open('generacion.slx');
sim('generacion','SimulationMode','accelerator');
% function driverSimulink
% % DRIVERSIMULINK Use Simulink model to run simulation
% global simArgs videoWriter
% 
% % Use appropriate preset
% preset = GalaxyPreset.singleGalaxy();
% if strcmp(simArgs.SimType, 'Two Galaxies')
%     preset = GalaxyPreset.doubleGalaxy();
% end
% 
% assignin('base', 'preset', preset);
% assignin('base', 'videoWriter', videoWriter);
% assignin('base', 'simArgs', simArgs);
% 
% open_system('generacion', 'loadonly');
% simOut = sim('generacion', 'SimulationMode', 'accelerator', ...
%     'StopTime', num2str(simArgs.SimulationTime));
% 
% % NOTE: Add frame capturing to 'generacion.slx' via To Video blocks or Simulink functions
% end
