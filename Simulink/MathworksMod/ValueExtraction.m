% === Baseline Metrics Extraction Script ===
% Assumes wm1, wm2, wm3 and Vt1, Vt2, Vt3 are logged as "Structure with time"

genMetrics = struct();

for i = 1:3
    % Load rotor speed and voltage from workspace
    wm = evalin('base', sprintf('wm%d', i));
    Vt = evalin('base', sprintf('Vt%d', i));
    
    % Extract time and signal values
    t = wm.time;
    w = wm.signals.values;
    f = w * 60;  % Convert pu to Hz
    
    % Frequency Nadir (minimum frequency)
    f_nadir = min(f);
    
    % ROCOF: Rate of change of frequency (Hz/s)
    rocof = diff(f) ./ diff(t);
    rocof_max = max(abs(rocof));
    
    % Settling time: last time when deviation from steady state > 0.1%
    f_ss = f(end);
    idx = find(abs(f - f_ss) > 0.001 * f_ss);
    if ~isempty(idx)
        t_settle = t(max(idx));
    else
        t_settle = 0;
    end
    
    % Voltage Dip (difference from nominal 1 pu)
    v = Vt.signals.values;
    v_dip = 1 - min(v);

    % Store results
    genMetrics.(['Gen' num2str(i)]) = [f_nadir; rocof_max; t_settle; v_dip];
end

% Create table
rows = {'Frequency Nadir (Hz)', 'Max ROCOF (Hz/s)', 'Settling Time (s)', 'Voltage Dip (pu)'};
BaselineResults = table(genMetrics.Gen1, genMetrics.Gen2, genMetrics.Gen3, ...
                        'VariableNames', {'Gen1', 'Gen2', 'Gen3'}, ...
                        'RowNames', rows);

% Display result
disp('=== Baseline Frequency Performance Table ===');
disp(BaselineResults);

filename = 'FSIIncreasedGain200.xlsx';
writetable(BaselineResults, filename, 'WriteRowNames', true);

disp(['Baseline results exported to: ', filename]);