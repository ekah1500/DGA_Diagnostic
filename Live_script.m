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
%_________Zero Handling + Ratio Calculation____________

if c2h4 > 0, r1 = c2h2 / c2h4;
elseif c2h2 == 0, r1 = 0;       % 0/0 -> 0 for Normal Logic (Normal is < 0.1)
else, r1 = 999;                 % High/0 -> Infinity (Arcing)
end

if h2 > 0, r2 = ch4 / h2;
elseif ch4 == 0, r2 = 0;
else, r2 = 999;
end

if c2h6 > 0, r5 = c2h4 / c2h6;
elseif c2h4 == 0, r5 = 0;
else, r5 = 999;
end

fprintf('\n---> Rogers Ratio Method Method <---\n') %[output:69eb918c]

% Display Ratio Calculations 
fprintf('\nCalculated Ratios:\n'); %[output:67d42bd2]
fprintf('R1 (C2H2/C2H4): %.2f\n', r1); %[output:4a0aed39]
fprintf('R2 (CH4/H2): %.2f\n', r2); %[output:17d29f0b]
fprintf('R5 (C2H4/C2H6): %.2f\n', r5); %[output:2a57dc1a]
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

gas_sum_dt1 = ch4 + c2h4 + c2h2;
p_ch4 = (ch4/gas_sum_dt1) * 100; p_c2h4 = (c2h4/gas_sum_dt1) * 100; p_c2h2 = (c2h2/gas_sum_dt1) * 100; %Percentages


% Calculating Sample Point (X, Y)
% Using fractions (0-1), not percentages (0-100) for the coordinate formula
if gas_sum_dt1 > 0
    f_ch4 = ch4 / gas_sum_dt1;
    f_c2h4 = c2h4 / gas_sum_dt1;
else
    f_ch4 = 0; f_c2h4 = 0;
end

