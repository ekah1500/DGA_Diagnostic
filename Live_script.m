%[text]{"align":"center"} ## **`Taking Inputs`**
disp("===== DGA Calculator =====") %[output:3d5553b9]
h2 = input('H2(ppm) - Hydrogen: ');
ch4 = input('CH4(ppm) - Methane: ');
c2h6 = input('C2H6(ppm) - Ethane: ');
c2h4 = input('C2H4(ppm) - Ethylene: ');
c2h2 = input('C2H2(ppm) - Acetylene: ');
co = input('CO(ppm) - Carbon Monoxide: ');
co2 = input('CO2(ppm) - Carbon Dioxide: ');

%[text]{"align":"center"} ## **`Calculating Total Dissolved Combustible Gas`**

tdcg = h2 + ch4 + c2h6 + c2h4 + c2h2 + co;

fprintf('\n---> TDCG Assessment <---\n'); %[output:9d5dc1e6]
fprintf('Total Dissolved Combustible Gas (TDCG): %.2f ppm\n', tdcg); %[output:044e7bc4]

if tdcg < 720 %[output:group:44023141]
    fprintf('Status: Condition 1 (Healthy/Normal). Ratios may be unreliable.\n'); %[output:82078133]
elseif tdcg >= 720 && tdcg <= 1920
    fprintf('Status: Condition 2 (Caution). Monitor closely for gas increase.\n');
elseif tdcg > 1920 && tdcg <= 4630
    fprintf('Status: Condition 3 (High Risk)\n');
else
    fprintf('Status: Condition 4 (Excessive Decomposition - Immediate Action)\n');
end %[output:group:44023141]

%[text]{"align":"center"} ## **`Rogers Ratio Method`**

% Zero Handling + Ratio Calculation
r1 = NaN; r2 = NaN; r5 = NaN;

if c2h4 > 0, r1 = c2h2/c2h4; end % R1: Acetylene/Ethylene
if h2 > 0,   r2 = ch4/h2;   end % R2: Methane/Hydrogen
if c2h6 > 0, r5 = c2h4/c2h6; end % R5: Ethylene/Ethane

fprintf('\n---> Rogers Ratio Method Method <---\n') %[output:69eb918c]

% Display Ratio Calculations 
fprintf('\nCalculated Ratios:\n'); %[output:67d42bd2]
fprintf('R1 (C2H2/C2H4): %.2f\n', r1); %[output:4a0aed39]
fprintf('R2 (CH4/H2): %.2f\n', r2); %[output:17d29f0b]
fprintf('R5 (C2H4/C2H6): %.2f\n', r5); %[output:2a57dc1a]

%_______________________________________(Comparison Logic)_______________________________________   
%| Fault Type                                   | R1 (C₂H₂/C₂H₄) | R2 (CH₄/H₂) | R5 (C₂H₄/C₂H₆) |
%| -------------------------------------------- | -------------- | ----------- | -------------- |
%| Normal Condition                             | < 0.1          | 0.1 – 1.0   | < 1.0          |
%| Partial Discharge (PD)                       | < 0.1          | < 0.1       | < 1.0          |
%| High Energy Discharge (Arcing)               | 0.1 – 3.0      | 0.1 – 1.0   | > 3.0          |
%| Low Temperature Thermal Fault (<300°C)       | < 0.1          | 0.1 – 1.0   | 1.0 – 3.0      |
%| Medium Temperature Thermal Fault (300–700°C) | < 0.1          | > 1.0       | 1.0 – 3.0      |
%| High Temperature Thermal Fault (>700°C)      | < 0.1          | > 1.0       | > 3.0          |

if isnan(r1) || isnan(r2) || isnan(r5) %Checking for NaN values
    rr_result = 'Warning: Invalid input.';
    
elseif (r1 < 0.1) && (r2 >= 0.1 && r2 <= 1.0) && (r5 < 1.0)
    rr_result = 'Normal working condition';
    
elseif (r1 < 0.1) && (r2 < 0.1) && (r5 < 1.0)
    rr_result = 'Possible Partial Discharge (Rogers method is limited)';
    
elseif (r1 >= 0.1 && r1 <= 3.0) && (r2 >= 0.1 && r2 <= 1.0) && (r5 > 3.0)
    rr_result = 'High-energy Discharge (Arcing)';
    
elseif (r1 < 0.1) && (r2 >= 0.1 && r2 <= 1.0) && (r5 >= 1.0 && r5 <= 3.0)
    rr_result = 'Low Temperature Thermal Fault (<300C)';
    
elseif (r1 < 0.1) && (r2 > 1.0) && (r5 >= 1.0 && r5 <= 3.0)
    rr_result = 'Medium Temperature Thermal Fault (300-700C)';
    
elseif (r1 < 0.1) && (r2 > 1.0) && (r5 > 3.0)
    rr_result = 'High Temperaure Thermal Fault (>700C)';
    
else
    rr_result = 'Diagnostic ratios do not match a standard fault pattern (Undetermined)';
end

fprintf('\nDiagnosis:\n%s\n', rr_result); %[output:722174fd]

%[text]{"align":"center"} ## **`Key Gas Method`**

fprintf('\n---> Key Gas Method (Hierarchical Analysis) <---\n') %[output:6c5805d7]

% Calculating percentages relative to Total Dissolved Combustible Gas (TDCG)
if tdcg > 0
    p_h2   = (h2 / tdcg) * 100;
    p_ch4  = (ch4 / tdcg) * 100;
    p_c2h6 = (c2h6 / tdcg) * 100;
    p_c2h4 = (c2h4 / tdcg) * 100;
    p_c2h2 = (c2h2 / tdcg) * 100;
    p_co   = (co / tdcg) * 100;
else
    p_h2=0; p_ch4=0; p_c2h6=0; p_c2h4=0; p_c2h2=0; p_co=0;
end

kg_result = 'Normal / Inconclusive';

% ARCING (Key Gas: Acetylene).
if (p_c2h2 >= 5) && (c2h2 > 0)
    kg_result = 'High-Energy Discharge (Arcing) [Key Gas: Acetylene]';

% THERMAL OIL FAULTS (Key Gas: Ethylene)
elseif (p_c2h4 > 20) && (c2h4 > c2h6)
    kg_result = 'Thermal Fault in Oil (>700 C) [Key Gas: Ethylene]';

% CELLULOSE DEGRADATION (Key Gas: CO)
elseif (p_co > 80)
    kg_result = 'Overheating of Insulation Paper [Key Gas: Carbon Monoxide]';

% LOW-TEMP THERMAL (Key Gas: Methane/Ethane)
elseif (p_c2h6 > p_ch4) && (p_c2h6 > p_c2h4)
    kg_result = 'Low-temp Thermal / Oil Decomposition [Key Gas: Ethane]';
elseif (p_ch4 > p_h2) && (p_ch4 > p_c2h4)
    kg_result = 'Low-temp Thermal (<300 C) [Key Gas: Methane]';

% PARTIAL DISCHARGE (Key Gas: Hydrogen)
elseif (p_h2 > p_ch4) && (p_h2 > p_c2h4)
    kg_result = 'Partial Discharge (Corona) [Key Gas: Hydrogen]';

end

fprintf('Diagnosis: \n%s\n', kg_result); %[output:372be70a]

%[text]{"align":"center"} ## **`CO2/CO Ratio`**

fprintf('\n---> CO2/CO Ratio Analysis <---\n'); %[output:090e3baf]

if co > 0 %[output:group:9b6df631]
    ratio = co2/co;
    fprintf('\nCO2/CO Ratio: %.2f\n',ratio); %[output:44ed4b8a]
    
    if ratio < 3
        fprintf('\nDiagnosis: Severe paper degradation (Carbonization).\n'); %[output:581a38c6]
    elseif ratio > 10
        fprintf('\nDiagnosis: Normal paper aging, Mild overheating.\n');
    else
        fprintf('\nDiagnosis: Healthy insulation, Standard operation.\n');
    end
else
    fprintf('CO2/CO Ratio: N/A Invalid Input.\n');
end %[output:group:9b6df631]

%[text]{"align":"center"} ## **`Duval Triangle 1`**

fprintf('\n---> Duval Triangle <---\n'); %[output:12750763]

gas_sum = ch4 + c2h4 + c2h2;
p_ch4 = (ch4/gas_sum) * 100; p_c2h4 = (c2h4/gas_sum) * 100; p_c2h2 = (c2h2/gas_sum) * 100; %Percentages

%____________Creating states___________________

% Gases   | Value	State	  |  Value	State	   | Value	State
%---------|-------------------|--------------------|---------------
% CH4	  | 0–98	State 0	  | 98–100	State 1	   | 
% C2H2	  | 0–4 	State 0	  | 4–13	State 1	   |  13–15	State 2
%    	  | 15–29	State 3	  | 29–100	State 4	   | 
% C2H4	  | 0–20	State 0	  | 20–23	State 1	   | 23–40	State 2
%    	  | 40–50	State 3	  | 50–100	State 4	   | 

if (p_ch4 < 98), ch4_state = 0;
else, ch4_state = 1;
end
if (p_c2h2 < 4), c2h2_state = 0;
elseif (p_c2h2 >= 4 && p_c2h2 < 13), c2h2_state = 1; 
elseif (p_c2h2 >= 13 && p_c2h2 < 15), c2h2_state = 2;
elseif (p_c2h2 >= 15 && p_c2h2 < 29), c2h2_state = 3;
else, c2h2_state = 4;
end
if (p_c2h4 < 20), c2h4_state = 0;
elseif (p_c2h4 >= 20 && p_c2h4 < 23), c2h4_state = 1;
elseif (p_c2h4 >= 23 && p_c2h4 < 40), c2h4_state = 2;
elseif (p_c2h4 >= 40 && p_c2h4 < 50), c2h4_state = 3;
else, c2h4_state = 4;
end

%____________________Finding Faults_________________________________

% Faults |	CH4	        |    C2H2                       |   C2H4
%--------|--------------|-------------------------------|---------------------------------
% PD	 | State 1	    | Any state	                    | Any state
% D1	 | State 0	    | State 2–State 3–State 4	    | State 0–State 1
% D2	 | State 0	    | State 2–State 3	            | State 2
% 	     | State 0   	| State 4	                    | State 2–State 3–State 4
% T1	 | State 0   	| State 0	                    | State 0
% T2	 | State 0	    | State 0	                    | State 1–State 2–State 3
% T3	 | State 0	    | State 0–State 1–State 2	    | State 4
% DT     | State 0      | State 1	                    | State 0–State 1–State 2–State 3
%  	     | State 0	    | State 2	                    | State 3
% 	     | State 0   	| State 3	                    | State 3–State 4

fault = 'Undetermined / Boundary Case';

if (ch4_state == 1), fault = 'PD: Partial Discharge';
elseif (ch4_state == 0) && (c2h2_state == 2 || c2h2_state == 3 || c2h2_state == 4) && (c2h4_state == 0 || c2h4_state == 1), fault = 'D1: Low energy discharge (Sparking)';
elseif (ch4_state == 0) && (c2h2_state == 2 || c2h2_state == 3) && (c2h4_state == 2), fault = 'D2: High energy discharge (Arcing)';
elseif (ch4_state == 0) && (c2h2_state == 4) && (c2h4_state == 2 || c2h4_state == 3 || c2h4_state == 4), fault = 'D2: High energy discharge (Arcing)';
elseif (ch4_state == 0) && (c2h2_state == 0) && (c2h4_state == 0), fault = 'T1: Low Temperature Thermal Fault (<300C)';
elseif (ch4_state == 0) && (c2h2_state == 0) && (c2h4_state == 1 || c2h4_state == 2 || c2h4_state == 3), fault = 'T2: Medium Temperature Thermal Fault (300-700C)';
elseif (ch4_state == 0) && (c2h2_state == 0 || c2h2_state == 1 || c2h2_state == 2) && (c2h4_state == 4), fault = 'T3: High Temperaure Thermal Fault (>700C)';
elseif (ch4_state == 0) && (c2h2_state == 1) && (c2h4_state == 0 || c2h4_state == 1 || c2h4_state == 2 || c2h4_state == 3), fault = 'DT: Mix of thermal and electrical faults';
elseif (ch4_state == 0) && (c2h2_state == 2) && (c2h4_state == 3), fault = 'DT: Mix of thermal and electrical faults';
elseif (ch4_state == 0) && (c2h2_state == 3) && (c2h4_state == 3 || c2h4_state == 4), fault = 'DT: Mix of thermal and electrical faults';
end

fprintf('Diagnosis: %s\n', fault); %[output:9f36b3a6]

%[text]{"align":"center"} ## **`Duval Triangle Plot`**

% Defining Vertices and Points (a-o)
top = [0.5, 0.866];   % 100% CH4
right = [1, 0];       % 100% C2H4
left = [0, 0];        % 100% C2H2

a = [0.49, 0.849]; b = [0.51, 0.849]; c = [0.48, 0.831]; d = [0.58, 0.658]; e = [0.6, 0.693]; 
f = [0.73, 0.398]; g = [0.75, 0.433]; h = [0.675, 0.303]; I = [0.85, 0]; J = [0.71, 0]; k = [0.555, 0.268]; 
l = [0.635, 0.407]; m = [0.55, 0.554]; n = [0.435, 0.753]; o = [0.23, 0];

% Zones Polygons
% PD: Top -> b -> a
PD_x = [top(1), b(1), a(1)];
PD_y = [top(2), b(2), a(2)];

% T1: a -> b -> e -> d -> c
T1_x = [a(1), b(1), e(1), d(1), c(1)];
T1_y = [a(2), b(2), e(2), d(2), c(2)];

% T2: d -> e -> g -> f
T2_x = [d(1), e(1), g(1), f(1)];
T2_y = [d(2), e(2), g(2), f(2)];

% T3: f -> g -> right -> I -> h
T3_x = [f(1), g(1), right(1), I(1), h(1)];
T3_y = [f(2), g(2), right(2), I(2), h(2)];

% D1: n -> m -> o -> left
D1_x = [n(1), m(1), o(1), left(1)];
D1_y = [n(2), m(2), o(2), left(2)];

% D2: m -> l -> k -> J -> o
D2_x = [m(1), l(1), k(1), J(1), o(1)];
D2_y = [m(2), l(2), k(2), J(2), o(2)];

% DT: c -> d -> f -> h -> I -> J -> k -> l -> m -> n
DT_x = [c(1), d(1), f(1), h(1), I(1), J(1), k(1), l(1), m(1), n(1)];
DT_y = [c(2), d(2), f(2), h(2), I(2), J(2), k(2), l(2), m(2), n(2)];

% Calculating Sample Point (X, Y)
% Using fractions (0-1), not percentages (0-100) for the coordinate formula
if gas_sum > 0
    f_ch4 = ch4 / gas_sum;
    f_c2h4 = c2h4 / gas_sum;
else
    f_ch4 = 0; f_c2h4 = 0;
end