% Using Formula (https://powertransformerhealth.com/2019/03/22/duvals-triangle-method/#:~:text=X%20%3D%20%5B%28%25C2H4,0%2E866,-For)
X_pt = ((f_c2h4 / 0.866) + (f_ch4 / 1.732)) * 0.866;
Y_pt = f_ch4 * 0.866;

% Using Geometric Diagnosis to check if the point is in polygon or not
if inpolygon(X_pt, Y_pt, PD_x, PD_y), dt1_fault = 'PD: Partial Discharge';
elseif inpolygon(X_pt, Y_pt, T1_x, T1_y), dt1_fault = 'T1: Low Temperature Thermal Fault (<300C)';
elseif inpolygon(X_pt, Y_pt, T2_x, T2_y), dt1_fault = 'T2: Med Temperature Thermal Fault (300-700C)';
elseif inpolygon(X_pt, Y_pt, T3_x, T3_y), dt1_fault = 'T3: High Temperature Thermal Fault (>700C)';
elseif inpolygon(X_pt, Y_pt, D1_x, D1_y), dt1_fault = 'D1: Low Energy Discharge';
elseif inpolygon(X_pt, Y_pt, D2_x, D2_y), dt1_fault = 'D2: High Energy Discharge';
elseif inpolygon(X_pt, Y_pt, DT_x, DT_y), dt1_fault = 'DT: Mix of Thermal/Electrical';
else, dt1_fault = 'Undetermined / Boundary';
end

fprintf('\n---> Duval triangle <---\n'); %[output:9f36b3a6]
fprintf('Diagnosis: %s\n', dt1_fault); %[output:7466ba0e]
%[text]{"align":"center"} ## **`Duval Triangle Plot`**
figure('Name', 'Duval Triangle 1', 'Color', '#24273a'); %[output:26bfd512]
hold on; %[output:26bfd512]
axis equal; %[output:26bfd512]
axis off; % Hide standard axes %[output:26bfd512]

% Zone Patches (Colored)
fill(PD_x, PD_y, [0.8500 0.9500 1.0000], 'EdgeColor', '#24273a');    %[output:26bfd512]
fill(T1_x, T1_y, [1.0000 0.6824 0.6863], 'EdgeColor', '#24273a');       %[output:26bfd512]
fill(T2_x, T2_y, [1.0000 0.8000 0.0000], 'EdgeColor', '#24273a');     %[output:26bfd512]
fill(T3_x, T3_y, [0.2471 0.2471 0.2471], 'EdgeColor', '#24273a');      %[output:26bfd512]
fill(D1_x, D1_y, [0.0000 0.8118 0.8784], 'EdgeColor', '#24273a');        %[output:26bfd512]
fill(D2_x, D2_y, [0.1490 0.3216 0.6549], 'EdgeColor', '#24273a');      %[output:26bfd512]
fill(DT_x, DT_y, [0.8314 0.3255 0.6392], 'EdgeColor', '#24273a');     %[output:26bfd512]

% Adding Zone Labels
text(mean(PD_x), mean(PD_y), 'PD', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:26bfd512]
text(mean(T1_x), mean(T1_y), 'T1', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:26bfd512]
text(mean(T2_x), mean(T2_y), 'T2', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:26bfd512]
text(mean(T3_x), mean(T3_y), 'T3', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:26bfd512]
text(mean(D1_x), mean(D1_y), 'D1', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:26bfd512]
text(0.65, 0.20, 'DT', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); % Manual placement for DT %[output:26bfd512]
text(0.5, 0.2, 'D2', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); % Manual placement for D2 %[output:26bfd512]

% Main Triangle Boundary
plot([0 1 0.5 0], [0 0 0.866 0], 'k-', 'LineWidth', 1.2); %[output:26bfd512]

% Plotting Sample Point
plot(X_pt, Y_pt, 'go', 'MarkerFaceColor', 'b', 'MarkerSize', 4, 'LineWidth', 1.5); %[output:26bfd512]

% Label to Sample Point
text(X_pt + 0.03, Y_pt, sprintf('  Fault\n  (%.1f, %.1f, %.1f)', p_ch4, p_c2h4, p_c2h2), ... %[output:26bfd512]
    'BackgroundColor', '#cad3f5', 'color', 'k', 'EdgeColor', 'r', 'LineWidth', 1, 'Margin', 1); %[output:26bfd512]

% Corner Labels
text(0.215, 0.45, '% CH_4', 'Rotation', 60, 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold'); %[output:26bfd512]
text(0.77, 0.48, '% C_2H_4', 'Rotation', -60, 'HorizontalAlignment', 'left', 'FontSize', 12, 'FontWeight', 'bold'); %[output:26bfd512]
text(0.5, -0.05, '% C_2H_4', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold'); %[output:26bfd512]

% Title
title(['Duval Triangle 1 Diagnosis: ' dt1_fault], 'FontSize', 14); %[output:26bfd512]
hold off; %[output:26bfd512]
%[text]{"align":"center"} ## **Duval Triangle 4**

if  strcmp(dt1_fault,'PD: Partial Discharge') || strcmp(dt1_fault, 'T1: Low Temperature Thermal Fault (<300C)')...
        || strcmp(dt1_fault, 'T2: Medium Temperature Thermal Fault (300-700C)')
    plot_dt4(h2, ch4, c2h6);
end

function plot_dt4(h2, ch4, c2h6)
    fprintf('The fault zones are shown on Duval trangle 4\n')
    % Coordinates: H2 (Top), CH4 (Right), C2H6 (Left)
    figure('Color', '#24273a', 'Name', 'Duval Triangle 4', 'NumberTitle', 'off');
    hold on;
    axis equal;
    axis off;
    
    % --- Vertices of the Main Triangle ---

    % Top (H2=100), Right (CH4=100), Left (C2H6=100)
    % Cartesian Co-ordinates: x ranges 0-100
    % Converting Triangular (h, m, e) to Cartesian (x, y)
   
    triangular = @(h, m, e) [ (m + 0.5*h), (h * sqrt(3)/2) ];
    
    Top   = triangular(100, 0, 0);
    Right = triangular(0, 100, 0);
    Left  = triangular(0, 0, 100);
    
    % Triangle Outline
    plot([Top(1) Left(1) Right(1) Top(1)], [Top(2) Left(2) Right(2) Top(2)], 'k', 'LineWidth', 1.2);
    
    % --- Defining Regions as per IEEE-C57.104.2019 ---

    % -- PD (Partial Discharge) --
    % 2 <= CH4 < 15, C2H6 < 1
    p_pd = [
        triangular(98, 2, 0);    % Right top edge
        triangular(97, 2, 1);    % Inner corner
        triangular(84, 15, 1);   % Inner corner
        triangular(85, 15, 0);   % Left top edge
    ];

    % -- ND (Not Determined) --
    % H2 >= 9, C2H6 >= 46
    p_nd = [
        triangular(54, 0, 46);   % Top tip of ND (on Left axis)
        triangular(9, 45, 46);   % Right corner (intersection H=9, E=46)
        triangular(9, 0, 91);    % Bottom corner (on Left axis)
    ];

    % -- O (Overheating) --
    % H2 < 9, C2H6 >= 30
    p_o = [
        triangular(9, 0, 91);    % Top Left (meets ND)
        triangular(9, 61, 30);   % Top Right (intersection H=9, E=30)
        triangular(0, 70, 30);   % Bottom Right (on axis H=0)
        triangular(0, 0, 100);   % Bottom Left Vertex (C2H6=100)
    ];

    % -- C (Carbonisation) --
    % Part 1: CH4 >= 36 AND C2H4 >= 24
    % Part 2: H2 < 15 AND 24 <= C2H6 < 30
    p_c = [
        triangular(0, 100, 0);   % Bottom Right Vertex (CH4=100)
        triangular(0, 70, 30);   % Bottom edge (meets O)
        triangular(15, 55, 30);  % Inner Step 1 (H=15, E=30)
        triangular(15, 61, 24);  % Inner Step 2 (H=15, E=24)
        triangular(40, 36, 24);  % Inner Step 3 (M=36, E=24)
        triangular(64, 36, 0);   % Right Axis (M=36, E=0)
    ];

    % -- S (Stray Gassing) --
    % Fills the center by connecting the surrounding points.
    p_s = [
        triangular(98, 2, 0);    % Start at PD top
        triangular(97, 2, 1);    % PD boundary
        triangular(84, 15, 1);   % PD boundary
        triangular(85, 15, 0);   % Right Axis
        triangular(64, 36, 0);   % Meets C
        triangular(40, 36, 24);  % C boundary
        triangular(15, 61, 24);  % C boundary
        triangular(15, 55, 30);  % C boundary
        triangular(9, 61, 30);   % O boundary
        triangular(9, 45, 46);   % ND boundary
        triangular(54, 0, 46);   % ND boundary (Left Axis)
        % Follow Left Axis up
        triangular(100, 0, 0);   % Top Vertex
    ];
    
    % --- Patches ---
    function fill_poly(pts, color)
             patch(pts(:,1), pts(:,2), color, 'EdgeColor', 'k', 'LineWidth', 1);
    end

    fill_poly(p_s,  [0.95, 0.95, 1.0]); % S 
    fill_poly(p_pd, [0.8, 0.9, 1.0]);   % PD
    fill_poly(p_nd, [0.9, 1.0, 0.9]);   % ND 
    fill_poly(p_o,  [1.0, 0.9, 0.6]);   % O 
    fill_poly(p_c,  [0.6, 0.6, 0.6]);   % C

    % --- Labels ---
    function text_loc(h, m, ~, str) % Helper to place text using triangular co-ords
            loc = [ (m + 0.5*h), (h * sqrt(3)/2) ];
            text(loc(1), loc(2), str, 'Color', 'r', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end

    text_loc(92, 9, 3, 'PD');
    text_loc(50, 20, 30, 'S');
    text_loc(25, 10, 65, 'ND');
    text_loc(4, 30, 66, 'O');
    text_loc(15, 70, 15, 'C');

    % --- Axes Labels ---
    % Left Label (H2)
    text(23, 48, '% H_2', 'Rotation', 60, 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Right Label (CH4)
    text(75, 50, '% CH_4', 'Rotation', -60, 'HorizontalAlignment', 'left', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Bottom Label (C2H6)
    text(50, -5, '% C_2H_6', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Title
    title('Duval Triangle 4 (Low Temperature Faults)', 'FontSize', 12);

    gas_sum_dt4 = h2 + ch4 + c2h6;
    p_ch4 = (ch4/gas_sum_dt4) * 100; p_h2 = (h2/gas_sum_dt4) * 100; p_c2h6 = (c2h6/gas_sum_dt4) * 100; %Percentages
    pt_dt4 = triangular(p_h2, p_ch4, p_c2h6);
    X4 = pt_dt4(1); Y4 = pt_dt4(2);

    % Geometric Diagnosis
    if inpolygon(X4, Y4, p_pd(:,1), p_pd(:,2)), dt4_fault = 'PD - Partial Discharge';
    elseif inpolygon(X4, Y4, p_s(:,1), p_s(:,2)), dt4_fault = 'S - Stray Gassing';
    elseif inpolygon(X4, Y4, p_c(:,1), p_c(:,2)), dt4_fault = 'C - Carbonisation';
    elseif inpolygon(X4, Y4, p_o(:,1), p_o(:,2)), dt4_fault = 'O - Overheating';
    elseif inpolygon(X4, Y4, p_nd(:,1), p_nd(:,2)), dt4_fault = 'ND - Undefined';
    else, dt4_fault = 'Undetermined / Boundary';
    end

    % --- Fault Point ---
    
    % Converting inputs (a,b,c) to x,y
    triangular = @(h, m, e) [ (m + 0.5*h), (h * sqrt(3)/2) ];
    input = triangular(p_h2, p_ch4, p_c2h6);
    
    % Plotting Sample Point
    plot(input(1), input(2), 'go', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'LineWidth', 1.5);
    
    % Label to sample point
    text(input(1) + 2, input(2), sprintf('  Fault\n  (%.1f, %.1f, %.1f)', p_h2, p_ch4, p_c2h6), ...
    'BackgroundColor', '#cad3f5', 'color', 'k', 'EdgeColor', 'k', 'LineWidth', 1, 'Margin', 1);
    % Update Title
    title(['Duval Triangle 4 Diagnosis: ' dt4_fault], 'FontSize', 14);

    fprintf('Diagnosis: %s\n', dt4_fault);
end


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
%   data: {"dataType":"text","outputData":{"text":"Total Dissolved Combustible Gas (TDCG): 307.00 ppm\n","truncated":false}}
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
%   data: {"dataType":"text","outputData":{"text":"R1 (C2H2\/C2H4): 1.33\n","truncated":false}}
%---
%[output:17d29f0b]
%   data: {"dataType":"text","outputData":{"text":"R2 (CH4\/H2): 0.33\n","truncated":false}}
%---
%[output:2a57dc1a]
%   data: {"dataType":"text","outputData":{"text":"R5 (C2H4\/C2H6): 1.83\n","truncated":false}}
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
%   data: {"dataType":"text","outputData":{"text":"\nCO2\/CO Ratio: 0.83\n","truncated":false}}
%---
%[output:581a38c6]
%   data: {"dataType":"text","outputData":{"text":"\nDiagnosis: Severe paper degradation (Carbonization).\n","truncated":false}}
%---
%[output:12750763]
%   data: {"dataType":"text","outputData":{"text":"\n---> Duval Triangle <---\n","truncated":false}}
%---
%[output:9f36b3a6]
%   data: {"dataType":"text","outputData":{"text":"\n---> Duval triangle <---\n","truncated":false}}
%---
%[output:7466ba0e]
%   data: {"dataType":"text","outputData":{"text":"Diagnosis: D2: High Energy Discharge\n","truncated":false}}
%---
%[output:26bfd512]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAArwAAAGlCAYAAAAYiyWNAAAAAXNSR0IArs4c6QAAIABJREFUeF7snQd4FWX2xt+EBEwCCYRwKSFIMBKQ2EEUy0pkdW2osaGigAWwgKhrQREFUdS1LYggWEBBUQErurtiAAsWwFU3gAGUYBJKqAlVWv7\/88W5Tm7uzczcOnfuO8+jKDNf+51vZs5895z3i8vJ7VENHiRAAiRAAiRAAiRAAiTgUAJxdHgdalkOiwRIgARIgARIgARIQBGgw8uJQAIkQAIkQAIkQAIk4GgCdHgdbV4OjgRIgARIgARIgARIgA4v5wAJkAAJkAAJkAAJkICjCdDhdbR5OTgSIAESIAESIAESIIGYcXgH9Lscl116nk+LHzhwADt27sKyZSvx5lsfoKSkLOpmh36MGzZUYNQj\/8RvpevqHcdzz4zEkTnZlsY6a\/bHeHXaO\/WW8acvljoR4osj1f+0tCYYM\/rv6JDdDjt37sbYJybghx+Xmxptu6w2eOjB29Gqlcvn9Xv27sX69RUonL8IH3w4DwcPHqx17XHHHoXh996Kxo2TsW\/ffrw69W188NE8U+3H2kWevM3cF6FgpLeZt\/qrq6uxZ89e9SyY+3Ghsr23IynpMPS54kKcfvpJaJ7eFAkJCdi\/fz82bNiEf3\/6udf54s94zM6x3hf0woD+V6Bhw8Q690Io7s8Hht+GHqecqIa0avUaDLtztD\/Dc5cxcz96NrDo66V4dOzzAbXr9MLBmO+hmD9WuNvl2WGlz064lg6vFyvu2rVbOXSf\/GtBVNnYn5uYDq93E\/vDMtDJ0qBBAwy66Wr87Zwz0aBBfEgcXq2P4gT99L+f8cQ\/JqKycoe762adkUDH6oTydnlpGTkAetbyYf\/VoiV4+tmXan3suFzNcf99t\/r8+D106BDEGXvyqRfrfCRZtaXZOUaH1yrZ2Lg+GPM9Es93vXXs8uyIjRnz5yjp8PqweGVlFcZPmIavv\/k+auaEPzcxHV57OLyyujb0tgHoccoJamVNjlCs8OpHK06vzO\/Hn5zodmLMOiNRc1OEsKN2eWlZcQAEhzi9H839DFNenummc9cdN6HnmacgLi7OJ7F9+\/Zh+oz3MPvdTwKianaO0eENCLNjCwdjvvvzrgwmULs8O4I5pmioKyYdXs+f+8XZ6H7Scbjy8guRldXa\/dAvKirG\/Q\/+I+AVjXBNhGDcxJ43Yqz+xBYMlmbsLqu6vS\/shUsuOgfNmzerVSRQh9fzJ3axbe\/ef0X+mT3QqFFD1Zb81P3ilDfw6bwvzHSX19iQgJED2blTDi4tOBddTzwaiYmJagTbt1fh8SdfwP+KiuF5z5eWrsOEia9h+YrVuPiis1WYQ3JykipXtGwl7h0+NiAKRv3VKq\/P4Q2oAz4KhzqkIVIhL6FgFck6jeaP0XyPZN+1tunwRsYKdHh13CV+8uGRd6DjkTUxrRLa8Ny4V9RPedFwBMNJo8NbY+lgsDQzZ\/Qvdble4mbFCQ5GSIOvF+wlF5+D6\/peqmIj5Viy9Cc8NOpZM93lNTYkYOQAaF0ePPAanHduvppbsrr\/8Sfz8cKk13F0Xi7uGHYjmjROQUJCA7wx8wO8M2uue6QPPjAUJ3c\/Xv1\/MGJbzfaXDq8NJ5sNumR2\/via7zYYQp2PTH4MhccqdHg9OF96ybnoe83FaNiwoXopyIN\/2uuz1VX6FQDPVWJfjuJ1116KywrOUy+ZzZu3YvSj4\/DLL2vdrbpaNMfoUXchq21r9XefFX6FZ557Sf23xNX1v+5ynHjC0UhJSVIrz1py3ZdfLcG012apFTrtCIaTZsbh1XNYvPhHJCYmIC8vVzlqW7dtx4QXXsNRnY90Jwl6S6DrddZpuKzgXLRq1cK96iQJVaW\/rVMv3MVLfnSPS98nWfX8x9OT0LXrsTjjtJOQmtpY2WnLlu34+JNCzH73X3VW5OVDRmJju3U9Vq1USSLOmjWl6mfdq6+6yJ3kpX\/oGLFs374tbry+Dzp1OgJJhx2m7LJl63Z88cV3mPn2h7XsUt+trL3UheHyFavw\/fdFuPKKC70m6hg9EsyuGjRp0hhjx9yD7OwsVaUkJY18+GmUr9sIo5eJNu7cjh3cq37Cc+u2SvzrXwtCwl8+OP\/z6Re4uk9v1WdZpZS58vPPv+ClV2Z6TTD1loAlHxNl5evx\/gefYt5nX9bBqd1vxx93FBo3TkF8fHy995sRb22Ot2zZwv1x4WuOS2fM3Hve5oCRzbQyRxxxOEY+MBQZGenqr4pX\/oo7\/\/6I0bSq9dzTO7yh7m8gIQ3HHdcF\/foWuOfL7t17sHjJT\/jl17Xoe\/UlXu8vzxXej+YWqmdY61YtVJhRTR0\/ql9E9HHvvgAazQ8j8Hq7yjP02XGv4Ly\/9US3rseoe0+eOes3bII8t7zNZyvPKD1raUtYnZV\/qmpH7puPPv4ML7\/yluqyFbYtWqRj0MBr1DNSFpDGPT8VX361uNbQB\/S\/HPLelfebmWTrYMz3+p7vVp8D2mCknPxKLB+H8l6S54ewKykprfedJuXnvPsvJDZMrPNO+3DuPMyeUzeEyOpzWB+6+K9\/L1SLelKHHOXlG\/D4Pyaq56g\/70qpQ979l17yN\/VB3bx5UzV2uV9WrS7B2+98ZDrx2uieCPQ8HV4PgkcddSQeuO82NG2aqs7of9L3x+HV1+ctBu6vvU6r9UDQVpRl4j00Yhhyczt4tbE4eZJ8MvaJFyLq8MoL\/LBGjdzO+Pf\/LcKYx57HdX0LfDq8vS\/8K667tkA9BL0d8jJ55rkpWLL0f+q0\/sUhN5E41W0zaz4Q9Ie8AN774D94deqfChL1cRR7AHFuZ8Ssw3vu385UK8ApKcl1+iB2WfHzaox5bLypl+IF558F+eff\/1mosuDPP7enz8x0o5vdygv2zmE3qheaHPrQifpeJuIw3X\/vreojxdsRKv7yE3tGi3Sv80UUJ0aPqa1GIv285++DvM4R6be3BCyjsYld5YPkkUfHY8eOnXXmpfyFfv7cdEMfZVctHtuTl3yovvzqW7USY0PtQEofnhg7HHldOqrumHEu9Kohns\/DUPfXX4f3lJNPwJBb+yEtreYZrj+EuyxmePsFRf98F0clPj7Oq\/1kHoweM849D3zdl1buR2916O9FCUGR+0v7WKk1pr17MXXaLPUBrx1Wn1F61vJcFOdTPixl3ssH8VPPTMbPxb\/AKttffv2t1se1fkFH+ur58b3w829UYmR9h1mHt7757svh9ec5IO0YPXPkPfna63PwwYefen12yLyUj3TPw9sz1aiP3sroHV59W7JYIQ7wpMkzlLPry+eo710p5e69+2Ycc3QnrzkA0t5r0\/8cu9F7LJTn6fB60PV8SOlj1vxxeKX6UQ\/dga4nHqNa8oyBkxfzX844WZ1btnwlhj\/wpFqh1K8My4rwk0+\/qB6wdwy9Ad26HauulxVjkbBZuWqN+n+jVUkzE8nMS0zPQeqUlSKJB6yo2OJuwldf5Cv4kVF3KWdEXipvznxfrQqeeUZ33HhDH6SmNlF1yGrthImve304yA298PNvlcMg\/R029Aa3E1Zath4jH3oaFZtq+qJPxpGHzocfzsPbs+bipG7H4fr+l9d6gZhxeDvlHqGy2SXeVvohSV8TX5yOjkd2wOBB16BVyxbqJfGv\/yzE8xOmmUFe65pAfsa18oLV20ceSBMnvY7P5i+qd4VXP1dlZf\/ZcS+rF9Y9dw1SD3w51v5WjnuHP+52BoLBX+rdsHGTWmH67w\/L1Dw\/5+wzlDNy8OAhvPX2h5jx5nuqfenPyBFD1S8MnuXkF4ULL+ilPlQ8E7duGXwtzju3p3pgizThuAlTlXxbwSV\/w5VXXKCcbc8PVl+89Sup8oH2+ox3lRxY69YuyIeGrI7LIb8yDB\/xpE8H2mz8vBUHQH\/vihP16OPPY\/nyVT7nqd5xl7GMnzAVn3\/xndf70p\/+mr1BPOPZ63u+jH7oTmRltalj\/2uuuhjnn5fv\/sD1rNPzufbrr7+pWGaZ0zKPZeVO5of+fqmv\/1ZlyTw\/QDyTs\/TPL3E8b7z+SrdTr3+v+POM8gytkqRtcYI0W8s45dntD1v9veX5fBYZuGFDr1f3pIzvxckz8Om8ur++6DkHY777mj\/+PAc8nznavFm\/oUIlIkt+kMwb\/S+8nnND\/06TBYV77hrs853mz3NY7\/DK++mbb\/+Lp5+dUuuXSH+f1bfd2g9\/O\/sv7jG+MvUdfLf4B0hIyZl\/OVk9p7ds2YbHHp+gPpoiedDh9aDvORH1P+H56\/DqV3Fl9VKcQ5GE0relf3HLzwNPPfmA+tlBvsBmvPm+O6bO31UPs5PMqsPr82cqne6x\/kGu77+nc6S\/KfUvT88+6T8MZFwDb7wKF\/U+Ww2xqmqHWvX25CvnPFcP9OErct6Mw6v\/+e2339bhvgced6\/k6u3sLXzFjA0i4fDq9XZ9vUz0NvC0ua+Xh6fd\/OXv+SI8vF0mHho5DC1dGQrpF19+p5Qm5NDb1NNB0+bKBef3Uit827ZXYsyj49VDWH9vywecODpa6JHoIh9\/XBdVv96x8OXw6hlK32fN+hjvf\/ipermcdmo3DL2tf80LXvehYWZu+LrGXwfAKClS7+x6+0XJ3z5bzbKXdsw6vPr7x5sDpV98qM\/h1T+npX1ZvRp+7y3qg9wz1M0Xh2A7vJ73jz62Wh+W5M8zytPh1S84aOPzl62wu++eW9QKoqdN9A6m5\/sglPPd1zPLn+fAWT174ObB16oVWs+8H3mHS52yMq9\/xxu90\/pdeykuv+x85UT6eqeZfQ4LR\/271XOhTM77+6zWlxNf5a13PsKbMz9QphM\/Zuyj96DLUR1r5Qz4+9wIRjk6vAYOrz7OzV+HV74Anxh7H+RFLZN+1pyP8drrs2u9nOtzkCTr9KRux6qJIzGMWsa02ZeAlYli1eH19bOomdVmeQDKSuuxx3SCjNHlylCxP3LU5\/B6Pox9OYmSlX7P3wcr5+L33\/dhystv1voJ2dNxMuPw6n8S9lzR0j\/c\/HVmIuHw6tmYcZ7kQXbsMZ3VLw2ympTdXuJqa6TU9PMhWPy9PaB9fRzp71FZaRl21+haMd36ECP9x6Q+xEPGIU7Nrl17sHZtmVrFL1ywqE6Iii+H1zMsSuqTtiTOvGhZsYrTlw+yYB1mbKa1peejf5Hq+yL2FWdXfhbXQjKKi3\/FqDHPmQrTMRpXKB1e\/cev3gl0O20X\/hXX979Czdf6HF5P58vKrydaW8F0eD0XPqQNX89Yf55RtUMavG84Ewhb\/Uej5rjr34v6JEor88docxxf890XO3+eA3ounivYZj+GzL7TPO9TM89hT4fXW+Kpv89qvbPv7QP61pvll7N81e1gKLwYzQ2j83R4PQgFO4ZXq17\/Jav9lHnv3YPdK0eeX+9a4LyWoODNkHZweH19ldfn8Eoyz+WXnYc2rVu6HVzP8dXn8HpmtPpyEo2cR\/0DV9o34\/Ca1S32\/Knd6EZ0v5Dr2V3KqA4rL2V\/Yni1RIm8LrluB9ezT75W8709DP3hr7Xny+H19fe+nBDN5mbi4iRJbvwL01BWtl5VVx9voxheWUGUeD5JcAz0sOLwGsXwirN71x034tQeXZWzK47I0u\/\/pxJpzSRqmRmL2f7682uWkbSYfoW9PofX0ymwcm8ZzTUzjOQaI06+nrH+PKP0rH39ahcIW\/0vL5I4+uBDT+PoLrk+V0brY2TERV\/W13z3N4ZXQg88nwNGXLyNxWg+1Tf3rT6HPR1eCQsbMfKpWt3y913p+ctAfXYz+zFg9v7w5zo6vB7U9AYMhkqDVr3+Zx15oEx\/4z1cefkFKjnO82cez5gguckkg\/7Hn1ZgR9VO9VNHqLbbtLrC60umyNcDRRJ5+ve7zJ2AJKtMktgwf\/4iXHzROejQoZ1CFu0Or6cDbfbmNHrw1FeP0UNUK6sPmZG\/M6PSIHWPHHG7ikOVY\/\/+A1hTUqpiauUXhwvPP0v9fbQ6vNJ3Mx+ZkkA3ctQzKl7diLdSadBl+XvaTu5rcbglxjeQw6wD4NlfT5UGT2dXVhU\/K1ykpMs8t6AOR3\/p8Na\/zXegDq\/+GWXmuWPk2NX3MeGZuyFblufktHcnznqGqQXD4a1vvptRaahvsUn\/HDDiEkyH15\/nsKfD6y3W3sj+vhYnrDi8ZpJkA3mumClLh1dHSR74Dz14u5IBk8MzHsffkAatCS1+TBxpSYwRBQbJhPVMXtH\/TCA\/2bw2fTbefe\/fqhp\/XgJmJoJ2TagdXv0XtyTbPTz6WffKkdkYXrMrvPoHsLefvvwJaXjmqQfdSUdmk3Ss8Dd68ATD4T3j9JMw5Nb+7tAYvQ6vL+dJEn5ELk1iX+UjRXYh1PSpfb08QsFfG3+wQxo8uUqIjSQpHXNMZ7UZjaYoog\/\/MHJ4tTq10B0JS5Kwl\/T0GtkeOcxKgwXDAbj80vOUDJ8muajp8Gp161elJSRHYvEC3VXNW7\/NOuj+POv0P6F6e8GKQoyZkIZoXuH15xll5rkTCFuZB\/pkqx9+XI6MjGYqeVkf5mfmWWl2\/tQ3382E3ElfzDwHaod6VGDUI7VVY4Lp8PrzHDbj8Pr7rJawp5tuuEptZGSUE2DGtqG+hg7vH4RlBfaKyy9QsYnay8hzpzX9xN5YsRmjRj+nMnjl0Gebyv97c4Y8k6TkOnF+5aWil9KSXZH6Xl2jBew5ifQPHTuENFhZ4d2ydRsef+w+dMiuu4qrj3\/15GfkWPh6WBsF4usfiNKmmZAGfWiKZ9KakeaymZvZzIvHVz1GnMTxOvecMyEvfflvOTx3WvP1MpFxS4a7HJ6OhD4+T38uFPyNHF4rSWta3LzUqenTersf9fFt+g8nX7z1c8Sb0xXujRxE67ug4Fz0yj\/VLX2k32lNxq\/\/5cXzI9vMvLVyjVmHxR+Ht77EKs8FDaeGNPjzjDLz3AmErec7Ui\/7ZkYtRD+\/jOaPmfnuzeEVHVx\/ngP6BSpJlH3+hddUgrQc+sQt+X9tccHoWe3LHv48h804vP4+q\/WKNJ5Ja\/pVfSsx2laeJVavjUmH1wwkkWWRVSxJWNEO\/SSUnyMXLPxGSbdITOMNA65wS+H4cnj1E0Cr0zMbWP5efwPJ1++ChV\/jxSkzcHavM3BVn95u\/ddoc3h\/K11XSwdUHA55OIh8y5Bb+qFLl45uHb9ghDQIS71kioSOvPf+f5SQt8iliFawJoNm1uGVXakk41hCUUTPden3RXhh0mtKMUCTR5Obe\/6Cr5Xsi9XDzIvHrMNr1Lb0U+a3KBxoP1mbWeGVl5XoHc+aPRdXXXlRLaknTwcv2PyNHF5P3Vi9nFl9smT6fsoKtuhGymYXjRsn44YBV+IvZ3RXMa31SQtpH0x6WShhLNrUk196U8X+yofxDddf6Zav06+ymvl1xZtNrSaBeUqyeWqh1jdv6vugMfuLh5HD4u15a\/ZZ583+k16cgZWrfq1lR2kj3A6v0f3o+TFpxMnXKqU\/zygzz51A2MrYfM0zqzs9BjrfpS++2PnzHPAmhShzThJUr7jsfFx4YS\/1C5F+ccFfh1e\/wmvlOWyU2xDIu1IvZyb+jCTkL\/zi21rykZ4f2GbuhVBcQ4fXC1XthffJvxbUOis3\/KOj73bvUKU\/KV83O3ftRrOmaeqvfT389V\/fcp23m93zBtK3I05WdbV8OcarOMpXpr7tFrM2+zNNfRPJzEvXTMyS2RhefV\/kRSxfxCLFos+w9\/fhIHXXJ6YtISvSlqZ6YWaFV+o02jgjkIx2My+eYDi8Mo8kJvwfT79YKxmpPlkyfQyvvg\/yUSaHzElh+uRTk9ybhoSCv7RV3wNcdoKSD6j6NsiQTVuefvYlt6NvJJ4ubRqJx+vnT33C\/xo7z3li5t4L1OGV55TsdPXsP19xj13\/gW30krG7wyv997U5gnx8bK+sQuOUZBVK5lSH159nlNnnjr9stXml\/xVM\/s7bZkxGc9CKw+ttvtfn8PrzHJD6jDae8PzI9Ped5hnDa\/Y5bMbh9fdZbbRJludz08i+oTxPh\/cPutqWvd9++wPeeufDWpso6A3Qtm1rJaisbSkrN5Qk\/cya84kSmJYVnPoc3hOOz1O7ksjKUX2SKrIaLLExxx\/fRX0d6ts5\/bRu7o0sJINaYoZkhS4aHF5hI8k8slItPz2JwynyTzIOWQmTsBGREdNrqPr7cNDs5pmMpG1LK9s5SohIq1Y1iVhmHV65Vh66EgJzZE575TDLy7Sqaic+\/\/K7Ols+W7mBzb54vNVpRgZJbW1buh4ffjQPhfMX1ammvlUlyQ6+eWBfd+y5tm3mO7M\/xtV9LlIfgt423QgFf6MHuD9bC2vbY5511qlqxV7baUpWZrxtkWk0L4WX3JOdcnPcW4Nr2zB724I6VA6v2MTXGGQC6EO1jOZqNDi8MgbZRlzbilpW5rV7c926jcom3pJ+6\/uQN7K1v\/ejZzk9X39XeLU6rTyjrDx3\/GGr9clTBcmfRCYjh9dovtfn8Mo5q88B\/XvG29bC3rYzN5pPRioNVp\/DRs\/LQN6VUtbb81aedZKf9MbMD9SW3HY4YsbhtQNs9sFeBIweOvbqrfN6Q\/7Os6ndR2TFsbP7WOzWPzNsjWJF7TYm9qeGgFOe1XR4OaNjloA+Uc4zPCRmoYRx4OQfRthsShEQScdrrrpIrd57Jh4TUWAEzLCtL\/EtsNZZOpQEnPKspsMbylnCuiNOQP9Tjj6WSMIprru2AGecfrKKPfV3K+CID9DmHSB\/mxvIYd3z\/Ll7\/foKjBk7HiUlZWp74JtuvMqtEmM1WcphqCwPx1+2KSlJqq0WLZpDEpw0lZ5f1\/ymNkAI1oYmlgfEArUIxMKzmg4vJ72jCci+8hf3Ptu9Raq3wUqs0fsffIpXp73jaBaRGBz5R4J67LZZX8Kvnsq27ZV47p8vu5MrY5eY+ZH7y9bb5gR2SmQyT8DZV8bCs5oOr7PnMEf3R5LcRb3\/qqSgJLheEuXkMErgIrzgEJAkRfIPDkvWYkxA7nHRMRcxfZEdlAQ1OUSZZOfOXShathIz3nxPrfrysEbAH7Yikzb83luQlpYKSQ7fsnU75n5cqOQhediLgNOf1XR47TXf2BsSIAESIAESIAESIIEgE6DDG2SgrI4ESIAESIAESIAESMBeBOjw2sse7A0JkEAMERi8pQx3bf7N54ifzmiHSc3bqvNG196c2QnzGqfHED0OlQRIgATME6DDa54VryQBEiCBoBIwcmKlMc3pNXPte6ktcHfrI4PaR1ZGAiRAAk4gQIfXCVbkGEiABKKSgObEfpuchkGZnbArvoF7HP9YvwrHVW3C6XFxKJP9xAHIv31de3HVJnUNV3qjciqw0yRAAiEmQIc3xIBZPQmQAAn4IlCfw9tr51a0LP8Zo3SFH\/p\/h\/dcL85xyqGDeLH8Z3TfXQmu8nK+kQAJkEBdAnR4OStIgARIIEIEfDm84sA+XLYcl+zZoXo29LY7Me75Z9R\/v5vUBA+3ParWarD8vVZXaeJh6NMuDxUJDSM0KjZLAiRAAvYjQIfXfjZhj0iABGKEQH1xuT0BLADQ57gTMOrzpbj+mA74qmQNzk9oiLLs4+s4vLIiPLH8Z9DhjZHJw2GSAAlYIkCH1xIuXkwCJEACwSPgy+EVR1cc3ratWuO1eYuQ2a490p8eixaj7leNH9G2M+JSmtXqCB3e4NmFNZEACTiPAB1e59mUIyIBEogSAt5CGg7s\/x0bN6zCnt1VuG34Qxgy\/GE1GnF4nx91v4rpbZyUilbt8mqNkiENUWJ0dpMESCAiBOjwRgQ7GyUBEiCBP+Nu9coLVZUVqNiwGgmJjdC+w4luTJpD2yYuHuurD8HVKgepaS73eVF1EKUGJq1xZpEACZBAXQJ0eDkrSIAESCBCBDxXeCsPHkBZaRFklffxAQNxZJssd89yv\/ocXRZ8ivHNW2DolhoJspzcHupPfWgEZckiZEw2SwIkYGsCdHhtbR52jgRIwMkEPB3e0q3rsHVLKc7skof5jzxSe+izZwMzpqu\/0xLa+gN4VXcVV3edPFs4NhIggUAI0OENhB7LkgAJkEAABPQO7wBXNlaU\/ID2LhdevW0IzsyrHaMLncOrJbVJ0\/MBHN8gAde3PQo\/HdY4gN6wKAmQAAk4lwAdXufaliMjARKIIgLlpUUqUa1\/z3y8OmSIYc8HjB+PqfMLkZSciswsD+fYsDQvIAESIIHYIkCHN7bszdGSAAnYkMCe3ZUoL12mVnfnj35E\/WnmiCu4RF2WmdUFSclpZorwGhIgARKISQJ0eGPS7Bw0CZCAXQjoZcgeuvJKPHxlH9NdkxVeWen1VHQwXQEvJAESIIEYIUCHN0YMzWGSAAnYk4AmQyarumsmvWi5kz0ffBALlhXVkSmzXBELkAAJkICDCdDhdbBxOTQSIAF7E5DV3ZJfl6pOFvzlXMy+faDlDi8oKkLPkQ+qcqLbK6u9PEiABEiABGoToMPLGUECJEACESKwccNq7KiswOFpbZHYqh2m39QH3Tv8qb1rtlvaKm+TNBdatsoxW4zXkQAJkEDMEKDDGzOm5kBJgATsREBb3W2TnIFHuw7E+ztXYlvDXVhwj\/VV3pKKCmQPHqSGxwQ2O1mZfSEBErALATq8drEE+0ECJBBTBDQZsosPPx1jug5Exb4dGLhyOoac1QNDe51qmQVlyiwjYwESIIEYIkCHN4aMzaGSAAnYg4CWqCaru\/8591l3p2ZWLMbMiiVqlTezmXWZMVnlldVervLaw87sBQmQgH0I0OG1jy3YExIggRggIKEMZaVFkD9lZVdWePXHwOLpOO2Yw\/HEZedapkGZMsvIWIAESCBGCNDhjRFDc5gkQAL2IOBrdVfrXeG2YowrLww4gS29eRbSM6wnwNmDEntBAiRAAsElQIc3uDxZGwmQAAn4JKCXIXv1jPvRrUVnr9eOWPM+Ulo2UE6v1YMyZVaJ8XoSIIFYIECHNxaszDGSAAnYgoAmQ6YlqvnqVNGudRA\/78xJAAAgAElEQVSnlzJltjAbO0ECJOAAAnR4HWBEDoEESMD+BPQyZK\/+5QFkJmfU22lxeMXxXTX2bsuDo0yZZWQsQAIk4HACdHgdbmAOjwRIwB4EPGXIjHoVqEzZw2\/NxKi33kJScioys\/KMmuN5EiABEnA0ATq8jjYvB0cCJGAHAkaJar76GCyZMlerHKSmueyAgn0gARIggYgQoMMbEexslARIIFYIGMmQGXEIhkyZtJGT28OoKZ4nARIgAccSoMPrWNNyYCRAAnYgsHVzKbZuKYXnJhNm+0aZMrOkeB0JkAAJ+CZAh5ezgwRIgARCRMCsDJlR85QpMyLE8yRAAiRQPwE6vJwhJEACJBAiAlYT1Xx1Q5Mpk93XCk60noA2YPx4yC5sTGALkaFZLQmQgO0J0OG1vYnYQRIggWgksGd3JcpLl6lQBjMyZEZjHFdWiMLtxTUyZd99Bzw+1qgIcN9w4KST1HVxBZeoP+cDeCuzE+Y1TjcuzytIgARIwCEE6PA6xJAcBgmQgH0ISCjDxg2rsGd3FW7pfAluOaogKJ27uGiiWuF9ol1zyw7vw3fegVElJTgTQCc6vEGxByshARKIHgJ0eKPHVuwpCZBAlBDwV4bMaHg+E9j++U9g4QLgL2cCt99eu5qtW4EH7gc2bkQ2gBIAPZu1RqlL\/o8HCZAACcQGATq8sWFnjpIESCBMBIKVqOaru14T2Hw5vKtXA6NHATt3Ai1bYkFVFXru2aOqpkxZmCYEmyEBErAFATq8tjADO0ECJOAUAhs3rMaOygp0a9EZr55xf9CHpSWwTb+pD7p3yKqpvz6H9+mngLv+XnPd6FHouXMnFgBokuZCy1Y5Qe8fKyQBEiABOxKgw2tHq7BPJEACUUlAW92VRLVHuw5UTm8oDlnl3dZwFxbcM7B+h1ff+B+rvQt27kTPP\/4+M6sLkpLTQtFF1kkCJEACtiJAh9dW5mBnSIAEoplAsGTIjBhU7NuBgSunY8hZPTC016m+V3i9OLwS3jDg6KMx9X\/\/o0yZEWieJwEScAwBOryOMSUHQgIkEEkCehmy\/5z7bMi7osmUySpv5mtTfSetaT3Rx\/PeNxxxf8iacZU35KZiAyRAAjYgQIfXBkZgF0iABKKbgF6GbEzXgbj48NPDMiC3TFn5SssO79RdOyEbUiQkNkL7DieGpb9shARIgAQiRYAOb6TIs10SIAHHEAiVDJkRIE2m7OuU\/cj4frF3WTIfK7yyIUXPBx\/EgmVFSG+ehfSMPxLgjBrleRIgARKIQgJ0eKPQaOwyCZCAfQiEWobMaKSSwHbXhsU4bd1ayw7vgqIi9Bz5oGpCVnlltZcHCZAACTiRAB1eJ1qVYyIBEggbgVDLkBkNRGTKGi16ChdXbbLs8Erd2iovZcqMSPM8CZBANBOgwxvN1mPfSYAEIkogXDJkRoOsI1NmVEB3vqSiAtmDB6m\/YQKbBXC8lARIIKoI0OGNKnOxsyRAAnYiEC4ZMqMx15EpMyrgcf7ht2Zi1FtvUabMIjdeTgIkED0E6PBGj63YUxIgARsRiFSimi8EMysWY2bFErUZRWYz65tJyCqvrPZylddGk4xdIQESCBoBOrxBQ8mKSIAEYoWAhDKUlRZB\/nS1ykHhqQ\/ZYugDi6fjtGMOxxOXnWu5P1PnF1KmzDI1FiABEogWAnR4o8VS7CcJkIBtCGiru2jTFjlN2iG\/aS6Gts2PeP80mbLpN\/VB9w7WZcYoUxZxE7IDJEACISJAhzdEYFktCZCAMwnoZcgwZSbSS8qRPms2xmRfhLyUNhEftCSwpbRsAHF6rR6UKbNKjNeTAAlECwE6vNFiKfaTBEjAFgQ0GTL0vgwY9ZTqU\/sht+O43YnK6Y30ITJl4vRKWEPBiXmWu0OZMsvIWIAESCAKCNDhjQIjsYskQAL2ILBndyXKS5dBQhlkdVf9CSBp+XJkjh5jm1XecWWFKNxejFVj77YMjjJllpGxAAmQQBQQoMMbBUZiF0mABCJPQEIZNm5YhT27q6Bf3dV6ljn6ERy+qgyTc\/tGvrMALi6aqFZ4\/Ulgo0yZLUzITpAACQSRAB3eIMJkVSRAAs4loE9Uw9wv6ww0YdMmFdowNDMf+c1yIw4iWDJlokKRmuaK+HjYARIgARIIhAAd3kDosSwJkEBMENDLkKm4XYnf9XK4Jk5C6sLP8V7ezbbgIjJl2VlN\/Upg02TKZCA5uT1sMR52ggRIgAT8JUCH119yLEcCJBAzBLZuLsXWLaVA15NrYnfrOXL6XG0bmTItgY0yZTEzVTlQEiABHwTo8HJqkAAJkEA9BNwyZJKgJqu74vTWczRZ+DlaTpxkmwQ2UWzY1nCX2oHN6kGZMqvEeD0JkIBdCdDhtatl2C8SIAFbECgvLfKZqOarg5LA1m1tpS1kyir27cDAldP9likbMH48JLwhKTkVmVnWZc5sYUR2ggRIIOYJ0OGN+SlAACRAAr4I+JIhMyLmJJkyGWtcwSVqyJlZXZCUnGY0fJ4nARIgAdsRoMNrO5OwQyRAAnYgUEuGbNAwYPAwS91yokxZQmIjtO9woiUOvJgESIAE7ECADq8drMA+kAAJ2I6AkQyZUYc1mbI+rq7o4+pmdHnIzxduK8a48kKl2NC9Q5bl9rIHD4JsSkGZMsvoWIAESMAGBOjw2sAI7AIJkIC9CLgT1aRbospgkKjmq\/fps2ZD\/pncsS9cDZtEfJCSwJbSsoFfMmX6BDbKlEXclOwACZCARQJ0eC0C4+UkQALOJ7Bxw2rsqKwwJUNmREM2ozh7fzqGts03ujTk54MlU9YkzYWWrXJC3l82QAIkQALBIkCHN1gkWQ8JkIAjCFiVITMatJNkyiSkQUIb5GACm5HleZ4ESMBOBOjw2ska7AsJkEDECfgjQ2bUaTvKlA05qweG9jrVqOt1zlOmzDIyFiABErABATq8NjACu0ACJGAPArVkyOZ+GbROaTJlQzPzkd8sN2j1+lvRzIrFmFmxRG1GkdnMuswYZcr8Jc9yJEACkSJAhzdS5NkuCZCArQjUkiGTHdV6XxbU\/rkmTkLqws\/xXt7NQa3X38oGFk\/HacccrjaksHrIRhSy0kuZMqvkeD0JkECkCNDhjRR5tksCJGArAoHKkJkZTE6fq+EUmbKeDz6IBcuKkN48C+kZ1mXOzPDiNSRAAiQQLAJ0eINFkvWQAAlELYFgyZAZAXCqTJlsRiGrvTxIgARIwK4E6PDa1TLsFwmQQNgIBFOGzKjTIlN23O5EjMm+yOjSkJ\/XZMokrKHgxDzL7WmrvJQps4yOBUiABMJMgA5vmIGzORIgAXsRCLYMmdHo7ChTJo7vqrF3G3W9znnKlFlGxgIkQAIRIkCHN0Lg2SwJkIA9CIRChsxoZHaSKZO+Xlw0Ef7IlH37aynOG\/sPbN1SiqTkVGRmWV8lNmLF8yRAAiQQDAJ0eINBkXWQAAlEJYFwJKp5A+MEmbLybZW4d9YnQKMifPXtMpSs52YUUXkTsNMkECME6PDGiKE5TBIggdoEJJShrLQI8idCIENmxNuOMmXZWU0x\/aY+Rl1X5+csLVIO7\/QRRVixugoDRoEyZabI8SISIIFIEKDDGwnqbJMESCDiBLZuLlU\/xaNNWyCIm0xYGZjIlOU3zcXQtvlWioXk2sJtxRhXXqgc3u4d6pcZk9Xda6a8he5Hr8ITg1ar\/vQcBCxYCsqUhcQ6rJQESCBQAnR4AyXI8iRAAlFHIFwyZEZg7JjAltKygeEq77h5X2HOT\/Mx44EiZLb4XQ1TnF1xeuWgTJmR5XmeBEgg3ATo8IabONsjARKIOAG3DJnspibhDBE87JTAZkamTFZ3z3xyMoYUlGLopaW1yGmrvJQpi+CEYtMkQAJeCdDh5cQgARKIKQJ7dleivHRZTSjDlJk1f0bw0BLYRJc3L6VNBHtS0\/S4skIUbi\/2KVPWd8pMlO1YjQXPLa3T15J1QHbvmr\/OzOqCpOS0iI+HHSABEiABIUCHl\/OABEggZghIKMPGDauwZ3cVMGgYMHiYLcYuq7yHryrD5Ny+tuiPyJTJRhSyIYX+EBkycXglbrfgjAqvfX14MjBqMihTZgtLshMkQAIaATq8nAskQAIxQyBSMmRGgBM2bYLswNbH1RV9XN2MLg\/5eW8JbHoZsukjltXbh+wLoWTKXK1ykJrmCnl\/2QAJkAAJGBGgw2tEiOdJgAQcQSDSMmRGENNnzYb8M7ljX7gaNjG6POTnR6x5H\/oENr0MWffOVfW2P\/VDKJkyOXJye4S8r2yABEiABIwI0OE1IsTzJEACjiDgliHrenJN7K4ND1nlPXt\/ui1kyrQENpEpa9sstY4MmRE+JrAZEeJ5EiCBcBKgwxtO2myLBEggIgTcMmSSoCaqDOL02vCwo0zZtoa7UHBClzoyZEb49DJlTGAzosXzJEACoSZAhzfUhFk\/CZBAxAmUlxbVJKrZQIbMCIadZMoq9u3AwJXTVZe9yZAZjWXAw8DUj5jAZsSJ50mABEJPgA5v6BmzBRIggQgSsJsMmREKu8mUzaxYjJkVS5QMmbbJhNEY9Ofjutb8H1d5rVDjtSRAAsEmQIc32ERZHwmQgG0I2FWGzAiQ3WTKBhZPx2mn\/OLeRtio\/\/rzWgJbQmIjtQMbDxIgARKIBAE6vJGgzjZJgATCQsCuMmRGg7etTNmIIhgpNHgbm5bARpkyI8vzPAmQQKgI0OENFVnWSwIkEFEC7kQ16YWoMtg0Uc0XJFvKlLVbASMNXm\/j0SewUaYsorcFGyeBmCVAhzdmTc+Bk4CzCWzcsBo7KitqHF2bypAZWcCWMmUBrvI2SXOhZasco6HzPAmQAAkElQAd3qDiZGUkQAJ2IBAtMmRGrGwpU5a8RiWwWT1K1gHZvWtKMYHNKj1eTwIkECgBOryBEmR5EiAB2xGIJhkyI3h2lCnzR6JMxkmZMiNr8zwJkECoCNDhDRVZ1ksCJBARArVkyOZ+GZE+BLNRTaZsaGY+8pvlBrNqv+qiTJlf2FiIBEggwgTo8EbYAGyeBEggeAQklKGstAjyp9pRTTaacMDhmjgJqQs\/x3t5N9tiNJQps4UZ2AkSIAELBOjwWoDFS0mABOxNIFplyMxQzelzNfKb5mJo23wzl4f0msJtxRhXXojpASawpTfPQnpGVkj7yspJgARIQAjQ4eU8IAEScASBaJchMzKCHRPYUoIgUyabUcimFDxIgARIIJQE6PCGki7rJgESCBsBtwyZhDFIOIMDD5EpO253IsZkXxTx0RXtWocRa95Xu68VnFFhuT\/aZhSUKbOMjgVIgAT8IECH1w9oLEICJGAvArVkyERzt01be3UwSL3REtjE4c1LaROkWv2vZlxZIQq3F2PVjEWWK6FMmWVkLEACJBAAATq8AcBjURIgAXsQcJIMmRFRkSk7fFUZJuf2Nbo0LOcvLpqoVnhlpdfq8fBkYNRkICk5FZlZeVaL83oSIAESME2ADq9pVLyQBEjAjgScnKjmjXfCpk2Q0AanyJRlXwiUrAdcrXKQmuay4xRjn0iABBxAgA6vA4zIIZBArBJwqgyZkT01mbLJHfvC1bCJ0eUhPy8yZdk5ZZg+YpnltqZ+CAwYVVMsJ7eH5fIsQAIkQAJmCNDhNUOJ15AACdiSwNbNpdi6pbQmZtcBm0xYgWwnmTItgY0yZVYsyGtJgATCSYAObzhpsy0SIIGgEXC6DJkRKDvKlG1LXoMFzy016nqd8wuWAqLaIAdlyizjYwESIAETBOjwmoDES0iABOxHIJYS1XzRlwS2bmsrHSFTNuBhYOpHAGXK7HevsUck4AQCdHidYEWOgQRijMCe3ZUoL11WE8rgYBkyI7M6SaZMxhrXtWbEmVldkJScZjR8nicBEiAB0wTo8JpGxQtJgATsQEBCGTZuWIU9u6uAQcOAwcPs0K2I9YEyZRFDz4ZJgASiiAAd3igyFrtKAiQAxJoMmZHNNZmyPq6u6OPqZnR5yM8XbivGuPJC+JvARpmykJuIDZBATBKgwxuTZuegSSA6CdSSIZNQhq4nR+dAgtzr9FmzIf\/YRaZMthxOabeCMmVBtjOrIwES8J8AHV7\/2bEkCZBAmAls3LAaOyorahxdcXh5uAnIZhRn70\/H0Lb5EacSLJkyJrBF3JTsAAk4hgAdXseYkgMhAWcTcMuQSaLaqKe4uuthbqfKlDGBzdn3NUdHAuEiQIc3XKTZDgmQQEAEKENmjM9OMmUV+3Zg4MrpGFJQiqGXlhp33uMKTaYsKTkVmVl5lsuzAAmQAAnoCdDh5XwgARKwPQHKkJkzkSZTNjQzH\/nNcs0VCuFVMysWY2bFErUZRWaL3y23RJkyy8hYgARIwAcBOrycGiRAArYmUEuGTEIZel9m6\/5GunOuiZOQuvBzvJd3c6S7otofWDwdp53yC54YtNpyf6Z+CAwYBSQkNlI7sPEgARIgAX8J0OH1lxzLkQAJhIUAZcisY87pczWcIlMmWw7L1sOuVjlITXNZh8ESJEACJCAb2+Tk9qgmCRIgARKwIwF3opp0jjJkpk3kJJkycXbF6ZVDVnlltZcHCZAACVglQIfXKjFeTwIkEDYClCHzH7XIlB23OxFjsi\/yv5IglaRMWZBAshoSIAG\/CdDh9RsdC5IACYSSAGXIAqOrJbCJw5uX0iawyoJQWjaj2Ja8RiWwWT1K1gHZvWtKUabMKj1eTwIkIATo8HIekAAJ2JIAZcgCN4vIlB2+qgyTc\/sGXlmANVCmLECALE4CJBAQATq8AeFjYRIggVAQYKJacKg6TaYs+0KgZD1XeYMzO1gLCcQWATq8sWVvjpYEbE9AQhnKSosgf6od1ShDFpDNKFMWED4WJgEScAgBOrwOMSSHQQJOIcDV3eBbUmTK8pvmYmjb\/OBXbrHGwm3FGFdeiOkjitC9c5XF0jWKDaLckN48C+kZWZbLswAJkEBsEqDDG5t256hJwJYEKEMWGrM0Wfg5Wk6cpBQb7JLAltJuBaaPWGZ5wJQps4yMBUiABJi0xjlAAiRgJwJuGTIJY5BwBh5BIyAJbN3WVtpKpkx2Xys4o8LyGLVV3iZpLrRslWO5PAuQAAnEHgGu8MaezTliErAlgT27K1Feugxo07Zmkwn5k0fQCNhNpmxcWSEKtxdj1YxFlsdImTLLyFiABGKeAB3emJ8CBEAC9iBAGbLQ28FOMmUy2ouLJqoVXlnpxUIAd5lg8DSAo4CRlwOP7ATOBDAfwNMZ7TCpOT+STBDkJSQQkwTo8Mak2TloErAXASaqhcceCZs2QXZg6+Pqij6ubuFptJ5WZlYsxsyKJWoziszlv5tzeIcBeAVAFZANoATAq\/\/\/Z386vRG3JztAAnYmQIfXztZh30ggBghQhiy8RtZkyiZ37AtXwybhbdxLawOLpyM7p6xuAttIAB8DOA\/AaF1B8W4nyJZrwNQrgQHP1JyrBlCaeBj6tMtDRULDiI+LHSABErAXATq89rIHe0MCMUdg6+ZSbN1SCnQ9uSZ2l0fICGgrvNKAXWTKinatg2w7XEemzJvDuxvAHQBkd+I\/HGEtge0hOdUgAde3PQo\/HdY4ZAxZMQmQQHQSoMMbnXZjr0nAEQQoQxZeM6rV3UU\/IM51EqrL59lKpmxb8hoV2uA+fK3weiDTy5QtSmiEvx9+NFd4wzut2BoJRAUBOrxRYSZ2kgScSYCJauGzq7a6G5fZC3FNO+NQyRzkodq+MmUmHV4sB\/pdD7x2ADgisRHiOpwYPqhsiQRIIGoI0OGNGlOxoyTgLAKUIQuvPUWhIWlVOeI79lMNV+8qR3XJHAzNzEd+s9zwdsZLa3Vkysw4vMsB3FaTwBb3R52ZWV2QlJwW8fGwAyRAAvYiQIfXXvZgb0ggJghIKMPGDauwZ3cVMGgYMFhS73mEioC201pc+wLEpWS6m5FVXuwqx3t5N4eqaUv11pIpM3J49TJmmcDfuzfA03MOIik5FZlZeZba5cUkQALOJ0CH1\/k25ghJwHYEKEMWPpNIKEPb0WOQsLsh4tsX1G54fxUOrZxmG5mywm3FGFdeWJPA9maVd5UGGYHe2ZUIhmcBJAPZFwIl6wFXqxykprnCB5ktkQAJ2J4AHV7bm4gdJAFnEWCiWnjtqVZ3X3oD8dmXAImpdRqvrvgW1Zu+g11kykSxIaXdCkzft8y7w6sLY4DO2ZWB6RPYcnJ7hBc0WyMBErA1ATq8tjYPO0cCziOwccNq7KisoAxZGEzrTlRr2hmSrObrkFXe\/JTWGNo2Pwy9qr8JTabs64zFyPhqf10dXi3UwVs1qUDPNsCCn4EmaS60bJUT8fGwAyRAAvYgQIfXHnZgL0ggJgi4V3fbtAVGPVXj9PIIGQFNhkxLVPPVUPX2FbaTKbu5tBBnb9pa2+HdBOBGAOU+RpIKLLgV6Dm25jwT2EI2tVgxCUQdATq8UWcydpgEopcAZcjCZztPGTKjlu0kU1axbwcGrpyOIQWlGHppqVHX65wf8DAw9SMwgc0yORYgAecSoMPrXNtyZCRgKwK1ZMjmfmmrvjmxM54yZEZjtJtM2cyKxZhZsURtRpHZ4nej7tc5H9eVq7yWobEACTiYAB1eBxuXQyMBuxCoJUMmoQy9L7NL1xzZD18yZEaDld3XJLzBLjJlA4un47RTfsETg1Ybdb3O+akfAgNGAQmJjdCem1FY5scCJOA0AnR4nWZRjocEbEiAMmThM4omQ5a4P6PeRDVfPTq0bDzym+baIoGtlkxZ5yrLEHsOqlFuSG+ehfSMLMvlWYAESMA5BOjwOseWHAkJBI1AkyaNccVl5+Oz+V+hpKQsoHopQxYQPsuF02fNRvr7n\/qUITOq0I4JbEqmbMQyo67XOa+XKZNVXlnt5UECJBCbBOjwxqbdOWoSqJfAlVdciKv79MbBg4cw77Mv8eq0d7Bnz16\/qFGGzC9sfhVyJ6q1OAlxru5+1SGF7JTApsmUqc0oAljlpUyZ39OBBUnAEQTo8DrCjBwECQSXwBmnn4Qht\/ZHcnKSqnjLlm149\/1\/44MP5+Hsv56OFT+vNrXySxmy4NrFqDariWq+6tMS2MZkX4S8lDZGzYb8vGxGsS15jUpgs3qUrAOye9eUokyZVXq8ngScQ4AOr3NsyZGQgCGB3hf+Fa1aZuD1Ge\/Wu2LboEEDPPbI3cjN7YCdu3ajaVrNDl0Vm7YgNbUxKrdXYdQj\/8RvpevqbZMyZIYmCdoFScuXI3P0GMS1L0BcSmbA9coqr2tfFSbn9g24rkArCFSm7OHJwKjJlCkL1A4sTwLRTIAObzRbj30nAQsE2mW1wcgRt6N1a5dasX1t+hwVruDr+Guv0zBo4DVYtmwlilf+igvPPwupqU3U5T\/8uBz\/HP8KKiq2+CzPRDULxgnwUgllaDlxEpLWViG+fUGAtf1RfH8VZAe2Pq6u6OPqFpw6A6glUJmy7AuBkvVc5Q3ABCxKAlFNgA5vVJuPnScB8wQG3ngVZIU3Li5OFTp06BBW\/7IWb7z5PhYv+bFORbLKO\/bRe9D+8LZ4btwrOPzwTFx5+QVITExU127Zug2PPzkRy5evqlNWQhnKSosgf6od1ShDZt5QflypZMheekOpMgRjdVfrgiZTNrljX7ga1nzsRPKgTFkk6bNtEohuAnR4o9t+7D0JmCaQlHQYBvS7HL3OOg2NGjV0l9u\/fz8WL\/kJU15+s86Kbe8LemFA\/yvw0\/9WoKUrAy1btsA7s+fiuGOPwrZtlRj7xAte2+fqrmmzBHyhO1GtaWe\/ZMiMOiCrvPkprSlTZgSK50mABGxNgA6vrc3DzpFA8Am4XM1x0w1XoVvXY9yrtdJKVdUOfDj3M7z19kc4ePCgaljkyUY9dAdyO3ZQ\/7\/0+\/+p2F3tvLfeUYYs+Darr0bXxElIXfSD3zJkRr2lTJkRIZ4nARKIBgJ0eKPBSuwjCYSAQPeTjsMtg69FRkZ6rdo943svuegcXHftpdizZw\/+Of5VfPvdD\/X2xi1DJmEMEs7AI2QE3Ku7EsrQtHPI2rGjTJnsvlZwRoXlMWubUVCmzDI6FiCBqCZAhzeqzcfOk4D\/BC65+Bxc1\/dSNGyYCAlr0GJzpUaJ7xXpsRcmva7kxySEQRzj+pLcpNye3ZUoL10GtGkLTJlZ8yePkBEIlgyZUQftJlM2rqwQhduLsWrGIqOu1zlPmTLLyFiABBxBgA6vI8zIQZCAdwJtWrfEtu2VdSTIJKxh9EN3IiurjQplmDDxNRxzdOc68b27du3G8y9Mw+dffGeIWEIZNm5YhT27q4BBw4DBwwzL8AL\/CQRbhsyoJ3aSKZO+Xlw0Ua3wykqv1YMyZVaJ8XoSiH4CdHij34YcAQl4JXDEEYfj\/vtuRWJCQh0JssEDr8F55+YjPj4O8xd8jaefnaLqaN++rQpz6NwpB\/Hx8UqO7KFRz2LHjp2GlJmoZogoaBeERIbMqHcOlSlztcpBaprLaPQ8TwIkEOUE6PBGuQHZfRLwReCuO25CzzNPUTJkEqJQsrYMr70+B3v37sV999yCpk1TsWHjJjz2+AT88svaWtX0OOVEXFpwLj7+uBCfzTf+2ZgyZOGdh6GSITMaRXXFt6je9B3sJFOWnVOG6SOWGXW9zvmpHwIDRtX8dU5uD8vlWYAESCC6CNDhjS57sbckYIqAaOjedEMfnJV\/qnt7YCkosbqVlTtUPO6BAwcwa\/bHate1QI+tm0uxdUsp0PXkmthdHiEjEGoZMqOO20mmrGjXOsi2w9NHFKF75yqjrtc5zwQ2y8hYgASilgAd3qg1HTtOAsYEfEmQScnS0nUY8dDT2Lx5q3FF9VzhliGTBDVRZRCnl0fICLhlyDr2C1kb9VVsR5mybclrsOC5pZZ5LFgKiNMrR\/sOJyIhsZHlOqwUkJAhUT1p06al2rBl5tsf1rvFt5W6eS0JkED9BOjwcoaQQAwQ6Nb1WFzf\/wpkZWQv8WYAACAASURBVLV277QmwzazxbARnvLSoppENcqQGaEK+Hy4ZMiMOuokmbIBDwNTPwKSklORmZVnNHS\/zsumL0Nu7Y8ep5zgVkOprq7G8hWr8Mij403FyPvVMAuRAAm4CdDh5WQggRghIGEOvS\/spVaYmjdv5h61pwSZFRyUIbNCK\/BrwyVDZtRTTaZsaGY+8pvlGl0e8vOByJRJ5+K61nQxM6sLkpLTgtpfue\/uu+dmnHLyCepjU0KKliz9CTk57dG6VQtMn\/EeZr\/7SVDbZGUkQAJ1CdDh5awgAQcRkJ9Mb7y+Dzp1OgJJhx2mJMcmvji9lqyYry2Gf\/99H7759nu8OOUN9VI2OihDZkQouOdVotrESYhrX4C4lMzgVu5HbdXl8yDhDe\/l3exH6eAXCUSmTEtgk5AGCW0I5nHM0Z0w\/N5bVCz9goXfYNLkGSqMYeht\/XHO2X\/BZ4Vf4ZnnXgpmk6yLBEjACwE6vJwWJOAQAmf17IEbb+iD1NQm7hFt2FChtgL+rXRdnVGKc3zzoGvRKbcDEhIS1PmiomLc\/+A\/6t06WKuIMmThmzgSytB29Bgk7s9AXGav8DVs0NKhZeOR3zQXQ9vmR7xPhduKMa680O8EtuwLgZL1QLBlymTTluH33oqKis0YdtdoNG\/e1L21d3x8A7z19oeY8eZ7EefHDpCA0wnQ4XW6hTm+mCDQKfcIpbmrhSpImML+\/QdUjOCIkfVv76vF98qL2MomEyW\/\/pEkJKoMTFQL6TxLnzUb6e9\/ivjsS4DE1JC2ZaVyOyawpbRb4ZdMmT6BLZgyZU2aNMbYMfcgM7MVysrXo1XLFm7llOLiXzFqzHOmflGxYhdeSwIkUJcAHV7OChJwAIEHht8G0c6VRJhly1Zi\/AvTUFa23uvIjjuuC2Q1+KVXZrpftBJnmJvbQWWOmzk2bliNHZUVlCEzAyvAayItQ2bUfZEpy2vYGGOyLzK6NOTn7SpTJvG7Q27th7S0mo8V+Rj99rv\/qq27zYQPhRwcGyCBGCBAhzcGjMwhOpvAUUcdiQfuu01tJCFSYyNHPYOKii1eB33G6Sdh0E3XIC2tCb5atARjn3jBMhzKkFlGFlCBSMuQGXVeS2AThzcvpY3R5SE\/L7q8\/sqUlawDsnvXdDHYCWxt27bGmWd0x\/4DBzF\/\/iJUbPJ+j4YcEBsggRglQIc3Rg3PYTuHQO8LemFA\/yvQsGEiPv6kEBMmvu5zcJI8c2qPripbfNeu3Xhu3CtY9LU1\/VLKkIVv7iQtX47M0WNU3G5c087ha9hiSyJT5tpXhcm5fS2WDP7lFft2YODK6RhSUIqhl5ZabiAcMmXSKflVpeOR2WjUqKHqo6z+tmrVAv\/69wKu+lq2GguQgDEBOrzGjHgFCdiawIB+l+OyS89TfZSd016d9o7P\/srK7sMj71AvWgl\/eGfWXEx7fbbp8dWSIZv7pelyvNA6AQllEFWGpLVViG9fYL2CcJbYXwUJbbCLTNnMisWYWbFEbUaR2eJ3yyT8kSmTTV7OPedMtGiRjjatW9W0GQdkZDTDYY1qNrSIbxCv1FN8HcHc\/dDyoFmABBxOgA6vww3M4TmfgH6F978\/LMNDo56tV2Vh4I1X4aLeZ5tykPX0asmQyY5qstEEj5ARsJsMmdFANZmyyR37wtXwT6UQo3KhOj+weDpOO+UXPDFoteUm\/JEpkxXbxx65G3l5vnWJZWvvffv2q\/7s\/f13bN68DagGDh46iHXrNqpfXTZt3op33\/u35T6zAAmQQP0E6PByhpBAlBPQx\/DKCtFHcz\/DlJdn+hyV5vBaXeGlDFn4JopdZciMCDhJpky2HBblhvTmWUjPyDIaujoviZ8ndz8BK1f+6t4yWBxZxuuawseLSCCkBOjwhhQvKyeB8BDQVBqkNVlFWvT19xg\/Yar7pav1QkIaxoz+Ozpkt8POnbvxxD8m4vv\/Fhl20p2oJldShsyQV6AX2FWGzGhcTpUpk80oZFMKfw9Z\/T39tG4qlGjb9ir1USqbT\/AgARIIHwE6vOFjzZZIIGQEjjjicNx\/760q6UU7RO5IdnGaNedjlQQjG03cevN16NwpRyWtyfamEv5g5qAMmRlKwbnGLUPW4iTEuboHp9Iw1iIJbHmopkzZH8xFLvCG669ES1eGuu\/k+HXNb\/jHUy963RAmjKZiUyQQUwTo8MaUuTlYJxOQn1NvH3I9Dm9Xe9tZCV2QuEFRcdBeuBs2bMJjT0zAL7+sNURCGTJDREG9IHP0I0haVY74jv2CWm+4KqNM2Z+kz\/3bmbhhwJWQ7bxlM5jy8g2Ii49Dm9Yt8cm\/FigdXh4kQALhIUCHNzyc2QoJhIWAvFhvHtQXp53azS135Nnwpk1b8fwLU7Fk6f9M9YkyZKYwBeUitwxZ+wLEpdT+cAlKA2GqxEkyZQ9PBkZNBpKSU5GZlWeaoIQxPPXkAyqMQT4wJ02egcVLflT35tDb+mPd+o0Ydudo0\/XxQhIggcAI0OENjB9Lk4AtCYjI\/cUXnY1uJx6DlMbJqo9VVTvxxRffYebbH5qOH2SiWvjMG1UyZEZY\/pAp6+Pqij6ubkZXh\/x8oDJl2RcCJeutbUaR2aYlRj98F5KSGuHJp17EDz8uV7shDrrpamRkpKNo2UrcO3xsyMfOBkiABGoI0OHlTCABEvBKQEIZykqLIH+CMmQhnyVKhuylN2o2mYji1V0NVHXFt6je9B2cJFMmY8vJ7WF6Lox66A4cd+xR+PnnX9SHp4QbxcfHqw\/Ol199S4U18CABEggPATq84eHMVkgg6ghs3VyKrVtKgTZtAW4yEVL7uRPVmnZWDq9TDtmMIj+lNYa2zY\/4kAq3FWNceSGmjyhC985Vlvvjj0xZ1xOPxrDbb0Czpmnu9rZs2YZXpr6NBQu\/sdwHFiABEvCfAB1e\/9mxJAk4lgBlyMJrWtfESUhd9EPUJqr5okWZMkDCi84\/Lx+tW7bAgs+\/wRdfLq53Y5jwzjy2RgKxQ4AOb+zYmiMlAdMEmKhmGlXAF7pXdyWUoWnngOuzWwV2lCmT3dcKzqiwjEpb5W2S5kLLVjmWy7MACZBA5AjQ4Y0ce7ZMArYksGd3JcpLl9WEMsgmE\/Inj5ARiHYZMiMwmkzZ0Mx85Dfzve2uUT3BOj+urBCF24uxasYiS1WWb2qEe1\/MwYz3lqlymVldkJT8Z6iCpcp4MQmQQNgJ0OENO3I2SAL2JSChDBs3rMKe3VXAoGHA4GH27awDeuYUGTIjU1SXz4OEN7yXd7PRpWE5f3HRRLXCKyu9Zo85n7tw\/0tHompbKdav\/82yTJnZdngdCZBAaAjQ4Q0NV9ZKAlFJgDJk4TObhDK0HT0GCbsbIr59QfgajlBLh5aNR7TKlMnq7jWP5mHbziQ0S2uAb7\/9Fnv37oWrVQ5S01wRIspmSYAErBCgw2uFFq8lAQcTqCVDJqEMXU928GgjPzSnyZAZEbWjTFl2Thmmj6gJUajvGDc7Cy+83w4t0hugQYM4bNiwAcXFxaqIFZkyo3Z4ngRIIHQE6PCGji1rJgG\/CcguTQ8+MBRLlv6Ej+Z+5nc9Vgq6ZcjE0RWHl0fICDhVhswImMiU5TVsjDHZFxldGvLzRbvWYcSa9w1lymR198xhJ6JJ43ikNm7g7tePP\/6I7du3gwlsITcVGyCBoBCgwxsUjKyEBIJL4Jyzz8BNN16FzZu2YuSoZ1BRsSW4DXjU5pYhkwQ12WSCq7sh5e1UGTIjaFoCmzi8eSltjC4P+XlxeLclr8GC55b6bKvvmC5YsrIpWrVIqHWNOLvi9MoRigS29u3b4qoreyOvSy5SUxvXbFixdy9WrlyDt9\/5SO3cxoMESMA8ATq85lnxShIIG4G0tCZ4aMQwdOyYjfkLvsbTz06p1bZoew65pR9ycztg\/\/4D6uU34833UFJS5lcfKUPmFza\/CjldhswIisiUufZVYXJuX6NLQ35eW+X1JVP27YpU9B2Th4z0BDRqGFenPxLWIOENScmpyMzKC0p\/5d6\/ZfC16H7S8UhMrO1kaw3s27cfH3z4KV6d9k5Q2mQlJBALBOjwxoKVOcaoJNDjlBMx5NZ+SExMxItT3sCn875Q45Bwh8ceuRt5ebUlnnbt2q1egFa3K6UMWXinh9NlyIxoRotMmSZD9sMvTZXD6+tYuHChOhWMVd4jjjgcd9x+A7LbZ9VqThzc\/fv3I75BPJIOO0ydk9Xe116foxxfHiRAAsYE6PAaM+IVJBAxAoMHXoPzzs3HunUb3KENp53aDUNv64\/Vv6zFhBem4ZJL\/ob8M3ugUaOGqKzcgWeem4IlS\/9nqs+UITOFKWgXqUS1iZMQ174AcSmZQas32iqKBpkyTYZMVBm8re5qzLUEtoTERmjf4US\/TaH9qiO\/2miHbEP83gf\/UR+xe\/bsVR+7V\/XpjYsvOls5vhs2VGDUI\/\/Eb6Xr\/G6XBUkgVgjQ4Y0VS3OcUUlAXoIPj7wDR+a0x7\/+sxDPT5iG3hf0woD+V2Dr1u147IkJ+OWXtSq04Z67BqNlywy8M2supr0+29R4KUNmClNQLtJkyBL3ZyAus1dQ6ozmSkSmzC6bURRuK8a48kJ3ApunDJkRZy2BLRCZMgljOO\/cnoiLi8OBAwew6OvvMe75V5Wj63ncdcdN6HnmKTh0qBqz5nyM10ze70bj4HkScDIBOrxOti7HFnUEup90HDrlHoH\/\/rAMP\/3vZ9X\/M04\/CUNu7a\/+e\/yEqShftxEjHxiKjIx0VFXtwMefzMesOZ\/g9iEDcHL34zHjzfeV02t0uBPV5ELKkBnhCvh8+qzZSH\/\/U8RnXwIkpgZcXzRXYLewBmEpCWwp7VYomTJPGTIj1voENn9kylwtmmP0qLuQ1ba1cnZFmWXKy76VUrRfeVJSklG0bCXuHT7WqIs8TwIxT4AOb8xPAQKwAwH5qfK+e27GKSefoFZ4qqursXnzNkx97R0sWPgNbru1H\/529l+wpqQUI0Y+BYnvHdDvcsgLT3+sX1+B0WPM\/cS5ccNq7KisqFFkoAxZSKeBO1GtxUmIc3UPaVvRULmdEtc0XvoENtlC2FOGzIhrIDJlxx17FIbfeysaN07Gb7+tw30PPK7Ck3wdXU88Gvf8fbC6\/1etXoNhd4426h7Pk0DME6DDG\/NTgADsQODSS85F32suRmXlThw8eAAuV4ZbhkgSU7759nuMfuhOiDqDFtogskU3Xt9HyRYlJDTAxorNmDjpdVPxu5QhC6\/VYz1RTU9bthiWGF67SJPp+yarvOL4yuYSnjJkRjNGdl6THdjksJrApnd4F329FI+Ofb7e5rQPYPk45gqvkWV4ngRqCNDh5UwgARsQeGD4bejW9Vi8MvVtlXXd66zTcF3fAjRv3gylZesx8qGnceyxR2HQTVer1V8Jbfj8i+\/87jllyPxGZ7lg0vLlyBw9JuYT1RS4\/VU4tOZd5Ke0xtC2+ZZZhrqAFsvrS4bMqH1\/ZcqOOboTht97C1JTm2DZ8pUY\/sCTOHjwoNfmMtu0VJvSZGW1wcGDhxjDa2QUnieBPwjQ4eVUIAEbEJBwhtNPOwkbNm7CpBdnYPGSH9G5U456CYoW59gnXlAxvVqyyqrVJXh49LP1\/uzpa1hMVAufwSWUQVQZktZWIb59QfgatmlLsr1wi+0r1Oquq2ETW\/WyYt8Olbi2av\/6emXIjDrtj0yZhDQ99eQD6HhkNnbv3mP4QSvyZfffe6uSKgvHxjRGY+Z5EogGAnR4o8FK7KPjCUjsrmjupqWlqpdY8co12LJlK0466ThsWL8Jw0c8iR07dqJdVhuMHHG7Cnn4+JNCTJo8wxIbCWUoKy2C\/Kl2VOt9maXyvNgaASVD9tIbSpUhlmXI3Ku7K6ehj6sr+ri6WQMZhqtldXfChvkwkiEz6oq\/MmVaWFPDhg0hmtrzPvsS3y3+Ec3Tm2L9xk1YvnxVraYlvElCmfzdbMZoHDxPAk4jQIfXaRbleKKWgCSiDbzxarRoke4eg0gSvfzqW7U2k7jg\/LPQv99l2L9vP8ZPmAaJ+TN7cHXXLKnAr6MMWW2GdkxU03ooq7sDV05HclK8cngDPbQEtvTmWUjPqL2JhK+6PRNX9dfJx+2Eia8H2i2WJ4GYJkCHN6bNz8HbjUBS0mH42zl\/QdcTj1EOrYjOy7bBnoeEOpzaoyushDZQhiy81nZNnITURT9QhgyAJkNmx0Q1mRXjygqxcMdKy4lqvmaUXqZMNqOQTSnMHKK7ffddg3DsMZ1V0qp2MDHNDD1eQwL1E6DDyxlCAlFIQIvh271nj5Ipq0\/CSBueW4ZMwhgknIFHyAhQhkyHVhLVyuchD9Uqdtduh7a6Kyu7ssIbrCMQmTLR3j4r\/1S0atUCsq3wypVr8NIrM71uQhGs\/rIeEnA6ATq8Trcwx+dYAqLksH\/\/ASz8\/BvDMdaSIRPN3TZtDcvwAv8JUIbsT3YiQ9ai4lulypCX0sZ\/qCEqKVJkK\/auD9rqrtbNQGTKvA1V4vebNk3F2t\/KTX3ghggXqyWBqCVAhzdqTceOk4B5ApQhM88q0CspQ+axuutgGTKjubJ27VqUlJQgKTkVmVl5Rpf7PJ\/fswduHtQXyclJapX3telzlHwhDxIgAfME6PCaZ8UrSSAqCTBRLXxmowxZbdZ2lyGT1d3KuJ0ByZAZzS7ZjEJWe12tcpCa5jK63Ot5SWgT7d3mzZsis00r7N37O555boqpTWb8apCFSMCBBOjwOtCoHBIJaAQoQxbeuUAZMo\/V3RiQITOaYZpMmVyXk9vD6HLD8wNvvAoXnN8LCxZ+jWeee8nn9bKRzVFHHYnpM971uYmFYWO8gAQcRIAOr4OMyaGQgCeBrZtLsXVLaU3M7twvCSiEBNyJak07K93dWD9iSYbMyNZmZcquvuoiXHDeWUpfd+\/vv+O339Zh\/vxFWPTN9+6EtcEDr8F55+bj2+\/+63ULYtly\/OZB16JTbgfsP3AAU6fNwkdzPzPqIs+TgOMJ0OF1vIk5wFglQBmy8FreLUPWsV94G7Zha7EmQ2ZkArMyZZ1yj8D9992qthTXHwcOHFCJapKkmpFRc27W7I\/x+ox33ZeJpOGAfperbckbNWro\/vtfflmLe+9\/nAoPRkbieccToMPreBNzgLFKgIlq4bO8e3VXdlRr2jl8DduxJZvLkBXtWgeJ3Q22DJmRKYqLiyHhDUYJbFrIQkXFZrXbWrdux+LwwzORdNhhqgnZifHLrxbj2X++okIVJL73r2edBlkd1jvKhw4dwoqfV+OFSa9zNzYj4\/B8TBCgwxsTZuYgY43Ant2VKC9dVhPKQBmykJufMmR\/Io5VGTIzk2zhwoXqssysLkhKTvNaxOVqjtEP3YnWrV1q45lXp76jrvMmSyZxutf3vwJZWa0RFxfnrm\/Llm1KyUEcZh4kQAI1BOjwciaQgMMISCjDxg2rsGd3FTBoGDB4mMNGaK\/hqES1iZMQ174AcSmZ9upcuHsjq7srpyG\/aa7S3bXbUbitGOPKC5UqQ6OGfzqI4eqnWZmy3hf0woD+V2DHjp147PEJ+Ln4l1pdFKf4phuuQreuxyAxMdF9TkIe3v\/wP5j51ocMYQiXUdlO1BCgwxs1pmJHScAcAcqQmeMUjKsklKHt6DFI3J\/BRDXZQrh8HlrsKsPk3L7BwBvUOmRHNQll2JmwS4UzROowI1MmYQqPPXI3jsg5HK+9\/qfmrsTp9rvuMvT8yylo3DjZPQQJX5AVXvnn62++x9gnXqAyQ6QMzHZtS4AOr21Nw46RgHUCTFSzziyQEpoMWXz2JUBiaiBVRX\/ZP1Z3h2bmI79Zru3GM7NiMd7ZshQt0hugQYPwr+5qQMzKlInawoEDB1FWtl4VbdYsDY88fBeys7PcbKurq1Fauh4z3nwXlxach45HZquV3RenvIFP531RxwZSR1XVTjrDtpud7FA4CNDhDQdltkECYSKwccNq7KisALqeXBO7yyNkBChDVhttNMiQNWkcj9TGkVvd1YhpMmVN0lxo2SrH9BzVEtoaNIiHZ5zuX3udjkE3XQ1ZBV65ag0eHv2sewticZ5vGXwtco5oj9dnzMG77\/3bdJu8kAScQoAOr1MsyXHEPAH36q4kqo16qsbp5REyApQh+xOt3WXIJJRhxd71aNUiIWTzwUrFepmy+hLYPOuU2F2RLVu5cg1enfZOrThdCYMYfu8tOOXkEyAyZiJbNmvOJ3WkykpL12HkqGdQUbHFSpd5LQlEPQE6vFFvQg6ABGoIUIYsfDMhaflyZI4eo+J2KUNWhUPl85CHaozJvih8RjDZkiZDFqlENV\/dNCtTZnKY6rKj83Jx3z23oGnTVFTt2IlDBw+p\/9YOifVdvmI1xk+Y6g6VsFI\/ryWBaCZAhzearce+k8AfBGrJkHFHtZDOCwllEFWGpLVViG9fENK2oqFyO8uQSaKaqDKs2r9eKTPY7TAjU2a1z3cOuxFn5Z9apxilyqyS5PVOI0CH12kW5XhijkAtGTIJZeh9WcwxCOeAKUOmox0FMmQTNsxXqgyRkCEzmpdaAltCYiO073Ci0eX1nvclVVZVtQMfzv0Mb739EZPVAiLMwtFOgA5vtFuQ\/Y95ApQhC98UoAxZbdZ2lyEbuHI6kpPiIypDZjQ7tQS29OZZSM\/4U4HBqJx2XttSuOeZpyA5OcldTHZkW7zkJ0x5+U3G65qFyescTYAOr6PNy8E5nYCdZMheG3Enrp07xyvybalpOOeF17C4y7FezzfZtQsfDLsBZy75Bhc\/OwXvn\/lXW5oufdZspL\/\/KShDJnvc1mwyYVcZsnFlhVi4Y6VtEtV8TWh9Apus8spqr9mj11mn4bq+BXW2FF79y1q88eb7WLzkR7NV8ToScDwBOryONzEH6GQCdpIhq8\/h1Wxw\/5B7MPb6W+qYRF\/Wrg6vW4asxUmIc3V38rQyNbZokCGTUAZZ4bX74a9M2bXXXILLLj0PCQk18cmM07W7pdm\/SBKgwxtJ+mybBAIgYDcZMs1pff38Alw35hn3yPSrt54rvW02bcQX11+ODmW\/ua+3q8ObOfoRJK0qR3zHfgFYzRlFJVFNwhlElSEvpY3tBmU3GTIjQHv37oXswCaHFZmytLQmGDP678hs0wrzPvuyjlSZUbs8TwKxRIAObyxZm2N1FAG7yZD5cngFut6x1VZ5uy37Ef++5To0q6rEmswsNN1Rpf7bjg6vW4asfQHiUjIdNY8sD0ZCGda8i\/yU1hjaNt9y8VAXKNxWrJQZ7CZDZjTutWvXoqSkBEnJqcjMyjO63H3ec0c20wV5IQnEGAE6vDFmcA7XGQTsmKhWn8Mr1LXzC7qejN7PvYxOJavx1r234connldG0Zxfuzm8lCGrfc9oMmSyuutq2MRWN5TIkMnqbmXcTlvKkBnBklVeWe21ssprVCfPkwAJ1BCgw8uZQAJRRkBCGcpKiyB\/qh3VbCJDZuTwDn\/lBTw2\/kloDu+OlBQ3ef1qr90cXiVD9tIbNZtMcHVXJarlN8217equnWXIjB41\/siUXXLxOZB\/mqc3w759+yHqDAcPHsTmLduwf98B7Nm7F0u\/\/x\/mvPsvo+Z5ngQcTYAOr6PNy8E5kYAdV3f1K7ieMbyaDaLR4XUnqjXtrBzeWD8oQxb6GWBVpuzyS8\/D1VddhIOHDqG0dD2qq6uRkdFMSZQlHXaY6vDu3XvU7mqff\/Fd6AfAFkjApgTo8NrUMOwWCXgjYCcZMs\/+Ga3weoY0RMMKr2viJKQu+oGJamJsypCF5aFkVaasSZPGGDliKDoemY1Zsz\/GrDmfYEC\/yyGSZY0aNcTvv+\/DZ4VfYvob76GyckdYxsBGSMCOBOjw2tEq7BMJ+CDgliGTMAYJZ7DRUZ\/Dq1dq8CZNZseQBvfqroQyNO1sI9KR6YqdZciKdq1TsbvRIkNmZEGrMmVnnH4ShtzaHwcOHFArvc2apuHQoUNY8fNqvDDpdZSUlBk1yfMk4HgCdHgdb2IO0CkE9uyuRHnpMqBNW2DKzJo\/bXTU5\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\/cmkzZ0Mx85DfL9b8im5aUzSgiJVN2\/88\/4+yNG\/Gfli3xWKdObkLX\/PYbblqzBusOOwxDjz8euxs0wGNFRThu+3ZMyc7GjHbt\/KJZXFwM2YUtKTkVmVl5ftXBQiTgBAJ0eJ1gRY7BtgQoQxZe01CGLHi8Zfc1CW94L+\/m4FVqk5o0mbImjeOR2rhBWHv1f+2de3RXV5XHd56YB0kI4Ufgl5RQGbIC0dHpU3xUY5d11VoKrYozddHqLKBWKa3Wmap1WsDitNYHPhJra+mSVaMFV5mxrjp10olT6dDHLHACTKC2CSGQ\/KA8EgKZpJZZ+8bz8+bm\/h73cc7v3nO\/9x8suffsfT77xPXt6T7fk0rwWpOoGRtLtjdwu8Pva2pc59nZ2Wl8G69fTCWlla7HwYcgEGYCELxhrh5yDzQB2JCpLQ9syPzn\/ebe71FLVaOWB9jaEy9Se+Il4zIKlTZl2QhesdvLFbXuBLupMu\/w8k5vYdE04wY2PCAQRQIQvFGsOuashABsyJRgNoIIG7Ki8RqjnQGPPwR0tylb1b2VzhSOGBdSqHqcCl7R4nC8uNhTirAp84QPH2tAAIJXgyJiCsEjkDyoxqmxKwMOqkktUvW27VS94xmCDZn\/mNmmrLm43Lh2WLcnFzZl2QhewVm8u7uqir7c3Gz09bp9zAfYYFPmliK+CzMBCN4wVw+5B5bA4MArNHw6MSF0YUMmtU5JG7JZl1Je7DKpsaI4uDjAxoK3uWyudgj4ANvB8aNUU12oZG5OBK9wePDi1GCeFGzKlJQYQQJKAII3oIVBWuElABsytbXDQTX5vNmmLDY2RA813ig\/mOIIXSNHiEUvtzWUluRLj24neEv\/9KekI4O5Z9dvwTs6OmrcwMYPDrBJLzUCBIwABG\/ACoJ0wk8ANmTqapi0IWtYTnllcXWBoxZpfIi4tUFXm7LNhzuo41Q3xWuLpFc2ky2Z2M09VFqaFMF+tDSIicGmTHqJESCgBCB4A1oYpBVOApNsyJ56LpyTCEnW3Mowu7WNSnqHKL9heUiyDm+aOtuUcVWu62olFTZlqQSv2YbMukq82pJZx4NNWXh\/D5G5ewIQvO7Z4UsQmESAWxkO93UR\/2ncqMYXTeCRRsCwIXv48YlLJkK8u3v\/Sz+kpYf+05bTUFEZffo9d9H\/zHjrpJ\/HRk\/S4533UP1IIvn331q8gn7UKPdgmRebssLRkzT\/PzZSsSln86RGZjXRoSV30JuFb0n+dfzFNqo69Pu0a2isLEavvf+r9MZbZnhaa6psytL18JpbG3gyfvXuWsHApszTUsHHISUAwRvSwiHt4BGADZm6miQPqlU1hd6GLJ3gFUTNYvZtJ\/9IP3luE1WMj0wBLlv08kUUvNPr5gBbJsHLk\/lTcRn1vudLdG7GhcbcVApejsc2Zafzzig7wKbuN2ZqJHGArXpmPVXX1OcyFcQGASUEIHiVYEYQ3QnAhkxthWOtbVSxczflL1ypNrCEaELw7rjgvfSliz+bjFD2xjlqe\/6bdOmxfWTe6V3dvYPu2NtOfWUx+tsr7qHEW2aQ3d9JSNUYkg+wNdN5xzZlZsF76F230\/Dcv0mmWHLyVZr33P1UMDZCdju9\/GK67\/2aay5syvzK3ek4ZpsyvoyCL6XAAwI6E4Dg1bm6mJsyArAhU4bauGSi4fO3TbQyVDWpCywpUirBy+HMrQu8e7v1rR9KimCzQP7g0Zfoh88\/OEkYS0qX3NqUZRKs04\/8N13w\/Len7PKKeWT63q\/5smPD\/tGjxg1suj+wKdO9wpifmQAEL9YDCHgkMMmGjD1359Z5HBGfpyOgmw1ZOsHLHMTPX5i1iNa864s0UlgyBY\/KHV4O7samLJNgNf98sPnjdLzxo5Pmmel7v35rVNuU+ZW3m3FgU+aGGr4JKwEI3rBWDnkHhgBsyNSVQkcbskyCV4jZVILX3NMru4c3Wek\/25StiF1MK2KXZLUAMgnW\/DdG6YKd36KyY\/spl4KXJ6PSpiwreBJf6u3tpZ6eHiopraB4fbPESBgaBHJLAII3t\/wRPeQEcFBNXQF1tSHzInjNYjfdDrCMKp1P7KLzx16ghxbeSLHi6RlDhEnw8mTYpowvouALKXR\/+DIK3u2N1S6gisqY7tPF\/CJKAII3ooXHtL0TgA2Zd4ZORtDFhsw650yCN1VLg+jb5fHMB9icMPX6Ll9G0VI2h9bWtWQcKpPgDUpLg5hIlA6wCZsynvuCxiUZa4kXQCCMBCB4w1g15BwIAieO99GJ1\/smenZxyYTUmuhkQ+ZE8JqdGsztCmaxq3pn15y\/E5uyTIJXODXw+GZrMhEv0\/cyFiAfYDs4fhQ2ZTLgYkwQUEwAglcxcITTgwBsyNTWUScbMieCV+zumm3JctnGYFf1bG3K0glW889yaUtmnZ84wFZTXUjTivPULnrF0WBTphg4wiknAMGrHDkC6kAAB9XUVVE3G7JUgjcdUfPurpub2WRWS9iUrY23UMuMxpSh3Fw8YR4sFzu8HD9KNmXd3d3E7Q3TK2M0u3aBzGWDsUFAOQEIXuXIETDsBM6dPU39fXsnWhlgQya9nLrZkDkRvNbeXLsrhc3jpbqKWHaR+PY1bm94svkW14L31AXvpv5L1mT1vfXiCpnzS4wN06oDW2l6eT5VlOt\/gK2zs9PAGa9fTCWllTLRYmwQUEoAglcpbgQLOwFuZRgcOEjnzg4RrV5HtGZd2KcU6PyNg2qtbZTXsJzyyuKBzjXqyb2593vkxKYsTLzaEy9Se+Il4zKKggK9WxtgUxamlYlcnRCA4HVCC+9GngBsyNQtAW5lqFu\/kYrGa4xb1fAEm4BTm7Jgz2Zqdqu6t9KZwhHYlIWtcMgXBP5MAIIXSwEEsiQwyYaMWxkuvjzLL\/GaGwLV27ZT9Y5nKH\/+MqKiCjdD4BvFBNimrLm4nDbOX6o4svxwsCmTzxgRQEAmAQhemXQxtlYEkjZkLHRZ8OKRRkBnGzJp0AIwsDjAxoK3uWxuADLyN4Uo2pThAJu\/awij5Y4ABG\/u2CNyiAgkbcj4oNq938TuruTa6WxDJhldzodnm7LY2BA91HhjznPxO4Go2pThAJvfKwnj5YIABG8uqCNm6AjAhkxdyUr27aP4+o1G325eVZO6wIjkC4Fsbcp8CZaDQaJoU1ZSWkHx+uYc0EZIEPCPAASvfywxkqYEYEOmrrDcysCuDCW9Q5TfsFxdYETylUA2NmW+BlQ4GGzKFMJGKBDwkQAEr48wMZR+BCbZkHErw7U36DfJAM3IsCF7+PGJ3V3YkAWoMs5TYZuylqpGWlvX4vzjgH8RJZsyvoiCL6QoLJpGDRdeFPDKID0QSE0AgherAwTSEIANmbrlARsydaxVROKLKHinV9cDbFGyKduzZw\/x1cOx2gVUURlTsXwQAwR8JwDB6ztSDKgLgeRBNZ4QbMiklxU2ZNIRKw\/AB9ia6TxsypST9zcgi10WvfzwLi\/v9uIBgbARgOANW8WQrzICgwOv0PDpxIQjA2zIpHJP2pDNupTyYpdJjYXB1RGATZk61rIjiV1e2JTJJo3xZRGA4JVFFuOGmgBsyNSWL75+A5Uc7Kf8hSvVBkY06QSiYFM2o7KASkvypbPMZYDR0VHatWuXkQJsynJZCcR2SwCC1y05fKc1AdiQqStv0oasYTkOqqnDri7S+BDxDWwrYhfTitgl6uIqirT5cAd1nOqmeG2Rooi5C8OH1\/gQG2zKclcDRHZPAILXPTt8qSkBHFRTV1jYkKljnctI5xO76PyxF+ihhTdSrHh6LlOREvu6rlZjh5d3enV\/eJeXd3uxy6t7pfWbHwSvfjXFjDwQ4FaGw31dxH8aN6rBhswDzcyfwoYsMyNd3uBd3payOVrblNVUF9K04jxdSmY7D9iUaV1erScHwat1eTE5pwSwu+uUmPv3kwfVqpoM3108ehOIgk3Z6bwzxKJX90ccYKueWU\/VNfW6Txfz04QABK8mhcQ0vBOADZl3hk5GiLW2UcXO3Tio5gRayN\/V2aasa+QI8bXDUdjlhU1ZyH8RI5o+BG9EC49pTyWQtCHjNgZuZ8AjjUByd5dvVKtqkhYHAweLgLApWxtvoZYZjcFKzodsWPDuHz1KtbOis8sLmzIfFg6GUEIAglcJZgQJOoFzZ09Tf99eorl1E567\/CceaQRgQyYNbeAH5l1eGumnJ5tvCXyuThNMjA3TqgNbjcNrsClzSg\/vg4BcAhC8cvli9JAQgA2ZukIZB9Va2ygPNmTqoAcpEmzKglQNT7n09vZST08PbMo8UcTHqghA8KoijTiBJYCDaupKw60Mdes3UuHZYspvWK4ucI4jLevtpM\/v357jLAIUfnzISCZWpJ9FGc8rMT5MBQWp3Rqerq2lLfPmBagg7lMRNmWx2gVUURlzPxC+BAHJBCB4JQPG8MEmABsytfWJqg3Z5\/ZvMwTv8CXvVQsc0QJFoLj\/EE070ktbGhq0EbzCpoxBL2hcEijeSAYEzAQgeLEeIk3gxPE+OvF6H9HFl0\/07uKRRiDKNmRC8P7vT56G6JW2woI\/MIvdt1+1SCvBy9RhUxb8tYcMiSB4sQoiSwA2ZGpLH2UbMghetWstqNF0FbywKQvqikNe2OHFGgABIsJBNXXLIOo2ZBC86tZakCPpKniZeXd3N3F7Q0lpBcXrm4NcBuQWUQLY4Y1o4aM+bdiQqV0BUbchg+BVu96CGk1nwcvMOzs7DfTx+sVUUloZ1DIgr4gSgOCNaOGjPG1uZRgcOEjnzg4RrV5HtGZdlHFInztsyIjcCN7OZ39Fd679RMr6XP3RT9I99z3sW\/3OjpyhL6z9GM2eHU+Oyzk8+8yTvsbxLeEQDqS74IVNWQgXZYRShuCNULEx1QkCsCFTtxKEDVnReA3lxa9UFzhgkbwI3gc2\/5yu+MA10mdkFbx2Alh6EpoH0F3wcvlgU6b5Ig7x9CB4Q1w8pO6cAA6qOWfm5YvqbdupesczlD9\/GVFRhZehQv0tBG+oy+db8lEQvOYDbLAp823pYCAfCEDw+gARQ4SHwODAKzR8OgEbMgUlSx5Um3Up5cUuUxAxuCFkC95jiaO0+qYP0eG+V5MQzC0P4udLr7+JVn7mC8l3HnvkQfrpo9+mzW07qGF+Y7Kl4dZ1GyaNV1E5w3hnUfNFwYUcgsyiIHi5DMKmbHpljGbXLghBZZBiFAhA8EahypijQSC5uzu3jujeb06IXjzSCET9oJoZrEzBaydm93W9TGvXLKVP3Xy7IXCdCl7uDUZLg\/+\/GlERvOZdXhxg838dYUR3BCB43XHDVyEkABsydUUr2beP4us3Ul7Dcsori6sLHNBIXgSv3ZTMu7e8S7tj+xb60ZZ\/o1mxOcnX7\/ny39PgYD89uPkJGhkZNnZss93hheCVs5CiIniZHmzK5KwhjOqeAASve3b4MkQEJtmQPfVciDIPX6rcyjC7tY1Keocov2F5+CYgIWMvgtfJoTWxszt0+qQxi4sufR8Er4R6uh1SCN5H6ubRT9\/a4HaY0HwHm7LQlCoSiULwRqLM0Z7kJBsybmW49oZoA5E8e8OG7OHHDVcG7O5OwJYpeK39u2L3Fzu8khe6i+GF4N08s56eaJpPBQV5LkYJzyd8EQXv9BYWTaOGC9H\/HZ7K6ZkpBK+edcWsTARgQ6ZuOSQPqlU1RdqGzEpcpuBlYfuH3bvQ0qBumbuOZBa8j9TPoxmVBa7HCsuH4gBb9cx6qq6pD0vayFNDAhC8GhYVU\/oLAdiQqV0NsdY2qti5O\/I2ZKoErzhYxvG4V7e0rNwILXZ9Z8+pS9vSwGL5ud89PcWlAT28cn5vhOBtn7OI7q6ooprqQppWrPcur\/kAG+\/y8m4vHhDIBQEI3lxQR0xlBGBDpgw1wYYsNWvZO7xCtArbMBayv\/7XnyV7eFkIW3eCxU1uwnLMbEsmbnAzt0UIMa1uRekXSQjeRNMyWl1SQAfHjxqiV\/cHNmW6Vzgc84PgDUedkKULArAhcwHNwydRsiEbjx2jofd30uuf2G4QK0rMoopn30czf2HfHy5T8HJ8IXBF+W5dt974n8Jjl4Ww2A1++YXfGT\/jA23XLltJD37ji7Y7vPyO+XpjJ4fnPCwjrT81C95n511OX31th9HWUFqSr\/W8R0dHjRvY+IFNmdalDvTkIHgDXR4k54UAbMi80HP2bZRsyFjsHr53A\/Gf1oeF7\/xbNk\/5ezeC11kF8HYYCJgF77FFy2nz4Q7qONVN8dqiMKTvKcfe3l7q6emhktIKitc3exoLH4OAGwIQvG6o4ZvAE8BBNXUlipoN2esf35bc2aXfXEXUvoJoRTvRVb8xoM\/8+fVTdnoheNWtxyBHsgpezvW6rlZjhzcKB9h4l5d3e7HLG+RVqm9uELz61jayM+NWhsN9XcbNasaNarAhk7oWomZD9lrr2ondXRa7H376L2yf\/nBS9C68\/meTmEPwSl2CoRncTvB2nOymzf0dkTjABpuy0CxVLROF4NWyrNGeFHZ31dU\/ijZkB7Z\/cgLwzY8SbbnpL7Bv2kL06M3GP3NbA7c3iAeCV92aDHIkO8HL+XIvb9QOsMGmLMgrVc\/cIHj1rGtkZwUbMrWlT9qQLVypNnAOo2Xa4bXr44XgzWHBAhQ6leDtGjliiF7YlAWoWEhFOwIQvNqVNNoTStqQcRsDtzPgkUYgubvLN6pVNUmLE7SBM\/XwVjx7BdV+f82ktCF4g1bF3OSTSvCKXd79o0epdhZsynJTHUTVnQAEr+4VjtD8zp09Tf19e4nm1hH9uH3iTzzSCETJhswKsW\/9Bjq3eN8UtnBpkLbctBg4neBNjA3TqgNbaXp5PlWU630DG2zKtFjOoZsEBG\/oSoaE7QhwK8PgwEE6d3Zo4pAadnelLhTjoFprG+U1LKe8srjUWEEd3LzTK8OHV8xb3Jp2252b6IoPXGP89WOPPEg\/+M7XkmiceuTu63qZvnLnSvr6A4+RuKzCCWf+fu2apTR0+qTxGXv6mm9647+z+v7W1V845frjVDHNvsLiYgyneQpuh\/tenRQmXR4clx9x8UY6JmaPYn7v6o9+ctJ3XKPX\/rh\/0t+lE7w8hrAp413eggK9b2CDTZmT3zi86wcBCF4\/KGKMnBPAQTV1JeBWhrr1G6lovIby4leqCxziSF5aGqwizHwdMItAIT4\/dfPttPIzX8hISQjBoaGTxoUTToWkNZ4QtoNHDycFrfVqY76ljQWg+SKMdGJ3cLA\/KaCz\/c46nsjz7g1tyX9RSAdH\/EuEVbjafSPErvgXDTHft7\/jsqTAFVwuX3Jlsi6ZBC\/HiqJNWax2AVVUxjKuXbwAAl4IQPB6oYdvA0EANmRqyyBsyPLnLyMqqlAbPKTR3ApeFlbffeCupJBMJW5ZrO3YviXjDqp5V9LtzqnddcNWcWknUoUAnD07nnIH1SokudzZfJdKlJrZpVo61p3oTIJXvM\/jmXe17eZsrV82gjeKNmXMckHjkpD+diPtsBCA4A1LpZBnSgInjvfRidf7iC6+fKJ3F480AlG0IfMDphvBayf0WEBtuHvNlJ3ZbHYzhZjka4cbLmy0HcftXK3x7UQxj51JmKf6eabv7PLmb\/5r52+ntFqY3zXvTn\/7h7+kb2xYS+kEuVmAZyN4rbu82QheHjeKNmXTK2M0u3aB2yWI70AgIwEI3oyI8EKQCSRtyPiAGvftsujFI41AFG3I\/IDpRvDaidhMgjfbtoZU47iZq137QjrBm66twe131ryF0Bw40kfDw6fS9hqLb53sJKdqaZg9p26KwDaL9bo3xujtVy2iRNMy4quFUz2wKXOzEvENCKQnAMGLFRJqAv19XTiopqiCJfv2UXz9RqNvN0o2ZH7gdSN47URpqp1c8+5tNn28fghecyuAtT0i1Y6stf\/YyjaV4HWar50It+s1ttvtzbTDK76xHorjnXM79ubc31ldk5XgFbu8UbEp6+7uJr6FraS0guL1zX78ymEMEJhCAIIXiyK0BGBDpq503MrArgwlvUOU35B6Z0pdRuGK5EbwZisazY4JqUSXlZZTAZmJtlVwpzq0xs4S6XqH\/RK8qfJNd8DPyQ6vVbinE9Pmf0n5UOPbsha8UbIp43p1dnYaZYvXL6aS0spMSw4\/BwHHBCB4HSPDB0EgMMmGbPU6ojXrgpCWtjnAhsxbad0IXhZVf9i9y\/Ygmtm2iy3B\/vHuzXT7Z5fT0utvysqpwW\/By3Ss+drtgGbqHfarpSFVtezcFMS72QreVKJZjG2tgVvBy3m1J16k9sRLxmUUutuU8Q4v7\/QWFk2jhgsv8vYLh69BwIYABC+WRSgJwIZMXdlgQ+adtRvB6+SgllNfXRWC145apoNkfh5as4vvp+C12p2lEsxeBC\/PYVX3VjpTOEIzKvW+jILnumvXLuJLKWBT5v3\/czDCVAIQvFgVoSOQPKjGmbMrAw6qSa1h9bbtVL3jGYINmXvMbgSvkx5eJ+KYZ+FW8KYSdVarrifafzTFJi2bHVS7vLL5zlqZVLuw6dwsso3jdIfXbQ+vmFOUbMpOnTpFe\/bsMaYOmzL3\/3+DL+0JQPBiZYSOwODAKzR8OgEbMgWVS9qQzbqU8mKXKYioZwg3gjeVOLP+Z38779pMFN0KXiGW71z7CTLf7iZaLKwXMZj\/8366Fg2Rr10vrNuLJ6x9tnZ9xWZO2Qpe\/sZJD68blwZr\/WBTlmlF4+cgkJkABG9mRngjQARgQ6a2GPH1G6jkYD\/lL1ypNrBm0dwIXiGsjD\/ve3gSkUxX72YSiakEb6bvRBLWq4Xtruu19vDaXT+cSgRnml824plztV7BnO5SiVSCN1UbhHXsdNcri9vWsvXhtS5\/YVPGbQ2lJfma\/XZMng63NHBrAz84wKZ1qZVPDoJXOXIE9EIANmRe6Dn7NmlD1rCc8srizj7G25MIuBW8XnZi3ZbggfvuoI9c+3eOrxx2G8\/NdyxO7\/\/6Orp13QaaFZvjZggl37i5aS1VYpsPd1DHqW6K1xYpyT2XQWBTlkv6+saG4NW3ttrNbJIN2VPPaTe\/IE0INmT+VsOt4OUseDfT+NOyy+vfDjCFAAAKBUlEQVRvhhOj8W7m1+76NK3f9JNAC0neYX70ofvp3k2PUGlZuQwUnse03rLGA7rd4RXJXNfVStPL86miXP8DbLAp87wEMYCFAAQvlkQoCEyyIeMb1a69IRR5hzVJw4bs4ccnLpnA7q7nMnoRvOI\/qd925ya64gPXeM4l3QC8I9nzandW1mZSE8kwOLcTsMWZbB5e5sg5vvbH\/ZP+RcWr4IVNmZeK4NuoE4DgjfoKCMn8YUOmrlDJg2pVTYbgxeOdgBfB6z06RggKAa+Cl+fBNmWn885QTXVhUKYlLQ92bGDnhuqZ9VRdUy8tDgaOBgEI3mjUOdSzhA2Z2vLFWtuoYuduHFTzEbsQvMeX3kj\/N\/cCH0fGUGEjEG+9jxJNy+jYInc3FooDbCx4pxXnhW36jvI125TxZRR8KQUeEHBLAILXLTl8p4wAbMiUoabk7i63MlQ1qQuseSQheDWfJqaXJQEvgpdDsE3Z\/tGjxg1suj9il3d6ZYxm1y7QfbqYn0QCELwS4WJo7wRgQ+adoZMRYEPmhFb278bPHsv+ZbzpC4HziRfo\/Kn99FDjjb6M5+cg46U1noaDTZknfPg4ogQgeCNa+LBMGzZk6ioFGzJ1rBFJDYE3936PWqoaaW1di5qACqNEyaast7eXenp6qKS0guL1zQopI5ROBCB4daqmZnPBQTV1BeVWhrr1G6nwbDHlN7jrLVSXLSKBQHYEzid20fljL9DG+UupuWxudh+F6C22KeOLKPhCCt0fvoyCL6XAZRS6V1re\/CB45bHFyB4IcCvD4b4u4j8JNmQeSGb3KWzIsuOEt8JH4M0Dj1FzcbkhenV7Ok520+b+DsOxQfcDbAMDA8QXUvDBNT7AhgcEnBKA4HVKDO8rIXDieB+deL2PaG4dES6ZkMocNmRS8WLwHBM4P9JP53t+qe0uLx9gOzh+FDZlOV5nCB98AhC8wa9R5DKEDZnaksOGTC1vRFNP4M2eX1JsbCiQB9i80oBNmVeC+D4qBCB4o1LpEM0zaUPGt6lxOwMeaQRgQyYNLQYOEoHxIeLWhrXxFmqZ0RikzHzJBTZlvmDEIJoTgODVvMBhm965s6epv2\/vRCvDj9sn\/sQjjQBsyKShxcABI3C+\/7eGTdmTzbcELDPv6STGhmnVga00vTyfKsr1PsDGB9f4ABs\/OMDmfe1EaQQI3ihVO+Bz5VaGwYGDdO7sENHqdURr1gU843CnZxxUa22jvIbllFcWD\/dkkD0IZEFAZ5uy9sSL1J54ybiMoqBA7xvYYFOWxWLHK1MIQPBiUQSKwCvdOwOVD5IBARAAARAILoEFjUuCmxwyCxQBCN5AlQPJgAAIgAAIgAAIgAAI+E0AgtdvohgPBEAABEAABEAABEAgUAQgeANVDiQDAiAAAiAAAiAAAiDgNwEIXr+JYjwQAAEQAAEQAAEQAIFAEYDgDVQ5kAwIgAAIgAAIgAAIgIDfBCB4\/SaK8UAABEAABEAABEAABAJFAII3UOVAMiAAAiAAAiAAAiAAAn4TgOD1myjGAwEQAAEQAAEQAAEQCBQBCN5AlQPJgAAIgAAIgAAIgAAI+E0AgtdvohgPBEBAGwLv+OtFdNc\/3Erl5aXGnHY+\/zJ9fdP3J81PvMN\/uemff0C79+zzZf43r\/wY3XD91ZPGGhsbp0e3\/IL+5Ve\/dRTjK3d9jpa86yLjm23bf02PPvaE7Rx4ngMDCbp3w3fpUN8RRzHwMgiAAAgEmQAEb5Crg9xAAARyRuCC+rn0T3ffRrW1sUk5WAWjEKYHX3mN1t2x3nO+VpFtN6DTWBC8nsuCAUAABEJOAII35AVE+iAAAnIIXHvNlXTzTR8n3lXlnduPXN1i7JKaxaYQxdXVM1ztvFozTyWy7WZot9ucigQEr5w1glFBAATCQwCCNzy1QqYgAAIKCYidW\/Gf+D\/Y8m6jxcD8n\/z93t01C1Nr+4JVDJ85czbrFgoIXoULB6FAAAQCSQCCN5BlQVIgAAK5JpBJ8HJ+3PIgY3c3Va+uEL3DZ0YctU9A8OZ6NSE+CIBArglA8Oa6AogPAiAQSAKZWhr83t0V8YqLiya1TfgBB4LXD4oYAwRAIMwEIHjDXD3kDgIgII1ApkNr3\/nW1+ivFsy3dT1wk5RZ8Drpz80mllnwZnofLg2ZCOHnIAACYSQAwRvGqiFnEAABJQRS2ZIJcXrixEnfLLzMNmQQvErKiyAgAAIRIgDBG6FiY6ogAAL+ELDu7pp3UJ0cJjNnA8HrT20wCgiAAAjYEYDgxboAARAAAQcErLu7wr3BPISbtgBzS4Ob74UI5zysotuPHl4xhlMPYAdo8SoIgAAISCMAwSsNLQYGARDQkYB1d1f8M7chPPXrDuNmNj545vRGNHPPcCaXBuZqvg3NLHYFc7No9ip4ZR6o03GNYE4gAALBIwDBG7yaICMQAIGAErDu7nKa4jY2voHt3zt+P+mfrVf4ZppWOh9e\/tYsbIUo5iuAWWTzwxdk8GMV3V4Er\/XwHnZ4M1URPwcBEAgiAQjeIFYFOYEACASSgBCO4lCZWQz6IXjd3LQmRHjvocOGN68Yo7y8PHkxhRfByyJ73gV1tHffAXrnOxb7bpkWyEIjKRAAAe0IQPBqV1JMCARAQAYB4dggdlJ379lnhPGrpUHkbHWGsJtLuh5fO39gt4JXjMUC\/8iRQeOmOezwylhdGBMEQEA2AQhe2YQxPgiAgBYErLu7YlJmdwXxd24OnVkh2Y2bqrfXmos1vhvBW11dZbRGnDlzxugXFofzIHi1WM6YBAhEjgAEb+RKjgmDAAg4JZBqd1eM44ctmdOcUglkP8Q2j53usgq\/YnidM74HARAAgWwJQPBmSwrvgQAIgEBACYjdYD+FKARvQIuNtEAABFwRgOB1hQ0fgQAIgEAwCKTq+c3U\/uA0e7veYKdj4H0QAAEQyBUBCN5ckUdcEAABEPCBgF2vLw8LwesDXAwBAiCgDQEIXm1KiYmAAAiAAAiAAAiAAAjYEYDgxboAARAAARAAARAAARDQmgAEr9blxeRAAARAAARAAARAAAQgeLEGQAAEQAAEQAAEQAAEtCYAwat1eTE5EAABEAABEAABEAABCF6sARAAARAAARAAARAAAa0JQPBqXV5MDgRAAARAAARAAARAAIIXawAEQAAEQAAEQAAEQEBrAhC8WpcXkwMBEAABEAABEAABEIDgxRoAARAAARAAARAAARDQmgAEr9blxeRAAARAAARAAARAAAQgeLEGQAAEQAAEQAAEQAAEtCYAwat1eTE5EAABEAABEAABEAABCF6sARAAARAAARAAARAAAa0JQPBqXV5MDgRAAARAAARAAARAAIIXawAEQAAEQAAEQAAEQEBrAhC8WpcXkwMBEAABEAABEAABEIDgxRoAARAAARAAARAAARDQmsD\/A64PPtOo0+LgAAAAAElFTkSuQmCC","height":0,"width":0}}
%---