% Using Formula (https://powertransformerhealth.com/2019/03/22/duvals-triangle-method/#:~:text=X%20%3D%20%5B%28%25C2H4,0%2E866,-For)
X_pt = ((f_c2h4 / 0.866) + (f_ch4 / 1.732)) * 0.866;
Y_pt = f_ch4 * 0.866;

% Plotting Graph
figure('Name', 'Duval Triangle 1', 'Color', '#24273a'); %[output:26bfd512]
hold on; %[output:26bfd512]
axis equal; %[output:26bfd512]
grid on; %[output:26bfd512]
axis off; % Hide standard axes %[output:26bfd512]

% Draw Zone Patches (Colored)
fill(PD_x, PD_y, [0.8500 0.9500 1.0000], 'FaceAlpha', 0.3, 'EdgeColor', '#24273a'); %[output:26bfd512]
fill(T1_x, T1_y, [1.0000 0.6824 0.6863], 'FaceAlpha', 0.3, 'EdgeColor', '#24273a');    %[output:26bfd512]
fill(T2_x, T2_y, [1.0000 0.8000 0.0000], 'FaceAlpha', 0.3, 'EdgeColor', '#24273a');     %[output:26bfd512]
fill(T3_x, T3_y, [0.2471 0.2471 0.2471], 'FaceAlpha', 0.3, 'EdgeColor', '#24273a');      %[output:26bfd512]
fill(D1_x, D1_y, [0.0000 0.8118 0.8784], 'FaceAlpha', 0.3, 'EdgeColor', '#24273a');      %[output:26bfd512]
fill(D2_x, D2_y, [0.1490 0.3216 0.6549], 'FaceAlpha', 0.3, 'EdgeColor', '#24273a');     %[output:26bfd512]
fill(DT_x, DT_y, [0.8314 0.3255 0.6392], 'FaceAlpha', 0.3, 'EdgeColor', '#24273a');      %[output:26bfd512]

% Adding Zone Labels
text(mean(PD_x), mean(PD_y), 'PD', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:26bfd512]
text(mean(T1_x), mean(T1_y), 'T1', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:26bfd512]
text(mean(T2_x), mean(T2_y), 'T2', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:26bfd512]
text(mean(T3_x), mean(T3_y), 'T3', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:26bfd512]
text(mean(D1_x), mean(D1_y), 'D1', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:26bfd512]
text(0.65, 0.20, 'DT', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); % Manual placement for DT %[output:26bfd512]
text(0.5, 0.2, 'D2', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); % Manual placement for D2 %[output:26bfd512]

% Main Triangle Boundary
plot([0 1 0.5 0], [0 0 0.866 0], 'k-', 'LineWidth', 1.5); %[output:26bfd512]

% Plotting Sample Point
plot(X_pt, Y_pt, 'go', 'MarkerFaceColor', 'b', 'MarkerSize', 4, 'LineWidth', 1.5); %[output:26bfd512]

% Label to Sample Point
text(X_pt + 0.03, Y_pt, sprintf('  Fault\n  (%.1f, %.1f, %.1f)', p_ch4, p_c2h4, p_c2h2), ... %[output:26bfd512]
    'BackgroundColor', '#cad3f5', 'color', 'k', 'EdgeColor', 'r', 'LineWidth', 1, 'Margin', 1); %[output:26bfd512]

% Corner Labels
text(0.5, 0.92, '100% CH_4', 'HorizontalAlignment', 'center', 'FontSize', 12); %[output:26bfd512]
text(-0.05, 0, '100% C_2H_2', 'HorizontalAlignment', 'right', 'FontSize', 12); %[output:26bfd512]
text(1.05, 0, '100% C_2H_4', 'HorizontalAlignment', 'left', 'FontSize', 12); %[output:26bfd512]

title(['Duval Triangle 1 Diagnosis: ' fault], 'FontSize', 14); %[output:26bfd512]
hold off; %[output:26bfd512]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":40.1}
%---
%[output:3d5553b9]
%   data: {"dataType":"text","outputData":{"text":"===== DGA Calculator =====\n","truncated":false}}
%---
%[output:9d5dc1e6]
%   data: {"dataType":"text","outputData":{"text":"\n---> TDCG Assessment <---\n","truncated":false}}
%---
%[output:044e7bc4]
%   data: {"dataType":"text","outputData":{"text":"Total Dissolved Combustible Gas (TDCG): 18.00 ppm\n","truncated":false}}
%---
%[output:82078133]
%   data: {"dataType":"text","outputData":{"text":"Status: Condition 1 (Healthy\/Normal). Ratios may be unreliable.\n","truncated":false}}
%---
%[output:69eb918c]
%   data: {"dataType":"text","outputData":{"text":"\n---> Rogers Ratio Method Method <---\n","truncated":false}}
%---
%[output:67d42bd2]
%   data: {"dataType":"text","outputData":{"text":"\nCalculated Ratios:\n","truncated":false}}
%---
%[output:4a0aed39]
%   data: {"dataType":"text","outputData":{"text":"R1 (C2H2\/C2H4): 1.00\n","truncated":false}}
%---
%[output:17d29f0b]
%   data: {"dataType":"text","outputData":{"text":"R2 (CH4\/H2): 1.00\n","truncated":false}}
%---
%[output:2a57dc1a]
%   data: {"dataType":"text","outputData":{"text":"R5 (C2H4\/C2H6): 1.00\n","truncated":false}}
%---
%[output:722174fd]
%   data: {"dataType":"text","outputData":{"text":"\nDiagnosis:\nDiagnostic ratios do not match a standard fault pattern (Undetermined)\n","truncated":false}}
%---
%[output:6c5805d7]
%   data: {"dataType":"text","outputData":{"text":"\n---> Key Gas Method (Hierarchical Analysis) <---\n","truncated":false}}
%---
%[output:372be70a]
%   data: {"dataType":"text","outputData":{"text":"Diagnosis: \nHigh-Energy Discharge (Arcing) [Key Gas: Acetylene]\n","truncated":false}}
%---
%[output:090e3baf]
%   data: {"dataType":"text","outputData":{"text":"\n---> CO2\/CO Ratio Analysis <---\n","truncated":false}}
%---
%[output:44ed4b8a]
%   data: {"dataType":"text","outputData":{"text":"\nCO2\/CO Ratio: 1.00\n","truncated":false}}
%---
%[output:581a38c6]
%   data: {"dataType":"text","outputData":{"text":"\nDiagnosis: Severe paper degradation (Carbonization).\n","truncated":false}}
%---
%[output:12750763]
%   data: {"dataType":"text","outputData":{"text":"\n---> Duval triangle <---\n","truncated":false}}
%---
%[output:9f36b3a6]
%   data: {"dataType":"text","outputData":{"text":"Diagnosis: D2: High energy discharge (Arcing)\n","truncated":false}}
%---
%[output:26bfd512]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAArwAAAGlCAYAAAAYiyWNAAAAAXNSR0IArs4c6QAAIABJREFUeF7snQl4HVX5\/9\/kJjfrTdIkJGnT0DYE2kJbBKTUoii0KspSCiKgaAH1B26AoriCsgiKovxBVkVARFBBhYIii\/Bjk60gJYXuTZukWZq02fe2\/9970rmcTO7cmbn3zsyZud95Hp9iZuac93zeM3O\/99xzviejbvbivYQDBEAABNKMwPx5s+m7l36F3nl3A\/3k2l9Pan0oFKIzPn0infCJ46i4OEK7d++mbY3b6ff3\/pVee\/2tCdfbufb9R8ynL1\/wOaqsKKfBwSF6+t8v0m\/ufECUrx2RSCFde\/WltJf20g8v\/wV1d\/cmnZ05sw+gs848mebMrqOCgjzKyMiggYFB0f677vkLNTQ0TajjB9\/7Gi3+wBH04EP\/EOdjHSefuJTOPefTtHVbE138zSuTjhEFgAAIgIBTBDIgeJ1Ci3JBAARUJcAC9kc\/vJhmz66ll\/6zKqbg\/dIXzqQTT1hC3T299Oaba6i4uIgOXTCXBgcH6aab76H\/vPxGtHlWr62oKKMrf\/RNYkH74F\/\/QYe97xBaMH8u3ffHv9FfHvpHtLzTT\/skffr0E+mBP62kh\/72z6QxnrvidDr5pI9SZmaGEO1r124UZS5YMJemTa2k3t6+SW2C4E0aOwoAARBQiAAEr0LJQCggAALOE2DR+Y2LvkDz580Ro5yxBO9RC99HF339XBocGqZrfnozbdq0VQS2\/JSP0+fPPo02bNxC3\/vBdWJU1s612ojoPx9\/hu747f100IGziIVla1sHfed714o6WIxffeW3aHR0jH50xa+EGE3mOP1TJ9BnzlwmhPptd9xHzz3\/arQ4Hplmsf6J4z9CHR276JqfvddWCN5kqONeEAAB1QhA8KqWEcQDAiDgGIGlSz5Inz\/7VCotLaHOzl1UXl4aU\/B+5YLP0Sc\/cSyxML351nuj8fDI7M+u\/S6Vl02hG278nbjXzrU80rrs5I\/R7+7+Mz2y8knav2Ya\/eiyi4gogy7\/8fXUvL2NPvfZ5eKa39\/7ED3y6FNJsdDKLy2dQr\/\/w0P0t7\/\/a1J53KYrfvQNIb7\/8c9n6JbbxtsLwZsUetwMAiCgGAEIXsUSgnBAAAScIaCJv3GR+wZ1dOykU5cfH1Pw\/uza79Hsg2qjwlSOiIXgUQsPoz\/9eSXdd\/\/fyc612tSCu1jwPvpUVPCOju2my390PeteMeWhp7cvOoKcDA0e3f3sWctoe0s7fed7PzUcLf7sWafQspM\/Sm+8WU8\/ve5WCN5koONeEAABJQlA8CqZFgQFAiCQagIseC84\/2z69zMv0VNPv0AsPj912icnCV55FPe6X9xGr696e0Io\/\/PFs8QIrLbYTBvxNbv2lzf8lsymNHz+c6fRSScsoTt++0d68qkXkkbw3Uu\/TB\/64EJ6\/oVXo0LWaqEY4bVKCteBAAj4gUBCgld7ERo1cHR0VKwqfuXV\/4qFGe3tnX5gMSFGuY08X89sBbI2elRVVWG5rSMjo6SN9MS7yW4slgNw6UKv4udV6d\/\/7leprGwKtba20xVX\/T+xYMfKoYkho2vHxsaot6+f1qxZT\/f\/6ZFJK9z5PrkMu\/VbiTFI13jBKpbg5b76gUWH0969eykzM1P8y\/N8tYPfbfzcFhTk06o33qbf3vmAmJJQWFhI1\/7sZvrvW++IS3me8Bmnn0QfPuYoysvLFeXwnNym5hYqLoqI\/\/\/An1eKunjR2r1\/GHd+4LJ4Lu33L\/v5BNcGo1ybcbvhl5fTgXWzqKmphaZPnyqK0b\/PjJ5Ps\/e8HJNcpv5dGM\/lIUh9OCht0b6UhcPZ1Nc3EO3XKuTVrL8HJQeJtkNbFFtTM41eX7VarAGIdeif7cGhIbr9jvtS8iXbTuxu9ylHBK\/cYP7Z8Kab7540SmIHihfX2hVpELzGWbLLMhX5ZpHxnW9dQEceeagozq7gNBO8coz9\/QPCtumfjz87IXS8nK1n0gtWiQhebpEmgoeHh4Wd2KdO\/cQEwTtv3mz6xoXnEX\/51a6VhTN\/WWI7MhbNQ0PDYt7s7\/\/wV\/rCuZ+mjy79kFjM9u7ajfT1r6ygOXMOEGXUr1lPP7\/+9kn2ZGbcUiF4W1raqacn9sI5fs6qq6to85at0UEBtz\/ErPcyXGmFAASvFUpqXsO\/Pp14wlLxZdloMO2AA2bQ5T+4UKxfkI\/\/fe5luu4Xt7vaMLffFY4L3nGxsWPC6l9XiSZYmV2RBsGrjuDVr8J3WvBy+d3dPZNsnczESIJdM5C3ecEqWcHLQpRHY3kAODc3V4yEvV2\/jq656tvEolcWx\/qRYv6SpC164+u0D6Gt25rFLxE8FeGwww6hxx77tyjnhBOOo1Wr3qZrf3aLrS9Vv\/zFZWIucjIjvHZ9eN3+EAvkA+FhoyB4PYSfRNWykOVfki770fUxf10\/bfkn6OzPnkLhcHhCbXYHhZIINXqr2++KpAWv\/ucxttT50NFHCg9J\/ilZe+k\/8+x\/6Ppf\/SYVjFwpw67gjRXU+w49mL73na9SYWG+OJ2uP+2lgqWVpPNo02fOWkZLjzuaiooiST3M8QQY18NWVPyTdU3N1OhP3vX16yz\/FG2lPbjGWQJGgpc3W+Bjz549dMVVN0R\/ndLebbzRQm5ujhh55aN\/YJDXmhHP4d2zZy9959tfjj7znZ1dVFZWQv964jlhC8bOD9oHDc8B5nm9fHztqyvomA8upF\/fco8YIJCtytg67BfX\/YBKpxQLv+D1G7ZEwZh9UfjmxV+kJccdTTs6dtJ++0Z0rEzR4goSncMrf4hpUznYkcJo8wpns4zS7RIwErx2y3HierP+7kSdfimT5\/9\/6tRPUiiUaegtzm1hR5b3H7FANIvfNUVFhZSfn0cjIyP0h\/v+nhLfb1WZpVzwag3lbxs8f7Kqcj\/xJ57acOVPboz6WaoKRIsrFSINgnecZipYWukv+mkI\/LMxi9PxBzvxObxG97IA+vHl43ZOQvjoRu2sxIxrvCMQT\/BqYvaO3\/xxkjXYNVdfSgvmzxGB8\/xentPL\/\/7urj\/R8MgIfe7sU4Ug3rN7DzU1t1LdATOFowPP2b3h+suptnZ\/ca\/m\/6vt+LZxU4OYc6e9N1a\/\/W50Qwx+hniurzxPmMswEwDaaM7Y2G7xocZHLMH7waOPFPZq\/AF44813iTnpqRK8zCZdv+x717sTrxmCN3F2Xt2p7cw4a1aNeB9Zmc7A7zi2KeRfo7TPsDf\/u0bs7BjUwzHBy8A0f0p+4Q0Pj9Bv7rxfzHM0E4LyS1ybNL+9pY2uuuISml49VYysyH6RWnLYWueMT58kvuF0dfXQT376a3rnnQ3i9MyZ0+mL550pft7TXvy8AGXnrm56\/PFn6aG\/PT5hkUgqRJpZOzkubY4d\/\/fj\/\/pf0fE4Vj6am1vppz+\/lbhd2qiT\/sOKR39OW348HX\/8R6istISysrIEHxZ769Zvpt\/+7oEJC6rkmFjI\/erG39Enjz+Wjnz\/AsGF5xe2tO4QH1C8kl1\/vO99h9CKs08lfrCys7PF1qSvvb6aNm3eSmd\/ZjnpFzpYEbxHvv9Q+syZJ0fL5LzwB++\/nnyOHln5lKXFO\/KHP7fh1dfeovb2Djpl2ccdE7xcsPzzEHP\/y4OP0T33PiTqNBMj7AnL8z+rqvYTLPngxQON27bTHx94ZNL2tXw+Wf6c18amFuFOMLVqP9FftBze\/fu\/xPwJjPsj90EWXLwlLR\/9\/YO0dt3GmFvS6p83\/tLB74B4z1s8VjxF5ZzPn06Hve9gKiwsEIvJtEWDL7z4Ot3z+wdFf5ePWO8QbUGZdp2Z4OWY\/\/HPf8f04eXdybKyQqJdLCb5nWPFs1d+3jXBe8k3vkQLjzxU5EIbOeYFbrzoRNvyOFHBy+z4vcnxMjc+Yi1a48Vz3BbmeMZnviaeOe0d+Mqrb9K0aVWiv\/D7hufzPvfCqzQ6Mips3fjg0aGLvnGFWBSqjfBWVu4n3kVju3fT1q3NVLFfmRhN4r\/xyPfKx56ih\/5qbxc5O++KZN912mcGz6POy80Vfa5zZxc9\/\/yr4suL3Ofkuvgz6\/F\/PSvmY\/OXYu73\/I7UcmnnGd5vv1I6\/38+K+rnL9Q3\/vpueuHF1yb29XNOF+8hzp+dL\/YfPPr9dOYZJ9P06qrou5x\/ieUvafxs2F20pr3POO98r5X3GV9z3LGL6aQTl9LMGdPFffzLCvex5198bdKzrX9P\/PH+h8VuiNrnEb8\/167dJDZY4Wk88mH3s1LWAK+99hZlZ2cJccjl7NzVRTff8nuxMJ+Pj3x4kWAZ7xmJlRs7fWzSh7H0B\/7CeuHXzhHrAvTaR75Psynkzxvupz\/7+a106KFzo\/2HzQZ+et0ttPrttROqs9O\/tQW7i446TDzv\/N5hEd7Q0Djpcy3elAY51\/yufOLJ5yfoBC3Xeo2jBR4rJ44K3iXHLhZ7xmujbNq3fDMhaPRhpf08xw3asqWRvvfD66K+ktwJr\/3JpXTIwQeJ9sorFMVo83e+KoRFrINfZH9\/5Am66+739ov3QvDKI5L8kmQBzA9uvFi0LU35wzLWwQtOrrz6PXcCmT0\/GNx2\/eR17UV19z0P0qOPPR0tlj8Uv\/7VFWKLVf3BsfNPtfzBL6\/s5evixa\/5kmovSLlcfvFxR+eJ9PwBbHZwWQuPfB\/95aHHhPWUmeCMV57Vew8++ED6wXe\/RiUl40zkXbvilcHbvH7+c6eKD7JYB794fnnDbyYs9kwF\/81btglBEqu\/vPPuBrry6hsneLWKOM8+NfoMx8o7L7jin6y1I16cfA3n9cWXXp9gk2XEyuzZZfHEcV\/1k5smxJ2s4OU4WXR27tw1Yac13vKXp83s2LFTTNligcoHLz7r6u6Jee2GjQ3CU\/fAuplR1xCOm7cM5nm53730K8K9Ycb+06NTIfhLyOYtjWL3tWSmNHBsvJHF6aefKKZd8IePXvDe8uurRZ\/gmHbs6KTzvnSpaJP23I6MjlJ43xcyLcd8LcfIH7B86AXvT676FpWUFE9wuJDdLvieWO9ds2eS+6PVd0Uy7zreeY77kNY+OS5uOy8qvPqam6KLCOW6uF08tUWLk59l3syDhardZ3jT5m107dWXCkHHhzwNhv+\/PLLH\/9\/qwiOj9w+3jftxYUG+EMFWXRrMPof48+HOu\/40aWEvL7LiaT7aF359\/tet20xXXH1DlLP8XHOf4z4V61795x6Xaxaj\/h75c4vFVW5Ozr4vuGPCr\/rqa34tPpfisZSfEb3gtdvH4j4b0pceXgdg5LnNOzjyduZ88NSob136Ezrk4APFO4i\/nO3evUc4a\/GmN\/JhtX\/z+\/rSb50vBiZjHczx9\/e+93lhVfA2Nm6n8v1KY35exsq1UU4cFbx6Yas9rIkKXh7lvPjC88RLiB+gW2+7l55+5iXBlX9i1JKmt9jgBHz4mEXiOv6m9qsb7xQviksvOV8sFuFD30m8ELz8snn5lTfFXGd59MAoFrnNPT29wiLp2edeESO+Z525TLxwWTjfd\/\/DYuSRDz17ZrVy5VP05wcfEy\/jL553RlTQ8spwbbtT2e6Ey2lt20F3\/u5PxD+B8OjfCZ88LvqCtyp4j\/nQQvr6V8\/ZN39olB77x7+Fkf+HP3QUrfj8aWIeLr\/U+Fv8Xx76R7znPeY5q6I11s1W79U\/sDIzozK0UTd+KfA33\/sfeFj8wvCRY46iL37hzOj8Y3l0MVX8ua2bN2+jm2\/9PbW0ttOFXztXzEfWRvfkZ+r9R8ynb178JfEi5L7JL3l2EODjnM9\/SvwqwMJZv2BPmyPG9zz\/wmt02x1\/EO1kHh\/\/2DHiHv30DyNW8q9EbAF34813E7\/geGTxjE+fKF6AseaepULw8ihOUaRQfOjzF2j+onfogrliLu6jj\/1bePFq8\/P5\/VE9rTLmtTfdfI\/4xYEXomkjqbzLG29ZfNqpnxBf0vlL2pmfPjlaHv+6U1pWYmvRmtEDwrmVvzAyL\/5CyF9QuW4eCOBrOF88rUKzYGR\/4XmHzI46Tcj95svnny3aon1x0gveX11\/GeXkjH8ZEO\/XrU1ifjvXdeklF0QHH\/jXBt5wo31HfOvKRN4Vib7rZDtDFq\/\/efkNuvX2P9BBB9bSBed\/VkzTY1aPP\/G\/9Oub7zF8r97\/wCMTRrATfYblZ0DPa8JnokVrKW0KjfYlXc7rF849Q1jpaXm1InjlxVIs8O6972\/iXT51agXxIBX\/qsqHfpCKR2bPWfEp8QwbfQ7pf83VT1vTPod4pFXbIptjZ+GmbQyj1wdWPyv11l38iymPfso2q\/FY6p8RWfAm0sfifQDKQpY1xFU\/uXHS5do25jzAJXPVDxZqQlh+Z8R6lvT9mzXV5T+8kA6ee6Co2+hzRp7ealXw6jWH\/Fmiz3W8nLgqeLXRr0QFrz4x8rfZc6VvOPJLQQaq\/0konqjxQvByR9AvSuFEG8Uit1meexOvE+nZ60cELvvBhcQ\/RYgO1rojut2pPK8rlmefPBHequCV28Xx8\/xF7SGTJ+DrX5RWla9V0ZpKwSuPnhnVL7PUf9GK9ZM3x5cq\/vqfrFjUXvqtC8SXSP2UDDmnPDLMc7v4fj607Wi1D7O3Vr9L3\/\/hdeKc1gYuj71lb73tD0LQaBs6zNi\/Wlwnj1YZsZL7CH\/gsFDftGmruF9+yctfNOz2D3lUXq6Pxd8bb9TTxz\/2YfHTHPdN\/smeRyj4i6S8IPXll98Q52Jdy18UZLGrjWzydKuLvn4urXqjftKCXhZH\/GWEX968No6nFfAoocZfa6NeAJi1nUfXOS\/8LuWDBQp\/GeEvNSx65f57x63XCssxvp5\/YpZ\/6tSPLMqCd8XnThNfSLQ6uM6\/P\/yE2LWODz7PP61yfSw+2HlC\/xOqvh2JvCsSfdfJ79Vt27bTd3\/w0yj3jy79YHSKgfzBra8r1lzIRJ\/heIM5shiON7In85Tbp38f6D9jrQheue382fDgg\/+gh1c+KQZt5J\/a9YNUvEPhvEMm\/yLLsX71y7y193EibPnzXO7v+s8h\/sJ55Y8viX6ZkjdbSeSzUu5zVqaT6FnqnxFZ8CbSx4yebc6ZvDZA\/yuAdp885VPfHv052UGG77fSv+Vf9PUDGrLYlgWqVcGrzzV\/hvzo8oupsqJcNM8o1\/qcuCp4taASFbzcMHkOima9MTg4HP3Zx2h+L9\/LHYNHaNiblb9hzZrJ81DHpwLof27wQvAarZ62EgvPj1u06HDxATl7di2VTimJ\/pwoLxiR2etHf5mDkfDQdpcaZ\/WeENYeJv4J4bxzPi14WhG8HO+VV1xCNfvM8PWLWqzOSYr3Ae+F4GVR9s1vXSXCslI\/Cw2ehnHogjk0d04dVVSUR+daykIsVfz1H4pGLxz93x9+5Ino6G6sF6j8ZU3+IONrtTl5Wxoa6ZlnXqKXXn4j7pxb+VmUpzFxWfx88\/xhHjHkkbd\/P\/vSJBFoJvrinbfyrMX6ADDayYync\/EcXf4SqY2icty8fa+VaTpmbbEreLk8qxtPyF9+5X6txTSxT44vCuXjR5ddLOZ68we+mMM7NkYPP\/KeS4PdRVGJvisSfdfJ\/Vd+Brlt8ge3LODMPtP43mSeYfnLnTZIIX+BjPe5p+9Dclmx8ip\/IbEiePXTurg+\/mzhedr1a9aJL7b6LzSyYNGP0Fl9p8caIDIaMJDLtPpZKb8LjOZGJ\/KM8BfjRPqYERer1l5ynfrPAX0O9WsX7PZvq7\/cWBW8dnIdLyeOCt5Uz+HlhMs\/n2g\/Zba1d0QnbMeadK1NDOef5zSBq+88KgheoxWSRh\/C2iR8\/mmotPQ9gatvm5HgjbWa08pIm9Eqb23SvBXBa8e3WD8yYCYCtPNWBKdRWVbvTXQOLy\/wOP1Tn5ywmEgfi9HIYyr4a3UZvXDkF5zRql8j4WI2h5fnxupHLBOdw8tiihep3HTLPZMWqVjtJ\/J1VgWv0btNLou\/zLBFGY\/QjS9uGxMf\/jffem9KxK7VL1V8Xbx2GZ0zEw\/y4IP2\/uR+c965Z8R8z2r92a7gTfRdYdaHjfqc3O54fUgWambi2iwHfF7+kq9\/h8qLY7WBnvmHzI6ukbHjEGOW10R8eM3mx\/LnMs\/z58V++i+MVncctdLfjdqWyGel\/FwYjZ6bsYz1jLDgTaSPJSN4Y30pide39YI1Ff07Vn1WBW+sLxxG7OPlxFHBKw\/bJ+vSIK+wlufk8tw6fpjYa5KPNe+sFwtEtNETBnr5Dy8S84nGv3mOEY80sbhkVwLet54PFQSvfjRB6yDxpjSccvLHos4MPOfw3Xc3irmW7IOsWcL5XfDaeSHKD5VV0RrrQbR6r\/zhYNWlQZ67xnXzz7q8OIVHP9lVQm9bleyHZTyx44Tg5Xj1q49jMZZ9i+Px1lwaNCeRWGXxoobLr\/hl0tuYWxW8Ru82LTa92OUvbX\/9++NiPnoqD6v91C3BK7s0aDvN8TtX9uF1UvDK7wqnBS\/nMdZCbKP3lVnfiid49fP+2Xaqrm6m4edevD5mJtISEbxcn3BpkNxf9DHwFz7mxXN8zXJjFL9ZfzdqGz+vdj8rzfLFMZqxTFbwyn0sGcErTxG08v7RTyGwki8rvPR1B0bw8guffzqpnTXuORlvvpP+52yzBSfyRH1eLc0PEgvaWItX5LkpLCx4AQkLSz5Um8NrR\/Dqf+bjn0l5LhwLfatzeO2M8MpzqmJ927I7pUE\/38oJn06zl2O8B9\/KvTxq8KPLLqIjDp8virK6EEv+aYkXCPz4yl9Ff5Y3eoGmmr\/WdiemNMhctWlEixcfIRYzTJtaEV1VLc\/ftMKby+VpHzw9YMGCuWLTD83lQv5CbeWFbnSNlZd2vHcbl8ttlufsshvK7b+5j557\/tVkQot5r1VuiQhe+afvWL8qxJrS4ITgTfRdYfYhbcRO252OgRu9k\/XJMKuLr0\/mGeb75YEeHgAqL58iVsMbraw36mzyT76x8mp3SoO+Hm2aFlvt8RQQ\/vVRs8TTplDo52Baff+b9fdY789EPyutvAsSfUYS6WOJCl79vGyrLyG571vp30bvg3j1OSF44+Uk5SO8DJdXfX\/mzGVilEebtybvtKbv7Pr5gfEWQDE8\/WRwDWgsIcaT+tlBgA\/9eRmM30Z42eKIX1zabnbyC0MeKdB\/QzTruFYWWum\/\/emFn5UpDRyXnGf9ojX55a7iojX+mZpH0XlOuPYy1++0Fosl21z99JrvRr8Iyi8VeX6g\/sM23oKXRPlzHfFeOHYWrWk2gPKX0VhfqIy+GMVilf1\/npzanu+ajZdsHSgvuEv0VwD9yzjeh5yVd5v4Ii2NJum\/ZFv9sLF6nZkA0MpJRPDGW9ykF\/3y+9NsTqHdEd5E3xWJvuvkhWD6RWvySJnRII6VKUB236HMQP9sZWZmiF\/34vmuxupH8iBQKhatybxifQYbCWz5i7\/+\/S8vDpQHEsz6eyzBm+hnpRXBm+gzkkgfi\/dOkNutX08gL3rkMuJZ18k5sdu\/5WlevBj217f8XtSlDQLEso11QvDGy0nSgtfKi5kXOV3zs5ujq6s1X0ltdw+2Frnt9vvEBHfu0GzYrXkY6sWTVl+sIfpYiZQfbn4Rsd\/ugw89RmedsWyClZbfBK\/+Wyuvomc7s0hhgZjXpa2ET5XgnfQBty9n6zdspnhWNly\/0YuD83z+lz4jPF55kQN\/KWLbK9keTf4ZzEpfk68xeznGK8\/uYiC9NZcQPitOFz\/x6b9s6V8q\/GJgi7Cvf2UFHXLIQdHFhrIYdoK\/meCVraCs2pLpxbdmG8RtmT59qli4c\/hh80Qb5S8yRqx4y93jP\/bh6Ip+9vxlA3K2A5P7nX4nR7NfiYxyr7ciMutz+nebvMbA7F55dM3KopBY5Vnt44kIXtk6ietmm6Hrb\/iN2GhDzqO+fzsheBN5VyQqeGVbI15wyS4at9z2e7Ei\/OILvyBcAPh5kAdxzOpiRsk8w3y\/0UCP7Dlv1udiPfPJ2pLJ\/UR+T\/DGDyzSv3DeGVErN3nDKHlqF7\/nn\/3fl4XvPH92ffXLn49O7bI69YnbZmWE1+pnpRXBm+gzkkgfi5db+UuFfi2QrJXMBgZkvSQvarfSv\/W2ZLKu+\/SnTqCTTlo6bkE3OES3\/+aP9ORTz8cdcDF7txn9GhovJ44LXp5y8Otb7p5goM+J47ktPAocy0Scv3WyCIq1a5eWdP0Hi9Gkff0cXrnT8E9B498+MsXP0df94rZonFY6u9nLxcqHmNkcoHiCUR5J0sfCnVUz5JZ9+cw6brxOZrQYKZ5Zebz4+Vy8xQ5cbjIr2s0emFQJXh7FYyHGuwhaEdz6ObzyPfziZ9HIgpA\/iC6+5MrofHQn+JuJE95k4dRTjjfceIKfm7vu+cuEtvOz+Y2LviBcUIwO\/RcEo1zp58LGKk9vZs7XuCF4Y73b5A8Ms\/eD6oKX4zcycGchuGtXd\/QXJqdHeBN5VyTzrjPbGEa\/IYJZXVpfSPQZ1u7XD\/TEmsZn1u+ieTXYUIbfZ7m5kz9\/470r4m2ioMWjZ8Z\/N9t4Qv+F0uydbmUOr9XPSqsaIJFnJN6zFY+XUW7l9468wG7S4GLruJsKTz2KdegXt2l2j1b7t9nGE\/z5xptZ\/ebOB0T1TozwxmPriODVthCNtQWjDJlN1086YSmVlY07DLDd0Ko33hbzpnhDAh7FMRrh1QupWGbJWl08teLL\/3O2sOtiEahtc8ebGbDo5l1s9EbiVjt7vJeL04KXOzOb75\/wieOimwNoWzLyjklnf+YUYS6vmdyvXbfJdLGA2QtF3tqTf07Tthndvr0t5naUZoKXz8faWpItbdgaRb\/ls5WXuXaNWVvilWU2wqttbfvKK\/+lP\/1lZczFUvHq5wUeZ515sthuVe77vOCQPwTYF5d\/Frrp5rsnzP1MNX8zwcuMEtlamL+wcv\/70AcXir7JfYVFUl9fP\/FLlDcYaWhoiqYgHitthfWSJUeLUTZ+hvl55ZEC3sXsz395lIy2DeYK4r3CopMcAAAgAElEQVRD9H3AbITX7N0mj7SY9VU\/CF5ug7wYiafvaM9mQWE+ferUyb9gmPWpRKY0aCztvCvMPqTN3g98P09b4p\/EeYGz5kfM2yrrt7M2q0vuC4k8w9r9ekFiZythfX\/Ub9PM7xueY\/vkUy8Q\/+Su\/\/w1yyu\/J5jpnNl1wpZO3k48nhYw2lr4zf\/Wi4EEeaMHs5zFc2mw+1lpRwPYfUa0XNjpY\/HeJ\/yrGTvCcM5kCy\/573y\/lV8D5F8gtSkv\/NxrvuNmo8RGWwuzuwjbEz719AvRpjgleI3eWwkJXrMXOc6nH4FkPsTSj1bqWwz+qWeKEuMTMBMf4GePgJVnWC8QrG4lbC8SXJ0qAm49I\/J0l1Qt4E0VA5XKgeBVKRs+jkW2X2Ff5CuuvEFs14zDHQLg7w5n1PIeAdl1QD\/9BpzsE7DyDJvt1ma\/VtzhJAE3nxF5uot+4wgn2+insiF4\/ZQtD2PVT89oaWmnq6+9SfwszatAv\/TFs6LOA1Z+NvGwKb6sGvx9mTZfBy2LK24Ie5z\/4pd3iCkNRy8+QiwaLC8vFT\/1y4uRfN1oB4NP9Bnm6QF87Ldfmdi1T7P61G\/37WDoKNqAgErPiLyuyeo200FMbLycQPAGMeMOtEm\/AtOoil1d3XTD\/7tz0iJFB0JKqyLBP63SrURj4y34lQPkXZmuufbXhgthlGiMAkEk+gzrP8C5KbEWairQxLQLQbVnRLM7GxoeptvvuE\/Mx063I15OIHjTrTck0V5tIRL7\/BYVRaIOG\/EWIyVRHW7VEQB\/dAm3CfAClM+ffarY6KMoUhh1frGyaNPtWP1QXyLPMFtYfe87X6Hi4iKxyVLnzi567B\/\/pof++k8\/NDnwMar0jMhiL53ndxvlBII38I8jGggCIAACIAACIAAC6U0Agje984\/WgwAIgAAIgAAIgEDgCUDwBj7FaCAIgICqBC7obKJLOrYZhnd9+f50W9l0cd7s2i9Xz6GnCktVbSriAgEQAAFPCUDweooflYMACKQzATMRy2w00Wvl2r8X7UffnnpgOiNF20EABEAgJgEIXnQMEAABEPCIgCZiX8kvpvOr51B\/Zigayc9bNlBJzw46VortGSLKM7j2lJ4d4kqM9HqUTFQLAiCgNAEIXqXTg+BAAASCTCCe4F3at5PWNq+lZyUAHyGin8YQvAV7dtPtzWvpqIFuwihvkHsM2gYCIJAoAQjeRMnhPhAAARBIkoCR4GUBe\/LW1XTVyKCoIVIQod7+XvHfl4Xz6JEZCyaMBvPftbIas3PpzP3nUXtWOMnocDsIgAAIBIcABG9wcomWgAAI+IyA0bzcBiIxlYH\/3S8nlz76ua\/Tk\/feRDuGh0QLDz3wqEmCl0eEb21eSxC8PusECBcEQMAVAhC8rmBGJSAAAiAwmYCR4P0xEV2x7\/JFx3yCag+aR8VPP0y3blkv\/lpZWk2R\/WZMKBCCFz0MBEAABIwJQPCid4AACICARwRiTWkYGx2mhs2rREQVU2to6Qlniv8++a2X6bbXno\/O6Z1ZewRlZedEI8eUBo+SiGpBAAR8QQCC1xdpQpAgAAJBJBBL8DY31tPgQI9obnXNIcKVgQ++9oiObVHXhrz8IqqumRfFwq4O7NSARWtB7CloEwiAQLIEIHiTJYj7QQAEQCBBAnrB2zHUR82Na0RpB+1\/AM2unR8t+fRt6+lzm9+hU8I59PDI8ARBLE+NgC1ZgsnAbSAAAoEmAMEb6PSicSAAAioTkAXvuRWzqKF9sxjdjeQX0olHf1T8qx2f2FBPp7zzpvi\/Gfv+OJOItkgNxOiuytlGbCAAAl4SgOD1kj7qBgEQSGsCsuA9PVJGjW2bBY8jZi+gI+YcOoGNLHjlRW13EdHyUBadN\/1gWp37nkBOa7BoPAiAAAjoCEDwokuAAAiAgMcE5IVqPKp71keXm0Z0\/5N\/o96BPnFd3ezFptfjAhAAARBIZwIQvOmcfbQdBEBACQJtrRupt7tdxHLi0R+jaeWVpnFt72ijR198QlwXKa6gyqo603twAQiAAAikKwEI3nTNPNoNAiCgBAF5dHdqeSWddPTHLMe18sUnqKWjTVwvOzpYLgAXggAIgECaEIDgTZNEo5kgAAJqEtBsyHgqw4cPW2xpdFdrCU9p4KkNfOhtytRsLaICARAAAW8IQPB6wx21ggAIgAANDnRHbcgqyqfRKUcvsU3l2TdfovXbNmGU1zY53AACIJBOBCB40ynbaCsIgIAyBHgqQ1vrBmFDVhAuoKmzDqXD9p9GU\/LzbMd4x8P3int45zXegQ0HCIAACIDARAIQvOgRIAACIOABgZ7udmpv3ShqXjRzEQ3n59No5hgtPmCG7Wh4hJdHevkoLauh0vIa22XgBhAAARAIMgEI3iBnF20DARBQkoC8UI1Hd09ecDIN7xmj1f3NNKt8Cs0qL7Udt7yAjUd5ebQXBwiAAAiAwDgBCF70BBAAARBwmYBsQ7Zk9hKqiFSICJqHu2j7SLcY5c3NzrIVFWzKbOHCxSAAAmlGAII3zRKO5oIACHhLQB7dZaHLglc+eJS3NJJHc6eOi2A7B2zK7NDCtSAAAulEAII3nbKNtoIACHhOQLMh46kMi2Ytio7uaoF1jPbRlqHOhBawwabM8\/QiABAAAUUJQPAqmhiEBQIgEDwC8kK1WWWzhOCNdawdaKNQTgYdvv802xBWrX2LVq1bLe7DZhS28eEGEACBgBKA4A1oYtEsEAABtQjwVIamxnrif7WFakYR9u4eIha9idqU8WYUPNoLmzK1+gCiAQEQ8I4ABK937FEzCIBAGhHY2dFIOzsbRYvZhmxW+ay4rWfBy8L3uDkH2KYEmzLbyHADCIBAwAlA8AY8wWgeCICA9wRi2ZCZRQWbMjNCOA8CIAAC1glA8FpnhStBAARAICECRjZkZoXBpsyMEM6DAAiAgDUCELzWOOEqEAABEEiIwOBANzU3rhH3xluoZlQ4bMoSwo6bQAAEQGACAQhedAgQAAEQcIgAT2Voa91AgwM9YqEae+4W5BTYqg02ZbZw4WIQAAEQiEkAghcdAwRAAAQcIiDbkM2bNo\/mT5ufUE2psimrqKqjomL7G1okFDRuAgEQAAGFCEDwKpQMhAICIBAcAnZsyMxardmU8e5rU4sjZpdPOq\/ZlPGJutmLbd+PG0AABEDA7wQgeP2eQcQPAiCgJAG7NmRmjeDd13h6A9uUHdraSF955VmzW+iWoz5Cb1XVkGxTdg4R5VbPoacKS03vxwUgAAIgEBQCELxBySTaAQIgoAwB2YasIlIh5u6m4nitd6sY4T0zY9iW4OW6X3\/8L\/TG8JAI47NVB9ArxZWpCAllgAAIgIAvCEDw+iJNCBIEQMBPBJob66ML1Xj7YBa9qTiMFrCd+8aLtKhxM71cU0t3HX70hKpKhgbp2y88TvX9fXTsvjPTcvIpf+b7UhESygABEAABXxCA4PVFmhAkCICAXwgka0Nm1s5YC9iMBO\/Mrk666KWnKH90hDryC+kbQwP0hz17RBXVNYdQXn6xWXU4DwIgAAKBIADBG4g0ohEgAAIqEEiFDZlZO7QFbIftP42m5OeJy+MJ3i+99hz95shjxHUsfgtGR8R\/Z2Xn0MzaI8yqw3kQAAEQCAQBCN5ApBGNAAEQUIFAqmzIzNrCo7yjmWO0+IAZcQWvXI422vvn0RE6d98J2JSZkcZ5EACBoBCA4A1KJtEOEAABTwnIC9V4k4mTF5zsWDzDe8aId2CbVT6FZpWXGo7wxhK8PL2hPCeXOvctYINNmWNpQsEgAAIKEYDgVSgZCAUEQMC\/BNpaN1Jvd7toALsypGqhmhERzaaMR3m\/\/PYrhovWtPvl+bzfmPs+uuHd\/4pTkeIKqqyq8y94RA4CIAACFghA8FqAhEtAAARAIB4Bp2zIzKhrNmXXtWywJXjZn\/fqTe9SS0ebqAIL2MxI4zwIgIDfCUDw+j2DiB8EQMBzAk7ZkJk1TLMpu7OniY5p2RbTlizWCC8L3heKphDvwMZHXn4RVdfMM6sO50EABEDAtwQgeH2bOgQOAiCgAgGnbcjM2sgL2K5ueYc+uavVluDlHdieffMlsQsbRnnNKOM8CICA3wlA8Po9g4gfBEDAMwI8laGpsZ74X6cXqhk1km3KvrDpBTqlZ4dtwctl3vHwvaJo2JR51o1QMQiAgAsEIHhdgIwqQAAEgklAtiFbNHMRzSqf5UlD9TZldoLgEV4e6eWjtKyGSstr7NyOa0EABEDAFwQgeH2RJgQJAiCgGgE3bcjM2q63KTO7Xn9+5YtPRBew8WYUPNqLAwRAAASCRACCN0jZRFtAAARcI+C2DZlZw5qHu2j7SLfYjCI3O8vs8gnnt3e00aMvPiH+BpsyW+hwMQiAgE8IQPD6JFEIEwRAQB0C8uguOxyccvAJSgTHm1GURvJo7tQK2\/HIo7ywKbONDzeAAAgoTgCCV\/EEITwQAAH1CGg2ZKGCCNVUHkRV+WU0K7fM80A1m7LD9p9GU\/LzbMXTO9AHmzJbxHAxCICAnwhA8PopW4gVBEDAcwLyQrW82jm03\/6HULilhebkV1IklOt5fLyALZSTQYfvP812LKvWvkWr1q0W91VU1VFRsf2RYtuV4gYQAAEQcIEABK8LkFEFCIBAMAjINmQ8uluxbIVoWP7b9VS0O1OIXq8Ptilj0cvTGqYWR2yHw5tR8GgvH3WzF9u+HzeAAAiAgIoEIHhVzApiAgEQUJLAzo5G2tnZKGIrWbSE8mrniv8O9fZR7vr1yozybhnqJJ7ecNycA2xzhE2ZbWS4AQRAwAcEIHh9kCSECAIg4D0BeaGaPLqrRcaCN79\/iBYUVHsfLBG91rtVjPAmu4ANNmVKpBNBgAAIJEkAgjdJgLgdBEAgPQhoC9W4tWVLllO4cqKwzRgZEVMbePFaeXah51BgU+Z5ChAACICAQgQgeBVKBkIBARBQk8DgQDc1N64RwfFCtZJFS2MGmtOwlbI6O+nIyAwlGsI2ZXm52QktYOPd13h6Ax+wKVMinQgCBEAgCQIQvEnAw60gAALBJ8BTGdpaN9DgQA\/xVIaypcspVFBk2PCCVW+IEV4VbMq0BWyJ2JRxA+94+N5xkZ9fRNU184KfbLQQBEAgsAQgeAObWjQMBEAgFQRkG7LC+QspMn9h3GJ5hJdHelWyKRvNHBM7sNk9YFNmlxiuBwEQUJUABK+qmUFcIAACnhMwsiEzC4wXsJUMjClhUza8Z4x4agNsysyyhvMgAAJBJgDBG+Tsom0gAAJJEZBtyGItVDMqPKg2ZZHiCqqsqkuKKW4GARAAAS8IQPB6QR11ggAIKE9AtiELV1SLubt2jqDalGEBm51egGtBAARUIQDBq0omEAcIgIBSBDQbMl6oxq4Mehsys2A1m7Jp4WKqzikxu9zx87wRBW9IkcgCtu0dbfToi0+IGLGAzfFUoQIQAAEHCEDwOgAVRYIACPibgFUbMrNWZm9voXBLi9iMIiczy+xyx8\/zlsOhnAzYlDlOGhWAAAioRgCCV7WMIB4QAAFPCdi1ITMLljej2G9vOFA2ZVnZOcQ7sOEAARAAAb8QgOD1S6YQJwiAgCsE7NqQmQUVJJsy3oiCN6Tgo6KqjoqKK8yaj\/MgAAIgoAQBCF4l0oAgQAAEVCAgL1TjubsVy1akJCwVbcpmlU+hWeWlttu38sUnqKWjTdzHo7w82osDBEAABFQnAMGreoYQHwiAgGsE2lo3Um93u6jPjg2ZWYCaTRnvvsa7sHl9NA930faRbrEZRW62vbnF8gI22JR5nUnUDwIgYJUABK9VUrgOBEAg0ASStSEzg8O7r\/H0hiMj9nc8Mys7kfO8GUVpJE9sSGH3kEd5YVNmlx6uBwEQ8IIABK8X1FEnCICAcgSStSGz0qCCVW9QEGzKegf66P4n\/yaaDJsyK5nHNSAAAl4TgOD1OgOoHwRAwHMC8kK1vNo5wnfXiQM2ZU5QRZkgAAIgYE4AgtecEa4AARAIMAGeytDUWE\/8byoXqhkhY5uyot2ZNCe\/0nOqvbuHiL15eVrD1OKI7Xh4lJdHe2FTZhsdbgABEHCZAASvy8BRHQiAgFoE5NHdkkVLKK92rqMBqmhTxsL3uDkH2G63bFNWWlZDpeU1tsvADSAAAiDgBgEIXjcoow4QAAElCThlQ2bWWJVsyjjW13q3UiI2ZbsGBsWWw4MDPaLJsCkzyzzOgwAIeEUAgtcr8qgXBEDAcwJO2ZCZNSwINmVDo2P0Tks77erZTps2vSuaDJsys8zjPAiAgFcEIHi9Io96QQAEPCUwONBNzY1rRAxOLlQzaqSKNmV5udl0+P7TLOWlpbuX3m1pp8MO7KEXXt1MLe0D4j7YlFnCh4tAAARcJgDB6zJwVAcCIKAGAdmGrGzpcgoVFLkeGNuU8UYUvCGF10fHaB9tGeqkw\/afRlPy8+KGw6O7b2xrpilF\/TR3Rj\/19o\/S\/Y9sGv\/ykF9E1TXzvG4O6gcBEACBCQQgeNEhQAAE0o6AWzZkZmBVXMAWyskwHeXd0rGTWno66fCDeig3vEc0c9XbHbSqvkP8d0VVHRUV29\/QwowXzoMACIBAogQgeBMlh\/tAAAR8ScBtGzIzSCotYLNiU8ajuy9t2kqzpg6K\/8kHj\/LyaC8fdbMXmzUd50EABEDANQIQvK6hRkUgAAIqENjZ0Ug7OxtFKG7YkJm1WVvAxr68kVCu2eWOn+dpDTy9wcim7I1t22lorJ8Wz+uaFMv6Ld307Mst4u+wKXM8VagABEDABgEIXhuwcCkIgIC\/Ccg2ZOGKauK5uyocPMqb3z9ECwqqVQhH2JTxRhS8IYV8sA3Zm9u2i3m7U8uGY8a68ult0QVssClTIp0IAgRAgIggeNENQAAE0oaAtlCNG1y2ZDmFK9UQmBkjI8Q7sE0LF1N1Tonn+Yi1gE2zIaPMHjr8oF7DGLe3D9CjT28T57GAzfNUIgAQAIF9BCB40RVAAATSgoDXNmRmkLO3t1C4pUWM8uZkZpld7vh53nJYXsAm25BNiYzFrZ+nNfD0Bj5gU+Z4qlABCICABQIQvBYg4RIQAAF\/E+CpDG2tG8SOYKGCiJjK4IUNmRlFHuXdb29YCZsybQEb25TlZWdPsCEzawefv+P+tRjltQIK14AACLhCAILXFcyoBARAwEsCsg1Z4fyFFJm\/0MtwDOtW0aZsNHNMzOfV25CZAYRNmRkhnAcBEHCTAASvm7RRFwiAgOsE5IVqPLpbsWyF6zHYqVAlm7LhPWO0ur9ZhB\/LhsysXbApMyOE8yAAAm4RgOB1izTqAQEQ8IRAW+tG6u1uF3WrtFDNCIZqNmXNw120faRb2JBpm0xYTaS8gC1SXEGVVXVWb8V1IAACIJBSAhC8KcWJwkAABFQioKoNmRkj1WzKeJS3dMr4NsJ2D9mmDAvY7NLD9SAAAqkiAMGbKpIoBwRAQDkCmg0ZT2UoWbRUGRsyM1DK2pQd2ENmDg36tsGmzCzbOA8CIOAGAQheNyijDhAAAdcJqG5DZgZESZuyvN64HrxGbYJNmVm2cR4EQMBpAhC8ThNG+SAAAq4T0NuQqb5QzQiQkjZlCYzycvs0m7Ks7BziHdhwgAAIgICbBCB43aSNukAABFwhINuQlSxaQnm1c12pN9WVKGlTFhoQC9jsHrwRBY\/08lFaVkOl5TV2i8D1IAACIJAwAQjehNHhRhAAARUJ+M2GzIyhijZliViUcTvlBWw8ysujvThAAARAwA0CELxuUEYdIAACrhHwmw2ZGRjNpmxWbhmVZxeaXe74ediUOY4YFYAACDhAAILXAagoEgRAwBsCfrUhM6OV07CVeHrDkZEZZpe6ch42Za5gRiUgAAIpJADBm0KYKAoEQMBbAn61IbNCrWDVG2KEl0d6vT46Rvtoy1AnHZbAArbe\/lHiHdj4yMsvouqaeV43B\/WDAAikAQEI3jRIMpoIAulAQF6ollc7R\/juBulQcQFbKEGbslVvd9Cq+g6RHmxGEaReiraAgLoEIHjVzQ0iAwEQsEiApzI0NdYT\/8ubTPjVhsysuWxTVrQ7k+bkV5pd6vj53t1DtHagTey+NrVs2HZ9PMrLo72wKbONDjeAAAgkQACCNwFouAUEQEAtAkGxITOjqi1gY8EbCeWaXe74eZ7WwNMbjjt8p+26YFNmGxluAAEQSIIABG8S8HArCICA9wSCZkNmRpRtyvL7h2hBQbXZpa6cf613qxjh5ZFeuwdsyuwSw\/UgAAKJEoDgTZQc7gMBEFCCQNBsyMygZoyMEE9tgE2ZGSmcBwEQAIH3CEDwojeAAAj4lsDgQDc1N64R8QdxoZpRYjSbMh7lzcnM8jx\/bFOWlz9Ihx\/UazsWeZQXC9hs48MNIAACFglA8FoEhctAAATUIsBTGdpaN9DgQI9YqFa2dDmFCorUCtLBaFSyKdMWsMGmzMGEo2gQAIGkCEDwJoUPN4MACHhFIOg2ZGZcVbQpGw0N0OJ5XWahTzov25RVVNVRUXGF7TJwAwiAAAjEIwDBi\/4BAiDgOwLpYkNmlhhewFYyMBYomzJuc93sxWZNx3kQAAEQsEUAgtcWLlwMAiCgAoGdHY20s7NRhFKyaAnl1c5VISzXYwiqTVmkuIIqq+pc54kKQQAEgksAgje4uUXLQCCQBGQbsnBFtZi7m84HbMrSOftoOwiAgFUCELxWSeE6EAABJQg0N9ZHF6rx9sHhSjX8aL2Co9mUTQsXU3VOiVdhROvljSh4Q4pEFrBtbx+gR5\/eJsrKyy+i6pp5nrcHAYAACASDAARvMPKIVoBAWhBIVxsys+Rmb2+hcEuL2IxCBZsy3nI4lNebkE3Zsy+3EO\/Cxgdsyswyj\/MgAAJWCUDwWiWF60AABDwlkO42ZGbweTOK\/faGxYYUXh\/J2JRx7Hfcv1Y0ISs7h2bWHuF1c1A\/CIBAAAhA8AYgiWgCCKQDAdmGrHD+QorMX5gOzbbcxiDZlPEIL4\/08gGbMstdABeCAAjEIQDBi+4BAiCgPAF5oRpvMlGxbIXyMXsRoEo2ZcN7xoh3YJs1dVD8z+5x\/yObqLd\/VNwGmzK79HA9CICAngAEL\/oECICA8gTaWjdSb3e7iLNsyfK0X6hmlDDNpoynNZRnF3qe1+bhLto+0i02o8gN77EVj7yADTZlttDhYhAAgRgEIHjRLUAABJQmABsye+nJadhKPL3hyMgMezc6dDWP8pZO6ae5M\/pt17Dy6W3U0j4g7sMCNtv4cAMIgIBEAIIX3QEEQEBpArAhs5+eglVvUBBsynhKA09t4AM2Zfb7Ae4AARB4jwAEL3oDCICAsgRgQ5ZYamBTlhg33AUCIBBcAhC8wc0tWgYCviagtyHDQjV76WSbsqLdmTQnv9LejQ5cDZsyB6CiSBAAAVsEIHht4cLFIAACbhGQbchKFi2hvNq5blUdiHq0BWwseCOhXM\/bxJtRjIYGxAI2u4dsU1ZaVkOl5TV2i8D1IAACaU4AgjfNOwCaDwIqEoANWWqywjZl+f1DYgc2r49kbcrkBWy8GQVvSoEDBEAABKwSgOC1SgrXgQAIuEYANmSpQQ2bstRwRCkgAAL+JwDB6\/8cogUgECgCsCFLbTphU5ZanigNBEDAnwQgeP2ZN0QNAoElABuy1KeWbcp4IwrekMLro2O0j7YMddJhB\/bQlMiYrXBgU2YLFy4GARCQCEDwojuAAAgoQ0BeqJZXO4dKFi1VJjY\/B8IbUfBIr0oL2EJ5vXT4Qb22sa56u4NW1XeI+7AZhW18uAEE0pYABG\/aph4NBwG1CPBUhqbGeuJ\/QwURgg1ZavPDC9hKBsaUsinj3demlg3bbihvRsGjvbxwjRew4QABEAABMwIQvGaEcB4EQMAVAjs7GmlnZ6OoCzZkqUeumk0ZT2vg6Q3HHb7TdmNhU2YbGW4AgbQnAMGb9l0AAEDAewKwIXMnByrZlHGLX+vdKkZ4eaT30KY++srzTaYgbvnQdNpalksvrtxEL+7eK67fQkQPle9Pt5VNN70fF4AACKQnAQje9Mw7Wg0CShHQFqpxUGVLllO40nvfWKUApSiYjJER4h3YpoWLqTqnJEWlJl5M83AXbR\/pFptRHNXeY0nwPnhYBX1yTSe9OrKbjt1X9TlEdBcRXQ\/Rm3gycCcIBJwABG\/AE4zmgYDqBAYHuqm5cY0IEwvVnM+WZlPGm1HkZGY5X6FJDav7mykvf3DSArZz\/9NCixq66eWZxXTXB6ZGS\/nEO510yls7qKMwmw7PzaLGjkFx7hkiOiA7l87cfx61Z4U9bxcCAAEQUIsABK9a+UA0IJBWBHgqQ1vrBhoc6BEL1cqWLqdQQVFaMXCzsdoIL9epik1Z7+4h4m2H9TZlsQRv7uge+upzTXRQ+4AQwjcuKCdewMbHR4jo76EsOm\/6wbQ6t9BNrKgLBEDABwQgeH2QJIQIAkElINuQFc5fSJH5C4PaVCXaJUZ3d3UThUuIhjqUsikbDQ2IqQ3aYTTCqwcp25RdH8qmh2YeihFeJXobggABtQhA8KqVD0QDAmlDADZk7qY6OrqbW06UXUg00EoRImVtyqwK3pk7h+j2Jxpo6\/j6NaqbvdhdsKgNBEDAFwQgeH2RJgQJAsEjABsyd3PKDg2h\/iGign1OBruHhOjl3dd4eoPXh96mzIrgZbF70TON9OeR3XTuvgZEiiuosqrO6+agfhAAAcUIQPAqlhCEAwLpQEC2IQtXVIu5uzicI6DttEb5VUSh3PcqGmgl2j1ER0ZmOFe5jZJlmzIzwSvbmOkXsGEHNhvQcSkIpAkBCN40STSaCQIqEdBsyHihGm8fDBsy57LDUxny1q2njN2ZJASvfOwZI+pvUsamjDei4JFeXsD2zfrGmC4NHL4sdtdX5NPNx0ynzbuG6NGnt4nW5eUXUXXNPOegomQQAAHfEYDg9V3KEDAI+JsAbMjczd\/O9FMAACAASURBVJ8Y3d3WTJRXRRTLhmy4i2iki1SxKWPHhlBeL93UuT6m4NWmMeSP7CZN7A5lZwqoz77cQrwLGx8Y5XW3n6E2EFCdAASv6hlCfCAQIAKwIXM3mdGFajxHlxerGR39TVQeyhXzeb0+NJuyO\/veoWOauyb58GpTHWLFORAOUcHIbnEqKzuHZtYe4XVzUD8IgIAiBCB4FUkEwgCBdCAAGzJ3sxy1IdMWqhlVP9qnnE3ZFdtX00ldHRMEb8ngGH37qa1U3jcasyUseFccNIUerO8Q5yuq6qiouMJd6KgNBEBASQIQvEqmBUGBQPAIyAvVeO5uxbIVwWukQi2aZENmFptCNmXDe8aId2CbNXVQ\/M\/usfLpbdTSPiBug02ZXXq4HgSCSQCCN5h5RatAQDkCba0bqbe7XcRVtmQ5Fqo5nKFJNmRm9SlmU9Y83EXbR7rFZhS54T1m0U84v719ILqADTZlttDhYhAILAEI3sCmFg0DAXUIwIbM3VwY2pCZhTHUQTTap4xNGY\/ylk7pp7kz+s0in3ReHuXFAjbb+HADCASOAARv4FKKBoGAegRgQ+ZeTqI2ZHvD8ReqGYXU2yA2olBhAZtsUzYlMmYLYm\/\/KN3\/yCZxD2zKbKHDxSAQSAIQvIFMKxoFAuoQkBeq5dXOEb67OJwjkL29hcJtO4xtyMyqVnABG9uUHX5Qr1nkk87Dpsw2MtwAAoElAMEb2NSiYSDgPQGeytDUWE\/8LxaqOZ+P6EK1cAlRTkniFSq0gE2zKePNKOyO8jKAO+5fKzjApizx7oA7QSAIBCB4g5BFtAEEFCUgj+6WLFpCebVzFY00GGHZXqhm1Ox9C9jm5FdSRN6K2CNMvBnFaGhALGCze\/BGFDzSy0dpWQ2VltfYLQLXgwAIBIAABG8AkogmgICKBGBD5m5WQr19xIJXbB+cCpE60Eo5e8fEDmxeH6m0KePNKHi0FwcIgEB6EYDgTa98o7Ug4BoB2JC5hpp4KkNOQwOFBsbGBW8qjj1jRP1NNC1cTNXJTI9IRSxEBJuyFIFEMSCQpgQgeNM08Wg2CDhJQB7dxUI1J0mPly1syLY1j7sypGJ0Vwt5n00Zj\/LmZGY53xCTGmBT5nkKEAAI+JYABK9vU4fAQUBdArINWdnS5RQqKFI3WJ9HFl2oll2YmA2ZWfv7m6g8lAubMjNOOA8CIKA0AQhepdOD4EDAfwRgQ+ZuznIatlLWru7EbcjMwg2QTdmqtztoVX2HaHFFVR0VFVeYtR7nQQAEAkIAgjcgiUQzQEAFArAhczcL0dFdnsrAI7xOHQralPHua1PLhm23mDej4E0p+Kibvdj2\/bgBBEDAnwQgeP2ZN0QNAkoS2NnRSDs7G0VssCFzPkUpsyEzC1Uxm7ItQ53Eu7Add\/hOs8gnnYdNmW1kuAEEAkEAgjcQaUQjQMB7ArAhczcHKbchMwtfIZsyDvW13q1ihJdHeu0eK5\/eRi3tA+I22JTZpYfrQcCfBCB4\/Zk3RA0CyhHQFqpxYGVLllO40nv\/VuUgpSggR2zIzGKDTZkZIZwHARBQmAAEr8LJQWgg4BcCgwPd1Ny4RoQLGzLns+aYDZlZ6MNdRCNdYjMKVWzK8vIH6fCDes0in3Sed1\/j6Q18VNccQnn5xbbLwA0gAAL+IQDB659cIVIQUJIAT2Voa91AgwM9FCqIEGzInE2T4zZkZuErZFPWu3uIeNvhww7soSmRMbPIJ52\/4\/6141\/S8ououmae7ftxAwiAgH8IQPD6J1eIFASUJCDbkBXOX0iR+QuVjDMoQUVtyAqme9MkBW3KRkMDtHhel20esCmzjQw3gIBvCUDw+jZ1CBwEvCcAGzJ3c+CaDZlZs2BTZkYI50EABBQjAMGrWEIQDgj4iUBb60bq7W4XIWOhmvOZc82GzKwp+2zKZuWWUbmT\/r9mcew7nyqbskhxBVVW1VmsFZeBAAj4iQAEr5+yhVhBQCECsg1ZuKJazN3F4RwBsVCtYStRfhVRKNe5iqyWPNRBNNpHR0ZmWL3D0etSZVOGBWyOpgmFg4BnBCB4PUOPikHA3wQ0GzJeqFayaClsyBxMJ09lyFu3njL2hol4VzVVjt4GMcLLI71eH7wRBY\/0JrKAbXv7AD369DbRBCxg8zqTqB8EnCEAwesMV5QKAoEmABsyd9Obvb2Fwm07iPKqiDKz3K08Xm0KLmAL5fXCpkydHoJIQEAZAhC8yqQCgYCAPwjAhszdPHluQ2bW3P4mimRk0Zz8SrMrHT+fKpuyrOwcsQMbDhAAgeAQgOANTi7REhBwhYBsQ1ayaAnl1c51pd50rcRzGzIz8PsWsLHgjSgwt5h9eRO1KeONKHhDCj5Ky2qotLzGrPU4DwIg4BMCELw+SRTCBAEVCMgL1XjubsWyFSqEFdgYQr19xM4MYt6uAm4IhqAHWiln75jYgc3rY3jPGK3ub6ZZUwfF\/+weK5\/eRi3tA+I2HuXl0V4cIAAC\/icAwev\/HKIFIOAaAdiQuYaaeCpDTkMDhQbGxp0ZVD72jBH1N4nFayrYlDUPd9H2kW6xGUVueI8tcvICNtiU2UKHi0FAaQIQvEqnB8GBgDoEYEPmbi6UsyEza\/4+mzIe5c1RYGEdj\/KWTumnuTP6zSKfdF4e5YVNmW18uAEElCQAwatkWhAUCKhHADZk7uVEWRsyMwQBsSnr7R+l+x\/ZJFoLmzKzpOM8CPiDAASvP\/KEKEHAUwLyQrW82jnCdxeHcwSUtSEza3KAbMpWvd1Bq+o7RIsxymuWeJwHAfUJQPCqnyNECAKeEuCpDE2N9cT\/YqGa86mI2pCFS4hySpyvMNU1DLRShCgQNmU8ysujvbApS3UnQXkg4D4BCF73maNGEPAVAdiQuZsudmUI9Q8RFUx3t+JU1QabslSRRDkgAAIpJADBm0KYKAoEgkYANmTuZjRqQ8auDAp42ibcetiUJYwON4IACDhDAILXGa4oFQQCQQA2ZO6l0Vc2ZGZY9tmUTQsXU7UC0zJgU2aWMJwHgeATgOANfo7RQhBIiMDgQDc1N64R92KhWkIIbd0kbMi2NY9vMuHn0V2t1cNdRCNdYjMK2JTZ6gq4GARAwAECELwOQEWRIBAEArINWdnS5RQqKApCs5RsQ3ShGu+mxoI3KEd\/E5WHcsWGFF4fHaN9tGWokw47sIemRMZshQObMlu4cDEIKEkAglfJtCAoEPCWAGzI3OWf07CVsnZ1+3ehmhGugNqUVVTVUVFxhbudBLWBAAgkRQCCNyl8uBkEgkcANmTu5jQ6ussjuzzCG7RDQZsy3n1tatmwbdKaTRnfWDd7se37cQMIgIB3BCB4vWOPmkFASQI7OxppZ2ejiK1k0RLKq52rZJxBCcr3NmRmidhnU8bTGsoVEPQ8rYGnNxx3+E6zyCecHxrJpFdWD9C6DQ3i76VlNVRaXmOrDFwMAiDgHQEIXu\/Yo2YQUI6AbEMWrqgmnruLwzkCgbEhM0M01EE02kdHRmaYXenK+dd6t4oRXh7ptXq0dObQ2m0FYiHnQH+3uG1m7RFiUwocIAAC6hOA4FU\/R4gQBFwjoC1U4wrLliyncGW1a3WnW0U8lSFv3XrK2J1JxL67QT96G8ivNmU8uvvG+iIa3Z1JI0M9tGVzvchWXn4RVdfMC3rm0D4QCAQBCN5ApBGNAIHkCcCGLHmGdkoInA2ZWeMVtCnLyx+kww\/qNYuctrTkUUNrHoWzMygjg6ipcQN17WoX91XXHEJ5+cWmZeACEAABbwlA8HrLH7WDgBIEeCpDW+sGGhzooVBBRExlgA2Zc6kJrA2ZGbL+JopkZNGc\/EqzKx0\/37t7iNYOtJnalPHo7kv1JZQVIsrKyojGVb\/6RfHfPKWBpzbgAAEQUJsABK\/a+UF0IOAKAdmGrHD+QorMX+hKvelaSWBtyMwSum8BGwveiAKba7DgHQ0N0OJ5XYaRv7E+Qt392ZQTfk\/s8sXtbduovW18cSdsyswSj\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\/0A3XTIZBsm+V5VBW\/UhixcQpRTolyv0QRv85e\/T9u\/8gPl4kNA6hGYc97x1PPfVyF41UsNInKAAASvA1BRJAi4QUC2IStZtITyaue6Ua1hHZpofXDWbLrwAx+NXieP3upHeisH++nvTz5EM\/p6oterKnjZlSHUP0RUMN1TzkaVQ\/AqmRalg4LgVTo9CC7FBCB4UwwUxYGAGwRUtCEzErzMQxa22ijv+zrb6f5nHqbikWHaVlgk\/uX\/qSh4ozZk7MoQynUjxbbrgOC1jSztb4DgTfsukFYAIHjTKt1obFAIqGhDFk\/wMnft\/EuV1XTOMSdQXU8X3fbi43TB0ceLtGjiVzXB6xcbMgjeoDzd7rUDgtc91qjJewIQvN7nABGAgC0CqtqQmQner69ZRd976z+kCd6+7HC03fJor2qCV9iQbWse32RC0dFdBpmI4P3fZx6lb194hmH\/++RJZ9GPr\/mtrf4Z7+KB\/j665MLTqbKyOloux\/DMk39PaT0pCzjgBUHwBjzBaN4EAhC86BAg4DMCqtqQBVHwRheq8W5qLHgVPpIRvD+\/8U\/04WNPdLx1esEbSwA7HgQqiBKA4EVnSCcCELzplG201fcE5IVqebVzqGTRUmXaZCZ49VMa\/DDCm9OwlbJ2dSu7UE1OPgSvMo+CbwKB4PVNqhBoCghA8KYAIooAATcIqGZDpm9zPMErOzXEsiZTcUpDdHSXR3Z5hFfxw2nBu6O9hc4\/52PU1Lg5SkKe8qCdX3baObTiC5dEr7nnzuvp3rt+RTfe9jDNnDU7OqXhqxdfNaG8ouIp4pqD5022rVMcvW\/Dg+D1beoQeAIEIHgTgIZbQMALAjs7GmlnZ6OoWgUbMjuCVxPDRhtQqCh4Vbch0\/N3UvDGErPv1K+iCy9YRp879xtC4NoVvDw3GFMavHiTvFcnBK+3\/FG7uwQgeN3ljdpAICECKtqQGQneeA002nhCNcHrBxuyVAreWDmTR295lPbhh+6m2+9+gvarmBq9\/Mff\/yK1tTXT9Tf+hfr7e8WIrdURXgjehF4FKb0JgjelOFGY4gQgeBVPEMIDASagLVTj\/y5bspzC\/7fKXbUj3k5rWwuL6JSPnkZteQUxw1ZJ8PrFhiyVgtfOojVtZLene5cI4YiFx0DwqvYwWowHgtciKFwWCAIQvIFIIxoRZAKDA93U3LhGNFG1hWpB5O4XGzI3Ba9+\/q42+osRXn8\/ARC8\/s4fordHAILXHi9cDQKuEuCpDG2tG2hwoIdCBREqW7qcQgVFrsaQTpX5yYbMTcHLwnb1f1\/BlIaAPQwQvAFLKJoTlwAELzoICChMQLYhK5y\/kCLzFyocrf9D85MNmVuCV1tYxvXxXN38gnHHCm3Ut3Lq9LhTGlgsv\/Dc45NcGjCH1\/vnBYLX+xwgAvcIQPC6xxo1gYAtAqrbkNlqjA8u9psNmVuCl+uRRatmG8Z\/+8fK+6NzeFkI60eCtZ3cNMsx2ZZM28FNnhahiWkfdJdAhAjBG4g0ohEWCUDwWgSFy0DAbQKyDZmqC9XcZuJkfarZkI1N7aeeEzfTzv95WzQ7q6WAilbWUulv5sfE4KQtmSZ6WeBqx1cvvlL8p+axy0JYGw1e9epz4hwvaDt5+Qq6\/qffijnCy9fI2xvbWTznZF9Il7IheNMl02gnE4DgRT8AAQUJyDZk4YpqMXcXh3MExEK1hq1E+VVEoVznKrJYMovdptufIv5Xf7DwnXnyskl\/T0TwWgwHlwWUAARvQBOLZsUkAMGLjgECChLQbMh4oRpvH6yiDZmC2BIKiacy5K1bTxl7w0S8q5oCx84vvR0d2aV\/fZzogTOJznyA6OP\/EtGV3jF\/0kgvBK8CifNZCBC8PksYwk2KAARvUvhwMwikngBsyFLPNF6J2dtbKNy2gyiviigzy93KDWpreOTh8dFdFrvHP\/7eVY8fHxW9dUd+ZsLdELxKpM5XQUDw+ipdCDZJAhC8SQLE7SCQSgKwIUslTfOyogvVwiVEOSXmN7h0xcbX\/jhe07l3Ed19znu1nnM30V3niv\/P0xp4eoN2QPC6lJwAVQPBG6BkoimmBCB4TRHhAhBwjwBsyNxjzTWptlBNa73ZCG+sebwQvO72nSDUBsEbhCyiDVYJQPBaJYXrQMBhAvJCNZ67W7FshcM1pnfxod4+IXjFvN3scW9ZVQ6zObyRR2up8opFE8KF4FUle\/6JA4LXP7lCpMkTgOBNniFKAIGUEGhr3Ui93e2iLNiQpQSpYSE8lSGnoYFCA2PjzgwKHs23PUWDR4z3B\/mAS4OCyfJpSBC8Pk0cwk6IAARvQthwEwiklgBsyFLL06w0YUO2rXl8dFcBGzKjeOWRXid8eLV6tV3TLvr2tfThY08Uf9Y2ltCuieWRe8+d19PNN1weDZ+9eVd84RIz\/JToffqCtbibGjeLU9Nraidtf2y1LbGCtsLAtLFE9E79KrrwgmXU071LXM7+xPKudfw3q23R12dWNvscP\/CHmyfVx+VA8FrJHq4JCgEI3qBkEu3wNQHYkLmXPhVtyFLR+mSmNLCwE8Lwmt9Gxe7q\/74SFY\/a5hCyoGXRKm86oQmvDx5zfLScWO1K9D4jsbvgfUdNiFvbxljeEc6sLUZiN5H7jATp5879hvgyoG3O0dbSFOWriV2ztiRStib45fxq5UDwpuLJQxl+IQDB65dMIc7AEpAXquXVzhG+uzicI6CiDVkqWpuo4GUx+\/9+\/r2o+NKE62VX3RYd7dVEU1tbsxgp7O\/vpfPP+RgtO+2cCSO6LGYffujumKOsXIYm7OzeZySc9XXpy7fSlljbGSd6n5Fw1rhpdenLj8XNiJVcR6xtmWPFzn\/7wbdX0E9+fg9pXwS4HAjeVDx5KMMvBCB4\/ZIpxBlIAjyVoamxnvhfLFRzPsWq2pClouWJCF5ttLGysjruqKxe8MYSiXyNmeA1amei9+nLsyISrbbFqnhNJHdGglouy2pb9PXHE+ui7ftG8SF4E8kc7vEzAQheP2cPsfuegDy6W7JoCeXVzvV9m1RugKo2ZKlglojgtSK8NCHLc3VjzePVYo817cFKuxK9T192rKkCserX5g\/Ha0sq7zMS5ZVTp8ecV8vXW22LnbKZ81WXXUA33vZwdJQXI7xWeiiuCQoBCN6gZBLt8B0B2JC5m7KoDRm7Mii8UC1RKokI3lgiSK5fE6P8t0+edFbMUWB50VSsxVhG7Un0vljlyYvLjISslbbEKjvR+4wE+apXn6Oi4ikThKd8rZW2JFJ2rC83ELyJPm24z48EIHj9mDXEHAgCsCFzL41+sCFLlkYigtfqVAKrI44s1vSLxqy0K9H79GVbWThntS2JjiBbaa+VUW0rbYkn0PWOGbGmSEDwWskWrgkKAQjeoGQS7fAVgcGBbmpuXCNixkI151PnFxuyZEgkInhZaMpOBPHq1wSY5jYQ69pYbgNW2pTofbHK1rtAxLrGSltSeV+ssqywt9IWq2VD8FrpibgmyAQgeIOcXbRNWQKyDVnZ0uUUKihSNla\/BxZdqMa7qbHvbkCPRASv1RFeRmZFJCYqXBO9D4I3dmeOJaYheAP64KNZlglA8FpGhQtBIDUEYEOWGo5WS8lp2EpZu7qJCqZbvcWX1yUieGPN4TWa16v9DM9zZPfbb6rYSEFvXWYmio0WyZndZzSKqbf74utksffOmlWTFmrxNXJbtI025DqsMIh1nz5OIxcM7e98Pdu8XfeTi8msLftVTJ1QvNWyjazQuDBMafDlo46gEyQAwZsgONwGAokQgA1ZItQSvyc6ussjuzzCG+AjEcEbS4DqxRgLJu26A2fPjzoL6EcRtRFERnz73U+QXqBp6BO9T5+6WCJZc2DQ5q9abYuRUNUEqREDK90plrjWFqZpC+ystCVWXVbK1u6DS4OVbOGaIBOA4A1ydtE25Qjs7GiknZ2NIi7YkDmfniDbkOnpJSJ4uQz9LmuyMP3Hyvuj1cTaNli\/RbDeycFo5DbR+\/Rt1m\/Ha+R+oN8iWN8Wo7myid5nJM61rYVjbYFspS2xpirotxaOt72yyDd8eJ1\/8aAGJQlA8CqZFgQVRAKwIXM3q2KhWsNWooDakKVK8JpZk7mbtfdq47gaNq+bsJObV7HEq\/fn13yTTjj5sxN2MFMtTuy0plpGEI8XBCB4vaCOOtOSgLZQjRtftmQ5hf9vdysczhDgqQx569ZTxu7MccGbBkeiI7xi1O\/7XxSE5NE\/r5FxTMd+9JQJ2xt7HZO+fh6Vvfx759GV1\/7OcAqHCjEb5RdzeFXIDmJwiwAEr1ukGdNCmwAAIABJREFUUU9aE4ANmbvpj9qQ5VURZWa5W7lHtSUjeLWf0y\/69rVKCEyO5+YbLqNLf3ADGW1j7BHmCdX6YRSaY3zgDzfH3NUNgleFXoQY3CIAwesWadSTtgR4KkNb6wYaHOihUEGEYEPmbFdIFxsyPcVkBK+zGUHpqhKA4FU1M4jLCQIQvE5QRZkgIBGQbcgK5y+kyPyF4OMggXSxITMSvL1Hfoh63v8hBwmj6KAQKH\/4PurY0UofqT0iKE1CO0DAkAAELzoHCDhIAAvVHIQbo+hQbx+xM4PYYCLgNmRGgtdd4qjN7wSas3MgeP2eRMRviQAEryVMuAgEEiPQ1rqRervbxc1YqJYYQzt3pZMNWSwuPK0hZcdIF9FoHx1aEMzFlW\/1N1MoRJQVykgZMisFXdqyhZZ0d9LTxWV03dRZhreUj43QL7auo6mjw\/Tj6XX0n8ISK8VPumZ0ZIi2bK4Xf8\/LL6KKqgMnXcOiFwcIBJ0ABG\/QM4z2eUZAHt0NV1SLubs4nCOQbjZkzpGUSu5toPLsQpqVW+ZKdW5W0jzcRdtHuiknnEEZLmreaxo30Em72mnllAr6fs1k8ckMvtjeRBe1bhU44l1nldeWTfXU398tLq+uOYTy8out3orrQCAwBCB4A5NKNEQ1ApoNGS9UK1m0FDZkDiYoakO2Nzw+nQFHaggMdxGNdNGCgmrKCaDbxer+ZhrLGKPsLPcUr13B2xTOpRUHzKf27HDCOe3v654wyltdMy\/hsnAjCPiVAASvXzOHuJUmABsyd9OTvb2Fwm07iNLIhsw1wv1NFMnIojn5la5V6VZFHaN9tGWok8LZGZSZ6U6tVgSvFol27WuFxfT1mXOpPzOUcJBNjRuoa9f49CqM8iaMETf6mAAEr4+Th9DVJKC3IatYtkLNQAMSVdSGLFxClJPYPMeAoHCmGbuHiAZaheCNhHKdqcPDUtcOtFH\/3iEhet047AjeY3t20o0N71JPKIvOn3UI1ecXJhVi\/eoXxf1Z2Tk0E84MSbHEzf4jAMHrv5whYsUJyDZkJYuWUF7tXMUj9nd46b5QzZXsDbRSzt4xMbUhaEfv7iFi0cvTGngRm9NHLMFbsGc33dTwLh3Z1z1hzm6qBe+uXe3U3LhBNLG0rIZKy2ucbi7KBwFlCEDwKpMKBBIEArAhczeLURsy3j44gKOP7tKMU9ueMaL+JrF4jRexBe3gaQ08vSE3x\/lRXqMRXm2hmjaauyU3LyqCUzGlQcuZvICNR3l5tBcHCKQDAQjedMgy2ugaAdiQuYaaeCpDTkMDhQbGiFjw4nCWwFCHsCk7MjLD2Xo8Kv213q2UxTZlDi9gMxK8FaMjdM+mt2n6yNAkAhfOnEvPFJWmhIy8gC1SXEGVVXUpKReFgIDqBCB4Vc8Q4vMNAdiQuZsqYUO2rXnclcHHo7s\/3\/IfOqVzS0x43aEwnXfQsbS6YKItWMXoID2w9kmqGe6L3nd99aF029RDnE1CEjZlU0YH6Udrn6IKKWY52HciFfSLumNoKJQd\/fOXt\/yHPtTZELdN7TmFdMWcpbQrOy+ptrtlUxZvDq88tYEbk6q5u3owsClLqqvgZp8SgOD1aeIQtnoEYEPmXk6iC9X453Wf25DFE7waUVnMLujvpN+tf4aKd49MAu646B3tIxrqSGgBm5ng5cb0h8L004OOpU0F46OZbgpero9tykZpzLUFbO49MRNrGhkZpvVrXxd\/5M0oYFPmVSZQr5sEIHjdpI26AktAXqiWVztH+O7icI5ATsNWytrVTVQw3blKXCpZE7x\/L5tF3571gWitBbtH6faNz9FRvW0kj\/Re0LKGLml+ixpzCunMOR+l9uw8ivU3x8IfaKUIkW2bMlnwXl\/3IVpV8l7uDujfSd9d\/wwV7B6hWCO93JZ496eqrV7YlKUqdrvltLdto\/a2RnEbbMrs0sP1fiQAwevHrCFmpQjwVIamxnrif3mTCdiQOZue6Oguj+wGYAGVkeBlivLUBR69vbfioKgIlgXy0q4munXjcxOEsWNZSNCmzEywHtHVRJdsfH7SKK\/WDrP7U9Vedmzo2zMkdmAL+rFu7es0OjIMm7KgJxrtEwQgeNERQCBJArAhSxKgzduDZkMWT\/AyGu38K5FKOr\/uGOqX5rhq6Fwd4eVKE7ApMxOs8vk\/VR9KD089eELPMLvfZjcyvNxtm7JUxZ1IObApS4Qa7vErAQhev2YOcStBADZk7qYhiDZkZoJXE7NGglee0+v4HF4t3ftsyqaFi6na4mYfZoI1d\/cofWvjc3Rwbzt5KXi5iW7alLn7BE2uDTZlXmcA9btFAILXLdKoJ5AEYEPmXlqDakOWjOCVxW68EWBHsjTcRTTSJTajyMnMMq3CT4KXG8M2ZbwRBW9IEeQDNmVBzi7aJhOA4EV\/AIEECQwOdFNz4xpxNxaqJQjRxm1BsSHTN9lM8BpNadDm7XJ58gI2G0iTv7S\/icpDuWJDCrPDTPCqMqVBa0c6LWCDTZlZ78X5IBCA4A1CFtEG1wnwVIa21g00ONAjFqqVLV1OoYIi1+NIlwqDZENmR\/DKTg3ydAVZ7Lo+sis3wIZNmZng1ZwauHjZmkyrzux+J54FXsDWv3cINmVOwEWZIOAyAQhel4GjumAQgA2Zu3kMkg2ZHcGrje7KtmSeTmOIlXaLNmXxBKt8zktbMn3ztAVs4ewMysx0t8+7XZtsU1ZRVUdFxRVuh4D6QMBRAhC8juJF4UEkABsyd7MaNBsyI8Ebj6o8upvIzmyOZmyfTRlPayiPYxOXyMYTctxejPBy\/eloU8btrpu92NFug8JBwG0CELxuE0d9views6ORdnaOG7aXLFpCebVzfd8mlRsQNBsyO4JXPzc31pbCcnlGWxE7nt+hDqLRPjoyMsOwKjPB+3zZTLpV2nhDX5BXgnd4z5jYgS0rRJQV8AVssClz\/ElBBR4SgOD1ED6q9h8B2YYsXFEt5u7icI6AWKjWsJUov4oolOtcRSg5eQK9DWTHpiz5Ct0roXm4i7aPdIvNKDKCbdpAsClzr1+hJncJQPC6yxu1+ZxAc2N9dKEabx8crqz2eYvUDZ+nMuStW08Ze8NEvKsaDrUJ2LQpU7sxk6PjUd6xjLG0sinLyy+i6pp5fksV4gWBmAQgeNExQMAiAdiQWQSVosuyt7dQuG0HUV4VkQWf1xRVi2KSIdDfRJGMLJqTX5lMKUrem042ZU2NG6hrV7vIQ3XNIZSXX6xkThAUCNghAMFrhxauTVsCsCFzN\/VBtiFzl6TLte1bwMaCNxLAKSjpYlPGvaZ+9Yui82Rl59DM2iNc7kioDgRSTwCCN\/VMUWIACcg2ZIXzF1Jk\/sIAtlKdJgXZhkwdyg5FMtBKOXvHxA5sQTtgUxa0jKI96UQAgjedso22JkRAXqjGm0xULFuRUDm4yRqBUG8fsTODmLcbx+bKWmm4ynUCFm3KXI8rRRXCpixFIFEMCLhMAILXZeCozn8E2lo3Um\/3+Hy2siXLsVDNwRTyVIachgYKDYyNOzPg8CcBCzZl\/mwYUTrZlPX3ddOWzfUiVZHiCqqsqvNr2hA3CBAELzoBCMQhABsyd7uHsCHb1jw+uhvAOaDu0vS4tt4GsREFb0gRtCNdbcqwgC1oPTm92gPBm175RmttEoANmU1gSVwOG7Ik4Kl462gf0VCHcGwI4gK2dLEpGxkZpvVrXxc9DDZlKj5oiMkqAQheq6RwXdoRgA2ZuymHDZm7vF2pbaCVIkSwKXMFtnOVwKbMObYo2T0CELzusUZNPiKgtyHDQjVnkxe1IQuXEOWUOFsZSnePAGzK3GPtcE2wKXMYMIp3nAAEr+OIUYEfCcg2ZCWLllBe7Vw\/NsM3MbMrQ6h\/iKhgum9iRqAWCaSBTVl2VgaFQhZ5+PSyXbvaqblxg4i+tKyGSstrfNoShJ2uBCB40zXzaLchAdiQuds5ojZk7MqAhWruwnejtj1jRP1NNC1cTNUBHL3fMtRJvAtbbk6GGzQ9rWPLpnrq7+8WMfBmFLwpBQ4Q8AsBCF6\/ZApxukYANmSuoSbYkLnH2tOahruIRrrEZhQ5Adwm+rXerWKEl0d6g3zApizI2Q1+2yB4g59jtNAGAdiQ2YCVgkthQ5YCiH4por+JykO5gbYpC2dnUGamXxKSWJzyKC9syhJjiLu8IQDB6w131KooAdiQuZeY6EI13k2NfXdxBJtAGtiUjdIYsegN8gGbsiBnN9htg+ANdn7ROhsE5IVqebVzqGTRUht341K7BHIatlLWrm4sVLMLzs\/XB9imrHf3EPG2w+kwytveto3a2xpFT8Qor58fyPSKHYI3vfKN1hoQ4KkMTY31xP+GCiIEGzJnu0p0dJdHdnmEF0d6ENhnU8a7r\/EubEE7WPD27RminHCwR3k5b+vWvk6jI8Ni4RovYMMBAqoTgOBVPUOIzxUCOzsaaWfn+IgFbMicRw4bMucZK1vDQCvR7iE6MjJD2RATDWx4zxjxDmywKUuUIO4DAecIQPA6xxYl+4QAbMjcTZRYqNawlQg2ZO6CV6U22JSpkomk44BNWdIIUYCLBCB4XYSNqtQkABsy9\/LCUxny1q2njN2Z44IXR3oSgE1ZIPIOm7JApDFtGgHBmzapRkNjERgc6KbmxjXiFBaqOd9HYEPmPGPf1NDfRJGMLJqTX+mbkK0GyhtR8IYU6bCADTZlVnsFrvOaAASv1xlA\/Z4R4KkMba0baHCgRyxUK1u6nEIFRZ7FE\/SKYUMW9AzbbF\/Abcp4AVv\/3iHYlNnsFrgcBJwiAMHrFFmUqzwB2YascP5CisxfqHzMfg4QNmR+zp5DscOmzCGw7hYr25RVVNVRUXGFuwGgtv\/f3pmAVV3lffwLFy6LAgaEFDGpoeJum5nVTKVNi6aZ7W6tU6mV1UzlVPpqi2VZZtpejpnVtL8t1rzZ8kzrmLYYGoIKCiiQisSOKPP+Dv5vF7hw7+V\/7+V\/z\/2e55lnnifO+vkd5HvP\/Z3vIQEPCFDwegCJVfQjQBuywMaUNmSB5R00o9GmLGhC5W6ihk2Z1MvoO8Jddf6cBAJOgII34Mg5oBUI0IYssFGgDVlgeQfVaLW7gH2VWtuURdiAiAi9vXnLykpRVJCrtl5cQgq6p2YE1TbkZPUnQMGrf4y5whYEnG3I7ClpKneXxX8EaEPmP7ba9FyRrx6ikAcpdCtFdXuxo75cPUYRprfmBS+w6bZ79VoPBa9e8eRqPCBQVJDluKgmzwfbu6d50IpVOkLAYUPWaAfkVTUWEnBFQPMLbPIYRUNYg3qQQufibFMWExuPtPSBOi+XawsyAhS8QRYwTtccAdqQmePnbevIHTthL\/kViEkFwiO8bc76oURA4wtsoWRTVliQi71lpWrnpqUPQExsQijtYq7VwgQoeC0cHE7NtwRoQ+Zbnu56c1xUs3cDorq5q86fhzqBgxfYxJc3zhatHY1QsSmTwGWt\/0rFLyIyCj16HatdLLmg4CRAwRucceOsO0CANmQdgGaiCS+qmYAXqk2rixHV2IDBXfRLM6rYXwsRvZLWYLPpHWDnC2y0KdM71sG0OgreYIoW59phAs4X1eSRiZRxUzvcFxu6J2CrqIQIXvV8sIande4JsEaHCBxoAKoKcbg9AWkafisggleEb3SU3rm8EnvnC2y0KevQbwMb+ZgABa+PgbI7axIoKd6MivKmvLKkkeN5Uc2PYZJUhqj8fNiqG5oELwsJeEOgbi9Qv1ed8kZpmPf9XcU2hIJNmfMFNtqUefMLwLr+IkDB6y+y7NcyBGhDFthQKBuy7UVNrgw83Q0sfF1GqypEsi2aNmVBHk\/alAV5ADWbPgWvZgHlcloToA1Z4HaF46JaZFfakAUOu34j0aZMi5jW19chJ3utWgttyrQIaVAvgoI3qMPHybsj4HxRLaZXJsR3l8V\/BKLytyGirJw2ZP5DHDo906ZMi1jTpkyLMGqxCApeLcLIRbgiIKkMhQVZkP\/nRTX\/7xHakPmfcUiNQJsybcJNmzJtQhnUC6HgDerwcfLtEXA+3e02fCRievUjMD8SoA2ZH+GGate0KdMi8s42ZYlJ6UhMTtdiXVxEcBGg4A2ueHG2HhKgDZmHoHxUjTZkPgLJbpoT0NymLK92N+QVtlCzKZPHKORRChYSCCQBCt5A0uZYASNAG7KAoQZtyALHOiRHCgGbMnmIQh6k0LnQpkzn6AbH2ih4gyNOnKUXBGhD5gUsH1SlDZkPILKL9globFMmJ7xy0muPDEN4uN4bgTZlesfX6quj4LV6hDg\/rwk425AljRoPW5d4r\/tgA88I0IbMM06sZZKA5jZl8gJbVWOtEr06F9qU6Rxd66+Ngtf6MeIMvSBAGzIvYPmgqsOGrMsRPuiNXZBAOwQ0timT54ZF9IbCKW9pyXaUlhSoQKekZiA+IYXbngQCQoCCNyCYOUggCNCGLBCUfx\/DcborL6rJQxMsJOBPAgdtynpGJyFZw\/0mgrfyQC2i7Hqf8soW2ZS9Fvvq69Ruyeg7wp+7hn2TgIMABS83gzYE9uwqwJ7dTScHtCHzf1hpQ+Z\/xhyhBYHaXcC+Shwfd6R2aOoONGB9VREibECE5hfYaFOm3fYNigVR8AZFmDhJdwRoQ+aOkG9\/ri6q5W8DYlMBW7RvO2dvJNAegYp8dcIrJ726FcOmTE55wzQ\/6HW+wEabMt12sjXXQ8FrzbhwVl4SMC6qSbOkkeNh757mZQ+s7ikBSWWI2ZSDsEY7IOkMLCQQSAKaX2D7rmIbaFMWyA3FsUKFAAVvqERa43XWVJejqGCDWmFMr0x0Gz5K49V2\/tIcNmQxqUB4ROdPiDMIPQIaX2ALJZuywoJc7C0rVfs3LX0AYmITQm8vc8UBI0DBGzDUHMgfBCSVoaQ4FzXVv8HWJQ60IfMH5d\/7pA2Zf\/mydw8JHLzAlhnbHXEaptSEik2ZRDtr\/VdNhxWx8UhLH+jhBmA1EvCeAAWv98zYwkIEnG3Iug4ahrhBwyw0O\/2mQhsy\/WIatCuqLkZUYwMGd9EvfYk2ZUG7KzlxCxOg4LVwcDi19gnQhiywO8RWUQlxZlB5uxraQgWWJkczTeBAA1BViMPtCUiL6ma6O6t1QJsyq0WE8wl2AhS8wR7BEJ5\/SfFmVJQ35X\/xopp\/N4KkMkTl58NW3dDkzMBCAlYgcNCmTE55ozTLJw9Vm7K4hBR0T82wwu7iHDQjQMGrWUBDZTnONmT2lDSVu8viPwK0IfMfW\/ZskoDGNmVFdXuxo75cPUYRSjZlvMBm8neCzV0SoODlxghKAoYNmVxUE1cG2pD5L4y0IfMfW\/bsAwKa25TJYxQNYQ2I1PwxiqrKcuRtzVIbghfYfPB7wS5aEaDg5aYIOgK0IQtsyCJ37IS95FeANmSBBc\/RPCdAmzLPWVm4Jm3KLBwcDaZGwatBEENpCbQhC2y0HTZk9m6AhheDAkuTo\/mNAG3K\/IY20B0bNmURkVGQF9hYSMBXBCh4fUWS\/QSEgLMNWbfhIxHTq19Axg3VQcSVwVZVC3Q5IlQRcN3BQiAEbMokrUFeYdO5lJWVoqggVy0xMSkdicnpOi+XawsgAQreAMLmUOYIOF9Uk9zdlHFTzXXI1u0ScNiQiSuDhub+DL9mBDS3Kcur3Q15hS06KkyzwLVeTt6WLFRVlasfyCmvnPaykIBZAhS8ZgmyfcAI0IYsYKhBG7LAseZIPiRQtxeo36seo9DNpkwofVexDRE2ICKELrDRpsyHvx8h3hUFb4hvgGBZPm3IAhspZUO2vajpkQme7gYWPkczR6CqEMm2aPSMTjLXjwVb06bMgkHhlIKGAAVv0IQqtCdKG7LAxd9xUU1eUxPBy0ICwUQgBGzK9qEB9ki9Uxvq6+uQk71W7TzalAXTL6B150rBa93YcGYHCThfVIvplal8d1n8RyAqfxsiysp5Uc1\/iNmzvwlobFNWsb8W8uywCN7wcH+D7Nz+aVPWufx1Gz1oBK\/NZsP99\/wNycmHYO49j2F7wY5WsRg18mRceslYpBza9FVW6a+78cqr72L1J192uG5CQhxuu\/VaDBzYV\/WRnb0Fjz+xHIWFO5v1Oe26yTj1T8Ox5Inl+PcXa0zvkyOOOAyXXTIWQwb3R3x8V4SHh6OmthZbt27H62+swndrf\/JqjDtnzcCIE4\/FG2+uwrLlr7tsO3bMKFxx+UXYtr0QM2+Z51X\/\/qosqQyFBVmQ\/+dFNX9R\/r1fx+munOzKCS8LCQQjgYM2ZZLWkKzhPhbBW3mgVr3ApnvZlL0W++rr1MW1zrQpGzSwL+64bRo2\/pKL++YvaYU9JSUJ11x1KY4+egBioqPV3+sfftiAZ59\/BaWlu5vVFz1z8UVjMPrs0yEaY\/\/+\/UrTvLjirVZ\/2487dhCuv24yuqcko6amFp98+hWeff5V1cYocXFdMf\/e29CIRtw1+2GUl1eY3haZfY9Seiqzbwa6dIlBWFgYqqtr1PpFQ+TnF3o8xh\/SD8ecu29C165dMf\/Bpfjxp40u23qiUzwe1EXFoBG811x1CcaMHoldu\/a4FLxjzz0DUyafj\/0NB7Du+5\/VUmWjhNvC1SZ6972PHcv3pu6tN1+Dk086Dp99\/i0qKioxevTp2LgxV83B2HCyMf5+x3Tk5RdgztxHzcRDtT37rFNxxdQLERMTjZKSXdiwMQe1tXXo27cXevZIx76GhlZrcjeoJxvJioKXNmTuIuvbn9OGzLc82VsnEqjdBeyrxPFxR3biJPwztHHKS5sy\/\/Bt2auI0jl3zVR\/g7\/+Zl0rwWv8vHfvHsjLK8CmnC3ol9kbPXocgZycPMy9d1EzEWromfLfKpQoTkiIx5DB\/VBTU4PHly7HN99+r6YgInrenFsggvaNt1bh6KEDMHhQP6x8+W28\/uYqxzQvnHAOLrpwDF7953t48+0PTUMR\/SE6KTw8TAnx7OzNqs\/Bg\/vh8MO6Ky3kPE93A1LwuiN08OfySUiE7NgxZ8Buj0RxcWkrwWvAjI2NUUGQDSlFTjRvmD4Vv1VU4u45C9WnrI7Ura6uxcxb5ymBe++8vyrRed8DS5TwlTJj+lSMGH4MHnt8Gf6z5kcPV+a62sknHY8bZ1yuhLqcTr\/5VvPNO+H8s9Wnrvq6eq82XDAKXtqQmdpKXjemDZnXyNjA6gQq8tUJr44X2GhTFpjNJ6Lz5puuwqCBmeqU05Xg\/cvVl2LM6FFY892PmP\/gE0oriHaZdfs0DDt+qBKrL654U034hGFDcdMNV6Cmtg73P7AUW7ZsU\/99\/HlnYsqkCcjdnIdZdy5QfRiHUB9+9Bmeee4V9OndE\/K3vLhkF26fNV+1E7EtumTfvgZ14CZi1Ey58ILRuOyScUp8P\/XMymbfWMuaRKzLodyuXWW4\/8Hf59\/emBS8HkREPh1JqkC\/zAxUVlYhOjoae\/aUtRK8E8afjUkTz8OGjbnqON+5yEYY0L83Xlr5jvrk403doUP6Y9bt05G1YRPuuW+x6lY227HHDFJfU3z40edw9zWHB8t0VJFPcXPn3IyMo3pg1Yefqs3mqhjide269R6fKAej4KUNmTe7x1xdSWWI2ZSDsP3hgPjuspCADgQO2pRlxnZHnIZuI2JTJg9RyEmvzqWqshx5W7PUEgNpUyZpklMmnY\/ExG7YvbsMycmJrQSvkU4gwnjxkn\/gy6++c4TCOMCSw7ZZdy1QYlQ0zTlnnwYRsUufXNHs7\/+D8+9ActIhWLT4BTWOnLSOG\/tnvPCP19S31IZwBMIw+38WomhHCSZPHK\/qiKB+9\/3VpraB0X9i4iF48aU38fY7\/2rVn6FTRHyv+vAzPPHU72toa3AKXg\/CYoi0bduLFPirr7wElZWVrQTvLTOvxsjTT8L\/vvt\/6lOQc5ENc8GEc1TeyyOLnoM3dQ3Bu\/7nXxxfYcic5GuFJ59agU8++xqS8nDM0QPx4ENPYv3P2R6squ0qxi+H5OlIjlBObp7LyiNPG4GrrrwYefmFeGzxCypX2V0JNsFbU12OooINalm8qOYuuuZ\/Thsy8wzZg0UJVBUiLiwCInp1K\/IQhZz0hsIFNufHKNLSByAmNsGv4TREWpPI\/V6lU54\/\/qxWgrd\/\/964844ZqKuvx9x5iyB6xShGH3JYZ3wr\/OD8Wejbp5dDxDovQv5OnzDsaPzztfew8pV3lOCV1IJlInjfX+0QvPsa9mP2nIWie1XKg3yLbZwKm4Eip7sTLx2HHTtLcfusB9o8LZ546XkYN\/YMfP9DFh5Y8KTbISl43SKCEqeSuyoJ0rJB5LTVleCVU9yBA\/q63ECyWa68\/CJsytmqvgLwpq4RpLZSGiJsNpXE\/uNPG7Dg4ac9WFH7VaZOngDZcCJ0b\/nrPab7a\/mLFEyX1pxtyJJGjYetS7xPebCz3wnQhoy7QWsCBy+w6XrKKxfYqhpraVPm400sf\/+vu3YSPv3sa3Xx3Tg8a5nSYBxUyX0bI\/XRmIqkACxaOBuHHZaiDsnWrF0P4xR3wcNPYe26pvtGRpHUCDmtNQ7o3KU0TJk8AeeOHolnnnsZH69ufTnfWyR33HY9Tjl5GL74co1HQtbT\/il4PSV1sJ5x2upK8C56ZDaO\/MMRjk9Bzl23vIjlTV3pp+nS2vHq6wfJkZFLaxs25KhUAvk01r9fbzyw4An8nLXJyxW1rm6cwrrKETLbudG3J\/1IDlFnujTQhsyTKPmuDm3IfMeSPVmUQHUxohob1AtsupVQsikrLdmO0pICFcKU1AzEJ6QELJxtCV53l72dNYe4E7TnVtByDOPSmlxgf\/W193Di8GPUpbUVLzW5OUhfkkv797sfauba0FEoMtfeGT3bdXPqSN+G4E1N9Sxe7blJdWR8o03QuDR0luCVhPAbpl+uHB8kYV2E7eIly9TFNUk8X\/d9lsq3kURuSauIjo5Sl+OefHpFq09v7gIVCMG7c2cpfvvNdVK7\/FKKlfWlAAAKT0lEQVSlpaVia962ThO8tCFzt0t8+3PakPmWJ3uzKIEDDUBVobq8Rpsyi8bIw2kZNmVSPaPvCA9bma\/WGYJXZj106ABc95eJSDu8u\/rGW\/JmX3zpLVx1xUU4Y9QpKo3zl+zNuGHaVGRmHoXGxkZkbcjBQwuf9tqezN+CV3KhCwuL1eGhq5KU1E3lSVPwHrxAFugT3rZ+TeRymYheuWUpyduX\/3+usFxu++rrtcoepPFAI+bd69ovuK0+ja8T\/HnCa3Uf3j27CrBnd9Mn+G7DRyKmVz\/z\/1KxhzYJ0IaMmyNkCGhsU1Z3oAHrq4oQYQMiNL\/AVlZWiqKCJoekxKR0JCanB2QLd5bgdbW4o446ErPvvFHlC4tFqmgH8f\/94INPVXX5Jnrdup+VY4Q35ZGH71bpo74WnExp8CYK8imnHcHrSV6uiFFxcPCmbltT\/OMpwzBj2lT8+8s1WLJ0eSursisuv1DZibz86rt4\/Y0PPF6pJIJffNG52Lwl3+scXoNP166xaryWaQlmLq0Zn\/qk38rK6naNoz1erIuKLW3I+KKaGZru24ZXVsC+YycQ1Q3Q8Aa7ewKsEXIE5AU2WzTSZM9rVuQCm\/wvMjJM7jJpXQoLc9VjFFLkMQp5lMLfxUwOb\/fuycrB4af1v3iUwysuTc4ODi3XJlaofzx5mHroqrj412ZWZZI3\/PCCO5F4SEK7l99d8TIu9Xckh9c5bbK+fl+zFFNfCV4Zo1fP9DYfH3O3B7RIaTCC5OpTSVsuDZ7UdQXPePEtNfVQzLtvsfLQE0EY17WLIwhGTo\/YiLT1qpmrvuVS2cwbr1SvqbTn0iAnyrf\/7Tr1tYD0X1dXry70GW4SxubamlfQzF2iI5fWWq7N7IZrb0M65+6627j8OQmQAAmQAAnExMYjLX2g30G0JXgNl4ba2to23who6dIgf8MN5wXnibd0aXC1KMMKVQ7G5C5RW25Skuvb3qtmrvo2bFt3Fv\/arkuD3GsSezUR24uXLoMc1jmPJ6zOOvNUx\/i+ELyGrnJlTetp8LUQvN5463pT1xVEyZmRm5Qfr\/7CYYHmK8ErYnr+fbepp\/za8+EV3z2xWisu+VU9qCHPEzpvLpm3bDh5Ic54hrkjJ7zGL9JH\/\/rcIdzlv91y89V4441Vpj3\/PN2krEcCJEACJEACnUmgLcHrTx9eV+uVi\/THHjPQ8dCVLwWvXJK7Z+6tSDk0uU0fXpmTzOG0U09Uzww\/9fRK3DlrOpwP2AyB++VXa5V2MCt4pb28ZislMjIitE9423o9TVIP5MLZnrK9bl9ac1W35WYzBGlSYrdmwFu+vtbRlAYZTwT1tddcpvz1XL20JvOUBPYuXWJVns2KlW+7\/Deg5UlsRwSvq47lU9akiePx0sq3KXg7819fjk0CJEACJBAwAm0JXplAWy+tiYvC0CEDPHppTZ4HvuzSccjdnN+mp+7gQZnKCnXDxhzHt7ctX18zk9IgazEO1Kqqqlu9tCY\/N157RSPw9LNih\/ZFqxi0PCwzK3hFvxgl5FMaBIT47coTxAf2H3C4I4izgjzR++KKt9QrJUbxpq5zJEXsTZkyAe++t9rxTKAae8won1xaM8aSrwfGjz8TUXY7xNtPNnd9fT0yMzPUJyUpcjlu4aPPubQicXUy6yvBK6fZUjrTtixg\/8JxIBIgARIgARI4+K2pfLPq6lK5uDnNuWsm+vTpifz8QvySnYt+mb0hr8Xm5ORh7r2LmjkmiKvTmNEj1Z0YeTE1ISEeQwb3U8\/5Pr50Ob759vs2D7IG9O+jrFCdH7pSD2L54NKaDCqCefr1k5XrlJTtBTuQnb0ZdrsdMrbkIzc07Feaqq2UzZYHbmYEr+iZG6ZPVVxGn3M6c3iNnSEb6ILzz4FYW0iRF8jklFRMo1sWb+pKW+M5vdiYaMye+4iyHjOKbBB5flCeCxRbsvxthXh+2Wv48ceml8I6UiTI4vbQO6MHxC5MLNEkEVz6fu\/91coM21UxxO7O4pJmotQXglfE7mGp3b3OC+rI+tmGBEiABEiABKxCoL0TXpmjpANMu24KBg7sg5joaNTU1uKHHzbg2edfaaYXDFE56bLzcOaf\/4T4+K7q4EqEpRzOib+uq3LCsKEOK9SFjz7brIqMfeOMKyD5vY2NwH\/W\/KCe\/C0vr+gwvtNPG4Fzx4xCevphaj1Sqqtr1An0a6+\/D\/EUdlVEaxx37GCfXVoT3fHTT78ocW32DlHQ5PB2OGoh1LAtsesLBBS7vqDIPkiABEiABEhATwKuxK6ZlcqHjCFD+jkO7yh4zdDUqK1xg1G+HhGHB18V46sI6c+4AOervtkPCZAACZAACZBA8BPwx6GYsyWqM6GO2qPyhDf495lLWxJfLaulA4Wv+mU\/JEACJEACJEACwU9ATl47YoPm7cp5wustMQ3rOxs+++JTkNGHcWpst0e2oubrl1g0DAuXRAIkQAIkQAJaE2j56JXzYn39aiwFr9ZbiYsjARIgARIgARIgARIwS4ApDWYJsj0JkAAJkAAJkAAJkIClCVDwWjo8nBwJkAAJkAAJkAAJkIBZAhS8ZgmyPQmQAAmQAAmQAAmQgKUJUPBaOjycHAmQAAmQAAmQAAmQgFkCFLxmCbI9CZAACZAACZAACZCApQlQ8Fo6PJwcCZAACZAACZAACZCAWQIUvGYJsj0JkAAJkAAJkAAJkIClCVDwWjo8nBwJkAAJkAAJkAAJkIBZAhS8ZgmyPQmQAAmQAAmQAAmQgKUJUPBaOjycHAmQAAmQAAmQAAmQgFkCFLxmCbI9CZAACZAACZAACZCApQlQ8Fo6PJwcCZAACZAACZAACZCAWQIUvGYJsj0JkAAJkAAJkAAJkIClCVDwWjo8nBwJkAAJkAAJkAAJkIBZAhS8ZgmyPQmQAAmQAAmQAAmQgKUJUPBaOjycHAmQAAmQAAmQAAmQgFkCFLxmCbI9CZAACZAACZAACZCApQlQ8Fo6PJwcCZAACZAACZAACZCAWQIUvGYJsj0JkAAJkAAJkAAJkIClCVDwWjo8nBwJkAAJkAAJkAAJkIBZAhS8ZgmyPQmQAAmQAAmQAAmQgKUJUPBaOjycHAmQAAmQAAmQAAmQgFkCFLxmCbI9CZAACZAACZAACZCApQlQ8Fo6PJwcCZAACZAACZAACZCAWQIUvGYJsj0JkAAJkAAJkAAJkIClCVDwWjo8nBwJkAAJkAAJkAAJkIBZAhS8ZgmyPQmQAAmQAAmQAAmQgKUJUPBaOjycHAmQAAmQAAmQAAmQgFkCFLxmCbI9CZAACZAACZAACZCApQlQ8Fo6PJwcCZAACZAACZAACZCAWQIUvGYJsj0JkAAJkAAJkAAJkIClCVDwWjo8nBwJkAAJkAAJkAAJkIBZAhS8ZgmyPQmQAAmQAAmQAAmQgKUJUPBaOjycHAmQAAmQAAmQAAmQgFkCFLxmCbI9CZAACZAACZAACZCApQlQ8Fo6PJwcCZAACZAACZAACZCAWQIUvGYJsj0JkAAJkAAJkAAJkIClCfwXheLOYEzTTJoAAAAASUVORK5CYII=","height":337,"width":560}}
%---
