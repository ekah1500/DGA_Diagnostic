clc; clear;
%[text]{"align":"center"} ## **`Taking Inputs`**
disp("===== DGA Calculator =====") %[output:6fd76dbe]
h2 = input('H2(ppm) - Hydrogen: ');
ch4 = input('CH4(ppm) - Methane: ');
c2h6 = input('C2H6(ppm) - Ethane: ');
c2h4 = input('C2H4(ppm) - Ethylene: ');
c2h2 = input('C2H2(ppm) - Acetylene: ');
co = input('CO(ppm) - Carbon Monoxide: ');
co2 = input('CO2(ppm) - Carbon Dioxide: ');

%[text]{"align":"center"} ## **`Calculating Total Dissolved Combustible Gas`**

tdcg = h2 + ch4 + c2h6 + c2h4 + c2h2 + co;

fprintf('\n---> TDCG Assessment <---\n'); %[output:74ffde31]
fprintf('Total Dissolved Combustible Gas (TDCG): %.2f ppm\n', tdcg); %[output:7775921e]

if tdcg < 720 %[output:group:7957ad6e]
    fprintf('Status: Condition 1 (Healthy/Normal). Ratios may be unreliable.\n'); %[output:5d44aef8]
elseif tdcg >= 720 && tdcg <= 1920
    fprintf('Status: Condition 2 (Caution). Monitor closely for gas increase.\n');
elseif tdcg > 1920 && tdcg <= 4630
    fprintf('Status: Condition 3 (High Risk)\n');
else
    fprintf('Status: Condition 4 (Excessive Decomposition - Immediate Action)\n');
end %[output:group:7957ad6e]

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

fprintf('\n---> Rogers Ratio Method Method <---\n') %[output:6ffaea4d]

% Display Ratio Calculations 
fprintf('\nCalculated Ratios:\n'); %[output:47960fcb]
fprintf('R1 (C2H2/C2H4): %.2f\n', r1); %[output:7ac3a5bf]
fprintf('R2 (CH4/H2): %.2f\n', r2); %[output:91a02b71]
fprintf('R5 (C2H4/C2H6): %.2f\n', r5); %[output:2fd24464]
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
    rr_result = 'High Temperature Thermal Fault (>700C)';
    
else
    rr_result = 'Diagnostic ratios do not match a standard fault pattern (Undetermined)';
end

fprintf('\nDiagnosis:\n%s\n', rr_result); %[output:0b94585b]
%[text]{"align":"center"} ## **`Key Gas Method`**

fprintf('\n---> Key Gas Method (Hierarchical Analysis) <---\n') %[output:6591190d]

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

fprintf('Diagnosis: \n%s\n', kg_result); %[output:9b368d44]
%[text]{"align":"center"} ## **`CO2/CO Ratio`**

fprintf('\n---> CO2/CO Ratio Analysis <---\n'); %[output:48b69102]

if co > 0 %[output:group:53e058e8]
    ratio = co2/co;
    fprintf('\nCO2/CO Ratio: %.2f\n',ratio);
    
    if ratio < 3
        fprintf('\nDiagnosis: Severe paper degradation (Carbonization).\n');
    elseif ratio > 10
        fprintf('\nDiagnosis: Normal paper aging, Mild overheating.\n');
    else
        fprintf('\nDiagnosis: Healthy insulation, Standard operation.\n');
    end
else
    fprintf('CO2/CO Ratio: N/A Invalid Input.\n'); %[output:3186b01c]
end %[output:group:53e058e8]
%[text]{"align":"center"} ## **`Duval Triangle 1`**

fprintf('\n---> Duval Triangle <---\n'); %[output:2a3f237e]

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
elseif inpolygon(X_pt, Y_pt, T2_x, T2_y), dt1_fault = 'T2: Medium Temperature Thermal Fault (300-700C)';
elseif inpolygon(X_pt, Y_pt, T3_x, T3_y), dt1_fault = 'T3: High Temperature Thermal Fault (>700C)';
elseif inpolygon(X_pt, Y_pt, D1_x, D1_y), dt1_fault = 'D1: Low Energy Discharge';
elseif inpolygon(X_pt, Y_pt, D2_x, D2_y), dt1_fault = 'D2: High Energy Discharge';
elseif inpolygon(X_pt, Y_pt, DT_x, DT_y), dt1_fault = 'DT: Mix of Thermal/Electrical';
else, dt1_fault = 'Undetermined / Boundary';
end

fprintf('\n---> Duval triangle <---\n'); %[output:894c2faa]
fprintf('Diagnosis: %s\n', dt1_fault); %[output:8fa1f197]
%[text]{"align":"center"} ## **`Duval Triangle Plot`**
figure('Name', 'Duval Triangle 1', 'Color', '#24273a'); %[output:4875bbe4]
hold on; %[output:4875bbe4]
axis equal; %[output:4875bbe4]
axis off; % Hide standard axes %[output:4875bbe4]

% Zone Patches (Colored)
fill(PD_x, PD_y, [0.8500 0.9500 1.0000], 'EdgeColor', '#24273a');    %[output:4875bbe4]
fill(T1_x, T1_y, [1.0000 0.6824 0.6863], 'EdgeColor', '#24273a');       %[output:4875bbe4]
fill(T2_x, T2_y, [1.0000 0.8000 0.0000], 'EdgeColor', '#24273a');     %[output:4875bbe4]
fill(T3_x, T3_y, [0.2471 0.2471 0.2471], 'EdgeColor', '#24273a');      %[output:4875bbe4]
fill(D1_x, D1_y, [0.0000 0.8118 0.8784], 'EdgeColor', '#24273a');        %[output:4875bbe4]
fill(D2_x, D2_y, [0.1490 0.3216 0.6549], 'EdgeColor', '#24273a');      %[output:4875bbe4]
fill(DT_x, DT_y, [0.8314 0.3255 0.6392], 'EdgeColor', '#24273a');     %[output:4875bbe4]

% Adding Zone Labels
text(mean(PD_x), mean(PD_y), 'PD', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:4875bbe4]
text(mean(T1_x), mean(T1_y), 'T1', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:4875bbe4]
text(mean(T2_x), mean(T2_y), 'T2', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:4875bbe4]
text(mean(T3_x), mean(T3_y), 'T3', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:4875bbe4]
text(mean(D1_x), mean(D1_y), 'D1', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); %[output:4875bbe4]
text(0.65, 0.20, 'DT', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); % Manual placement for DT %[output:4875bbe4]
text(0.5, 0.2, 'D2', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); % Manual placement for D2 %[output:4875bbe4]

% Main Triangle Boundary
plot([0 1 0.5 0], [0 0 0.866 0], 'k-', 'LineWidth', 1.2); %[output:4875bbe4]

% Plotting Sample Point
plot(X_pt, Y_pt, 'go', 'MarkerFaceColor', 'b', 'MarkerSize', 4, 'LineWidth', 1.5); %[output:4875bbe4]

% Label to Sample Point
text(X_pt + 0.03, Y_pt, sprintf('  Fault\n  (%.1f, %.1f, %.1f)', p_ch4, p_c2h4, p_c2h2), ... %[output:4875bbe4]
    'BackgroundColor', '#cad3f5', 'color', 'k', 'EdgeColor', 'r', 'LineWidth', 1, 'Margin', 1); %[output:4875bbe4]

% Corner Labels
text(0.215, 0.45, '% CH_4', 'Rotation', 60, 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold'); %[output:4875bbe4]
text(0.77, 0.48, '% C_2H_4', 'Rotation', -60, 'HorizontalAlignment', 'left', 'FontSize', 12, 'FontWeight', 'bold'); %[output:4875bbe4]
text(0.5, -0.05, '% C_2H_4', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold'); %[output:4875bbe4]

% Title
title(['Duval Triangle 1 Diagnosis: ' dt1_fault], 'FontSize', 14); %[output:4875bbe4]
hold off; %[output:4875bbe4]
%[text]{"align":"center"} ## **Duval Triangle 4**

if  strcmp(dt1_fault,'PD: Partial Discharge') || strcmp(dt1_fault, 'T1: Low Temperature Thermal Fault (<300C)')... %[output:group:1d0727a1]
        || strcmp(dt1_fault, 'T2: Medium Temperature Thermal Fault (300-700C)')
    plot_dt4(h2, ch4, c2h6); %[output:37dea0d2] %[output:77469102] %[output:74fde7c4]
end %[output:group:1d0727a1]

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
%[text]{"align":"center"} ## Duval Triangle 5
 if  strcmp(dt1_fault, 'T3: High Temperature Thermal Fault (>700C)') || ...
    strcmp(dt1_fault, 'T2: Medium Temperature Thermal Fault (300-700C)')
    plot_dt5(ch4, c2h4, c2h6);
 end

function plot_dt5(ch4, c2h4, c2h6)
    fprintf('The fault zones are shown on Duval trangle 5')
    
    total_gas = ch4 + c2h4 + c2h6;
    p_ch4  = (ch4 / total_gas) * 100;
    p_c2h4 = (c2h4 / total_gas) * 100;
    p_c2h6 = (c2h6 / total_gas) * 100;
    
    % --- Defining Coordinate System ---
    h = 100 * sqrt(3) / 2;     % Triangle Height
    
    get_x = @(c2h4, ch4) c2h4 + 0.5 * ch4;
    get_y = @(ch4) ch4 * (sqrt(3) / 2);
    
    % --- Defining Zone Polygons ---
    to_xy = @(pts) [get_x(pts(:,1), 100 - pts(:,1) - pts(:,2)), ...
                    get_y(100 - pts(:,1) - pts(:,2))];
    
    % Defining regions as per IEC 60599 / IEEE C57.104

    % -- PD (Partial Discharge) --
    % C2H4 < 1, 2 <= C2H6 < 14
    poly_PD = [
        0, 2;
        1, 2;
        1, 14;
        0, 14
    ];
    
    % -- S (Stray Gassing) --
    % C2H4 < 10, 14 <= C2H6 < 54
    poly_S = [
        0, 14;
        10, 14;
        10, 54;
        0, 54
    ];
    
    % -- O (Overheating) --
    % Composed of 3 parts
    % 1. Top Tip: C2H4 < 1, C2H6 < 2
    % 2. Side Strip: 1 <= C2H4 < 10, 2 <= C2H6 < 14
    % 3. Bottom: C2H4 < 10, C2H6 >= 54

    % Top + side O Section 
    poly_O_Top = [
        0, 0;    % Top Vertex (CH4=100)
        10, 0;   % T2 Boundary Start
        10, 14;  % S Boundary Top-Right
        1, 14;   % PD Top-Right
        1, 2;    % PD Bottom-Right
        0, 2     % PD Bottom-Left
    ];
    % Bottom O Section
    poly_O_Bot = [
        0, 54;    % S Boundary Bottom-Left
        10, 54;   % S Boundary Bottom-Right
        10, 90;   % ND Boundary
        0, 100    % Left Vertex
    ];
    
    % -- T2 (Thermal 300-700) --
    % 10 <= C2H4 < 35, C2H6 < 12
    poly_T2 = [
        10, 12;
        35, 12;
        35, 0;
        10, 0
    ];
    
    % -- C (Carbonisation) --
    % Complex center shape
    poly_C = [
        10, 30;
        70, 30;
        70, 14;
        50, 14;
        50, 12;
        10, 12
    ];
    
    % -- ND (Not Determined) --
    % 10 <= C2H4 < 35, C2H6 >= 30
    poly_ND = [
        10, 90;
        35, 65;
        35, 30;
        10, 30
    ];
    
    % -- T3 (Thermal >700) --
    poly_T3 = [
        35, 65;
        100, 0;
        35, 0;
        35, 12;
        50, 12;
        50, 14;
        70, 14;
        70, 30;
        35, 30
    ];
    
    % --- Plotting ---
    figure('Color', '#24273a', 'Name', 'Duval Triangle 5');
    hold on; axis equal; axis off;
    
    % Function to draw filled patches
    draw_zone = @(p_data, col) patch('Vertices', to_xy(p_data),'Faces', 1:size(p_data,1), ...
    'FaceColor', col, 'EdgeColor', 'k', 'LineWidth', 0.8);
    
    % --- Zones ---
    draw_zone(poly_T3, [0.451 0.651 1.0]); 
    draw_zone(poly_C,  [1.0 0.682 0.102]); 
    draw_zone(poly_ND, [0.792 0.827 0.961]); 
    draw_zone(poly_T2, [0.2 0.49 1.0]); 
    draw_zone(poly_S,  [1.0 0.592 0.663]); 
    draw_zone(poly_PD, [1.0 1.0 0.102]); 
    draw_zone(poly_O_Top, [1.0 0.102 0.102]); 
    draw_zone(poly_O_Bot, [1.0 0.102 0.102]);
    
    % --- Triangle Boundary --- 
    plot([0 100 50 0], [0 0 h 0], 'k-', 'LineWidth', 1.5);
    
    % --- Text Labels ---
    % Manual placement for visual match
    text(46, h-8, 'PD', 'Color', 'r', 'Horiz', 'center', 'FontWeight', 'bold');
    text(50, h-10, 'O', 'Color', 'k', 'Horiz', 'center', 'FontWeight', 'bold'); % Top O
    text(33, 50, 'S', 'Color', 'r', 'Horiz', 'center', 'FontWeight', 'bold');
    text(15, 20, 'O', 'Color', 'k', 'Horiz', 'center', 'FontWeight', 'bold'); % Bot O
    text(35, 20, 'ND', 'Color', 'r', 'Horiz', 'center', 'FontWeight', 'bold');
    text(55, 40, 'C', 'Color', 'r', 'Horiz', 'center', 'FontWeight', 'bold');
    text(52, 11, 'T3', 'Color', 'r', 'Horiz', 'center', 'FontWeight', 'bold');
    text(83, 15, 'T3', 'Color', 'r', 'Horiz', 'center', 'FontWeight', 'bold');
    text(57, 60, 'T2', 'Color', 'r', 'Horiz', 'center', 'FontWeight', 'bold');
    
    % Axis Labels
    text(17, h-50, '% CH_4', 'Rotation', 60, 'HorizontalAlignment', 'left', 'FontSize', 12, 'FontWeight', 'bold');
    text(50, -4, '% C_2H_6', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
    text(78, 45, '% C_2H_4', 'Rotation', -60, 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');

    % --- Fault Point ---
    ux = get_x(p_c2h4, p_ch4);
    uy = get_y(p_ch4);
    
    plot(ux, uy, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'LineWidth', 1.5);
    text(ux+2, uy, sprintf('  Input\n  (%.1f, %.1f, %.1f)', p_ch4, p_c2h4, p_c2h6), ...
        'BackgroundColor', 'w', 'EdgeColor', 'k', 'FontSize', 8);
    
    % --- Diagnostics Output ---
    xy_PD    = to_xy(poly_PD);
    xy_S     = to_xy(poly_S);
    xy_O_Top = to_xy(poly_O_Top);
    xy_O_Bot = to_xy(poly_O_Bot);
    xy_T2    = to_xy(poly_T2);
    xy_C     = to_xy(poly_C);
    xy_ND    = to_xy(poly_ND);
    xy_T3    = to_xy(poly_T3);

    % Point-in-polygon check
    if inpolygon(ux, uy, xy_PD(:,1), xy_PD(:,2))
        diag = 'PD - Partial Discharge';
        
    elseif inpolygon(ux, uy, xy_S(:,1), xy_S(:,2))
        diag = 'S - Stray Gassing';
        
    elseif inpolygon(ux, uy, xy_O_Top(:,1), xy_O_Top(:,2)) || ...
           inpolygon(ux, uy, xy_O_Bot(:,1), xy_O_Bot(:,2))
        diag = 'O - Overheating';
        
    elseif inpolygon(ux, uy, xy_T2(:,1), xy_T2(:,2))
        diag = 'T2 - Thermal Fault (300-700 C)';
        
    elseif inpolygon(ux, uy, xy_C(:,1), xy_C(:,2))
        diag = 'C - Carbonization';
        
    elseif inpolygon(ux, uy, xy_ND(:,1), xy_ND(:,2))
        diag = 'ND - Not Determined';
        
    elseif inpolygon(ux, uy, xy_T3(:,1), xy_T3(:,2))
        diag = 'T3 - Thermal Fault (>700 C)';
        
    else
        diag = 'Undetermined / Boundary';
    end

    fprintf('\nDetected Zone: %s\n', diag);
    title(['Duval Triangle 5: ' diag]); 
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":40.1}
%---
%[output:6fd76dbe]
%   data: {"dataType":"text","outputData":{"text":"===== DGA Calculator =====\n","truncated":false}}
%---
%[output:74ffde31]
%   data: {"dataType":"text","outputData":{"text":"\n---> TDCG Assessment <---\n","truncated":false}}
%---
%[output:7775921e]
%   data: {"dataType":"text","outputData":{"text":"Total Dissolved Combustible Gas (TDCG): 470.00 ppm\n","truncated":false}}
%---
%[output:5d44aef8]
%   data: {"dataType":"text","outputData":{"text":"Status: Condition 1 (Healthy\/Normal). Ratios may be unreliable.\n","truncated":false}}
%---
%[output:6ffaea4d]
%   data: {"dataType":"text","outputData":{"text":"\n---> Rogers Ratio Method Method <---\n","truncated":false}}
%---
%[output:47960fcb]
%   data: {"dataType":"text","outputData":{"text":"\nCalculated Ratios:\n","truncated":false}}
%---
%[output:7ac3a5bf]
%   data: {"dataType":"text","outputData":{"text":"R1 (C2H2\/C2H4): 0.00\n","truncated":false}}
%---
%[output:91a02b71]
%   data: {"dataType":"text","outputData":{"text":"R2 (CH4\/H2): 0.67\n","truncated":false}}
%---
%[output:2fd24464]
%   data: {"dataType":"text","outputData":{"text":"R5 (C2H4\/C2H6): 0.13\n","truncated":false}}
%---
%[output:0b94585b]
%   data: {"dataType":"text","outputData":{"text":"\nDiagnosis:\nNormal working condition\n","truncated":false}}
%---
%[output:6591190d]
%   data: {"dataType":"text","outputData":{"text":"\n---> Key Gas Method (Hierarchical Analysis) <---\n","truncated":false}}
%---
%[output:9b368d44]
%   data: {"dataType":"text","outputData":{"text":"Diagnosis: \nLow-temp Thermal \/ Oil Decomposition [Key Gas: Ethane]\n","truncated":false}}
%---
%[output:48b69102]
%   data: {"dataType":"text","outputData":{"text":"\n---> CO2\/CO Ratio Analysis <---\n","truncated":false}}
%---
%[output:3186b01c]
%   data: {"dataType":"text","outputData":{"text":"CO2\/CO Ratio: N\/A Invalid Input.\n","truncated":false}}
%---
%[output:2a3f237e]
%   data: {"dataType":"text","outputData":{"text":"\n---> Duval Triangle <---\n","truncated":false}}
%---
%[output:894c2faa]
%   data: {"dataType":"text","outputData":{"text":"\n---> Duval triangle <---\n","truncated":false}}
%---
%[output:8fa1f197]
%   data: {"dataType":"text","outputData":{"text":"Diagnosis: T1: Low Temperature Thermal Fault (<300C)\n","truncated":false}}
%---
%[output:4875bbe4]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAArwAAAGlCAYAAAAYiyWNAAAAAXNSR0IArs4c6QAAIABJREFUeF7snQd4FNX6xt9QTYAEAiwlRAhGAhrLvTRFVIjYFRAbKgpYAEUQuygiIIp6LVwQQVBBBQUFhGu\/YgALioDXEsBQJJiEEmpClfr\/fyfOOpns7sxsy+zuO8\/jAzKn\/s6ZnXfPfuc9cekZHY6DFwmQAAmQAAmQAAmQAAlEKYE4Ct4oHVl2iwRIgARIgARIgARIQBGg4OVEIAESIAESIAESIAESiGoCFLxRPbzsHAmQAAmQAAmQAAmQAAUv5wAJkAAJkAAJkAAJkEBUE6DgjerhZedIgARIgARIgARIgARCKnj79r4W11x9maK8ZUsRRj75b\/yRv8kn9bEvDsfJ6Wm2Rmb2nE8w9c33febxpy22GhHixBXV\/pYZJ+HRRwaibt06lsdQQ3HmGadg6MMDUbNmgkc6x48fx4EDB9Wc+PiTbGQvXFIunb6MQ4cOY+q09\/CfjxaEmHZkFu8UVsF8hu8e2BuXXHQ+4uLiYOU5tzNyjw29Gx3Obq2yrF23AUPuG2Unu+PSnpjaGE88fg8aNnRZbhufKcuoYiZhIPNI3hN23\/mxANaf97c+jxmjvXv3Y8yzE\/DTz6vMkgb1vnGuBPsz+v5770DnTmdjx45dGPXUOKxfvzGg9lPwBoQvfJn9eWACbV18\/Al4+IEBaNv2DFtfWqwKXn37jhw5gm+XLMcLL72Go0ePum85RcQFyjIc+Z3CKliC9\/zzzsKAfjciMbGWwhfsD1MKXoCCN\/hPpnxuyuf1jp27Meu9D4NfQYhLpOANPmB\/3t\/RInibNWuCXjdehf98+AV++fU3y3DbtzsT9wzqi6SkRCz5bgWeGvOy5byeEp50UtPQujT4M8jBelkaO+xPWwKiG+TM4W6\/y1UX995zG07LbKlW1+Syukrvj+CVPCJ6P\/r4S0x5fSYFrx\/zJ5oEb9crL0SvG7ujRo2\/fx2g4PU9KQIRKvzVxI8HzkOWLhd0xC29eqhfxII9X4PTQvNSAplHXOH1zNef93ekC17ti588E4cPH7G9Aj3yiXvRpvXpOHDwIF6dPANfLPjGfPICqFy5Mrpe2QUXZJ2Dzz5frDSFXFKe41Z4jT0yPnzBUPqWqDkskT8PjD9dkEl64w3d0CXrHPfKmlZOIILX00pSq5bpuLrHpWjT+jRUrVpVVbN7dwmeee4V\/JqT60\/zmceBBOw8wyLab7qxOySUplKlSmV6E2wBEW0rvJ6G3hhWFGyGDpxuFdakUP+8W2EdA2B1HoXrPVWRLPyp2x8u\/uTxp22B5PE157te0QV9+1yHatWqwm7IxemntcQjD92FpKRalhfaRLv0vO5KdO58Nuom1ynz69Upp5yMxx65m4I3kMEOZ95wTX7jt0qJsZWJJFewBa\/Gb0C\/m3DZpVmoXLkSJK73k08X4pVJb4cTL+sKIQGrgteY7vDhw2o+VKtWTbUu2GKNgjeEgx6DRVPwQoVyMIa3\/OT3h4s\/ecL92IVK8N414GZcdmln9euy2SJnkyaNcO3Vl6n9GAkJ8W4E+kU2uXftNZeXF7wXdO6AOwfcrESOiJ2Jk97Gl39tJpKfufvcci1a\/\/M01KgRrxojP0Pv2bsP33y7HG++NVvl0a5gDJiVl6U+DEKWsFucnAaJG5GrsHALnvnXRHQ+\/2yfD6Isu1\/T41I0bFjfvdooS+n5f2zCOzP\/g2XLf3b3S98m+ebyrxcmoU2bM3Bex3ZITKypXtI7duzGJ59mY84Hn5WJSZVC5FtL\/ztuRNs2Z6gBkhf7hg35auldVle1TSf6F7wZS+nv7bf2RMuWJyH+hBPUuEgM2ddf\/4CZ731YZlx8PRRaPZL\/h2U\/o6hoO7p3uzikgldia4Y\/Nhj16iWrenLX\/I77HnhS\/d3sZ3qt3xktmrsnu\/DcuasYn322yCP\/M888Fb179UBaWqoa6\/37D2DZ8l+w\/veNKtbI0zdSvTiScckv2KzmU6OG9VGlShV3GdPeeh9FRTvKIZZ23nRDd5x+Wiv17Mi1b98B\/Ja7Tm24zMsr8JhHxlT6Js+jPG+++uaLlfzMc\/VVl+CSSzohuU6S6re2aVB4v\/bGzHJtsLqqY\/Yha+UZljL06Xbs3IXZsz9Bt64Xenwe9HXqx8bOl7JABa\/wue7aK3ByejM1944dO4aSkr343085eGv6XPc8qFWrJp4d8wianpiimi2fCxMm\/v2FTt8O+YXjqWdexqpVa1VabWWidu1Ev+JtrY6hfBbd2LOr+5mQebZlyzZ8\/sVX+M+HC8p8huk\/i2Sz30cfZ5d7Fr77\/kdMfHU6zunQpty9hYu+U3Ne\/67QM5C8a9b8rr4E161bW8174bpw0RK8Me39cp+nwslO+\/V1LVv2M6pWrYLMzAz1U+jOXbsx4ZW3sPSHn9T\/a89M3eTa6jn39sz4+vlZ2xDpa576ekb0K2Uyv+WzSn6ulTknL\/WPPvkSr78xS80XOxzMnlv9favzyPieeufd+bji8gvc80reqb\/9th6TJs9AQcHmck2w034rXI4dPeZ+7wdrrkqjw6GFzN75vsbPztyVcvQsPf0a623uehO8vkJTzRYu9J+XR48eU3HwM96dV6678itgr5uuQuapGeoZ1i75HN60easKZzB+dsVdfNkNx\/U73x56oD9ks4hcIsKGDnsOe\/bsVSLtiWFDkJHR3CNn+SCQTUdjnn3FfT+QAdMKsfKy1MPVr0jKh7Z0Wh4uX22ReMFbbu6hhKKnq7h4D14cOwXLV\/yqbuvbJGJJPiSbpDQql1VE47z\/\/BdTp\/3tIOGL46FDh+TwOyW45LIqeC+9pJPqnz7eUWuMjMvq39Zh9NPjIf0wu6Scdm3PxPtzPlauCYGMoZlY1bfl2TFDkXlqC\/VPetHiqwwRyo8+PFB9SfF0eeJ\/9ln\/xKCBvVUgvPGSuSOribLSbPwJRv\/A\/77hDzUH5AVovFatXotRo8epZ0a71Pzq1cO9Uu6pXhFIEtSvXb7aKWnkoZbn7ZnnJrrzeGMlH36PPHQnpEwtHtvYhl27izH236+757jct\/qSM5tTVp5h7bl68IH+WLcuD+\/O+g9OqF69jOuAtw\/KihC8\/W6\/Qa1AaKE4RgYiXF9+5U2IeJNr4J2yYpGl\/r5m7QY88NBTSrgZxbB8Zs14dz7en\/2xSiurEjfd0E3VY0fMa+2xMobyjMsc1T539H2ReSYrLM89\/6pbaOo\/E+TlKCH+Rg7yuSOCuV69Oh7vieh94aUp7qr0YyhzsVbNGuWeLylTeMqc129stdt+fV0iwGSeaYs3P\/4vB6OfflmVf8dtPZVY8\/ScS8M3by7CqNGlzkPhErzyjpC2al9YhfHzL07Gb7nrVRvsjKPZc6u\/b2UeSfqyc+Pvthrr0rPT7tltf1mR5pmLfOZpK87Bmqvh0kKBvHvtzF3h7yTB+89\/ZOLhB+9U7k779u3HuJen4Ztvl7mnkKzWypie1PzEMs+mxAnL+\/e99z\/y6lYR98SI545r6lm+tTw58n4l3kRZz577Cd56e46q6Jabr8Y1PS5TYkAE8nMvvKpe6vcOvs29i3\/79p1qJ518oBsnvz8f1tpLUG+142l5Wy945UPx+6X\/Ux+mVlab9X2WB+LdmfPVqmCn89rj9tt6uuNY9asyxhe4CKvFXy3F61NnKSE0ZPBtbhEmK4HDn3gBRdtKV\/00mw350JIP2w8\/XID3Zn+sROatfa51r3JKWiuCV28bJu3QVlZanNwcA\/rfhIYN6qtVic\/+uxgvT3jTzmdcwGNoR\/B6W+XyVYb+y5ms1Lw07nUlIB66vz9EDMu18Y9CPDz0GTVXZaxHPXEfUlMbq3tbtm5TKyP\/+2mlWn29\/LIs90vfl+CVvL\/\/\/gcmTHwLm7cUYfDdfSE7StWYGn4Vkfjk+4bcob4wyjjIC3Xya++q+vvccg3atjldPbTFxSUYP+FvgaQF7Euer79ZhkmTp6vVHPkQvPii81Qe+TAYO+4NJUjk8sZKPiCGDL5VfSGSldPXXp+Jr77+AadlZpSZq8tX\/IInRr7kniNWX3Jmk8qq4DWWY\/Un4nALXhFBfXpf4\/4lRXv2GzV04bZbr4fEpstcEDHy9LMT1Odlx3PaYvDdfdQYyNx69l8T1VzQf7hr\/dd\/xo0e9QD+ceap6pbZT3uexsFsDM87tx0GDezjXi0Ue0B5H5x\/bnv0vuVq9fknIktW6t6f80m5zwTtGZNfArcWbVc2hPILm3bJO0FWZVf\/tlY9J1pfjO8K\/Rgan00Jeep0\/llqzstnnHwuvj3jA1WFP+031iW\/cMi+Af0vM\/oYwpKSPeqZWfTVUrXie0PPbupzwvjlxGy+BmOFV\/osnxWyiCPPsHb5w8HsudXfN5tHWlqj8Nc+Y2XFXESYLM7IOBpX7vxpv16keeNibI+8DwKdq+HSQr6+ROnHxviu8mfuBlvwSvv8jeHVf8mXz5SRo8aq97jxHacxkOdTdM\/ceZ97\/NVAzypu7gcfHh\/62HPqG62+gfqf1mSF6PnnHlMfZMaH3FenAvmGojXSystSL3iNH6SeHkS9+Na3Xy+OJJ++XP3LxtimlavWQGMo+WT1p1vXi1TVMhiy6i12HMZ8i7\/6Xq2caNfVV12KXjd19xiz6I1l3z7XQvLJC\/aPPzbhkceeca\/kXtilI\/r3u0m9mIWLPz52gYyhv4JX\/wB7K0PP0vgt0Fub9WPtaeenJjJlPHwJXlkplxekZrEiovahBwYoMSMCVVbn3vzri6K+TFkZHjb8eff4iDiX+xKyINfPv6zGo8OeU3\/X5p6UJ+E0EydNV1+ajCuCX2Z\/ixfHvlbuw0D\/s5S+3\/KyFAEiK2zyzOs\/XIw\/p9t5IfpKa+UZ9pTfTEAE2j5\/QhqE\/5jRD6mfaOVa8eOvyl9cW3HUt1nGTsbnpX+\/Dlf9uhg18n6kNildTNB+ppMvWtdfd6VaSNAu7UvyCSf8vcItonP6jHmY88GntrptJlT0DOSLn3zh0fqif7Hrf+3TP1\/G50h\/z7hoIquPt\/a5Tv386Ov5MpYp7x9Z9JBQOrn0bfGn\/fo8nlaQpA7956pwkedWLl9z0my+BkvwGkNipF3+cLAzkczmkaf3rHEcUxo3wKgR97sXg77+5gf3L1T+tN8oeD1xCfZcDacW8lfw+jN3nSR49frJuGBonIfyzpRfJrUFRbM5HffDD8uPay9v\/cvZuNqjL0hWMNq1PQOnntJCffBrgcLGD7FAxJJWn5WXpV6YejOQt9IWWYWTldYzTm+pVmlcrnruneK+BK\/xQfP2JUAvjP788xCmvP4uPv1skRutxPg9MXwIGrjqqX+zssKrDwUwrgDJFxT5IJHYWOPKo9nE8PQBZneV3l\/Bq\/+SYKUM+RA64\/RW6pcGWfFOayaxuaXhBvo26x8kWX0bPuIFFG7a6kZh9YVs\/GLk7UVn\/Pf5\/\/mve3VXq1QvePRf1vTjKmm1+NANeflYuHAJlnz\/Y7m4bG+s9HH5Wr0iiGV1Wj4wFnz5TcCG3rEiePUrsvIT2htyEIouFEU43DfkdhVjKZd+ruj\/XRNR2gquCNojR46qz1JtBbhO7UT3fgp\/v7D6Eip6EW78vJH\/169K678M6T9LjQsM+mdIxORzz09yh8mU+cJp+CWkrBgs\/2zqv5hpnw\/yDGtfIuy03+4vAsLprLP+qX4RkZC+5DqlccXGOsMheD3FV\/o7jlbfAZLOH8HrafHJ0yKSv+03E2nqi4tuE12w5mq4tJC\/glffPqtz14yl3RheaYO\/K7y+FiKM81Dqkc\/hn35aqfYqSWiPryvut99+Oy674uWl5xZHHnzPtCBt+QlWvxNOX7gTBK\/+27i+bb4Er2xYu\/aay9C4UYNyVkhaGb4ErzG20NtAm00A4+qdFcFr1bfYV\/C3rwli5YuCt\/xWxKqW158YXm3DmjFoXd8eveA1W9Ez\/uysP7nGV15vLzor\/fc2J8xieOUhX\/rD\/5SbhRab7W8Mr6xEbt++C7LhbtHi7+28By2ltfKl1VNBZgLCUuU+EpnNB09ZzZ5h40tWP\/\/0Xzzk3yWEReLJZZOqvIzXrstTcdbas1q7di133K+3zzUzBr6EipGvr7L0X5h97ofwYUXk66VqNhaeuO\/cudvyyXL69uvrMn551Rhom34kfCU5+W+Ba2Sk\/4w2m6\/BWOH1tCLt7ziazR39fX8Er6cFEk+C19\/26+eE15V6H64Rvp5lX3M1XFrI33evP3M3UgSvzElvMbwS7rT+9z\/UQqEW5mec43G5ubnH5SeiZSt+UT+Ny09rBYWb8bjEnf6121yE2PBhg3FKq5NVfilYVsZkdWhPyV71s6inne3+Dpi+kVZelt5CD6wIXn08nqSX1QOBJqto4k7QvPmJqphIF7zSB7PdkZ4+AAMZQyuCT+o0jrEVlwbJM3zYPWjUqPQYVRGAsvopwkC+kF15+QXq3yNV8Erbjc4bnsYnJycXjz7+L\/UztC\/e2oegtvPd6HErZYsoeHXKO\/hiwdd23oWmaa08w7EgePX7BeTn3i+\/\/FatBIsDR87KNfj222Vu30o5IjQpsZb6Bc0YRmYKXJcgWIJXv7IYiYJX334zca2+tPS5Ft27XuR2ZpCNyatXr1Nx1+LMIXsjjJ+p4RC8nvxM7QhGf0\/Wc4rg9Raq5c3nNdhzNZxayN93rz9zN5IEr\/bxJr\/miu+uuC7pXRq0DbMff5pd3qVBBK9MFrGfEnHnyQdVvzIhE+6t6XPwwbzPVb1Oi+H1trHD2+TRryzKZrsRo15yr5hZjeG1usKrX0H09MHjT0jDi88\/7o4B9WdTi9nL09+HTsq1KnjFQ0\/s2MQhwTj\/vJWhDwWQLymyWqZ9q\/PWZv1OeU+rD1ZDGoxhM6EIadCPixay0aFDa\/Wls3Ejl3vnu93wDylX+5lLwpKap52orPS0n2j1cXVmc8Pq\/WgSvPr5aDekQXjpN1qKG0Gd2klqzkts7rffLnf\/yiafyZWrVHLH3+s3A1vlbnwGjQLNGFNp9QtxsEWEtEsvQo0bVeS+p1jz4t0lZWJCrbbfTPAaf2KXDTGyD0O+VFZ0DK8nYefvOAZrHunLMXtfeHqn+tv+QH5tMdMu3gRgOLWQGUtP4+fv3I1Ewav1XxYSbri+qwrB8ubDK2YBamO5CF49OP0OYu3f5TQsOeZTBInxgdOLCCeENNgRvLJj\/ZmnH1Evfbn0efXxr8Z7Zt\/kvT2IZpvW9MLP+HLyNvn1Bs3GTWv6TSf+xgD689Bp88ZM8MrD2aPHpepUN+1wC+NJa97KkH6Lq4JcRvGq39nubYOi2cYYX5tqrApeaZudTWta3LzeVcHTFyNvwtwbK30b9JZY0j4R02NfGO7xlww7L0RfaaNJ8NrdtGY8RMW40Ua46X+ONcZuy31Z\/X146Bi\/hsNsZU4\/N4yb1rxZVIZa8BpdIYzPkX7Tmj\/tNxO84qv8+GOD1fHAxs9h\/aKF8Z5ZzL5+D4FR1OufeeP7xoqw84eDnQllNo+0sszeF94WkfxpvxUuwZ6r4dRCZiw9jZ+\/c1e\/v8j4Rd74mad\/p\/rSQsaQE308v6+5V7bf5eP5veX1ddKapoXifvr55+N6\/1mj44AUrv9WI\/FlixZ\/h1enzMBFXc7DDT27uv1fI03win+i\/gUjovDlV0qtpgbd1RunntrCvfIVjJAGYXn3wN645KLzSy2sDh7EvPn\/xZy5nyrbHfFqFRsg7bISwysbKeQIPjGml41NK37MwSuT3lIb3zR7NFlBMvpeWv2w8+eh8yR4rdQnoTJy+MaU12e6k1tZ4RVRKH7Hs+d8jBuu71bGXkz\/cMqmRBHD2hccscyZ9OoMrFn7O27rez3OP6+929cvWIJXb7dj1ZbMuCtds\/aROSinysiLUzZPyRzSv\/y9sdK3QW+hJ3286MJz3fPO6ARg9SVnNrahFrx2NyFp7TXaU\/nqh34e6b+Y6nn6siXTyvb087N+J7J+h7Xk8Tf23tszaFwFvbDLueoQHHlZSOiEfE6IbZ7EEt9+6\/XKr9poBRZsESFtNY6FxKWLJebir5eWsQw0tsWf9psJXuMqmbiriM2leAPLoUzaASJGwSv\/rxd08gVC9gGkNG6owuQuv7SzO2RF+iHx8mIvJnsQbut7ndsu0R\/B6w8Hs+dWf9\/qZ4HZ+8Kb4PWn\/RUheMOphcxYeho\/f+eu8XNJbDdfGDtFHajU73Y5JKvUPlMuq4K37K9hhzHr\/Y9UGJe4z4j28nbpF3S8uW75mrvy\/rzwgo644ooL1DkMoim0\/sV99tmC45rFjjfrG2Pcir4yEVnHj8tKUSUVR6nftezPgBk7YuVlGcwYXn398qEk8ERYyAQYcv8o05+1JL+vB9GXabWs9Ehd2rK8FcGr6jM5OCM393eMHD3W0sETRv6BjKGnHZXeJqq8bMVc+qV\/v1HGVN6biDPG8OrLFZEgl8xJ405xb5vBRIzuLi5BzRoJKlwgWIJX2iHhGj26X+L14Alpo5w8pXfsEB\/he++5TTlOeLuM3r2+VtRlHL2Z0kv5nkz9rb7kzF6cVp5hT2WY\/ZKi5Qm34JXPBPmF4YKsDl4PnpAP6vETppU5yMNTe+Xf9BvSjCuIgVrFWRlDXyb1nuZFqAWvvGTlMm6O9nbwhN32mwleqVsfB2mcm\/JZpR20IZ7vTz41zp1Evyqu\/aMmEIpL9uCpUQ+6Le305UqZe\/ftVyEucukXWKwIO8ljl4PZc6u\/b2UeKW4mRwv7elfbbb8VLsGeq+HUQmYsvY2fv3NXPtPEJ9m4v8P4brQqePV7FvRtNQu91J8u6W0zop25q6WVvsU9Neal45qPqy\/bKWn8HbfdgH\/841QVV6YdPTl77qc4t2NbtGl9uipX70vp74DpO2PlZRmI4JW6xKVBVqrl25EITjnyVfohGxRkNU38VeVDWF5gYvZt9iI2exCNuzy14xbnfvCZOpHJn6OF5QNJf8ypTFI5jvOrb34od+SznckSyBiaCV7tmE7Zne7tdBRfIk42dd3Zr5eyCpIXkKz05uXlK4P8G3t2Uy8WT4du6I+vlG+tGqdNm7aqD2yzo4XthDRorP05WlhW3SSU6NyO7dTBFdJW+YK5d+8+9TO3HBCgP5LYLIRE+i1uJCKiNTEhzLZu9XyErNWXnNl8svIMR5Lg1dpqfOa8HS1s7Jveb9u4gmtcofH0i5sZb3+ESlbnDrjyii5o1rSJmv\/SF2\/HowdbREh7jV9a3pr+gTpWWk5Tki8YZkcL22m\/FcErdV5\/3RW4\/NIs96Ex0oavv12Gbdt2uEP8duzYhaefmeC2Q5LP9rsG3ILMzBbug0nEI1ROQ5OFB\/mFRg7S0I6A179HJcZQQhv8FbySzw6HUMwjs\/eF2bvaTvvN3rNmAjwQl4ZwaCEzlt7Gz9+5K\/nk8KvOnTqofR2ahpA5r383WhW80j6Zz\/LLtWwul\/eXvG9+\/nkVRjw51uv08+V1bGfOekobl57RoUwMb6AFMr\/\/BMyEtP8lM6cVAlY+QK2UwzQkQAL2CPi7Sm+vFqYmARKIBAL6vUnB3EhNweug0ddvlPO2A9xBzY26pvg60jDqOssOkYCDCFDwOmgw2BQSqGAC+uORvXll+9NECl5\/qAWQR\/+TjoQyvPX2XHVSk\/yUecvNPXDeuWep2FN\/XRUCaFrUZzX+RL95cxFGjxmvwgLkAbvj9hvcG9p8nTQY9aDYQRIIMwEK3jADZ3Uk4HACmnNHMON4KXjDPOi+Asq1pkhc1\/z\/fKE2MvEKHgFfGw70tYg\/qpzPvXzFr8GrnCWRAAl4JUDBy8lBAiSgJ6C36lv81fd47vlXAwZEwRswQvsFyCY52ZAhp\/XIxiTN9F9WfPPzN+PDjxYge+ES+wUzhykBbSOY7IYXCzjZoCOXr81gpoUyAQmQQEAEKHgDwsfMJBCVBIY+fBfO6dAGhZu2lDn919\/OUvD6S475SIAESIAESIAESIAEIoIABW9EDBMbSQIkQAIkQAIkQAIk4C8BCl5\/yTEfCZAACQRIYMCOAty\/\/Q+vpbxQ70RMqttE3TdLe2dKSyyomRxgi5idBEiABKKTAAVvdI4re0UCJBABBMxErHRBE71W0s5LrI8HG50cAT1nE0mABEggvAQoeMPLm7WRAAmQgJuAJmKXJiShf0pL7KtU2X3vX5vX4sySbTg3Lg4Fcn67HAENwFva7iXbVBqu9HKCkQAJkEB5AhS8nBUkQAIkUEEEfAneLnt3okHhbxipa9sT\/y94L\/UgjmscO4pXC39D+\/3F4CpvBQ0mqyUBEnA0AQpeRw8PG0cCJBDNBLwJXhGwIwpW4aoDe1T3B999H8a9\/KL6+wfxtTCiySllVoPl37Wy8quegJ4nZqKoSrVoRse+kQAJkIAtAhS8tnAxMQmQAAkEj4CvuNzOABYB6HnmPzHyqxW49fTm+DZvAy6vUg0Faf8oJ3hlRXhi4W+g4A3e+LAkEiCB6CFAwRs9Y8mekAAJRBgBb4JXhK4I3iYNG+GtBUuQcmIzJL8wBvVHPqp6eFKTVoirUadMbyl4I2zw2VwSIIGwEqDgDStuVkYCJEACfxPwFNJw5PCf2LplLQ7sL8HdQ5\/AoKEjVAYRvC+PfFTF9NaMT0TDEzPLoGRIA2cWCZAACXgnQMHL2UECJEACFUTAk+AtKS5C0ZZ1qFK1Opo1b+1umZa2cVwlbD5+DK6G6UhMcrnvi6uDODVw01oFDSarJQEScDQBCl5HDw8bRwIkEM0EjIK3+OgRFOTnQFZ5n+nbDyc3TnV3P+Pbr3Dqoi8wvm59DN5RakGWntFB\/akPjaAtWTTPGPaNBEjAXwIUvP6SYz4SIAESCJCAUfDm79yEnTvy0enUTCx88smypc+ZA8yYrv5N29DWB8BUXSqu7gY4IMxOAiQQtQQoeKN2aNkxEiABpxPQC96+rjSszvsJzVwuTL17EDpllo3RhU7wapvapH8LAfyjchXc2uQU\/HJCTad3me0jARIggQrrr\/oQAAAgAElEQVQhQMFbIdhZKQmQAAmUJVCYn6M2qvXpnIWpgwaZ4uk7fjymLcxGfEIiUlIN4tg0NxOQAAmQQGwRoOCNrfFmb0mABBxI4MD+YhTmr1SruwtHPan+tHLF9bhKJUtJPRXxCUlWsjANCZAACcQkAQremBx2dpoESMApBPQ2ZE9cfz1GXN\/TctNkhVdWeo2ODpYLYEISIAESiBECFLwxMtDsJgmQgDMJaDZksqq7YdKrthvZ+fHHsWhlTjmbMtsFMQMJkAAJRDEBCt4oHlx2jQRIwNkEZHU37\/cVqpE9zr8Uc+7pZ7vBi3Jy0Hn44yqf+PbKai8vEiABEiCBsgQoeDkjSIAESKCCCGzdsg57iovQNKkJqjY8EdPv6In2zf\/23rXaLG2Vt1aSCw0aplvNxnQkQAIkEDMEKHhjZqjZURIgAScR0FZ3GyfUw1Nt+mH+3jXYVW0fFj1kf5U3r6gIaQP6q+5xA5uTRpltIQEScAoBCl6njATbQQIkEFMENBuy7k3Pxeg2\/VB0aA\/6rZmOQRd0wOAu59hmQZsy28iYgQRIIIYIUPDG0GCzqyRAAs4goG1Uk9Xd\/176krtRM4uWYWbRcrXKm1LHvs2YrPLKai9XeZ0xzmwFCZCAcwhQ8DpnLNgSEiCBGCAgoQwF+TmQP2VlV1Z49Ve\/3OnoeHpTPHvNpbZp0KbMNjJmIAESiBECFLwxMtDsJgmQgDMIeFvd1VqXvSsX4wqzA97Allw3Fcn17G+AcwYltoIESIAEgkuAgje4PFkaCZAACXgloLchm3reo2hbv5XHtMM2zEeNBpWV6LV70abMLjGmJwESiAUCFLyxMMrsIwmQgCMIaDZk2kY1b43K2bcJInppU+aIYWMjSIAEooAABW8UDCK7QAIk4HwCehuyqec\/hpSEej4bLYJXhO\/aMQ\/a7hxtymwjYwYSIIEoJ0DBG+UDzO6RAAk4g4DRhsysVYHalI2YNRMjZ81CfEIiUlIzzarjfRIgARKIagIUvFE9vOwcCZCAEwiYbVTz1sZg2ZS5GqYjMcnlBBRsAwmQAAlUCAEK3grBzkpJgARihYCZDZkZh2DYlEkd6RkdzKrifRIgARKIWgIUvFE7tOwYCZCAEwjs3J6PnTvyYTxkwmrbnGxT1qO4CCmH\/7TaFaaLcgJzk1worFo9ynvJ7kUqAQreSB05tpsESMDxBKzakJl1xKk2ZYt+X0HBazZ4MXS\/U\/PWFLwxNN6R1lUK3kgbMbaXBEggYgjY3ajmrWOaTZmcvtajtf0NaH3Hj4ecwhbsDWwieOvVb4jcqZ9GzJiwocEnUHfedKRMfBoUvMFnyxKDR4CCN3gsWRIJkAAJuAkc2F+MwvyVKpTBig2ZGbpxBdnI3p1balP2ww\/AM2PMsgCPDAXatVPp4npcpf5cCGBWSkssqJlsnt8khSZ4f\/l8VcBlsYDIJdD4lacoeCN3+GKm5RS8MTPU7CgJkEC4CEgow9Yta3FgfwnuanUV7jqlR1Cq7p4zUa3wPntiXduCd8R992JkXh46AWhJwRuU8WAhpQQoeDkTIoEABW8kjBLbSAIkEFEE\/LUhM+uk1w1s\/\/43sHgRcH4n4J57yhazcyfw2KPA1q1IA5AHoHOdRsh3yf8FdnGFNzB+0ZKbgjdaRjK6+0HBG93jy96RAAmEmUCwNqp5a7bHDWzeBO+6dcCokcDevUCDBlhUUoLOBw6oooNhU+aP4F288CM8OPh6r6Ny2ZU3YMTTrwVt1Pbv24v7B1+LBg1S3OVKGxZ+MS+o9QStwRFYEAVvBA5aDDaZgjcGB51dJgESCB2BrVvWYU9xEdrWb4Wp5z0a9Iq0DWzT7+iJ9s1TS8v3JXhfeB64\/4HSdKNGovPevVgEoFaSCw0apgfUvkAE77\/GzcL5na8IqH4rmY2C15MAtlIO03gnQMHL2REJBCh4I2GU2EYSIIGIIKCt7spGtafa9FOiNxSXrPLuqrYPix7q51vw6iv\/a7V30d696PzXv6eknor4hCS\/m0jB6ze6qMpIwRtVwxm1naHgjdqhZcdIgATCTSBYNmRm7S46tAf91kzHoAs6YHCXc7yv8HoQvBLe0Pe00zDt118DtikLteDdVrQZ\/ftchIL839090Yc8aPe7Xd0HvW+7353mzddfwNtTX8K4SfPRLC3DHdIwcMiTZcpLTKqj0pyS2doMOe\/7IEDBy+kRCQQoeCNhlNhGEiABxxPQ25D999KXQt5ezaZMVnlT3prmfdOa1hJ9PO8jQxH3l61ZIKu8oRS8nsTsqpwVGDygG27ue68SuHYFr8QGM6Qh+FOTgjf4TFli8AlQ8AafKUskARKIMQJ6G7LRbfqhe9Nzw0LAbVNWuMa24J22by\/kQIoqVaujWXP\/VjgDEbyeAOlXb2WVdv6caXh12n9R39XInXzEo7dj69ZCvDDufezbt0et2Fpd4aXgDc20pOANDVeWGlwCFLzB5cnSSIAEYpBAqGzIzFBqNmXf1TiMej8u82xL5mWFVw6k6Pz441i0MgfJdVORXO+vDXBmleruByJ47Wxa01Z2S4p3qdpbtzuPgtfGOIU6KQVvqAmz\/GAQoOANBkWWQQIkELMEQm1DZgZWNrDdv2UZOm7aaFvwLsrJQefhj6sqZJVXVnvtXKEUvMb4XW31lyu8dkYoPGkpeMPDmbUERoCCNzB+zE0CJBDjBEJtQ2aGV2zKqi95Ht1LttkWvFK2tsrrj01ZKAWvCNtfflrKkAazCeCA+xS8DhgENsGUAAWvKSImIAESIAHPBMJlQ2bGv5xNmVkG3f28oiKkDeiv\/sXuBrZQCV5tY5m0SWJ1E2rUVO3TVn0bNGriM6RBxPI3X31WzqWBMbw2JoaNpBS8NmAxaYURoOCtMPSsmARIINIJhMuGzIxTOZsyswyG+yNmzcTIWbNs25SFSvBK8\/SiVbMNk3\/75MN33TG8IoSNK8HaSW6a5Zjelkw7wU0fFqGJaZvImFxHgIKX0yESCFDwRsIosY0kQAKOI1BRG9W8gZhZtAwzi5arwyhS6tg\/TEJWeWW1184qbygFryZ6ReBq18Aho9RfNY9dEcLaavCKH75S92RDW9ereuOFZx7wuMIrafTHG9vZPOe4SeiQBlHwOmQg2AyfBCh4OUFIgARIwCYBCWUoyM+B\/OlqmI7sc56wWUJokvfLnY6OpzfFs9dcaruCaRuy0bdkPDCiNGuVwupI\/MCF5Je9uzf4I3htN4wZHE+AgtfxQ8QGAqDg5TQgARIgAZsEtNVdNG6C9FonIqt2BgY3ybJZSvCTazZl0+\/oifbNrduM5SUUofO5j0P+NF4ifJtd4Nmnl4I3+GMYiSVS8EbiqMVemyl4Y2\/M2WMSIIEACOhtyDBlJpLzCpE8ew5Gp3VDZo3GAZQcnKyyga1Gg8oQ0Wv1GtHy\/2N4W80qTf75xcDMnkDPmcDFn6t\/klVeTyu9FLxWCUd3Ogre6B7faOkdBW+0jCT7QQIkEBYCmg0Zul4DjHxe1dls0D04c39VJXor+hKbMhG9EtbQo3WmpeakXdy\/dHVXxO4ln\/2d57NL3KI3vWWHcmVR8FrCG\/WJKHijfoijooMUvFExjOwECZBAOAgc2F+MwvyVkFAGWd1VfwKIX7UKKaNGO2aVd1xBNrJ352LtmActYYm76qrSdH2nAtP6\/J2nzzRgat9SUX9BaxXXq78oeC3hjfpEFLxRP8RR0UEK3qgYRnaCBEgg1AQklGHrlrU4sL8E+tVdrd6UUU+i6doCTM7oFeqmWCq\/e85EtcJrZQOb2QqvtzheCl5LQxH1iSh4o36Io6KDFLxRMYzsBAmQQKgJ6Deq4eNvylVXZds2FdowOCULWXUyQt0c0\/Lt2JSZxfDW+sCFBkPTy9VJwWs6DDGRgII3JoY54jtJwRvxQ8gOkAAJhJqA3oZMxe1K\/K6HyzVxEhIXf4V5mXeGukmWyhebsrTU2pY2sIlLw6J6OeXLzQPSLykfvysJAxG82qlp9zw4Bud3vkLV++brL2DC2OHuNojvbu\/b7nf\/v5anIP\/3Mu1sktq83BHEWoJVOSsweEA3lBTv8sjssitvgHYghSWoukTS3u+XLChzGpynMiTd\/DnTvLZRn0c7XEP7N399go3+xL4Y6es38jLykb5sWL+6DDMKXrszh+krggAFb0VQZ50kQAIRRWDn9nzs3JEPtDmrNHbXx5Xe80bH2JRpG9is2pTpV3qb7XcB04C8gUVIrvv\/Lg31ytucBSJ4RdjJpYlNEVL6AyU04XVz33vdolf7t8efnOQWyf5OJE8nudkpSzu8Qg660B9\/bCxDa3NiYh1Twevt1Dij8DdrpyZ2GzRIcfM1lu2pDCNf7QvG6We2d5ejlX1Why7ucaHgNRsR3ncCAQpeJ4wC20ACJOBYAm4bMtmgJqu7Inp9XLUWf4UGEyc5ZgObODbsqrZPncBm91qUk4POwx9X2Zo1b40qVYOzaU3E4r\/\/NdQtAD0JKyWGH70dv\/y01J3OmM9uf7T0mlj1d\/VUvwrrS\/DqV1nNVli9iXl\/jkE2fnmQfmuMu13dp8yqucZEa6v8v17AC6snHx+gTq3Tjng2jgMFr78zkfnCSYCCN5y0WRcJkEDEESjMz\/G6Uc1bZ2QDW9uNxY6wKSs6tAf91ky3ZVOm71ff8eMxbWE24hMSkZJa1ubMnxVeT6uPVgWv1RACX5PMm7CzOjH1K8PvvTMRW7cWel3h1dp72untsODzuaYrvJ7a4I\/g9ZbHV1neBLGnfzeu8lLwWp09TFeRBCh4K5I+6yYBEnA0AW82ZGaNjnSbMmP\/4nqU2palpJ6K+IQk921\/BK+3lUxvIQ0dz7tE\/Zyuiawtm\/KxZ89ud0yuWUiBsS+Bru7qy\/MlIPUro8uWLrIcw6svX4tptrMS7ekLhVamr7AGb+Pi7cuIPi75jNlvIGXi0+jUvDUKDb8CmD0rvE8C4SJAwRsu0qyHBEggogiUsSHrPwQYMMRW+yPZpszY0RGz\/v8ktlmzVEiDhDZolz+C19NP5Fp5xg1TeqGnCa8GjZq4V1Q1cbd1c4Gl1dNAV3fLcXn0do8rvMZVUTub1qQOTZTL3+1uqvMleH21w5vg9Vaefhy7fPUZBa+tTwcmrggCFLwVQZ11kgAJOJ6AmQ2ZWQc0m7Kerjbo6Wprljzk97N35WJcYbZybGjfvPwGNLMGpA3oj7yiIrgapiMxyaWS+yN4PYkuT8LVk8D11EZPm9u89cVOWjMect9q6IBdwavVbVfQS75wCV69QL5h9c8UvFYmDNNUKAEK3grFz8pJgAScSMC9UU0aJ64MJhvVvPUhefYcyH+TW\/SCq1qtCu+qbGCr0aCyJZsyY2P1G9jSM0ptyvwRvJ5+VvcWZmDFlcHbT+6eYHvazBXIoHgSvJ5WsP0VvNI2uyI9XCENFLyBzBzmrQgCFLwVQZ11kgAJOJrA1i3rsKe4yJINmVlH5DCKiw4nY3CTLLOkIb9v16bM2KDOjz+ORStzUCvJhQYN0\/0SvJ7En7cwBzNnAWmfVcEb7HAGqduT4DX66BoZ2rUYsyt4vbXL17\/rORpdHLyNAQVvyB9XVhBkAhS8QQbK4kiABCKbgF0bMrPeRpNNmYQ0SGiDXLKBbemWdahXvyF++XyVGQb3fW82Vw8Ovh7GzVl6UVW\/fiN1gITel1cKtbIK7EvQWW64h4RWHRSsrPB6E\/3+bLLzVJ\/ZlwcrsbqaLZmgYAxvIDOHeSuCAAVvRVBnnSRAAo4l4I8NmVlnnGhTNuiCDhjc5Ryzppe7r7cpW3v4T9uC15NAtRrDazwswmqcrx1hbAdIMAWvpxVojdXJGaeZnuamb7cnLlYOntDEtbYK7Wv1nC4NdmYK0zqBAAWvE0aBbSABEnAEgTI2ZB9\/E7Q2aTZlg1OykFUnI2jl+lvQzKJlmFm0XB1GkVLnb5sxq+VpNmUbADRq3NTWCq\/UYTxlTavXGA7gyaHAePywMY23EACzldJghg4YOXpacfUWT2xkYAyBsBqHbHa0sDcxa3a0sPSNPrxWnxSmcxIBCl4njQbbQgIkUGEEytiQyYlqXa8JaltcEychcfFXmJd5Z1DL9bewfrnT0fH0pupACruXHEQhK73+Cl5f1mR22xLM9NKuvN9zPZ5EFsx6Ai3rX0\/fh8u73uQ++SzQ8uzm50lrdokxvRMIUPA6YRTYBhIggQonEKgNmZUOpPe8EdFiUyYb2KauzPFrhVdYeVvltcIxVGmkTZ0v7I7zO18RqioCLldWZocPvRWjxryB+q5GAZdntwDj6q7k50lrdikyfUUQoOCtCOqskwRIwFEEgmVDZtapaLMpazb8cb8Fr\/aT+j0PjnGEwJT2TBj7OB56bCwSatQ0G8oKu1\/Rq9ASUrFh\/Wp1+p12UfBW2HRgxTYIUPDagMWkJEAC0UkgmDZkZoTEpuzM\/VUxOq2bWdKQ39dsyiSsoUfrTPv1DeiPP6vE247htV8RcziZAAWvk0eHbdMIUPByLpAACcQ0gWDbkJnBdKJNmQjftWMeNGt6+ftiUVZURMFrn1xU5ag7bzpPWouqEY3OzlDwRue4slckQAIWCYTChsysaifZlElbu+dMhF82ZX8JXrP+8n5sEOjUvDUKq1aPjc6ylxFHgII34oaMDSYBEggWgXBsVPPU1miwKSvcVYylY54HqhRBOOZtBuITEhEfb9\/mLFjjyXIqlsD4eqkV2wDWTgI+CFDwcnqQAAnEJAEJZSjIz4H8iRDYkJlBdaJNWVpqbUy\/o6dZ09X9uSty8PDsTzF9WA5WrytB35FAlarV0ax5a0v5mYgESIAEwkmAgjectFkXCZCAYwjs3J6PnTvygcZNgCAeMmGng2JTllU7A4ObZNnJFpK02btyMa4wWwne9s19r9TJ6u5NU2ah\/Wlr8Wz\/dao9nfsDi1YAyXVTkcyVvpCMEQslARLwnwAFr\/\/smJMESCBCCYTLhswMjxM3sNVoUNl0lXfcgm8x95eFmPFYDlLq\/6m6KWJXRK9cssorq728SIAESMApBCh4nTISbAcJkEDYCLhtyOQ0NQlnqMDLSRvYrNiUyepup+cmY1CPfAy+Or8MOW2Vt1aSCw0aplcgVVZNAiRAAmUJUPByRpAACcQUgQP7i1GYv7I0lGHKzNI\/K\/DSNrCJL29mjcYV2JLSqscVZCN7d65Xm7JeU2aiYM86LBq7olxb8zYBaV1L\/zkl9VTEJ3ADW4UPKBtAAiSgCFDwciKQAAnEDAEJZdi6ZS0O7C8B+g8BBgxxRN9llbfp2gJMzujliPaITZkcRCEHUuivpb\/nQwSvxO32OK\/IY1tHTAZGTi51bEhJ9eMwC0cQYCNIgASijQAFb7SNKPtDAiTglUBF2ZCZDUmVbdsgJ7D1dLVBT1dbs+Qhv+9pA5uEMogrA6rnYPqwlT7bkHYllE2Zq2E6EpNcIW8vKyABEiABMwIUvGaEeJ8ESCAqCFS0DZkZxOTZcyD\/TW7RC65qtcySh\/z+sA3zod\/Aprcha9+qxGf90z6EsimTKz2jQ8jbygpIgARIwIwABa8ZId4nARKICgJuG7I2Z5XG7jrwklXeiw4nO8KmTNvAJjZlTeoklrMhM8PHDWxmhHifBEggnAQoeMNJm3WRAAlUCAG3DZlsUBNXBhG9DrycaFO2q9o+9PjnqeVsyMzw6W3KuIHNjBbvkwAJhJoABW+oCbN8EiCBCidQmJ9TulHNATZkZjCcZFNWdGgP+q2ZrprsyYbMrC99RwDTPuIGNjNOvE8CJBB6AhS8oWfMGkiABCqQgNNsyMxQOM2mbGbRMswsWq5syLRDJsz6oL8f16b0\/7jKa4ca05IACQSbAAVvsImyPBIgAccQcKoNmRkgp9mU9cudjo5nr3cfI2zWfv19bQObnLwmJ7DxIgESIIGKIEDBWxHUWScJkEBYCDjVhsys8461KRuWAzOHBk990zaw0abMbOR5nwRIIFQEKHhDRZblkgAJVCgB90Y1aYW4Mjh0o5o3SI60KTtxtakHr6f+6Dew0aasQh8LVk4CMUuAgjdmh54dJ4HoJrB1yzrsKS4qFboOtSEzGwFH2pQFuMpbK8mFBg3TzbrO+yRAAiQQVAIUvEHFycJIgAScQCBSbMjMWDnSpixhg9rAZvfK2wSkdS3NxQ1sdukxPQmQQKAEKHgDJcj8JEACjiMQSTZkZvCcaFPmj0WZ9JM2ZWajzfskQAKhIkDBGyqyLJcESKBCCJSxIfv4mwppQzAr1WzKBqdkIatORjCL9qss2pT5hY2ZSIAEKpgABW8FDwCrJwESCB4BCWUoyM+B\/KlOVJODJqLgck2chMTFX2Fe5p2O6A1tyhwxDGwECZCADQIUvDZgMSkJkICzCUSqDZkVquk9b0RW7QwMbpJlJXlI02TvysW4wmxMD3ADW3LdVCTXSw1pW1k4CZAACQgBCl7OAxIggaggEOk2ZGaD4MQNbDWCYFMmh1HIoRS8SIAESCCUBCh4Q0mXZZMACYSNgNuGTMIYJJwhCi+xKTtzf1WMTutW4b3L2bcJwzbMV6ev9TivyHZ7tMMoaFNmGx0zkAAJ+EGAgtcPaMxCAiTgLAJlbMjEc7dxE2c1MEit0TawieDNrNE4SKX6X8y4gmxk787F2hlLbBdCmzLbyJiBBEggAAIUvAHAY1YSIAFnEIgmGzIzomJT1nRtASZn9DJLGpb73XMmqhVeWem1e42YDIycDMQnJCIlNdNudqYnARIgAcsEKHgto2JCEiABJxKI5o1qnnhX2bYNEtoQLTZlaVcCeZsBV8N0JCa5nDjF2CYSIIEoIEDBGwWDyC6QQKwSiFYbMrPx1GzKJrfoBVe1WmbJQ35fbMrS0gswfdhK23VN+xDoO7I0W3pGB9v5mYEESIAErBCg4LVCiWlIgAQcSWDn9nzs3JFfGrMbBYdM2IHsJJsybQMbbcrsjCDTkgAJhJMABW84abMuEiCBoBGIdhsyM1BOtCnblbABi8auMGt6ufuLVgDi2iAXbcps42MGEiABCwQoeC1AYhISIAHnEYiljWre6MsGtrYbi6PCpqzvCGDaRwBtypz3rLFFJBANBCh4o2EU2QcSiDECB\/YXozB\/ZWkoQxTbkJkNazTZlElf49qU9jgl9VTEJySZdZ\/3SYAESMAyAQpey6iYkARIwAkEJJRh65a1OLC\/BOg\/BBgwxAnNqrA20KaswtCzYhIggQgiQMEbQYPFppIACQCxZkNmNuaaTVlPVxv0dLU1Sx7y+9m7cjGuMBv+bmCjTVnIh4gVkEBMEqDgjclhZ6dJIDIJlLEhk1CGNmdFZkeC3Ork2XMg\/znFpkyOHK5x4mralAV5nFkcCZCA\/wQoeP1nx5wkQAJhJrB1yzrsKS4qFboieHm5CchhFBcdTsbgJlkVTiVYNmXcwFbhQ8kGkEDUEKDgjZqhZEdIILoJuG3IZKPayOe5umsY7mi1KeMGtuh+rtk7EggXAQrecJFmPSRAAgERoA2ZOT4n2ZQVHdqDfmumY1CPfAy+Ot+88YYUmk1ZfEIiUlIzbednBhIgARLQE6Dg5XwgARJwPAHakFkbIs2mbHBKFrLqZFjLFMJUM4uWYWbRcnUYRUr9P23XRJsy28iYgQRIwAsBCl5ODRIgAUcTKGNDJqEMXa9xdHsrunGuiZOQuPgrzMu8s6KbourvlzsdHc9ej2f7r7PdnmkfAn1HAlWqVlcnsPEiARIgAX8JUPD6S475SIAEwkKANmT2Maf3vBHRYlMmRw7L0cOuhulITHLZh8EcJEACJCAH26RndDhOEiRAAiTgRALujWrSONqQWR6iaLIpE7ErolcuWeWV1V5eJEACJGCXAAWvXWJMTwIkEDYCtCHzH7XYlJ25vypGp3Xzv5Ag5aRNWZBAshgSIAG\/CVDw+o2OGUmABEJJgDZkgdHVNrCJ4M2s0TiwwoKQWw6j2JWwQW1gs3vlbQLSupbmok2ZXXpMTwIkIAQoeDkPSIAEHEmANmSBD4vYlDVdW4DJGb0CLyzAEmhTFiBAZicBEgiIAAVvQPiYmQRIIBQEuFEtOFSjzaYs7UogbzNXeYMzO1gKCcQWAQre2Bpv9pYEHE9AQhkK8nMgf6oT1WhDFtCY0aYsIHzMTAIkECUEKHijZCDZDRKIFgJc3Q3+SIpNWVbtDAxukhX8wm2WmL0rF+MKszF9WA7atyqxmbvUsUGcG5LrpiK5Xqrt\/MxAAiQQmwQoeGNz3NlrEnAkAdqQhWZYai3+Cg0mTlKODU7ZwFbjxNWYPmyl7Q7Tpsw2MmYgARLgpjXOARIgAScRcNuQSRiDhDPwChoB2cDWdmOxo2zK5PS1HucV2e6jtspbK8mFBg3TbednBhIggdgjwBXe2Btz9pgEHEngwP5iFOavBBo3KT1kQv7kFTQCTrMpG1eQjezduVg7Y4ntPtKmzDYyZiCBmCdAwRvzU4AASMAZBGhDFvpxcJJNmfS2e85EtcIrK71YDOB+CwxeAHAKMOI6YOQeoBOAhQBeqHciJtXllyQLBJmEBGKSAAVvTA47O00CziLAjWrhGY8q27ZBTmDr6WqDnq624anURy0zi5ZhZtFydRhFyqo\/rQneIQDeAFACpAHIAzD1\/\/\/sQ9Fb4ePJBpCAkwlQ8Dp5dNg2EogBArQhC+8gazZlk1v0gqtarfBW7qG2frnTkZZeUH4D23AAnwC4DMAoXUZRtxPkyDVg2vVA3xdL7x0HkF\/1BPQ8MRNFVapVeL\/YABIgAWcRoOB11niwNSQQcwR2bs\/Hzh35QJuzSmN3eYWMgLbCKxU4xaYsZ98myLHD5WzKPAne\/QDuBSCnE\/8lhLUNbE\/IrcpVcGuTU\/DLCTVDxpAFkwAJRCYBCt7IHDe2mgSiggBtyMI7jGp1d8lPiHO1w\/HCBY6yKduVsEGFNrgvbyu8BmR6m7IlVarjgaancYU3vNOKtZFARBCg4I2IYWIjSc7bVYcAACAASURBVCA6CXCjWvjGVVvdjUvpgrjarXAsby4ycdy5NmUWBS9WAX1vA6YdBk6qWh1xzVuHDyprIgESiBgCFLwRM1RsKAlEFwHakIV3PMWhIX5tISq16K0qPr6vEMfz5mJwShay6mSEtzEeaitnU2ZF8K4CcHfpBra4v8pMST0V8QlJFd4fNoAESMBZBCh4nTUebA0JxAQBCWXYumUtDuwvAfoPAQbI1nteoSKgnbQW16wH4mqkuKuRVV7sK8S8zDtDVbWtcsvYlJkJXr2N2f93aUQnYOQMID4hESmpmbbqZWISIIHoJ0DBG\/1jzB6SgOMI0IYsfEMioQxNRo1Glf3VUKlZj7IVHy7BsTVvOsamLHtXLsYVZpduYHu3xLNLg\/RAL3YlguElAAlA2pVA3mbA1TAdiUmu8EFmTSRAAo4nQMHr+CFiA0kgughwo1p4x1Ot7r72DiqlXQVUTSxX+fGipTi+7Qc4xaZMHBtqnLga0w+t9Cx4dWEM0Ild6Zh+A1t6RofwgmZtJEACjiZAwevo4WHjSCD6CGzdsg57iotoQxaGoXVvVKvdCrJZzdslq7xZNRphcJOsMLTKdxWaTdl39Zah3reHy\/vwaqEOnopJBDo3Bhb9BtRKcqFBw\/QK7w8bQAIk4AwCFLzOGAe2ggRigoB7dbdxE2Dk86Wil1fICGg2ZNpGNW8VHd+92nE2ZXfmZ+OibTvLCt5tAG4HUOilJ4nAooFA5zGl97mBLWRTiwWTQMQRoOCNuCFjg0kgcgnQhix8Y2e0ITOr2Uk2ZUWH9qDfmukY1CMfg6\/ON2t6uft9RwDTPuIGNtvgmIEEopgABW8UDy67RgJOIlDGhuzjb5zUtKhsi9GGzKyTTrMpm1m0DDOLlqvDKFLq\/2nW\/HL349pwldc2NGYggSgmQMEbxYPLrpGAUwiUsSGTUIau1zilaVHZDm82ZGadldPXJLzBKTZl\/XKno+PZ6\/Fs\/3VmTS93f9qHQN+RQJWq1dGMh1HY5scMJBBtBCh4o21E2R8ScCAB2pCFb1A0G7Kqh+v53KjmrUXHVo5HVu0MR2xgK2NT1qrENsTO\/UudG5LrpiK5Xqrt\/MxAAiQQPQQoeKNnLNkTEggagVq1auK6ay7Hlwu\/RV5eQUDl0oYsIHy2MyfPnoPk+V94tSEzK9CJG9iUTdmwlWZNL3dfb1Mmq7yy2suLBEggNglQ8MbmuLPXJOCTwPXXXYkbe3bF0aPHsODLbzD1zfdx4MBBv6jRhswvbH5lcm9Uq98Oca72fpUhmZy0gU2zKVOHUQSwykubMr+nAzOSQFQQoOCNimFkJ0gguATOO7cdBg3sg4SEeFXwjh278MH8z\/GfDxfgogvPxerf1lla+aUNWXDHxaw0uxvVvJWnbWAbndYNmTUam1Ub8vtyGMWuhA1qA5vdK28TkNa1NBdtyuzSY3oSiB4CFLzRM5bsCQmYEuh65YVo2KAe3p7xgc8V28qVK+PpJx9ERkZz7N23H7WTSk\/oKtq2A4mJNVG8uwQjn\/w3\/sjf5LNO2pCZDknQEsSvWoWUUaMR16wH4mqkBFyurPK6DpVgckavgMsKtIBAbcpGTAZGTqZNWaDjwPwkEMkEKHgjefTYdhKwQeDE1MYYPuweNGrkUiu2b02fq8IVvF0XdumI\/v1uwsqVa5C75ndcefkFSEyspZL\/9PMq\/Hv8Gygq2uE1Pzeq2RicAJNKKEODiZMQv7EElZr1CLC0v7IfLoGcwNbT1QY9XW2DU2YApQRqU5Z2JZC3mau8AQwBs5JARBOg4I3o4WPjScA6gX633wBZ4Y2Li1OZjh07hnXrN+Kdd+dj2fKfyxUkq7xjnnoIzZo2wdhxb6Bp0xRcf+0VqFq1qkq7Y+cuPPPcRKxatbZcXgllKMjPgfypTlSjDZn1gfIjpbIhe+0d5coQjNVdrQmaTdnkFr3gqlb6ZaciL9qUVSR91k0CkU2Agjeyx4+tJwHLBOLjT0Df3teiywUdUb16NXe+w4cPY9nyXzDl9XfLrdh2vaIL+va5Dr\/8uhoNXPXQoEF9vD\/nY5x5xinYtasYY559xWP9XN21PCwBJ3RvVKvdyi8bMrMGyCpvVo1GtCkzA8X7JEACjiZAwevo4WHjSCD4BFyuurjjthvQts3p7tVaqaWkZA8+\/PhLzHrvIxw9elRVLPZkI5+4Fxktmqv\/X\/Hjryp2V7vvqXW0IQv+mPkq0TVxEhKX\/OS3DZlZa2lTZkaI90mABCKBAAVvJIwS20gCISDQvt2ZuGvAzahXL7lM6cb43qu6XYxbbr4aBw4cwL\/HT8XSH37y2Rq3DZmEMUg4A6+QEXCv7kooQ+1WIavHiTZlcvpaj\/OKbPdZO4yCNmW20TEDCUQ0AQreiB4+Np4E\/CdwVfeLcUuvq1GtWlVIWIMWmyslSnyvWI+9MultZT8mIQwijH1tcpN8B\/YXozB\/JdC4CTBlZumfvEJGIFg2ZGYNdJpN2biCbGTvzsXaGUvMml7uPm3KbCNjBhKICgIUvFExjOwECXgm0LhRA+zaXVzOgkzCGkY9cR9SUxurUIYJE9\/C6ae1Khffu2\/ffrz8ypv46usfTBFLKMPWLWtxYH8J0H8IMGCIaR4m8J9AsG3IzFriJJsyaWv3nIlqhVdWeu1etCmzS4zpSSDyCVDwRv4Ysgck4JHASSc1xaOPDETVKlXKWZAN6HcTLrs0C5UqxWHhou\/wwktTVBnNmjVRYQ6tWqajUqVKyo7siZEvYc+evaaUuVHNFFHQEoTEhsysdVFqU+ZqmI7EJJdZ73mfBEggwglQ8Eb4ALL5JOCNwP333oHOnc5WNmQSopC3sQBvvT0XBw8exCMP3YXatROxZes2PP3MBKxfv7FMMR3Obo2re1yKTz7JxpcLzX82pg1ZeOdhqGzIzHpxvGgpjm\/7AU6yKUtLL8D0YSvNml7u\/rQPgb4jS\/85PaOD7fzMQAIkEFkEKHgja7zYWhKwREA8dO+4rScuyDrHfTywZJRY3eLiPSoe98iRI5g95xN16lqg187t+di5Ix9oc1Zp7C6vkBEItQ2ZWcOdZFOWs28T5Njh6cNy0L5ViVnTy93nBjbbyJiBBCKWAAVvxA4dG04C5gS8WZBJzvz8TRj2xAvYvn2neUE+UrhtyGSDmrgyiOjlFTICbhuyFr1DVoevgp1oU7YrYQMWjV1hm8eiFYCIXrmaNW+NKlWr2y7DTgYJGRLXk8aNG6gDW2a+96HPI77tlM20JEACvglQ8HKGkEAMEGjb5gzc2uc6pKY2cp+0Jt22csSwGZ7C\/JzSjWq0ITNDFfD9cNmQmTU0mmzK+o4Apn0ExCckIiU106zrft2XQ18GDeyDDmf\/0+2Gcvz4caxavRZPPjXeUoy8XxUzEwmQgJsABS8nAwnECAEJc+h6ZRe1wlS3bh13r40WZHZw0IbMDq3A04bLhsyspZpN2eCULGTVyTBLHvL7gdiUSePi2pQ2MSX1VMQnJAW1vfLcPfLQnTj7rH+qL5sSUrR8xS9IT2+GRg3rY\/qMeZjzwadBrZOFkQAJlCdAwctZQQJRREB+Mr391p5o2fIkxJ9wgrIcm\/jq9DK2Yt6OGP7zz0P4fumPeHXKO+qlbHbRhsyMUHDvq41qEychrlkPxNVICW7hfpR2vHABJLxhXuadfuQOfpZAbMq0DWwS0iChDcG8Tj+tJYY+fJeKpV+0+HtMmjxDhTEMvrsPLr7ofHyZ\/S1eHPtaMKtkWSRAAh4IUPByWpBAlBC4oHMH3H5bTyQm1nL3aMuWInUU8B\/5m8r1UsTxnf1vRsuM5qhSpYq6n5OTi0cf\/5fPo4O1gmhDFr6JI6EMTUaNRtXD9RCX0iV8FZvUdGzleGTVzsDgJlkV3qbsXbkYV5jt9wa2tCuBvM1AsG3K5NCWoQ8PRFHRdgy5fxTq1q3tPtq7UqXKmPXeh5jx7rwK58cGkEC0E6DgjfYRZv9igkDLjJOU564WqiBhCocPH1ExgsOG+z7eV4vvlRexnUMm8n7\/a5OQuDJwo1pI51ny7DlInv8FKqVdBVRNDGlddgp34ga2Gieu9sumTL+BLZg2ZbVq1cSY0Q8hJaUhCgo3o2GD+m7nlNzc3zFy9FhLv6jYGRemJQESKE+AgpezggSigMBjQ++GeOfKRpiVK9dg\/CtvoqBgs8eenXnmqZDV4NfemOl+0UqcYUZGc7Vz3Mq1dcs67Ckuog2ZFVgBpqloGzKz5otNWWa1mhid1s0sacjvO9WmTOJ3Bw3sjaSk0i8r8mV06Q\/\/U0d3WwkfCjk4VkACMUCAgjcGBpldjG4Cp5xyMh575G51kIRYjQ0f+SKKinZ47PR557ZD\/ztuQlJSLXy7ZDnGPPuKbTi0IbONLKAMFW1DZtZ4bQObCN7MGo3Nkof8vvjy+mtTlrcJSOta2sRgb2Br0qQROp3XHoePHMXChUtQtM3zMxpyQKyABGKUAAVvjA48ux09BLpe0QV9+1yHatWq4pNPszFh4tteOyebZ87p0EbtFt+3bz\/GjnsDS76z519KG7LwzZ34VauQMmq0ituNq90qfBXbrElsylyHSjA5o5fNnMFPXnRoD\/qtmY5BPfIx+Op82xWEw6ZMGiW\/qrQ4OQ3Vq1dTbZTV34YN6+Ozzxdx1df2qDEDCZgToOA1Z8QUJOBoAn17X4trrr5MtVFOTpv65vte2ysruyOG36tetBL+8P7sj\/Hm23Ms96+MDdnH31jOx4T2CUgog7gyxG8sQaVmPewXEM4ch0sgoQ1OsSmbWbQMM4uWq8MoUur\/aZuEPzZlcsjLpRd3Qv36yWjcqGFpnXFAvXp1cEL10gMtKlWupNxTvF3BPP3QdqeZgQSinAAFb5QPMLsX\/QT0K7z\/+2klnhj5kk+XhX6334BuXS+yJJD19MrYkMmJanLQBK+QEXCaDZlZRzWbssktesFV7W+nELN8obrfL3c6Op69Hs\/2X2e7Cn9symTF9uknH0RmpndfYjna+9Chw6o9B\/\/8E9u37wKOA0ePHcWmTVvVry7btu\/EB\/M+t91mZiABEvBNgIKXM4QEIpyAPoZXVog++vhLTHl9ptdeaYLX7govbcjCN1GcakNmRiCabMrkyGFxbkium4rkeqlmXVf3ZePnWe3\/iTVrfncfGSxClvG6lvAxEQmElAAFb0jxsnASCA8BzaVBapNVpCXf\/YjxE6a5X7paKySkYfSoB9A87UTs3bsfz\/5rIn78X45pI90b1SQlbchMeQWawKk2ZGb9ilabMjmMQg6l8PeS1d9zO7ZVoUS7dpeoL6Vy+AQvEiCB8BGg4A0fa9ZEAiEjcNJJTfHowwPVphftErsjOcVp9txP1CYYOWhi4J23oFXLdLVpTY43lfAHKxdtyKxQCk4atw1Z\/XaIc7UPTqFhLEU2sGXiOG3K\/mIudoG33Xo9GrjqqedOrt83\/IF\/Pf+qxwNhwjhUrIoEYooABW9MDTc7G80E5OfUewbdiqYnlj12VkIXJG5QXBy0F+6WLdvw9LMTsH79RlMktCEzRRTUBCmjnkT82kJUatE7qOWGqzDalP1N+tJLOuG2vtdDjvOWw2AKC7cgrlIcGjdqgE8\/W6R8eHmRAAmEhwAFb3g4sxYSCAsBebHe2b8XOp7T1m13ZKx427adePmVaVi+4ldLbaINmSVMQUnktiFr1gNxNcp+cQlKBWEqJJpsykZMBkZOBuITEpGSmmmZoIQxPP\/cYyqMQb5gTpo8A8uW\/6yezcF398GmzVsx5L5RlstjQhIggcAIUPAGxo+5ScCRBMTkvnu3i9C29emoUTNBtbGkZC++\/voHzHzvQ8vxg9yoFr7hjSgbMjMsf9mU9XS1QU9XW7PUIb8fqE1Z2pVA3mZ7h1GkNG6AUSPuR3x8dTz3\/Kv46edV6jTE\/nfciHr1kpGzcg0eHjom5H1nBSRAAqUEKHg5E0iABDwSkFCGgvwcyJ+gDVnIZ4myIXvtndJDJiJ4dVcDdbxoKY5v+wHRZFMmfUvP6GB5Lox84l6cecYp+O239eqLp4QbVapUSX3hfH3qLBXWwIsESCA8BCh4w8OZtZBAxBHYuT0fO3fkA42bADxkIqTj596oVruVErzRcslhFFk1GmFwk6wK71L2rlyMK8zG9GE5aN+qxHZ7\/LEpa9P6NAy55zbUqZ3krm\/Hjl14Y9p7WLT4e9ttYAYSIAH\/CVDw+s+OOUkgagnQhiy8Q+uaOAmJS36K2I1q3mjRpgyQ8KLLL8tCowb1seir7\/H1N8t8HgwT3pnH2kggdghQ8MbOWLOnJGCZADeqWUYVcEL36q6EMtRuFXB5TivAiTZlcvpaj\/OKbKPSVnlrJbnQoGG67fzMQAIkUHEEKHgrjj1rJgFHEjiwvxiF+StLQxnkkAn5k1fICES6DZkZGM2mbHBKFrLqeD9216ycYN0fV5CN7N25WDtjia0iC7dVx8OvpmPGvJUqX0rqqYhP+DtUwVZhTEwCJBB2AhS8YUfOCknAuQQklGHrlrU4sL8E6D8EGDDEuY2NgpZFiw2Z2VAcL1wACW+Yl3mnWdKw3O+eM1Gt8MpKr9Vr7lcuPPraySjZlY\/Nm\/+wbVNmtR6mIwESCA0BCt7QcGWpJBCRBGhDFr5hk1CGJqNGo8r+aqjUrEf4Kq6gmo6tHI9ItSmT1d2bnsrErr3xqJNUGUuXLsXBgwfhapiOxCRXBRFltSRAAnYIUPDaocW0JBDFBMrYkEkoQ5uzori3Fd+1aLMhMyPqRJuytPQCTB9WGqLg6xo3JxWvzD8R9ZMro3LlOGzZsgW5ubkqix2bMrN6eJ8ESCB0BCh4Q8eWJZOA3wTklKbHHxuM5St+wUcff+l3OXYyum3IROiK4OUVMgLRakNmBkxsyjKr1cTotG5mSUN+P2ffJgzbMN\/UpkxWdzsNaY1aNSshsWZld7t+\/vln7N69G9zAFvKhYgUkEBQCFLxBwchCSCC4BC6+6DzccfsN2L5tJ4aPfBFFRTuCW4GhNLcNmWxQk0MmuLobUt7RakNmBk3bwCaCN7NGY7PkIb8vgndXwgYsGrvCa129Rp+K5Wtqo2H9KmXSiNgV0StXKDawNWvWBDdc3xWZp2YgMbFm6YEVBw9izZoNeO\/9j9TJbbxIgASsE6Dgtc6KKUkgbASSkmrhiWFD0KJFGhYu+g4vvDSlTN3i7Tnort7IyGiOw4ePqJffjHfnIS+vwK820obML2x+ZYp2GzIzKGJT5jpUgskZvcyShvy+tsrrzaZs6epE9BqdiXrJVVC9Wly59khYg4Q3xCckIiU1MyjtlWf\/rgE3o327f6Bq1bIiW6vg0KHD+M+HX2Dqm+8HpU4WQgKxQICCNxZGmX2MSAIdzm6NQQN7o2rVqnh1yjv4YsHXqh8S7vD0kw8iM7OsxdO+ffvVC9DucaW0IQvv9Ih2GzIzmpFiU6bZkP20vrYSvN6uxYsXq1vBWOU96aSmuPee25DWLLVMdSJwDx8+jEqVKyH+hBPUPVntfevtuUr48iIBEjAnQMFrzogpSKDCCAzodxMuuzQLmzZtcYc2dDynLQbf3Qfr1m\/EhFfexFVXXYKsTh1QvXo1FBfvwYtjp2D5il8ttZk2ZJYwBS2R2qg2cRLimvVAXI2UoJUbaQVFgk2ZZkMmrgyeVnc15toGtipVq6NZ89Z+D4X2q478aqNdcgzxvP\/8V32JPXDgoPqye0PPruje7SIlfLdsKcLIJ\/+NP\/I3+V0vM5JArBCg4I2VkWY\/I5KAvARHDL8XJ6c3w2f\/XYyXJ7yJrld0Qd8+12Hnzt14+tkJWL9+owpteOj+AWjQoB7en\/0x3nx7jqX+0obMEqagJNJsyKoeroe4lC5BKTOSCxGbMqccRpG9KxfjCrPdG9iMNmRmnLUNbIHYlEkYw2WXdkZcXByOHDmCJd\/9iHEvT1VC13jdf+8d6NzpbBw7dhyz536Ctyw+72b94H0SiGYCFLzRPLrsW8QRaN\/uTLTMOAn\/+2klfvn1N9X+885th0ED+6i\/j58wDYWbtmL4Y4NRr14ySkr24JNPF2L23E9xz6C+OKv9PzDj3flK9Jpd7o1qkpA2ZGa4Ar6fPHsOkud\/gUppVwFVEwMuL5ILcFpYg7CUDWw1TlytbMqMNmRmrPUb2PyxKXPVr4tRI+9HapNGSuyKM8uU1707pWi\/8tSokYCclWvw8NAxZk3kfRKIeQIUvDE\/BQjACQTkp8pHHroTZ5\/1T7XCc\/z4cWzfvgvT3nofixZ\/j7sH9sYlF52PDXn5GDb8eUh8b9\/e10JeePpr8+YijBpt7SfOrVvWYU9xUakjA23IQjoN3BvV6rdDnKt9SOuKhMKdtHFN46XfwCZHCBttyMy4BmJTduYZp2DowwNRs2YC\/vhjEx557BkVnuTtatP6NDz0wAD1\/K9dtwFD7htl1jzeJ4GYJ0DBG\/NTgACcQODqqy5Fr5u6o7h4L44ePQKXq57bhkg2pny\/9EeMeuI+iDuDFtogtkW339pT2RZVqVIZW4u2Y+Kkty3F79KGLLyjHusb1fS05YhhieF1ijWZvm2yyivCVw6XMNqQmc0YOXlNTmCTy+4GNr3gXfLdCjw15mWf1WlfgOXLMVd4zUaG90mglAAFL2cCCTiAwGND70bbNmfgjWnvqV3XXS7oiFt69UDdunWQX7AZw594AWeccQr633GjWv2V0Iavvv7B75bThsxvdLYzxq9ahZRRo2N+o5oCd7gExzZ8gKwajTC4SZZtlqHOoMXyerMhM6vfX5uy009riaEP34XExFpYuWoNhj72HI4ePeqxupTGDdShNKmpjXH06DHG8JoNCu+TwF8EKHg5FUjAAQQknOHcju2wZes2THp1BpYt\/xmtWqarl6B4cY559hUV06ttVlm7Lg8jRr3k82dPb93iRrXwDbiEMogrQ\/zGElRq1iN8FTu0JjleuP7u1Wp111WtlqNaWXRoj9q4tvbwZp82ZGaN9semTEKann\/uMbQ4OQ379x8w\/UIr9mWPPjxQWZWF42Aasz7zPglEAgEK3kgYJbYx6glI7K547iYlJaqXWO6aDdixYyfatTsTWzZvw9Bhz2HPnr04MbUxhg+7R4U8fPJpNiZNnmGLjYQyFOTnQP5UJ6p1vcZWfia2R0DZkL32jnJliGUbMvfq7po30dPVBj1dbe2BDENqWd2dsGUhzGzIzJrir02ZFtZUrVo1iKf2gi+\/wQ\/Lfkbd5NrYvHUbVq1aW6ZqCW+SUCZ\/D5sx6wfvk0C0EaDgjbYRZX8iloBsROt3+42oXz\/Z3QexJHp96qwyh0lccfkF6NP7Ghw+dBjjJ7wJifmzenF11yqpwNPRhqwsQyduVNNaKKu7\/dZMR0J8JSV4A720DWzJdVORXK\/sIRLeyjZuXNWnky+3Eya+HWizmJ8EYpoABW9MDz877zQC8fEn4JKLz0eb1qcrQSum83JssPGSUIdzOrSBndAG2pCFd7RdEychcclPtCEDoNmQOXGjmsyKcQXZWLxnje2Nat5mlN6mTA6jkEMprFziu\/3g\/f1xxumt1KZV7eLGNCv0mIYEfBOg4OUMIYEIJKDF8O0\/cEDZlPmyMNK657YhkzAGCWfgFTICtCHToZWNaoULkInjKnbXaZe2uisru7LCG6wrEJsy8d6+IOscNGxYH3Ks8Jo1G\/DaGzM9HkIRrPayHBKIdgIUvNE+wuxf1BIQJ4fDh49g8Vffm\/axjA2ZeO42bmKahwn8J0Absr\/ZiQ1Z\/aKlypUhs0Zj\/6GGKKdYka0+uDloq7taMwOxKfPUVYnfr107ERv\/KLT0BTdEuFgsCUQsAQreiB06NpwErBOgDZl1VoGmpA2ZYXU3im3IzObKxo0bkZeXh\/iERKSkZpol93o\/q3MH3Nm\/FxIS4tUq71vT5yr7Ql4kQALWCVDwWmfFlCQQkQS4US18w0YbsrKsnW5DJqu7xXF7A7IhM5tdchiFrPa6GqYjMcllltzjfdnQJt67devWRkrjhjh48E+8OHaKpUNm\/KqQmUggCglQ8EbhoLJLJKARoA1ZeOcCbcgMq7sxYENmNsM0mzJJl57RwSy56f1+t9+AKy7vgkWLv8OLY1\/zml4OsjnllJMxfcYHXg+xMK2MCUggighQ8EbRYLIrJGAksHN7PnbuyC+N2f34GwIKIQH3RrXarZTvbqxfsWRDZjbWVm3KbryhG6647ALlr3vwzz\/xxx+bsHDhEiz5\/kf3hrUB\/W7CZZdmYekP\/\/N4BLEcOX5n\/5vRMqM5Dh85gmlvzsZHH39p1kTeJ4GoJ0DBG\/VDzA7GKgHakIV35N02ZC16h7diB9YWazZkZkNg1aasZcZJePSRgepIcf115MgRtVFNNqnWq1d6b\/acT\/D2jA\/cycTSsG\/va9Wx5NWrV3P\/+\/r1G\/Hwo8\/Q4cFskHg\/6glQ8Eb9ELODsUqAG9XCN\/Lu1V05Ua12q\/BV7MSaHG5DlrNvEyR2N9g2ZGZDkZubCwlvMNvApoUsFBVtV6ettW17Bpo2TUH8CSeoKuQkxm++XYaX\/v2GClWQ+N4LL+gIWR3WC+Vjx45h9W\/r8Mqkt3kam9ng8H5MEKDgjYlhZidjjcCB\/cUozF9ZGspAG7KQDz9tyP5GHKs2ZFYm2eLFi1WylNRTEZ+Q5DGLy1UXo564D40audTBM1Onva\/SebIlkzjdW\/tch9TURoiLi3OXt2PHLuXkIIKZFwmQQCkBCl7OBBKIMgISyrB1y1oc2F8C9B8CDBgSZT10VnfURrWJkxDXrAfiaqQ4q3Hhbo2s7q55E1m1M5TvrtOu7F25GFeYrVwZqlf7WyCGq51Wbcq6XtEFfftchz179uLpZybgt9z1ZZoooviO225A2zano2rVqu57EvIw\/8P\/YuasDxnCEK5BZT0RQ4CCN2KGig0lAWsEaENmjVMwUkkoQ5NRo1H1cD1uVJMjhAsXoP6+AkzO6BUMvEEtQ05Uk1CG\/qvWpQAAIABJREFUvVX2qXCGirqs2JRJmMLTTz6Ik9Kb4q23\/\/bclTjd3rdcg87nn42aNRPcXZDwBVnhlf+++\/5HjHn2FTozVNQAs17HEqDgdezQsGEkYJ8AN6rZZxZIDs2GrFLaVUDVxECKivy8f63uDk7JQladDMf1Z2bRMry\/YwXqJ1dG5crhX93VgFi1KRO3hSNHjqKgYLPKWqdOEp4ccT\/S0lLdbI8fP478\/M2Y8e4HuLrHZWhxcppa2X11yjv4YsHX5cZAyigp2Usx7LjZyQaFgwAFbzgosw4SCBOBrVvWYU9xEdDmrNLYXV4hI0AbsrJoI8GGrFbNSkisWXGruxoxzaasVpILDRqmW56j2oa2ypUrwRine2GXc9H\/jhshq8Br1m7AiFEvuY8gFvF814CbkX5SM7w9Yy4+mPe55TqZkASihQAFb7SMJPsR8wTcq7uyUW3k86Wil1fICNCG7G+0Trchk1CG1Qc3o2H9KiGbD3YK1tuU+drAZixTYnfFtmzNmg2Y+ub7ZeJ0JQxi6MN34eyz\/gmxMRPbstlzPy1nVZafvwnDR76IoqIddprMtCQQ8QQoeCN+CNkBEiglQBuy8M2E+FWrkDJqtIrbpQ1ZCY4VLkAmjmN0WrfwDYLFmjQbsoraqOatmVZtyix2UyU7LTMDjzx0F2rXTkTJnr04dvSY+rt2SazvqtXrMH7CNHeohJ3ymZYEIpkABW8kjx7bTgJ\/EShjQ8YT1UI6LySUQVwZ4jeWoFKzHiGtKxIKd7INmWxUE1eGtYc3K2cGp11WbMrstvm+IbfjgqxzymWjVZldkkwfbQQoeKNtRNmfmCNQxoZMQhm6XhNzDMLZYdqQ6WhHgA3ZhC0LlStDRdiQmc1LbQNblarV0ax5a7PkPu97syorKdmDDz\/+ErPe+4ib1QIizMyRToCCN9JHkO2PeQK0IQvfFKANWVnWTrch67dmOhLiK1WoDZnZ7NQ2sCXXTUVyvb8dGMzyafe1I4U7dzobCQnx7mxyItuy5b9gyuvvMl7XKkymi2oCFLxRPbzsXLQTcJIN2VvD7sPNH8\/1iHxXYhIufuUtLDv1DI\/3a+3bh\/8MuQ2dln+P7i9NwfxOFzpy6JJnz0Hy\/C9AGzI547b0kAmn2pCNK8jG4j1rHLNRzduE1m9gk1VeWe21enW5oCNu6dWj3JHC69ZvxDvvzsey5T9bLYrpSCDqCVDwRv0Qs4PRTMBJNmS+BK82Bo8Oeghjbr2r3JDo8zpV8LptyOq3Q5yrfTRPK0t9iwQbMgllkBVep1\/+2pTdfNNVuObqy1ClSml8MuN0nT7SbF9FEqDgrUj6rJsEAiDgNBsyTbS+fXkP3DL6RXfP9Ku3xpXextu24utbr0Xzgj\/c6Z0qeFNGPYn4tYWo1KJ3AKMWHVllo5qEM4grQ2aNxo7rlNNsyMwAHTx4EHICm1x2bMqSkmph9KgHkNK4IRZ8+U05qzKzenmfBGKJAAVvLI02+xpVBJxmQ+ZN8Ap0vbDVVnnbrvwZn991C+qUFGNDSipq7ylRf3ei4HXbkDXrgbgaKVE1j2x3RkIZNnyArBqNMLhJlu3soc6QvStXOTM4zYbMrN8bN25EXl4e4hMSkZKaaZbcfd94IpvljExIAjFGgII3xgac3Y0OAk7cqOZL8Ap17f6iNmeh69jX0TJvHWY9fDeuf\/ZlNSia+HWa4KUNWdlnRrMhk9VdV7VajnqgxIZMVneL4\/Y60obMDJas8spqr51VXrMyeZ8ESKCUAAUvZwIJRBgBCWUoyM+B\/KlOVHOIDZmZ4B36xit4evxz0ATvnho13OT1q71OE7zKhuy1d0oPmeDqrtqollU7w7Gru062ITP7qPHHpuyq7hdD\/qubXAeHDh2GuDMcPXoU23fswuFDR3Dg4EGs+PFXzP3gM7PqeZ8EopoABW9UDy87F40EnLi6q1\/BNcbwamMQiYLXvVGtdisleGP9og1Z6GeAXZuya6++DDfe0A1Hjx1Dfv5mHD9+HPXq1VEWZfEnnKAavH\/\/AXW62ldf\/xD6DrAGEnAoAQpehw4Mm0UCngg4yYbM2D6zFV5jSEMkrPC6Jk5C4pKfuFFNBps2ZGH5ULJrU1arVk0MHzYYLU5Ow+w5n2D23E\/Rt\/e1EMuy6tWr4c8\/D+HL7G8w\/Z15KC7eE5Y+sBIScCIBCl4njgrbRAJeCLhtyCSMQcIZHHT5Erx6pwZP1mRODGlwr+5KKEPtVg4iXTFNcbINWc6+TSp2N1JsyMxG0K5N2XnntsOggX1w5MgRtdJbp3YSjh07htW\/rcMrk95GXl6BWZW8TwJRT4CCN+qHmB2MFgIH9hejMH8l0LgJMGVm6Z8OunwJXu2etwMonCh4aUP29+SiDVl4HzS7NmVt2\/xfe+caXNd13feFJ4XXBQiBlxAvwIAKSoQhmtgR9bAcTzuImg9pqweiZDgpJ2o6E0pKY5r1tOnYcduYZuI247ot1QQsrYmrGVbDiaWMlInyoVLRYipTQ0luxClIGqQaEQTBB0SRIEiQGMIWOutA5+YCAnDvPY9999nnd77AJs7ea63fOvD8Z3vv\/\/5Z+e3f+nXp6Gj3tjScP39R\/vSl12T4fx41mzjRIGAxAQSvxc0hNQgUErDNhmx5d8JcPGGb4MWGrKC72JBV5H+ISrUp+3uPfEGe\/s1fE71iWJ+ZmRvy3B+9IEff+kFF8iYoBGwlgOC1tTPkBYECArYeVCts0lqC96+7NssX\/uR7cmHDxhX7apPgxYZsaYsWpo7JhulT3iUTttqQ3ayd9bYzuPb4NmXZzl7JtGZXLE\/38H7tq1\/0hO61a9flvp\/rl+++8JK8+f13XMNBPRAIRQDBGwofgyEQPwFbbcjir7wyEbAhW7a6e\/oF2ZndITuz91emIWtEPTL1jnzvox\/IhvYaqampsi6\/sAn5NmU6T2\/fw2GnYzwEUk0AwZvq9lN8EghcvTIhVz+aENnx0OLeXZ7YCGBDthStzQfV9JKJ3acPS0tztWSa3Vvd9TtRrk1ZbH8cTAyBhBNA8Ca8gaTvNoG8DZkeUFNXBhW9PLERwIbsb9AuzE7Kwtk\/kz25ARlY3xcb86ATHzg\/LCM3TkvnhtqgUyRiXLk2ZYkoiiQhUAECCN4KQCckBEolYPtBtVLrSMJ72JAVdEkPqk2+If2y4O3dtfFJi+BV9mNjY6LbGxoaM5Lr7rexHeQEAesJIHitbxEJppWA7TZkrvUFG7KC1d3pU7Jh6ph3fXB\/0yYrW52WLQ0+\/JGREe8\/5rq3S0Njq5U9ISkI2EwAwWtzd8gttQR0K8PlS2fk9q0Zkaf3ijyzN7UsTBTuHVQbOihVPYNS1ZQzEdLeGJbbkBWC00NrR6be9bY1uHhorbBW36astm6d9Nx7n73fD5lBwFICCF5LG0Na6SaQBBsyVzqkWxm69u2XuvkOqco94kpZgeuw2YZspaJ2jx0WV23Jltdbik1Z4MYzEAKOE0DwOt5gyksegfxBNU1dXRk4qBZrE9tfelnaX31dqrc8IVKXiTWW9ZPr6q7FNmQr8Ru+NiYHJoelo71W1tW7Z01WWHPhATZsyqz\/ayJBywggeC1rCOlA4PKl9+XG9SlsyAx8CvmDahsekKrsgwYi2h3CZhuytch97YNX5cz8RU\/0uv74NmUtrVnZ2NnrernUB4HICCB4I0PJRBAITwAbsvAMy5mBg2p\/Q8u3IVNXBlsPqq3W29HZC6KiNw2rvHNzc6JbG\/ThAFs5f+28m3YCCN60fwHUbxUBbMjMtaPh5EnJ7dvv7dutattmLrCNkRJgQ1YMmwpeFb65zrpiryb+99iUJb6FFFABAgjeCkAnJARWIrDEhuy1N4EUIwHdyqCuDA3jM1LdMxhjpGRMvZAAG7JiJLEpK0aI30Mg3QQQvOnuP9VbQmCJDZneqPbok5Zk5mYang3Z8y8uru5iQ+YdVBto6\/N8d5P8pMmmTC+i0JVebMqS\/MWSu0kCCF6TtIkFgVUIYENm7tPAhmwp64XJN2TD7Hk51LfLXBNijJQmmzL\/AFv73d3S3tEdI1WmhkDyCSB4k99DKkg4AWzIzDYQG7IC3p\/YkO3JDcjA+j6zjYgpWlptyvQyCl3t5YEABFYmgODly4BAhQlgQ2auAdiQLWWdVBuyYl8MNmXFCPF7CKSPAII3fT2nYosIYENmthnYkH16dTeJNmTFvhrfpmx9a400NlQXez3Rv8emLNHtI3mDBBC8BmETCgLLCWBDZu6byNuQ9QxyUO0T7B+feE52ZnfIzuz95hphKNKB88MyPD2WCpuy8fFxOXv2rDQ0ZiTX3W+IMGEgkCwCCN5k9YtsHSLAQTVzzcSGbGXWemBNLckObd0l2foWcw0xFOnx0SFvhVdXel1\/9DIKXe3lMgrXO019QQkgeIOSYxwEQhDQrQznJ0ZFfwo2ZCFIljYUG7LVOekqrwuWZCtVmKYDbNiUlfa\/BbyVXgII3vT2nsorSODqlQm5+tGEyKYuES6ZiLUT+YNqbds8312epQR0hVdXel3cy6uVpvEAGzZl\/JVD4NMEELx8FRAwTAAbMrPAs0MHJXP0Pane+pTZwAmKpm4N\/bLgiV7XHv8AW0d7rayrr3KtvCX1TE9Pi3rz6oNNmdOtprgABBC8AaAxBAJhCORtyPQ2Nd3OwBMbgfzqrt6o1rYttjhJn3hhdlIWzv6Z06u8p+YuSueG2qS3qmj+\/mUULa1Z2djZW\/R9XoBAWgggeNPSaeq0gsDtW9dlcuLE4laG7xxZ\/MkTGwFsyEpH66onrxKYunNDdp8+7B1ew6as9G+CNyHgEgEEr0vdpBarCehWhsuXzsjtWzMiT+8VeWav1fkmPTnvoNrQQanChqy0Vn5y65rrNmW6yltT4\/bWBmzKSvvkeStdBBC86eo31VaQADZk5uDrVoaufful9la9VPcMmguc8EgLU8dk4cO3sSlLeB81fd+mLNvZK5nWrAMVUQIEwhFA8Ibjx2gIlEQAG7KSMEX2km9DVr3lCZG6TGTzpmGij0+\/IANN98iergHnyk2jTZk2sbfvYed6SUEQKJcAgrdcYrwPgQAE8jZkOx5a3LvLExsBbMjCocWmLBy\/5aM\/f+WK\/P6JE0Un\/d3t22Usk5EDf\/VXsmluznv\/Rm2t\/Iuf+Rn5YUuwS0E4wFYUOy+kiACCN0XNptTKEMjbkOkBNXVlUNHLExsBbMjCo8WmLDxDf4ZSBe+\/7euTXx8fz4tdf3wY0YtNWXR9ZKbkE0DwJr+HVGA5gcmJ0cWDatiQxd6phpMnJbdvv3fBBDZkwXH7NmV7cgMysL4v+ESWjtTLKCplU\/bVH\/5QfvHyZfnvGzfKH\/zUT+UJ\/aNz5+Q3P\/hALtx1l+z57GflVk2N\/MHoqHxmelq+s2WL\/LfNmwPRHBsbE72FraExI7nu\/kBzMAgCLhBA8LrQRWqwlgA2ZGZbgw1ZdLz19jXd3vBK\/7PRTWrJTL5NWUtztWSaa4xmtZrgXZ5Ex507+e0Nut3h+x0dgfMcGRnxxua6t0tDY2vgeRgIgSQTQPAmuXvkbjUBbMjMtgcbsuh5f3ziORlo63PyANuRqXfkyNS73mUUJm3KShG8\/mqvdnT5SnCQLusKr6701tat825g44FAGgkgeNPYdWo2QgAbMiOYvSC+DVndfIe3nYEnGgKu25TtHjssN2tnvQspTD3lCl5\/i8OV+vpQKWJTFgofgx0ggOB1oImUYB+B\/EE1TU1dGTioFmuT2l96WdpffV2wIYses9qU9dc3e9cOu\/ZUwqasFMHrc\/bffa+tTb7a3+\/t6w36FB5gw6YsKEXGJZkAgjfJ3SN3awlcvvS+3Lg+tSh0sSGLtU95G7IND0hV9sFYY6Vxcv8Amwre\/qZNziHQA2xn5i9KR3utkdrKEby+w0MYp4bCorApM9JiglhKAMFraWNIK7kEsCEz2zsOqsXPW23Ksndm5FDfrviDGY4wOntBVPTqtobGhurYo68keBt\/\/OO8I0Phnt2oBe\/c3Jx3A5s+HGCLvdUEsIwAgteyhpBO8glgQ2auh3kbsp5BqWrKmQuctkjzM6JbG1y1KTtwfliGp8ck11kXe2eL2ZL5q7nnGhvzIjiKLQ1+YdiUxd5iAlhKAMFraWNIK5kEltiQvfZmMotISNa6lWHj0EFpGJ+R6p7BhGSd3DRdtinTrjw+OiQmbMpWE7yFNmTLv5KwtmTL58OmLLl\/h2QenACCNzg7RkJgCQHdynB+YlT0p3ejml40wRMbAc+G7PkXFy+ZSPDq7h+++8fy2Ln\/vSKnmbom+Sc\/\/xX5v+t\/csnvs3PX5MWR35Pu2an8v397+075L33xHiwLY1NWO3dNtvyv\/VJfkHNhUbMbtsm5h78sH9felf\/n3DsHpe3c99f8hu40ZeWDv\/s1+dFd60N9a6Zsytbaw1u4tUGLiWrv7nIw2JSF+lQYnFACCN6ENo607SOADZm5nuQPqrVtS7wN2VqC1ydaKGb\/9rX\/J3\/y5jclMz\/7KeBxi169iEJXeoMcYCsmeLWYH9c3yfjP\/47cXn+vV5tJwavx1KbsetVNYwfYzP3FfDqSf4Ct\/e5uae\/ormQqxIaAEQIIXiOYCeI6AWzIzHY4O3RQMkffk+qtT5kNHEM0X\/C+uvkL8js7fisfoelHt+XgW9+SBz48KYUrvU+PvSpfPnFEJpqy8mt\/5\/dk6q71stK\/xZCqN6UeYOuXhbJtygoF77nP\/TO5senn8ik2XPtr+Yk3\/1Bq7szKSiu9+uJa46OqtRI2ZVHlXu48hTZlehmFXkrBAwGXCSB4Xe4utRkjgA2ZMdTeJRM9X\/zS4laGtm3mAscUaTXBq+EKty7o6u3hn\/zFvAguFMi\/cPFd+eO3\/v0SYRxTuhLUpqyYYG258H9k81v\/4VOrvH4dxcZHVa86Npyau+jdwOb6g02Z6x2mvkICCF6+BwiEJLDEhkw9dzd1hZyR4WsRcM2GbC3Bqxz837+94aflmc\/9c5mtbfgUHpMrvBo8iE1ZMcFa+PvL\/b8qV\/r+4ZI6i42P6q\/GtE1ZVHkHmQebsiDUGJNUAgjepHaOvK0hgA2ZuVa4aENWTPD6YnY1wVu4pzfuPbz5Tn9iU7Yzu0N2Zu8v6QMoJlirfzQnm49+W5o+PCWVFLxajEmbspLgxfjS+Pi4nD17VhoaM5Lr7o8xElNDoLIEELyV5U\/0hBPgoJq5BrpqQxZG8BaK3bVWgOPo0sLUMVn48G05tHWXZOtbioZIkuDVYtSmTC+i0AspXH\/0Mgpd7c129kqmNet6udSXUgII3pQ2nrLDE8CGLDzDcmZwxYZsec3FBO9qWxr8fbs6X+EBtnKYhn1XL6MYaLpH9nQNFJ2qmOC1ZUuDX0iaDrD5NmVae2\/fw0V7yQsQSCIBBG8Su0bOVhC4emVCrn40sbhnl0smYu2JSzZk5QjeQqeGwu0KhWLX9MpuYf7l2JQVE7y+U4POX2hN5scrNj6OD1APsJ2Zv4hNWRxwmRMChgkgeA0DJ5wbBLAhM9tHl2zIyhG8\/upuoS1ZJbcxrNT1Um3K1hKshb+rpC3Z8vr8A2wd7bWyrr7K7EdvOBo2ZYaBE844AQSvceQEdIEAB9XMddE1G7LVBO9aRAtXd4PczBZnt3ybsj25ARlY37dqqCAXTxROVokVXo2fJpuysbEx0e0NLa1Z2djZG+dnw9wQME4AwWscOQGTTuD2resyOXFicSsDNmSxt9M1G7JyBO\/yvbkrXSlcON9qVxHH3SS9fU23N7zS\/2xgwTu9+fMyef8zJY1ffnFFnPVN3bkhu08flpbmask0u3+AbWRkxMOZ694uDY2tcaJlbggYJYDgNYqbYEknoFsZLl86I7dvzYg8vVfkmb1JL8nq\/L2DakMHpapnUKqaclbnmvbkPj7xnJRjU5YkXkem3pEjU+96l1HU1Li9tQGbsiR9meRaDgEEbzm0eDf1BLAhM\/cJ6FaGrn37pW6+w7tVjcduAuXalNldzaez2z12WG7WzmJTlrTGkS8EPiGA4OVTgECJBJbYkOlWhh0PlTiS14IQaH\/pZWl\/9XWp3vKESF0myBSMMUxAbcr665tl\/5bHDEeOPxw2ZfEzJgIE4iSA4I2TLnM7RSBvQ6ZCVwUvT2wEXLYhiw2aBRP7B9hU8PY3bbIgo2hTSKNNGQfYov2GmK1yBBC8lWNP5AQRyNuQ6UG1r3+L1d2Ye+eyDVnM6Co+vdqUZe\/MyKG+XRXPJeoE0mpTxgG2qL8k5qsEAQRvJagTM3EEsCEz17KGkyclt2+\/t2+3qm2bucBEioRAqTZlkQSrwCRptClraMxIrru\/ArQJCYHoCCB4o2PJTI4SwIbMXGN1K4O6MjSMz0h1z6C5wESKlEApNmWRBjQ4GTZlBmETCgIREkDwRgiTqdwjsMSGTLcyPPqke0VaVJFnQ\/b8i4uru9iQWdSZ8lNRm7KBtj7Z0zVQ\/mDLR6TJpkwvotALKWrr1knPvfdZ3hnSg8DqBBC8fB0QWIMANmTmPg9syMyxNhFJL6LQlV5XD7Clyabs+PHjolcPZzt7JdOaNfH5EAMCkRNA8EaOlAldIZA\/qKYFYUMWe1uxIYsdsfEAeoCtXxawKTNOPtqAKnZV9Oqjq7y62ssDgaQRQPAmrWPka4zA5Uvvy43rU4uODNiQxco9b0O24QGpyj4YaywmN0cAmzJzrOOO5K\/yYlMWN2nmj4sAgjcussybaALYkJltX27fN6ThzKRUb33KbGCixU4gDTZl61trpLGhOnaWlQwwNzcnx44d81LApqySnSB2UAII3qDkGOc0AWzIzLU3b0PWM8hBNXPYzUWanxG9gW1ndofszN5vLq6hSAfOD8vw9JjkOusMRaxcGD28pofYsCmrXA+IHJwAgjc4O0Y6SoCDauYaiw2ZOdaVjLQwdUwWPnxbDm3dJdn6lkqmEkvsx0eHvBVeXel1\/dFVXl3tZZXX9U67Vx+C172eUlEIArqV4fzEqOhP70Y1bMhC0Cw+FBuy4oxceUNXeQea7nHapqyjvVbW1Ve50rIV68CmzOn2Ol0cgtfp9lJcuQRY3S2XWPD38wfV2rZ5vrs8bhNIg03Z9aqboqLX9cc\/wNZ+d7e0d3S7Xi71OUIAwetIIykjPAFsyMIzLGeG7NBByRx9j4Nq5UBL+Lsu25SNzl4QvXY4Dau82JQl\/A8xpekjeFPaeMr+NIG8DZluY9DtDDyxEciv7uqNam3bYovDxHYR8G3K9uQGZGB9n13JRZCNCt5Tcxelc0N6VnmxKYvgw2EKIwQQvEYwE8R2ArdvXZfJiRMim7oWPXf1J09sBLAhiw2t9RPrKq\/MTsor\/c9an2u5CU7duSG7Tx\/2Dq9hU1YuPd6HQLwEELzx8mX2hBDAhsxco7yDakMHpQobMnPQbYqETZlN3QiVy\/j4uJw9exabslAUGWyKAILXFGniWEuAg2rmWqNbGbr27ZfaW\/VS3TNoLjCRrCKATZlV7QiVjG9Tlu3slUxrNtRcDIZAnAQQvHHSZW7rCWBDZrZF2JCZ5W1zNLUp669vlv1bHrM5zUC5DV8bkwOTw6k4wObblCmo3r6HA\/FiEARMEEDwmqBMDGsJXL0yIVc\/mhDZ8dDi3l2e2AhgQxYb2kRO7LpNmR5gOzN\/EZuyRH6dJO0iAQSvi12lppIIYENWEqbIXsKGLDKUzkyETZkbrcSmzI0+ul4Fgtf1DlPfqgQ4qGbu48CGzBzrJEXCpixJ3Vo717GxMdHtDQ2NGcl197tTGJU4QwDB60wrKaQcAtiQlUMr\/LvYkIVn6OoMC5NviG5vcNmmrKW5WjLNNa62MF\/XyMiI959z3dulobHV+XopMFkEELzJ6hfZRkBAtzJcvnRGbt+aEXl6r8gzeyOYlSlWI4ANGd9GMQIfn3hOBtr6ZE\/XQLFXE\/f7I1PvyJGpd73LKGpqqhKXfzkJY1NWDi3eNU0AwWuaOPEqTgAbMnMt8G3I6uY7pCr3iLnAREoUAdcPsO0eOyw3a2e9Cylcf7Apc73Dya0PwZvc3pF5AAIcVAsALcSQ9pdelvZXX5fqLU+I1GVCzMRQ1wm4fIAtTTZlhQfYsClz\/a82WfUheJPVL7INSeDypfflxvUpbMhCcixleP6g2oYHpCr7YClDeCfFBPwDbOrL29+0yTkSabQpa2nNysbOXud6SUHJJIDgTWbfyDoAgfzq7qYuka9\/a1H08sRGgINqsaF1dmJd5c3emZFDfbucq3F09oKo6NVtDY0N1c7VV1hQ4SovB9icbnWiikPwJqpdJBuGADZkYeiVN7bh5EnJ7dsvVT2DUtWUK28wb6eXwPyM6A1sO7M7ZGf2fuc4qOBV4ZvrrHOutuUFYVPmfIsTVyCCN3EtI+EgBJbYkL32ZpApGFMiAd3KsHHooDSMz0h1z2CJo3gNAosEFqaOycKHb8uhrbskW9\/iHJbHR4cEmzLn2kpBCSCA4E1Ak0gxHIElNmS6leHRJ8NNyOg1CXg2ZM+\/6LkysLrLxxKEgK7yDjTdg01ZEHgWjdGLKHSlt7ZunfTce59FmZFKGgkgeNPY9ZTVjA2ZuYbnD6q1bcOGzBx25yJhU+ZOS48fPy66p7f97m5p7+h2pzAqSRwBBG\/iWkbC5RDAhqwcWuHfzQ4dlMzR97AhC48y9TNgU+bGJ1B4gE1XeXW1lwcClSCA4K0EdWIaI4ANmTHUgg2ZOdZpiIRNmTtd9ld5sSlzp6dJrATBm8SukXNJBLAhKwlTZC9hQxYZSib6hAA2ZW58CnNzc6I3sOmDTZkbPU1iFQjeJHaNnEsigA1ZSZgieQkbskgwMslyAo7blB04PyzD02OpsCkbHx+Xs2fPSkNjRnLd\/XzrEDBOAMFrHDkBTRDgoJoJyosxsCEzxzqNkdJgU6YXUeiFFK4\/usqrq72s8rreaTvrQ\/Da2ReyCkFAtzKcnxgV\/endqIYNWQgsemYNAAANdElEQVSaxYdiQ1acEW+EI+CyTdnwtTE5MDksHe21sq6+Khwoy0djU2Z5gxxPD8HreIPTWB6ru+a6jg2ZOdZpjuS6TZnewHZm\/qInel1\/sClzvcP21ofgtbc3ZBaAADZkAaCFGJK3Idv6VIhZGAqB4gRctinT64ZV9KZhlRebsuLfOm\/EQwDBGw9XZq0QgbwNmW5j0O0MPLERyK\/u6o1qbdtii8PEEFACvk3ZntyADKzvcw6KCt5Tcxelc0N6VnmxKXPuM7a6IASv1e0huXII3L51XSYnTohs6hL5zpHFnzyxEcCGLDa0TLwKgYXJN0S3N7zS\/6xzjKbu3JDdpw9LS3O1ZJrdPsCGTZlzn28iCkLwJqJNJFmMgG5luHzpjNy+NbN4SI3V3WLIQv3eO6g2dFCqegalqikXai4GQ6AcAh+feE4G2vpkT9dAOcMS8a5vU6arvDU1bh9gw6YsEZ+kU0kieJ1qZ3qL4aCaud7rVoauffulbr5DqnKPmAtMJAjo1obpU6Irvfu3PCb9TZucY\/L46JCkzaYs29krmdasc72kILsIIHjt6gfZBCCADVkAaCGG+DZk1VueEKnLhJiJoRAIRsDlA2xptCnTr6C37+FgHwOjIFAiAQRviaB4zV4CV69MyNWPJkR2PLS4d5cnNgLYkMWGlonLIOAfYHN1lTeNNmUcYCvjD4BXAxFA8AbCxiBbCORtyPSAmu7bVdHLExsBbMhiQ8vEZRLQVd7snRk51LerzJH2v45Nmf09IsPkEUDwJq9nZFxAYHJilINqhr6IhpMnJbdvv7dvFxsyQ9AJszqB+RnRG9h2ZnfIzuz9zpFKk03Z2NiY6C1sDY0ZyXX3O9dLCrKDAILXjj6QRQAC2JAFgBZwiG5lUFeGhvEZqe4ZDDgLwyAQLQHfpuzQ1l2SrW+JdvIKz5YmmzJFPTIy4hHPdW+XhsbWCtMnvIsEELwudjUFNS2xIXt6r8gze1NQdeVKxIascuyJvDYBl23Kjky9I0em3vUuo3DdpkxXeHWlt7ZunfTcex+fPQQiJ4DgjRwpE5oggA2ZCcqLMbAhM8eaSOUTcN2mbPfYYblZOyvrW92+jEI7f+zYMdFLKbApK\/\/vgBHFCSB4izPiDcsI5A+qaV7qysBBtVg71P7Sy9L+6uuCDVmsmJk8BAFsykLAs2jo9PS0HD9+3MsImzKLGuNIKgheRxqZpjIuX3pfblyfwobMQNPzNmQbHpCq7IMGIhICAuUTwKasfGa2jlDBq8IXmzJbO5TcvBC8ye1dKjPHhsxs23P7viENZyaleutTZgMTDQJlEkiDTZlua9Bb2Fx+dEuDbm3QhwNsLnfafG0IXvPMiRiCADZkIeCVOTRvQ9YzKFVNuTJH8zoEDBNw3KbswPlhGZ4ek1xnnWGw5sNhU2aeeRoiInjT0GVHalxiQ\/bam45UZWcZ2JDZ2ReyWpvAwtQxWfjwbXHRpkwrf3x0SFqaqyXT7P4BNmzK+GuPmgCCN2qizBcLgSU2ZHqj2qNPxhKHSRcJeDZkz7+4eMkEq7t8FgkioJdRDDTdI3u6BhKUdWmpYlNWGifegsBKBBC8fBeJIIANmbk25Q+qtW3zBC8PBJJEIA02ZderbkpHe22S2hIoV\/8AW\/vd3dLe0R1oDgZBwCeA4OVbsJ4ANmRmW5QdOiiZo+9xUM0sdqJFSMBlm7LR2Qui1w6r4F1XXxUhNfumKrQp08so9FIKHggEJYDgDUqOccYIYENmDLV3yUTPF7+0uJWhbZu5wESCQIQEfJuyPbkBGVjfF+HMdkylgvfU3EXvBjbXH2zKXO+wufoQvOZYEykAAWzIAkALMQQbshDwGGoVgYXJN0S3N7zS\/6xVeUWRjL\/Ki01ZFDSZIy0EELxp6XRC68SGzFzjsCEzx5pIZgh8fOI5GWjrc\/IAW5psysbHx+Xs2bPS0JiRXHe\/mY+HKM4RQPA611J3CuKgmrle6laGrn37pfZWvVT3DJoLTCQIxEjAtynbv+Ux6W\/aFGOkykytNmV6EYWu9Lr+6GUUeikFl1G43un46kPwxseWmUMQ0K0M5ydGRX8KNmQhSJY2FBuy0jjxVvIIqE1Zf32zqOh17Rm+NiYHJodTcYDt0qVLohdS6ME1PcDGA4FyCSB4yyXG+0YIXL0yIVc\/mhDZ1CXCJROxMseGLFa8TF5hAv4BNldXefUA25n5i9iUVfg7I7z9BBC89vcodRliQ2a25diQmeVNNPME1KYse2dGDvXtMh885ojYlMUMmOmdIYDgdaaV7hSStyHT29R0OwNPbASwIYsNLRPbRGB+RnRrAzZlNjUlWC7YlAXjxigRBC9fgVUEbt+6LpMTJxa3MnznyOJPntgIYEMWG1omtoyAyzZlU3duyO7Th6WluVoyzW4fYNODa3qATR8OsFn2R2Z5OgheyxuUpvR0K8PlS2fk9q0Zkaf3ijyzN03lG6\/VO6g2dFCqegalqilnPD4BIWCagMs2ZUem3pEjU+96l1HU1Lh9Axs2Zab\/ctyIh+B1o4\/OVPH+2FFnaqEQCEAAAhCIl0Bv38PxBmB2ZwggeJ1pJYVAAAIQgAAEIAABCKxEAMHLdwEBCEAAAhCAAAQg4DQBBK\/T7aU4CEAAAhCAAAQgAAEEL98ABCAAAQhAAAIQgIDTBBC8TreX4iAAAQhAAAIQgAAEELx8AxCAAAQgAAEIQAACThNA8DrdXoqDAAQgAAEIQAACEEDw8g1AAAIQgAAEIAABCDhNAMHrdHspDgIQgAAEIAABCEAAwcs3AAEIQGAVAp\/52Z+Wr\/zLfyrNzY3eG0ff+oH8\/jf\/85K3\/Xf0H7\/57\/5I3jt+MhKev\/HUr8iTv\/xLS+a6c2devvtf\/1T+\/C\/eKCvG737lt+Xhz93njXnp5b+U777wvRVr0DovXZqSr3\/jP8m5iQtlxeBlCEAAAjYTQPDa3B1ygwAEKkZgc\/cm+Tf\/6kvS2ZldksNywegL0zPvfyB7v7wvdL7LRfZKE5YbC8Ebui1MAAEIJJwAgjfhDSR9CEAgHgKP\/oNH5Df+8a+Krqrqyu3f\/6UBb5W0UGz6ori9fX2gldflma8msleqcKXV5tVIIHjj+UaYFQIQSA4BBG9yekWmEICAQQL+yq3\/f\/H\/wsDnvS0Ghf+Xf9Sru4XCdPn2heVi+ObNWyVvoUDwGvxwCAUBCFhJAMFrZVtICgIQqDSBYoJX89MtD3Gs7q62V9cXvTduzpa1fQLBW+mvifgQgEClCSB4K90B4kMAAlYSKLalIerVXT9efX3dkm0TUcBB8EZBkTkgAIEkE0DwJrl75A4BCMRGoNihtf\/47X8tf6t3y4quB0GSKhS85ezPLSVWoeAt9j4uDcUI8XsIQCCJBBC8SewaOUMAAkYIrGZL5ovTq1evRWbhVWhDhuA10l6CQAACKSKA4E1RsykVAhCIhsDy1d3CFdRyDpMVZoPgjaY3zAIBCEBgJQIIXr4LCEAAAmUQWL6667s3FE4RZFtA4ZaGION9Ea55LBfdUezh9eco1wO4DLS8CgEIQCA2Agje2NAyMQQg4CKB5au7\/n\/XbQiv\/eWwdzObHjwr90a0wj3DxVwalGvhbWiFYtdnXiiawwreOA\/UufiNUBMEIGAfAQSvfT0hIwhAwFICy1d3NU3\/Nja9ge1\/DH9\/yX9ffoVvsbLW8uHVsYXC1hfFegWwimx99IIMfZaL7jCCd\/nhPVZ4i3WR30MAAjYSQPDa2BVyggAErCTgC0f\/UFmhGIxC8Aa5ac0X4ePnznvevP4czc3N+YspwgheFdk\/sblLTpw8LZ\/9zPbILdOsbDRJQQACzhFA8DrXUgqCAATiIOA7Nvgrqe8dP+mFiWpLg5\/zcmeIlWpZa4\/vSv7AQQWvP5cK\/AsXLns3zbHCG8fXxZwQgEDcBBC8cRNmfghAwAkCy1d3\/aIK3RX8fwty6Gw5pJXmXW1v7\/JclscPInjb29u8rRE3b9709gv7h\/MQvE58zhQBgdQRQPCmruUUDAEIlEtgtdVdf54obMnKzWk1gRyF2Na517qsIqoYYWtmPAQgAIFSCSB4SyXFexCAAAQsJeCvBkcpRBG8ljabtCAAgUAEELyBsDEIAhCAgB0EVtvzW2z7Q7nZr7Q3uNw5eB8CEIBApQggeCtFnrgQgAAEIiCw0l5fnRbBGwFcpoAABJwhgOB1ppUUAgEIQAACEIAABCCwEgEEL98FBCAAAQhAAAIQgIDTBBC8TreX4iAAAQhAAAIQgAAEELx8AxCAAAQgAAEIQAACThNA8DrdXoqDAAQgAAEIQAACEEDw8g1AAAIQgAAEIAABCDhNAMHrdHspDgIQgAAEIAABCEAAwcs3AAEIQAACEIAABCDgNAEEr9PtpTgIQAACEIAABCAAAQQv3wAEIAABCEAAAhCAgNMEELxOt5fiIAABCEAAAhCAAAQQvHwDEIAABCAAAQhAAAJOE0DwOt1eioMABCAAAQhAAAIQQPDyDUAAAhCAAAQgAAEIOE0Awet0eykOAhCAAAQgAAEIQADByzcAAQhAAAIQgAAEIOA0AQSv0+2lOAhAAAIQgAAEIAABBC\/fAAQgAAEIQAACEICA0wT+P7iPT73WNotmAAAAAElFTkSuQmCC","height":337,"width":560}}
%---
%[output:37dea0d2]
%   data: {"dataType":"text","outputData":{"text":"The fault zones are shown on Duval trangle 4\n","truncated":false}}
%---
%[output:77469102]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAArwAAAGlCAYAAAAYiyWNAAAAAXNSR0IArs4c6QAAIABJREFUeF7snQl0VEX2xi+bmAgJJhCyEAwawRlwGRE1mGhQx4VNxwVFVBIdBxAXnLjFBQIqccsfXBDR0cSFURFcCImoaFAYEBXHJbgAQqRBCRI0QRIVkf+5xVT78tLd7\/Xy9q\/OmcOYfq\/q1u9Wd39dr+qrdtn9Bu8lFBAAARAAARAAARAAARBwKYF2ELwuzSy6BQIgAAIgAAIgAAIgIAhA8GIggAAIgAAIgAAIgAAIuJoABK+r04vOgQAIgAAIgAAIgAAIQPBiDIAACIAACIAACIAACLiaAASvq9OLzoEACIAACIAACIAACEDwOnwM3Fp8FQ3OGRi0F7t376bGxp206v2Paf5L1bRtW4Pjelw49nw679yhIu6tW7fR1DseoE2+b4P2o3dmOk25\/VpKTU3R3ddff91N5RXzaOGiJSHvCTcW3QGYdKFyvKxbv5Em\/XOaSS0TnZh3LF09sYDi4+Pop5+aqfSeWfTxJ59rtn\/UkX+m4psmUpcu8QGv3bt3L7W0\/CzGRFX12\/R2zYo21zk9b5qQYniBkrfe90UMm29TFcfD7\/9Ds\/vQAQfEUbt27ej333+nn37aRbVr1tLc516hurrNRobQqu6UlGQ675yhdPxxf6HExK7UsWNH8XrLzz+Tz\/cdVS5aEnAMmhagSQ116NCBRo44lU4eMpjS0lIobv\/9Rcucm+bmn2nzlu+Cvh9NCjGiZuw2\/iPqBG4KSACC1+EDQ0vwKru3ffsOemhWBX24+jNH9TpcsQLBGzy9VgleFgYlk6+jvof2EcHFUvAqe\/vbb7\/Rf1Z8SGUz\/kV79uzxvxTuGHLUGyTGwdrpC5\/zNnLEX2m\/\/ToF7SX\/2Hn62ZdoYeWbMSbRtrpjBh4ufrR1754UtC0WfCtWrqZ775\/TagzKGwYdcySd9tc8eubZl0L+cDe8M1E0cNRR\/Wn8FRdRZmZ6yFqYxSeffkH3lc0REy9OKHYa\/07g5aQYIXidlK0AsYYjePn2rVu\/p+n3zKKvv\/7GMT0PV6xA8NpP8F5x+YU0fNgp\/tkwowQv95xF76Kqt+jxJ56H4I3gXW6XL\/zjjj2Krr26kBITEzR78eOPTXT3vY\/QZ7VfaV4b6QVdu3ahqVOuo359D9asgsfg\/AXV9Mzcl\/3X8szwFZePpkHHHEENDT9oPqnSbMSiC3KOP5quunIsdeumnRcZ4uqPPhP9Vf4ItSh8zWbtMv41A8UFYROA4A0bmb1uCDVjx7NqeScMolHnD6fk5ANF4Pz4t2bpSiqb8bi9OhIimnAFb6Cq1I\/F+cuo\/KkXHcMgVoFaMcPLs2L\/nHSFePwrS6SCN9Aj9j8dlk3nnnMmcTudOu2bCTRDAMUqJ6gnMIF\/Tvo7nXLyCeJFXi6wZMlyeunlxbTt+wY65JCDaPQFI4V45CUF\/LlW\/VoNPfLoM4bhPGXIYJow\/hKKi9tftMczly\/Mq6RPP\/tSjO0Rw0+lkcNPpQMO2Lf0ZuNGHxXfdi\/t3PmT+O9YfI4Z1jmdFauf1PBtvs3f0asL36QVKz8Us7icG+aQl3ssde683778tfxMsx99ht4KsNxIZ9O4DASiJgDBGzVCayvQI2D4A+iWmydSas8eIlhe2jDtrgcdM8sbiy8KCN5941TPeInliOZ1ftPvuIEGDOjXqtpYCl5Z8fh\/jKGhZ55MHTq0N0UAxZIT6mpLQDlWN2zYRJOKprWaIeQZ13tKb6aDemeIm3k9703FpYahZBFXWDBKLK\/YtauZ7r3\/0TbLwyZOuESMQS78o+uuux+mzz9f5xrBe+7fzqSLx5xN++23T8h+9dUGmnrnzIDLFf529unihyivr66pWUEr3vtICF8UELCKAASvVeRj1K5eAXPleP4gHiI2fPzyy6\/0+BPP0WuLl4ooZv7fZLEhhIt6I1Mgocjr5UrvupH6\/7mvuOfD1Z\/SlKkzWvVIORui\/nXPj\/YKLj2fBh59uH8TCj8C3PnTLlr+nw\/pqafnt\/pgNEvwKjksfv0dsd40K6uX6NeWLVvp7vtm05CTcoJuoGNxd+7fzqAzzsin5KRu\/pkn7v9XazfQv558vtXmGiVb3ow348EnaegZQ8SsFW\/sYibfbf1ePBpd8tbyNiOG19GNvfgc6tMnU8xsNje30Acffkpfb\/iGLr7ob+KLWS0stcYLry+86MKR\/jp50yMvg3n9zXdpYeWSsB9Jnn\/uULpo9FniC5J\/aPHj6U6dOka8hjfUJir+YTf51mv86yuZ+T+vv0OX2Dj1lFw675wzKTW1h3+WWGxC2vQt\/fv5hfTBh5\/EnD\/nlWfHeENWWmoPMV5kDiuefjHgBlMej2NGn01HHP4n8d7hsmtXC3351XrxxCLQ5i2+5++XXSgexfPsJH8GcF53\/NBIixcvpQUvL26V11CPdJVjPOnARMFKbhoMNMY5vkh\/bCpneDnejz\/5gp5\/YSF9+dXXMfr0DK8a9Qzv5s3f0fyXXhNPzEI9qg+1xEqOZ95wKTdm8nt28etL6a+n5omZY+47v6\/vKn1YBKzMJ39OcAmUz7+emkvj\/jFGbCZjgf7gwxW0\/D8ftOp0YcH5xCKWx4SeDcH3lBbTgP77Pvd5NpeXkfAMdyQl3M9Ldd\/1jOVI7gk1\/pWfn+G+f7m\/lxWcT0PyB1NCQhcxZuTn+\/BhJ\/u\/g3n9t8x1JFxxT3ACELwOHx1aAkZ2T\/lhzX9TPtIPV\/DyFyt\/6V4waoSYTQs0Y3zj9ePopBOPF80rH+3xB\/iU2yZRv36B18HxlydvOiq95xF\/ZqwQvCxS+QNVfpmwAH70sbkhH0uq16mqh9Z3322jaXf+4TCh\/GDl2SAWuIE2w7DwqnhqvliXKguvo7t64tiA6xs5dhaYnJtwBG+oDUJaG3ECvY2UTxb4y\/Gtt\/8j1vEGEuKh3obhrKlTfiErv8BDjSHeFHXpJef4d5mrY+HY\/2\/m461m82LBf8PGTcRiSO7yV7b7+RfraNqdD\/ofh\/NrIs6Lz\/GPS3WcgTZvhYqT7+e88vvt7ntn+6sLxpu\/sG++cQJxnSyQApUffmykmQ880YpVpIKXBd+4Ky5q1V\/+fGCB\/803m2nlex\/R20tXmLYZin+oT5vyzzYbtVi0frd1m1jiwD9M1fsjwhW8\/Dnw++97\/Rv1ePzxUg0Wq+I9ddNE8cMsUOF7X1n4BpVXvEg8A156543ixysXfv\/938x\/+W9Tv\/7Ou++JjXbBSkZ6T5pWUuRvO9oZ9XA\/LyMZy5Hco1fwhvP+DfXe4R8re\/eSP98QvMaJMghe49iaUrNewav+0lF++EUieJWzaXv2\/C7WsrE9EBf+YrhjahH1ykgjfo3t0J5+ZoF47dJLzhWWPizG+Ivh3rI54kv9umsup0GDjhTXsIDmX7hr120U\/22F4OUv1vdW\/VesdVY+hgsWyxGHH0Y333ilmJFpatpJ\/3rieVr67iox4zv6Qp7h7CRmYeY+9yq9OL9K9EudExa2lZVLaN78KiEq\/n7ZBX5Bq\/xyUX\/xbq3\/np548gX678drxA+RYUNP9n946hW8Sssw\/gJney\/O50l5x9HYS8+lhISu9Ouvv9K\/Of4F1ZpjW\/kBz1\/e1a+9Td9+W+9\/JGzEkgYOSvl+UD5SDpY35Vjlfj\/3\/KtixjP\/xOPo75dfKPrNheOfNXvf+tBY8ee6+FH9rNlPC8F0zVWFxBu1WEyqn4oo10Hz2Pzov7X02L+eE\/EUXHqefy1rY2MTPTTrKSEGufAmq2MGHiFmYZct\/4AefexZ4n4yj9NPO1GIbZ79m\/ngk8JZQD0ulTPqbH846ZrLxBrVhh0\/iDH+7rL36fAB\/WjSNZf7hZD6iU+kgpdj0RJFLPC+\/GoDzZ7zjCnWZFoCijlv3\/4DPfvvl9s8lQn1ORbos+C55xfSgpdea\/VeU04kfPDBJzTjwSeEsL2xaJwQw1y+2bSFbiq+W3yuKp\/s8dOEyVPKxBpoLsp88mfPnMfm0ptL2j5JkgGoY4xGmEXyeRnJWI7kHr2CN5z37yVj\/iae5PD7jcfsO++uoifKXxA\/eHlduFyWw3VGw1Xzg9njF0DwOnwARCp4lW+qSAQvY1N++K75fC0V33qveEyjXOumFB0sgu6\/91axVEAt\/pT3qMWQFYJXLbrlMAkWi\/LRIAvP2ybfL25Rz+4oZ9bVXyDqGZbbb71GeH1y4WUFk0vKaMu39a34Bvqikh\/yfJ9ewascRxw\/L1GRj2mVP1LUG3GCvX14Jrdg7Hli1pRnQpgHi2e5BtIMwatsI1jelONOKRS4X8r3hfL9orwnGv7qR8Isam+8frwQlCyc+IfRU\/\/7oajMqeQpbZ7U7gE803jLbfeK1Mg+cH28LGP2o88KwaNe\/6r8ARzsC1\/ZbxbWT1a86H+cf\/55w2jM6LPEEgf12tVoP2J5ucn55w2l9LSe1L59+4DVqYV+tG2Gul8uKRjQv59YnhOohOsUov4sUH6GyPqVnyXqJQp6foirx6pSDKvHfqA+6RG8yveMug7lZ18kn5eRjOVI7tErePW+f5Xfe8xE+V2p\/uEBwWvkO5cIgtdYvobXHqngXbb8ff9jzEgFb+4Jg+iaqwrEF7Tyza\/8cg60vldC4d31xw46UqwF5sducj2aHQRvsEMZ9IjvlB7JdPzxR4uZL166kXRgN\/8j4GCCV\/0DgBkFa+sffx9NZ408rY0Qllz50fdlBaMCrpUNNF443mlTiyizV5qoQu1gocyzHjGjnAHlmco5j\/+b3lyyrJVQN0Pw8kw7L43hNYZ68saz88cOOoqOPOIw4rGZktLdL7CUgjdW\/NUiI9iPI\/XfX134hn92V+ZcvcRIPiFRLvHga3kJQ1PTT7Sxzhd0I1GwL3z1siiuT+txfiw\/AHkG88TcY+mII\/5EmZlpbZagqH8IxLLtQHXxeOFlW\/wZdnCf3mJdpnKpB6\/HZt9zngUP9X7m18KdBWcRdeQRfxJPxQ7rdwj1yeJ1\/PvEt3ot7p3Trqe\/HNVfvCZ\/VCt\/8Oh1uOBZ2eKbrvQ\/9Qg0E6lX8Cp56v28jGQsR3KPXsGr9\/3Ls7dTJk+inind2\/yQZQ6cy5llk+ngg3sLLJjhNe6dC8FrHFtTatYreGO9hpc7p1wDJj80eQ0bx8RrUQPNfskNa3JjViBIdhC8gWZYQn1pyQ0YPLOZlPSHwFX3L5jgDbQZK5hI08q5UqDqmeENx7dYj73QVRPH0hmnnSS6rlyPHWoWP9Sbxeg1vHpmEJVfQrHmL\/seTPDq6X8wtlqP4Hfv\/o1Wvf9fsUZUzhhHuoZXPs7nDXdL33nP8M8\/fiTPa5rl4Qd6xmaosR6t0OjVK63V8hIGoJw517ukIdCPXwlTz+yyWvAqnRX49LPbp5TR4f37+S3W1EtagiVOvYY3kHOGXsEbyedlJGM5knv0Cl71pEg071\/lj5Jox6HhbzwHNwDB6+DkcehaX76ye8pHSNG6NCj9a9WPuz9Y\/anY9ctrdOWHqzzOmAXy5NuuoT\/\/6VARFj\/240f0\/Ah2Z9NPxI9FA21o0jM7p5VGPTMowR5hK+sOtaTh7JGn+Z0ZdvzwI33xxXqx1pJ9kKUlnNMFr56jZkN96anzpKc+PYKP61V\/4ehxaVAuveA6eFb46w2bxOzn2WedHnDWRes9F+4PDiMFL9ctRdJhhx0SdGNebe1XdMvt94llLHpcGth6Kzm5W8AlBspZfa33ZbDXzzwjXxzSwD6uodaXKpeB6BlLkQpetdgLtsEr1GydXsEbrB8c++TbrhXH+HLhHys8U88\/zvnp2Ihhp4i\/qwWvep06H6GenZ3l9zhWP2IPlTOlMFPPYKvvC7Wci7+Pwv28jGQsR3IPBG+k71r73wfBa\/8chYxQ68uXb+ZHb\/xBxY\/duKhdFSJd0sB1KTev8Wzitm3bhUgI9JhMOcvMH+pPP7uAXn7ldRGT3dbwBvuVHehL6+eff2m1JIA3DPGjdBYPetfwhjPDq\/T6DGQlFO6SBvWXebSHclgleJUWaOrxF0xsKB958ibJkmkz\/DOdwX4AxZq\/luCNZkmD8sNDPgYfPHig+NGZnpbit2BTLv\/Q+wNDPooO9EhfuWQqko9YXucvnxTx\/cFO6uIlBVddeakQfEYKXo5BKfb4pLTpd89qY5HGn7V333Uz9e6978hd5edItIJXuWyF88WbE+VGQ61JAeV+i48\/+Zy6dz8w4KZirVy18eFdu0FYk8lJDeX9ykf5\/Hf5uaJeQqX38zKSsRzJPbEWvOqxrP58xZIGrVEXu9cheGPH0pKaQglefiPxru+LLjxLzPLw+rJAJ60pN0epH1OpP+ACiSHlml0JgcXvPffNFjOcsrAJ+cUX7TMtVz9qV4oIOyxpCEfw8iwUM5Sn2SkZKWf7lB\/6\/P+1hIWejVbq2S\/O+ZTbrxUex1z0LGng65Q5VG9aC2YxF2zAmy14+Qv0nHPOpFNPPsFvYaU+aS0QS3YauHv6zf4fgsqcq7+k9G5ai5Q\/swz14yicTWty3bxyF34gMRjsh1GwcamMgX8cXH\/jXf6NjUZ8aSvb47XH\/CRo3ouL\/CebiVMkRw2n5KR9p0hG6wur9QGu\/izkH5vsqMJrdJkvr6kdfeFIsf6bP2vVDjXKMVi\/bTtNnTZTOCro+Szga3iTGTuwcAm1TjfQj2D1WGjfvp14GqVnTb6Si\/opHb\/G4v\/VyjeFKwXngPt\/4onH0QmDB\/pzo\/zsOzQ7K+zPy0jGMv8Ikq4isRj\/3IdQ37fB3r9am9aUDjnqH0laYxKvh0cAgjc8Xra7WvkG1BMc7\/affs+sVl6RyuUOLKBeefUNYkucIfk5wp9UfqGoBZtsT2lwLv8W6DGZcoaXvwyWvrOS5jw+l0479UTxRSGP5HSa4FXP8PLmGbYz69rlgDaWM7FY0qCesWdbskfnzKW16zbQ5YUX0EknHuf3dtUreJWep7yGkM302fZKaY\/GS1A4\/mfmvqxnqLW5JhZrePU0HM4OeeUMLz\/5ePiRfRZhV185lvr37+vfhKQUvEbw1xK8yi9FvbZkavEt7eu4L7zelDffHf2XAaKPSveNYIJXGYPSWonH2Gl\/zRPraaV93bNzX6EFL++z1NKznChQXrXWXyrvCeTfrWeshHONloe4ui6177Zy\/PNyAB5rGzduIv78SE\/v6T94IthMtXKGl69hv935C6po9AVntbIiDCR41Z67MtZQm4qDseFlJFdPLAjoGR7sHl7mwjZcfNiReoZXz+dlJGOZGSt\/\/Ec7\/iMVvHyf8ukTv3d4jTv7uvNmwssvu8C\/5A2CN5x3ZPjXQvCGz8xWd4QjeL\/\/nr\/QK9och8m7fG+8YbzYRaou\/EHFAkj6kQaa4VV\/mLJfq\/ILT9YZaHZAvsYzOGy+zWt\/eW3akxXzaGHlm+Jlrcd1ehKi50s3Vmt41fEwP7Zr4sLevnfc9WAbIRDOkga+OZgY4C\/+HxubqMsB8aJNvYKX6wzlecr18qNHPqAg1KlSoXJhhuBl1mzQP+OBJ1vFGWwMqdfwKuPnLyb+omVBqH7yYQT\/UDO8HBefWHfO2WcEPXiCNx\/x+np5giLfw0uOrrv2crGLP1hRW3qFevIQ6nASrj\/QONHz3gsWG6\/l5Tblj+FA13Gb7MTBT5Tkxjs9nwmRXKOHJ9fLP57YoeHD1Z\/5m1F6zyrb5s9UfqoiT1rTu4ZXWQdPIHDhz89gxx4r91vwtcE+p\/VwYfeZq64cK8ZVsENIuB7+XF\/\/9TfCv1t5WqFyDa\/ez0s97NVjOZJ7Yr2kYV9egh\/aov6OxaY1PSMwsmsgeCPjZpu7tASvPHJy2bL36fl5lUHPMlcfU8sfunV1PnGs6piLzvIfexhsfafeIyp5AwVvRvnLX\/qLDTTy6Fo+ojMvd5AwyeeiXLPnBMHLH2gXjBpOw848WayZ5i9htn9a9p8P6PvvG\/xLOZRr\/yJd0iAHn\/IYYH48ye29u\/z9fQc8jD0\/oqOFTx4ymEYMP5WyDuol7ucvrIaGH8XBC+ojaMN9ExgleOXRtuvW14lH3rxGUV1CjSF2aeAnDDzzxF\/efJIXjz9ejsOzoCy2Am3QiTV\/LcHLfYrkaGE+MZCXEuXlHivGJo8VzutPP+0iPtCEDxhRHkmsNS653+yLy2JHWgny50V9feAjqKMRvLLPoy8YKWbc+amJPJmOn0bxLOrbNSsiOvY63PErr2eeF44aQccf\/xdK6dHdf8gLf5ax4F71\/sfisJ1A61r5BxYfvCM3\/HEf3n57hViLqyV4JYsJ\/7hY2B3yD1r5Oc2HwfDSNbZ35PfD4jfeoYdnPdWqi3\/+86F0681XUbduCeLveo4SDsWIP\/P4KSD\/KOGxK4\/6lcfEr1mzVuzRCHQUdCSflxxLuGM5knuMELwyjrGXnies9djCjjnxkxX1dywEb6TvTO37IHi1GeEKEHAUgUiFpaM6aeNgwd\/GyfFwaOofVFpHCXsYleld1\/N00fSgXNggBK8Lk4oueZuA8tQr9eYYb5Mxp\/fgbw5ntBIeAa0TAsOrDVfHioD61MNAB8vEqi2v1wPB6\/URgP47joD6ETE\/1r2z9CHxWJrXCV7x99F+54FINqU4DojJAYO\/ycDRXMQEDjggTtzbo0cyFV13hf9zwexT6SLugEtuVC495KUv1a\/V0BPl86hLl3ixLp8dU3gJmd5DQFyCxfRuQPCajhwNgkB0BEJt\/lPW\/MOPjTTzgSfabFKMrnXcDf4YA04hoJzVlTHzuuGnn3nJvynYKX1xcpyhNsfKfvG6ej6ZkjcGoxhDAILXGK6oFQQMJSA3b7DPLzto8OwAl1CbkQwNyGOVg7\/HEu7Q7h4+oB8V33QlJSYmiE1SDTt+pKrqt2nBS\/ss41DMIyA3ex7UuxfFx+\/vP6Uw1IZP86LzRksQvN7IM3oJAiAAAiAAAiAAAp4lAMHr2dSj4yAAAiAAAiAAAiDgDQIQvN7IM3oJAiDgYAItzY0UF5\/o4B4gdBAAARCwlgAEr7X80ToIgAAIhCTw2+5fqG7DasrI7A\/Ri7ECAiAAAhESgOCNEBxuAwEQAAGjCbDY3eyrJf6XS3a\/wUY3ifpBAARAwJUEIHhdmVZ0CgRAwA0Edmz30Y4Gn78rScmZlNQ90w1dQx9AAARAwFQCELym4kZjIAACIKCPgFzK0Lt3FlVX19CAAX3EjVkHD6SOnTrrqwRXgQAIgAAICAIQvBgIIAACIGBDAlt8tdTS3ETFxVOouLiE5s6toAkTCqlrYgr1TM22YcQICQRAAATsSwCC1765QWQgAAIeJcCuDFt8a4hnd2trN\/opDB06hJYvX4oNbB4dF+g2CIBA5AQgeCNnhztBAARAIOYEeClD\/dZ1Yna3qqqG8vLy\/W0sW7aUhg0bQnHxCZSROSDmbaNCEAABEHArAQhet2YW\/QIBEHAkgabGbbRt63rKzc0Xa3fVRc7ypqRmU0JiiiP7iKBBAARAwGwCELxmE0d7IAACIBCEgLQhS09Lo9mzy1vN7vItmzbV0fjxhWJZAxfYlGEogQAIgIA+AhC8+jjhKhAAARAwnIC0IRszpkAIXnWRG9fSMrPoO18dNrAZnhE0AAIg4BYCELxuyST6AQIg4GgCShsy5UY12Sme3WVrMha7las20jHp7cRLOIHN0WlH8CAAAiYRgOA1CTSaAQEQAIFQBKQNGc\/s8gxvsNnd4aMKqGRmOVXOq6CpkwqxgQ3DCgRAAAR0EIDg1QEJl4AACICAkQSC2ZCp25Qb1ubMr6GBg\/Np3LlDaPVK2JQZmRvUDQIg4A4CELzuyCN6AQIg4FACoWzI1F2StmQDc\/JpzoIaWr1iKY07b4g4eY1PYEMBARAAARAITACCFyMDBEAABCwkIG3Igm1UU4fGp63x5jX1LC9syixMIpoGARCwPQEIXtunCAGCAAi4lYByoxp77vLJanpKQkI7\/+a1b311NPK4PuI2nuXl2V4UEAABEACB1gQgeDEiQAAEQMAiAvVb19POxm1ik1ogG7JgYZWWllBp6VSaMrOcRowqoMfKSuixsqmwKbMoj2gWBEDA\/gQgeO2fI0QIAiDgQgJaNmRaXWaLMrYqW7hqI6VnZtGI4\/oIb17YlGmRw+sgAAJeJADB68Wso88gAAKWE9CyIdMKUB5CAZsyLVJ4HQRAAASIIHgxCkAABEDAZAJyoxqv2Q10yITecGBTppcUrgMBEPA6AQher48A9B8EQMBUAryUYbOvlvjfqqoaysvLj7h92JRFjA43ggAIeIwABK\/HEo7uggAIWEsgXBsyrWjVNmUlkwpp0bwKSkrOpKTumVq343UQAAEQ8AQBCF5PpBmdBAEQsAOBSG3ItGJnm7LpiQdSceMPQS8t696bHk3uJV4f37CZirZvCnrthIzDaEmXJK1m8ToIgAAIOIYABK9jUoVAQQAEnE5A2pAVF0+h4uKSmHWHN7BtmlBI0zVqlKJXS\/ByNa8k9KAb0g6NWYyoCARAAASsJADBayV9tA0CIOAZAtHakGmBeu6Ig+kfdRtp+9HH0+bn36Chpxzhtyl7uHEbnd30Pfk67U8X9h5A5zRuEzO8q+ITaVzGYbSrfQd\/9fd9t05cywUzvVrU8ToIgIBTCEDwOiVTiBMEQMDRBKQNWbQb1YJB+PbqK6jfU\/+iz3qk0p7\/rKVXqhfQ1EmFFBefQGMPTKfZW76kxg4d6bJef6bBu34MKngP+H0PzdnyJR3X3IhZXkePOAQPAiCgJADBi\/EAAiAAAgYTkBvVcnPziY8QNqLsV1ZKnafeQkuJaOMzVXTEKUNp3LlDaO3KpbR4vzga\/GuLrhlejk0ueZAzwts67mdEyKgTBEAABEwjAMFrGmo0BAIg4EUC0oYsPS1NHB8cjQ1ZKH5S8Ia6Rr2GN9CSBr7\/1J92iBlhCF4vjlj0GQTcSQCC1515Ra9AAARsQmDHdh\/taPDRmDEFQvAaVUIJXvZuOL9bT\/qm5yGieTmDC8FrVDZQLwiAgN0IQPDGvvEdAAAgAElEQVTaLSOIBwRAwDUEjLIhCwRICt49efl0RN0G+ty3iT78dq+49Jj0duLfrIMHUsdOnTUFL5Y0uGYIoiMgAAL\/IwDBi6EAAiAAAgYRkBvVeGaXZ3iNLErB+9S5F9DlkybQP4qm0D+KSqhyXoV\/A1tG5gBNwSudGmBNZmTGUDcIgICZBCB4zaSNtkAABDxDoKW5kbb41lDv3llUW7vR8H4rBW\/LCwvpzFEjafnypbRw1UZKz8wSG9hWr1xKGZn96bqWnUFdGpQevbAlMzxtaAAEQMAkAhC8JoFGMyAAAt4hwEsZ6reuo5bmJjLKhkxNUy143\/3vaho2bAgNzMmnOQtqaPWKpTTuvCHCpuyO+G4hT1rjujG7653xip6CgBcIQPB6IcvoIwiAgKkEzLAh0xK8e7t0paFDh4hZ3jnza2jg4Hz\/LO+dXZLo1p92BGQivXo\/3b+LqczQGAiAAAgYSQCC10i6qBsEQMBzBJQb1Yy0IdMDdtOmOhowoI9\/lvdbXx2NPK6PuDW732A9VeAaEAABEHAFAQheV6QRnQABELALgfqt62ln4zbDbcj09re0tIRKS6fSlJnlNGJUAT1WVkKPlU2lrokp1DM1W281uA4EQAAEHE0AgtfR6UPwIAACdiKgnN01Y6Oa3r7zLC\/P9kqbshHH9aHvfHViA1tcfKLeanAdCIAACDiWAASvY1OHwEEABOxGwEwbsnD6PnduBU2YUEjDRxVQyczyNjZl4dSFa0EABEDAiQQgeJ2YNcQMAiBgOwJm25CFCyDYBjbM8oZLEteDAAg4kQAErxOzhphBAARsRcAKG7JwASxbtjSgTRmfvMYnsKGAAAiAgJsJQPC6ObvoGwiAgCkEpA0Zn6bGzgx2LbysgZc3qG3KkpIzKal7pl3DRlwgAAIgEDUBCN6oEaICEAABLxNQblSrrq4RJ6vZuSQktKO0zCyqXLWRlDZlPMvLs70oIAACIOBGAhC8bswq+gQCIGAaAbvZkGl1XNqU\/aNoCv2jiC3KYFOmxQyvgwAIOJ8ABK\/zc4gegAAIWETArjZkWjikTdnCVRspPTOLYFOmRQyvgwAIOJ0ABK\/TM4j4QQAELCNgVxsyLSByAxtsyrRI4XUQAAG3EIDgdUsm0Q8QAAFTCciNarm5+cRrd51WYFPmtIwhXhAAgWgIQPBGQw\/3ggAIeJIAL2XY7Ksl\/reqqoby8vIdxwE2ZY5LGQIGARCIggAEbxTwcCsIgIA3CTjFhkwrO2qbspJJhbRoXgXBpkyLHF4HARBwGgEIXqdlDPGCAAhYSsBpNmRasJQ2ZXztMentxC2wKdMih9dBAAScRACC10nZQqwgAAKWE5A2ZMXFU6i4uMTyeKINgA+i4Jle2JRFSxL3gwAI2JkABK+ds4PYQAAEbEWgpbmRtvjWiMMlams32iq2aIKRG9hgUxYNRdwLAiBgZwIQvHbODmIDARCwDQFeylC\/dR21NDc5dqNaMJhqm7LVK5bSuPOGUFx8AmVkDrBNDhAICIAACERKAII3UnK4DwRAwFMEnG5DppUstU2ZPIwiJTWbEhJTtG7H6yAAAiBgawIQvLZOD4IDARCwAwFpQ5aelkazZ5c70oZMi+OmTXXEJ7ANzMmn4ReMpamTCv23ZPcbrHU7XgcBEAABWxOA4LV1ehAcCICAHQjs2O6jHQ0+GjOmQAhet5bS0hIqLZ0qusfrlNlfmDe1wabMrRlHv0DAOwQgeL2Ta\/QUBEAgAgJKGzI3bVQLhoJneXm2l4U9C3y2LeMCm7IIBg9uAQEQsA0BCF7bpAKBgAAI2JHAFl+t2KgmBaAdY4xlTDyjy7O8UtxL2zJsYIslZdQFAiBgNgEIXrOJoz0QAAHHEHCrDZlWAniGl5c0yCI3tGVk9qe4+ESt2\/E6CIAACNiOAASv7VKCgEAABOxAwM02ZOHylbZlHTt1FksbUEAABEDAaQQgeJ2WMcQLAiBgCgG325CFC1HO8sKmLFxyuB4EQMAOBCB47ZAFxAACIGArAsqNam61IQsXuLQt4\/tgUxYuPVwPAiBgNQEIXqszgPZBAARsR6B+63ra2bjN9TZk4YKXtmVdE1OoZ2p2uLfjehAAARCwjAAEr2Xo0TAIgIAdCXjNhizcHEjbMmxgC5ccrgcBELCSAASvlfTRNgiAgO0IeM2GLNwEwKYsXGK4HgRAwA4EIHjtkAXEAAIgYAsCXrUhCxc+bMrCJYbrQQAErCYAwWt1BtA+CICALQjAhkx\/GmBTpp8VrgQBELAHAQhee+QBUYAACFhMQNqQ8XG67MyAEpqAnOVNSs6kpO6ZwAUCIAACtiYAwWvr9CA4EAABMwgoN6pVV9e0OmXMjPad2IbSpowPo+BDKVBAAARAwK4EIHjtmhnEBQIgYBoBaUNWXDyFiotLTGvX6Q3BpszpGUT8IOAdAhC83sk1egoCIBCAAGzIohsWsCmLjh\/uBgEQMIcABK85nNEKCICATQnAhiy6xMCmLDp+uBsEQMAcAhC85nBGKyAAAjYkIDeq5ebmE6\/dRYmMAGzKIuOGu0AABMwjAMFrHmu0BAIgYCMCvJRhs6+W0tPShCtDXl6+jaJzViiwKXNWvhAtCHiRAASvF7OOPoMACNCO7T7a0eAj2JDFZjBMmFBIvLwBNmWx4YlaQAAEYksAgje2PFEbCICAAwjAhsyYJCUktBMVw6bMGL6oFQRAIHICELyRs8OdIAACDiUAGzJjEic3sHVNTKGeqdnGNIJaQQAEQCACAhC8EUDDLSAAAs4l0NLcSFt8a8ThErW1G53bEZtGDpsymyYGYYGAxwlA8Hp8AKD7IOAlAryUoX7rOmppbqKqqhpsVDMg+XIDW1x8AmVkDjCgBVQJAiAAAuETgOANnxnuAAEQcCgB2JCZkzhpU5aSmk0JiSnmNIpWQAAEQCAEAQheDA8QAAFPEIANmXlp3rSpjnhpA5fsfoPNaxgtgQAIgEAQAhC8GBogAAKeIAAbMnPTLG3KsIHNXO5oDQRAIDABCF6MDBAAAdcTUNqQYaOaeemGTZl5rNESCIBAaAIQvBghIAACriewxVcrNqrxiWp80ASKOQSkTRk2sJnDG62AAAgEJwDBi9EBAiDgagKwIbM2vXIDW0Zmf4qLT7Q2GLQOAiDgWQIQvJ5NPToOAu4nABsy63Msbco6duosTmBDAQEQAAErCEDwWkEdbYIACJhCADZkpmDWbAQ2ZZqIcAEIgIDBBCB4DQaM6kEABKwhoNyoxmt38\/LyrQkErRJsyjAIQAAErCYAwWt1BtA+CICAIQTqt66nnY3bxCY1Frwo1hIoLS2h0tKpBJsya\/OA1kHAqwQgeL2aefQbBFxMADZk9kwuH0bBs73YwGbP\/CAqEHAzAQheN2cXfQMBjxKADZk9Ew+bMnvmBVGBgBcIQPB6IcvoIwh4iABsyOydbNiU2Ts\/iA4E3EoAgtetmUW\/QMCDBHgpw2ZfLfG\/VVU12KhmwzEAmzIbJgUhgYAHCEDweiDJ6CIIeIWAtCHDRjV7Z1zO8iYlZ1JS90x7B4voQAAEXEEAgtcVaUQnQAAElBvVqqtrqHfvLECxMYGEhHYiOj6Mgg+lQAEBEAABIwlA8BpJF3WDAAiYRkDakBUXT6Hi4hLT2kVDkRGATVlk3HAXCIBAZAQgeCPjhrtAAARsRAA2ZDZKRhihwKYsDFi4FARAICoCELxR4cPNIAACdiAgbciwUc0O2dAfA2zK9LPClSAAAtERgOCNjh\/uBgEQsJiA3KiWm5tPvHYXxVkE5Aa2lNRsSkhMcVbwiBYEQMAxBCB4HZMqBAoCIKAmIG3I0tPSxPHBeXn5gOQwAtKmjMPO7jfYYdEjXBAAAacQgOB1SqYQJwiAQBsCO7b7aEeDj2BD5uzBMWFCIfHyBtiUOTuPiB4E7EwAgtfO2UFsIAACQQnAhsxdgwM2Ze7KJ3oDAnYjAMFrt4wgHhAAAV0E5EY12JDpwmX7i+QGtq6JKdQzNdv28SJAEAABZxGA4HVWvhAtCIAAEbU0N9IW3xpxuERt7UYwcQkBuYEtI7M\/xcUnuqRX6AYIgIAdCEDw2iELiAEEQEA3AV7KUL91HbU0NxFsyHRjc8SFcgNbXHwCZWQOcETMCBIEQMAZBCB4nZEnRAkCIPA\/ArAhc\/dQgE2Zu\/OL3oGAVQQgeK0ij3ZBAATCJgAbsrCROe6GTZvqiE9g4wKbMselDwGDgG0JQPDaNjUIDARAQE2gfut62tm4DTZkLh8a0qYMG9hcnmh0DwRMJADBayJsNAUCIBA5AaUNGTaqRc7RKXdKmzJsYHNKxhAnCNibAASvvfOD6EAABP5HQNqQ8YlqfNAEirsJSJsybGBzd57ROxAwiwAEr1mk0Q4IgEDEBGBDFjE6R98ImzJHpw\/Bg4CtCEDw2iodCAYEQEBNADZk3h0T0qasY6fOlHXwQO+CQM9BAASiJgDBGzVCVAACIGAkAWlDxssYeDkDircIwKbMW\/lGb0HAKAIQvEaRRb0gAAJRE1BuVKuurhEnq6F4i4DSpoxneXm2FwUEQAAEwiUAwRsuMVwPAiBgGgHYkJmG2tYNlZaWUGnpVIJNma3ThOBAwNYEIHhtnR4EBwLeJQAbMu\/mPlDP+TAKnu2FTRnGBQiAQCQEIHgjoYZ7QAAEDCcAGzLDETuqAdiUOSpdCBYEbEcAgtd2KUFAIAACcqMar9nFIRMYD5IAbMowFkAABCIlAMEbKTncBwIgYAgBXsqw2VdL\/G9VVQ3l5eUb0g4qdR4B2JQ5L2eIGATsQgCC1y6ZQBwgAAKCAGzIMBBCEZgwoZB4eUNSciYldc8ELBAAARDQRQCCVxcmXAQCIGAGAdiQmUHZ+W0kJLQTnYBNmfNziR6AgFkEIHjNIo12QAAENAlIG7Li4ilUXFyieT0u8CYB2JR5M+\/oNQhEQwCCNxp6uBcEQCBmBFqaG2mLb404XAIb1WKG1bUVwabMtalFx0DAEAIQvIZgRaUgAALhEpA2ZNioFi45b14vN7DFxSdQRuYAb0JAr0EABHQTgODVjQoXggAIGEVAblTLzc0nPkIYBQT0EJA2ZSmp2ZSQmKLnFlwDAiDgUQIQvB5NPLoNAnYhIG3I0tPSaPbsctiQ2SUxDohDHkbBoWb3G+yAiBEiCICAVQQgeK0ij3ZBAAQEgR3bfbSjwUdjxhQIwYsCAnoJyBlevh42ZXqp4ToQ8CYBCF5v5h29BgFbEFDakGGjmi1S4pgg5OxuTk4OrVy5UsQNmzLHpA+BgoDpBCB4TUeOBkEABCQBuVGNZ3Z5hhcFBPQQ2LSpjnh2d9eunVRUVERr166liooKwgY2PfRwDQh4kwAErzfzjl6DgOUEYENmeQocG4Cc3S0oKCCe4eVSVlYmhG9GZn+Ki090bN8QOAiAgDEEIHiN4YpaQQAEQhDgpQz1W9dRS3MTwYYMQyUcAjy7yx68ycnJNH36dP+tLHZZ9GKWNxyauBYEvEMAgtc7uUZPQcA2BGBDZptUOC6QCRMKiWd4eSlD3759W8UvZ3lhU+a4tCJgEDCcAASv4YjRAAiAgJKAcqMabMgwNsIhIA+bYKHLglddGhoa6JZbbhF\/hk1ZOGRxLQi4nwAEr\/tzjB6CQNQEEhO7UkZGKm3c6KOWlp+jqq9+63ra2bgNNmRRUfTmzbxR7YsvPiNeu6ue3ZVEKisradGiRdQ1MYV6pmZ7ExR6DQIg0IYABC8GBQiAQFACHTp0oCvHX0KnnDyYOnXqRE1NO+m5FyppYeWbEVGDDVlE2HATkVjGwMsZeJMaC95QhWd5ebYXG9gwdEAABCQBCF6MBRAAgaAEzj93KF00+ixq164d7d79G8XF7S9E7wMPldOq9z8OmxxsyMJGhhuISGlDptyoFgwO+\/LCpgxDBwRAQEkAghfjAQQ8SOCQQw6ivof2oTfeXEZ79uwJSIBnd++\/91bqlZFKD82qoP+sWE3FN11JOccfTStWrqa7Sh8OixxsyMLChYsVBEpLS6i0dKqY2ZU2ZFqAYFOmRQivg4C3CEDweivf6C0IEAtZFq7HH\/cX8vm+oycr5tEHH37ShkzvzHSacvu1FBcXR3ff+wh9+tmXlHvCILrmqgLa8UMjTZ5SRvvv35luuH4c+Xzf0pzH\/02NjTsDEoYNGQZepASC2ZBp1Sdtyjp26ixOYEMBARDwNgEIXm\/nH733IIG\/nppH4664SCxP4LJ79276+JMvqOLpF6mubrOfCAvj6XfcQAMG9KMPV39KU6bOoIz0njStpIi6dj2A7r3\/UTr++KPpjNNOorXrNorXd+78KSBRaUPGp6mxMwMKCOglwBvVli9fGtCGTKsOOcublJxJSd0ztS7H6yAAAi4mAMHr4uSiayAQiEBKSjJdcfloGnTMEWIjmiy\/\/PIrLXlrOZU\/9aLfieGoo\/rTpRefQy\/Or6KV730kLr1z2vV0xOF\/osWvL6UTBh9DnTvvJ2Z331yyLCBw5Ua16uoa6t07C4kBAV0EpA2Zno1qgSpU2pTxLC\/P9qKAAAh4kwAErzfzjl6DAB3W7xC6rHAU\/emwbGrfvr2fSEPDD\/T0sy8J8RuojBl9Nl0waoR4qUOH9kIIl97zSNC1wLAhw2CLhAAvZRg\/vlDYkLHnLp+sFkmBTVkk1HAPCLiPAASv+3KKHoFAWAROPSWXLr3kHEpOOtB\/3++\/\/05132ymp595qc363iMOP4xuvvFKYm\/eH39sEut7P6v9SnN2t7Z2Y1hx4WJvEwjHhkyLFGzKtAjhdRBwPwEIXvfnGD0EgZAEeKb3lpsnUnLyH4JX3sDrez\/48FN6\/InnaNu2Bn89RdddQfknHU+vv\/kuPTzrqaD1w4YMgy8SApFuVAvWFmzKIskC7gEBdxGA4HVXPtEbEAibwK3FV9HgnIH022+\/0eLX36GkpG5t1vey927F0\/Pp9TfeFfXz7O555wylyqolrYSwsnG5US03N5947S4KCOglwAdM8AxvODZkWnXDpkyLEF4HAXcTgOB1d37ROxAQNmSTb7uGUnp0b2NBdmLesXT1xAKKj4+jDRs30W2T7xfWYoOOOZIuKxhFmZlp4tAJraULasy8UW2zr5b436qqGsrLy0cmQEAXATm7y0cH89rdWBXYlMWKJOoBAWcSgOB1Zt4QNQjoJjBy+KlUWDCK9tuvk7AgW\/P5OrFEoaHhR5o65Trq1\/dgavn5Z6p4aj4tqnrLXy8L5ZEjTqWzR55GH6z+NOTSBXUwsCHTnR5cqCIQjQ2ZFkw+fY2XNxhpU5aV1Yv+dtbplJ7ekz7\/fB09P6\/S73qiFR9eBwEQMI4ABK9xbFEzCNiCwHXXXk4nnXhcGwuy9V\/X0aHZWbTffvvR6o8+o6l3PBDUaSGcjsCGLBxauFZJIFobMj00x40bJy6LtU0Z+1rz05LBOUf732t79+6lz79YR3fc9VBQj2o9MeMaEACB6AlA8EbPEDWAgO0J8KzTleMvaWNBxoE3NjbRAw+V06r3P45JP6QNWXHxFCouLolJnajE\/QRiZUOmRcoImzJ+GnLzjRPEsdu8BIiXBfFhLdnZWZSW2oOenfsKLXj5Na3Q8DoIgICBBCB4DYSLqkHAbgSEBdnF57RyZAhlQRZu\/C3NjbTFt0YcLgEbsnDpeft6aUM2fPhwGjFin8+zUSXWNmVs1cfHdfNa+KXvvEePPjZXLGPgY7hPP+0keuvt\/9D\/zfyXUd1BvSAAAjoIQPDqgIRLQMBNBPjR69hLz6MhJ+VQly7x\/q4FsyDT23deylC\/dR21NDdho5peaLhOEIi1DZkWVrmBLS4+gTIyB2hdrvn6UUf+mYpvmkjbtm2nSUXTKDm5m\/80w\/btO9AL8ypp7nOvaNaDC0AABIwjAMFrHFvUDAK2JhDsiGG2IFvy9n\/o38+9GtZmG9iQ2Trdtg5O2pCxKwO7M5hRpE1ZSmo2JSSmRNVk165dqPTOGykjI5U2b\/mOUnv2ELO9XL76agNNvXOmWOaAAgIgYB0BCF7r2KNlELAFAbUFGQfFxwtPv3sWffnV17pilDZk6WlpNHt2OWzIdFHDRUzAKBsyLboNDQ3ESxu4ZPcbrHW55uu8fvfqiWMpMTFBXLt792+06v3\/0iOPPgOxq0kPF4CA8QQgeI1njBZAwBEE5Prebt0SaVHVEnrsX8\/pjnvHdh\/taPDRmDEFQvCigIBeAmxD9sUXn4lDJsya3ZWxSZuyrokp1DM1W2\/IQa\/r1SuN8k88jnb\/todqalbQtu\/\/OJ0w6spRAQiAQFQEIHijwoebQcBdBHh9719PzaP3Vn0U9AQ1dY+VNmTYqOau8WB0b+RGtZycHCF4rShG2ZRxX9i9oe+hfahz5\/1E13j2NzW1By1+fSlmfa1INtr0NAEIXk+nH50HgegJbPHVio1qPLPLM7woIKCHAC9l4NndXbt20vTp0\/XcYsg1fBAFz\/Tq2cDG697PPD2fevRIovS01H3xtCPq3v1A2r9zZ\/Gf7Tu0p7j99w8aKx\/hPX9BNT0z92VD+oNKQQAEAhOA4MXIAAEQiJgAbMgiRuf5G+XsLs\/s8gyvlUVuYMvI7E9x8YlBQ+EZ2+l33EADBvQLeg27nfz6627x+s+\/\/ELbt\/9AtJdoz+976Ntv62nXrmb6fvsOevmV163sMtoGAc8RgOD1XMrRYRCIDQHYkMWGoxdrMduGTIuxtCnr2KmzOIEtVOnX72A6\/rijae3aDX4XExayWK+rRRmvg4C1BCB4reWP1kHAsQRgQ+bY1FkeuBU2ZFqdjtamjGd\/83IHiTW7P\/zYRIuq3grL1k8rPrwOAiAQHQEI3uj44W4Q8CQB5UY12JB5cghE3Olly5bSsGFDhCMD++7apURjUzY4ZyBdftkF1DOluzhamMuGjZvovvvn0Cbft3bpIuIAAU8TgOD1dPrReTcQYNP7nTt\/MrUr9VvX087GbbAhM5W68xvjpQzjxxdaZkOmRbCyspIWLVpE4diUnXlGPl1eeAGxwwkf071ly1Zq174dpaf1pNcWLxU+vCggAALWE4DgtT4HiAAEIiZwWL9DaNI1l9GClxfTm0uWRVxPODfK2V2+Jzc3n6qra8K5Hdd6mIAdbMi08PNhFDzbq7WBjevhZQz333urWMawdev39Ohjc+mDDz+h3BMG0TVXFdC339XTpH9O02oSr4MACJhAAILXBMhoAgSMIjBm9Nl0wagR9M2mzXTb5PsDenvyl3J29kHiCzkWx5tKG7LMrEzy1fmoqqoGJ6sZlWAX1WsXGzItpOHYlGWk96RpJUUUF9eZ7r1\/Dn38yefEyxvGXXERde+eRLVr1tJNxaVaTeJ1EAABEwhA8JoAGU2AgFEEEhO7Usnk6+jQ7Cxa\/MY79PCsp1o1xY9bL734HEpI6Ers\/\/n1hk303PMLxSxUJEXakLHYXbVxFaW3S6fevbMIB05EQtNb95SWllBp6VRxwITVNmRa5PXalHE9U6dcR0cd+Wf68suv6YAu8XRQ7wxq37692LD2RPkLYlkDCgiAgPUEIHitzwEiAIGoCJyYdyxdPXHfgQ8Pzaqgd5e9L\/4\/L3e45eaJxKJ4716iTp06ir\/zF\/HTz75ECyvfDKtdpQ3Z\/Jr5NDh\/MM2rmEeTCidRcfEUKi4uCas+XOwdAnazIdMiH45N2TEDD6dJ115OB3b7w7+3oeEHerJiHi195z2tpvA6CICASQQgeE0CjWZAwEgCV00cS2ecdhJtrPP5lzbI5Q6LqpbQE+Xz6IJRw2nEsFPEbO8PPzbSnXc9RF9+9bXusKQN2aiCUTSzfKb\/vnOHnEsrl64Us7w824sCAmoCfKLa8uVLhSsDuzM4ochZ3qTkTErqnhky5F690mjY0JMprWcPWvrue7Rs+Qe0Z88eJ3QTMYKAZwhA8Hom1eiomwnwLO6d066ng3r3ourX3habZ8Zeci6df94wqq\/fTveWPUpffbWBDjnkIDHrm3RgNyqvmEcLFy3RhUVuVOOlDDy7y\/\/KsmLpCjpvyHlwbNBF0nsXSRsyXsbAyxmcUpQ2ZXwYBR9KgQICIOBcAhC8zs0dIvcoAZ5NOvus0ygtNYU+XP0pLX79HbFM4a+n5onNMny06UOznhJWZTffeCV165ZAv\/zyKy1b\/j69t+q\/dMnF51By0oF0z32z6aP\/1uqiKG3IiqYUUVFJW+9UOcuLDWy6cHrmIqUNGc\/uJicnO6rvkdiUOaqDCBYEPEQAgtdDyUZXnU9AzNDeNJFSU3v4O9PUtJOee6FSrMktuu4KGpKfQ+vW11HJtBl0zNGH0+WXXSjW8cqyd+9eWvneR3T3vbN1PXZVzu7yRrVAhd0ajutznOdtytr9tJPiLhhJHZb9sVFp94WX0M+PPe38wRdBD6QN2fDhw2nEiBER1GD9LeHYlFkfLSIAARAIRgCCF2MDBBxE4Mbrx9EJg48RM7Px8fHUr28f6tSpE7X8\/DM9\/cxL9PHHa2jybddSSkp3\/9KGlJRkuuD8ETRo0BHUsUNH+viTNTTn8X\/rtiiTNmS8bpfX7wYrZSVlVDa1jPjktTFjnPPoOlbpb\/fdtxR\/eh61r9vQpso9efnU8sJC2tvljx8esWrXrvU4baNaMI7h2JTZNReICwRAgAiCF6MABBxEYOb\/TaaM9FR6+JGn6Z1336NBxxxJlxeOoszMdFq7biNdf+NdxFZkBWPPo92\/7lvasGLl6oh7KDeq5eTn0IKaBZr18Cwvz\/Y2Ne3VvNZtF3SsepXiRp9Ne7sdSC2vvE57jh5E8m\/c15bnXqHfhp3ltm4H7c+ECYXEM7xOsCHTSko4NmVadeF1EAABawhA8FrDHa2CQEQE7iktpgH9+1LDjh\/EjO6St5YT2yLdeP142vFDI02eUkbbvm+g4puuFDPBa9dupKl3ztQ9m6sMipcybPbVUlpGCs0onyFsyLSKtCnjGV6e6fVS2a+slDpPvYV+zzqYmrCGBTUAACAASURBVF9fRnvT0km5xOGXKdPp16JiTyCRs7vsyMBrd51ewrEpc3pfET8IuJUABK9bM4t+uZJAzvFH09UTx1JiYgL9\/vvvtG3bdvptzx5KT+spPD\/LZjwu+i3X+nbvfiAtqnqLHn\/i+bB57Njuox0NPrGMQWlDplWRVzewdfjoA4o7+3Rq9+MPApGX1+6yDdkXX3wmZnedYkOmNa4rKiqIlzfosSnTqku+npXVi0ZfMJIG9O9HCQld9h1Y8fPP4ofqvBcXiZPbUEAABGJDAII3NhxRCwiYRuCoo\/rTuL9fRJmZadSuXTvRLvvvznjgCfr662\/8cYwc8Ve69JJz6NdffhVLG3ijmt4SyoZMqw5pU5abm0\/V1TVal7vqdTnLq+yUcsbXVZ0N0hmn2pDpyc24cePEZdHalPEm0ivHX0LHHfsX\/4Ew6vZ\/\/XW32Iha\/tSLekLDNSAAAhoEIHgxREDAoQSOOPwwGnj04cSnOr351nJhTaYsHTp0EEsbeFb48y\/W0bQ7HxRWZXqKlg2ZVh1eneVlLsE2r3lhDa\/Tbci0xrXcwNY1MYV6pmZrXR7wdX76ct21l1MfhZc1X8gCly0F23doT3H77y\/ulZtRwz0VMaLAcBMIuJwABK\/LE4zueZvAvqUNV9LnX6z3L3fQItLS3EhbfGvE4RLBbMi06uDX09uli5PX+AQ2rxblMgcvODW4wYZMa6xGY1PGM7tTbptE\/fod7G+Gf7C+svANem3xUvGjlX+ojr5wpPDaZuG7des2mnrHA7TJ961WaHgdBEAgBAEIXgwPEHA5AZ4J5g1tmzd\/p9lTXspQv3UdtTQ3iRPV9GxUC1apl2zKlJvT1Gt3pVOD25c2uMWGTOtNIjewxcUnUEbmAK3LW73OyxiGnjlELEX67bffaMXKj+jBh8vbPJ3hm6Sn9u+\/76X5L1XT089ou6SEFQwuBgGPEYDg9VjC0V0QCEUgXBsyLZpesimT63eVtmRKIez2GV5pQ8auDG7ZqBb0x1xZGbHwTUnNpoTEFK23gXg9pUcyTZtaRJm90oTY1dpMmnvCILrmqgI64IB4ql2zlm4qLtXVDi4CARAITACCFyMDBEBAEIjEhkwLnZdsykIdPMGc3LyG1202ZFrjuqGhgXhpA5fsftp2fXzdUUf+mYpvmkhdusTTpk3f0s233h3SLlDaDbLgXbd+I0365zStsPA6CIBACAIQvBgeIAACgkCkNmRa+Ly0gS3Q0cLKGV8tVk593Y02ZFq5kDZlejewKQUvHwZzV+nDIZu4auJYOuO0k8TyB8zwamUDr4OANgEIXm1GuAIEXE9AaUMWzUa1QKC8bFPm+oFDJE5T4+UMOTk5wnfXS0XalGVk9qe4+MSQXee19OyakpDQldZ8vpaKb72X9uzZE\/CejPSedPut14gTFPfs+R1reL00qNBXwwhA8BqGFhWDgHMIbPHVio1qfMAEHzQR6zKpcBLx8oaqqhrKy8uPdfWozyICvJSBZ3d37dpJ06dPtygK65qVNmV6NrCx+8L9995KfQ\/tQ83NLfTQrAp6d9n7QYOXh8ewVdnkqf9H27Y1WNdRtAwCLiAAweuCJKILIBANgVjZkGnFAJsyLULOe720tIRKS6eKmV2e4fViKfvfBjY9s7zn\/u1MunjM2bTffvvRrl3N4mjw9z\/4hJKTutF39d\/T55+va4WwV6806tixA9XVbfb\/nTe\/8fHhKCAAAuERgOANjxeuBgFXEYilDZkWGLmBrbh4ChUXl2hdjtdtTsArNmRaaZA2ZR07dRYnsIUqPMt7840TxGEw8pREeX31a2\/TrNnPBL2d1wCPuehsOqh3Bj38yFMhZ4e1YsbrIOBFAhC8Xsw6+gwC\/yMQaxsyLbByAxsfRsGHUqA4l4CXbMi0siRnefXYlPHhEzcUjaMjj\/gTtW\/f3l91sI1pKSnJdMXlo2nQMUdQp06dxPVfrd1AU6bO0H1yolb8eB0EvEAAgtcLWUYfQSAAAeVGNT5kgk9WM7rIDWxjxhTQ7NnlRjeH+g0isGzZUho2bIjw22XfXa+XSGzKTsw7lk45+QRKTe0hjhVeu3Yj\/evJ5\/2HUPBs8AWjhtOIYaeIjW6y8JreDz78VMzyNjbu9Dp69B8EdBOA4NWNCheCgLsI1G9dTzsbt4lNarxZzaziJZsys5ia2Q4vZRg\/vpC++OIzsXbX7YdM6GVbWVlJixYtIr02ZaHqPfWUXLr4or9R9+4H+pc+7N27l3y+7+jJinn0wYef6A0L14EACPyPAAQvhgIIeJCAkTZkWjh9dT7iE9hyc\/OpurpG63JPvM4zprz5yyll+fKlIlSI3dYZ4\/W8XNi1IZKy\/\/6dKT09lQ6Ij2t1++7ffqOGhh9o+\/c7aC\/t9b8WF5dISd2NfzITSV9wDwjYjQAEr90ygnhAwAQCRtuQaXVB2pTxsgZe3uD1IpcIeJ0D+h8eAT12aOHViKtBwL0EIHjdm1v0DAQCEpAb1XjNbqwPmQgHOduUcWlq+mPGKpz73XStFLyT75xDw8+62E1dQ18MInDs4QeImeSMzAEGtYBqQcBdBCB43ZVP9AYEQhLgpQybfbXE\/\/JGtcH5gy0jBpuyP9BD8Fo2DB3bMAvelJ7p9PDDj9Bbby2nt2pWOLYvCBwEzCAAwWsGZbQBAjYhIGd3zd6oFqz7sCnbRwaC1yZvEAeFwYJ30KBB9Oyzz9KGjZvotsn3w7XBQflDqOYTgOA1nzlaBAFLCFhhQ6bVUdiUQfBqjRG8HpgAC95jjz2WnnnmGfrll1\/pyfIXaFH128AFAiAQhAAEL4YGCHiEgLQhK5pSREUl9vFOhU1ZZDO879QsohuuuSDo6B06YjSVTP9XzEZ3866fqOia86lnzwx\/vRxDzZuvxLSdmAXs8oqk4L3rrntgVebyXKN7sSEAwRsbjqgFBGxNwEobMi0wsCmLTvDe9+ALdNKQ4VqYo35dLXgDCeCoG0EFugmw4M3snUXxXTJpz549uu\/DhSDgVQIQvF7NPPrtKQLShszqjWrBoJeVlFHZ1DJx+poXbcoiWcMrZ3gheD31VvZ3Fi4N3sw7eh05AQjeyNnhThBwBAG5US0nP4cW1Cywbcx8GAXP9nrRpsxowfv9tu9oXMFptNm3wZ9\/5ZIH+fpZ5xbQ2Mv\/WO7y1BNl9Ez5DHrw0Vcpq08\/\/5KGiZPuaFVfQuKB4po\/Dxho2\/HltsAgeN2WUfTHaAIQvEYTRv0gYCEBaUOWlpFCM8pnWGpDpoVB2pTxDC\/P9HqpGCl4A4nZz2tX0zXjz6JLCq8TAjdcwctrg7GkwdoRCsFrLX+07jwCELzOyxkiBgHdBHZs99GOBh\/ZxYZMK3CvbmCLRvAGYqqcveVZ2lcXVNCcijeoR0qa\/\/KSW\/5O9fVbqOzBF2nXrp1ixlbvDC8Er9ZINv51CF7jGaMFdxGA4HVXPtEbEPATsKMNmVZ6pE1Zbm4+VVfXaF3umtejEbzhrOGVM7tNjT8IdgOPPRGC16GjCILXoYlD2JYRgOC1DD0aBgFjCciNanazIdPq9aTCScTLG6qqaigvL1\/rcle8bqTgVa\/flbO\/mOF19tCB4HV2\/hC9+QQgeM1njhZBwHACLc2NtMW3hjKzMmnVxlWGtxfrBtLbpVPv3llUW7sx1lXbsj4jBS8L208\/XoUlDbbMfORBQfBGzg53epMABK83845eu5gAL2Wo37qOWpqbyK42ZFr4pU1ZcfEUKi4u0brc8a8bJXjlxjIGxGt14w\/oIljJWd+eab1CLmlgsbz83cVtXBqwhtf6IceCt3uPVOqWdLD1wSACEHAAAQheByQJIYJAOAScYkOm1SdpU8azvDzb6+ZilOBlZkrRKm3D+G\/Vlc\/51\/CyEFbPBEufX2k5prQlkye4KZdFSDHt5jzZqW8seJO7p9KByRC8dsoLYrEvAQhe++YGkYFA2AScZEOm1Tm5gc0NNmWb2tfR3I4VVNp5quh279+zaMzusVT8677ZayMFrxS9LHBlmThpmvi\/0mOXhbCcDV79\/rviNd7QNvJvY6ns7usDzvDyNcrjjcPZPKeVe7yuTQBLGrQZ4QoQUBKA4MV4AAEXEajfup52Nm5zjA2ZFno32JSx2B0aN4T4X3Vh4Vu7a2NEgleLHV53NwEIXnfnF72LPQEI3tgzRY0gYAkBpQ2ZEzeqBYLmBpuy0v1K\/DO79PrpRM9fSHTh80Snvy66XPzLFMp9K5+GDRtCk++cQ8PPutiS8YNGnUUAgtdZ+UK01hOA4LU+B4gABGJCQNqQzSyfKWZ43VKcblM24IA++2Z3WeyesfiPtCw+wy96q6prIHjdMmBN6gcEr0mg0YxrCEDwuiaV6IiXCTjdhkwrd062KUvo2m5f9wrLiSoK\/uhqQQVReaH479mLy2nCmYWY4dUaCHjdTwCCF4MBBMIjAMEbHi9cDQK2I+AGGzItqHwQBc\/0OtGmTGuGl9fxsuDFkgatUYDXlQQgeDEeQCA8AhC84fHC1SBgOwLShoyXMfByBrcWuYHNaTZlWmt4x+wuoIveHAvB69aBa1C\/IHgNAotqXUsAgte1qUXHvEBAuVGND5ngk9XcWpxsUzY0fggt77C0TWrg0uDW0Wp8vyB4jWeMFtxFAILXXflEbzxGwG02ZFrpc7JNmXKmNxY+vJKVPDXt2htK6aQhw9sgfOqJMnp1QUWbo4U\/r11N14w\/i5oafxD3DB0xmuSBEqHyEOl96jrV9cgDLuThGPJ6pdcv\/439gZWnxqnrVV+vfp09iMdeXqQ11Pyvq+MM1L7MwWbfBnFfr8yD2\/AO1KBW3dyX55+dFbC\/ELy6U4gLQUAQgODFQAABhxJwow2ZVip8dT7iE9hyc\/OpurpG63LHvB7JwROyc3zaGZdAYlUKqoSEA1sJMPn32+94VIhkKdiOOOq4kKI30vuCiVKl+GRhPmvmZFIeYKH+m\/pIZL2nu8lDNeq\/26xLiMp4ZX8vKbxOiORA9QRiF+h0u2CCP1TdIq9B8gvB65i3NwK1CQEIXpskAmGAQLgE3GpDpsWhrKSMyqaW0ezZ5cSnsLmhRCp4eQbwgfuKA4o45clpyhlH+Xfmppwp5bruuH28OFVNPcvK10Z6X6D8BDqSWNbfs2eGEN1SSJ51bkGrGVmtOAO1x8JZeaqc3jETKE616A80gx4sdmW7eurm67m9W28YS3fd91SrvEDw6s0irgOBfQQgeDESQMCBBORGtZz8HFpQs8CBPYguZJ7l5dnepqa90VVkk7sjEbxqgajuCgux91YsocOPOJaWvP6SXxQHE2NaIi3S+\/QiVgvqD95fGlTM662Tr9M7e623TrXgDXSfFstgbQWrO9AsLwSv3ozhOhCA4MUYAAFHEuClDJt9tcT\/8ka1wfmDHdmPaIJ2sk1ZoH5HInhDCS\/lLOgHq5a2WsMb7D4tYRjpfXrzrG5fCvabb3+QrrvyHJLrY\/WuNZbtRjq7G0rI9kzrFXQdcaTLJ0It1wg0qw3Bq3dk4ToQgODFGAABRxLwig2ZVnKcalMWK8Eb7NG+enZR\/cg9mHDVmjGO9D6tPMrX1ete+b+rK58j5Wa2cNfwaol4vbEpl4cE21zHdcmY+f8r1yKHakdP3YHYQ\/DqzR6uAwEIXowBEHAcAS\/ZkGklR9qUuWEDWyQzvMHcF9RrQ50geOXmNOUmNike1cJRujDoEZThXKs13uTrss5Qbg9SoOaeeIYu5wutugMtkYDg1ZsxXAcCELwYAyDgOALShqxoShEVlei3VnJcR3UG7GSbMmUXIxG8LAg\/\/XhVqw1rgWZ99QperdlQo5Y0BBK7crZ0+buL22yiC2d9bCBGOodWyMv01BvpUopAdUPwxiJrqMPrBLBpzesjAP13DIGW5kba4lsjDpdYtXGVY+I2MlC32JRFIngDzfAqH6kH4s6zkkNHXETjCk4jtfuBlpA0YtOajDfQbGkwwagVp+y3loCPZlxC8EZDD\/eCgDUEIHit4Y5WQSBsAtKGzKsb1YIBc4NNWSSCV689l1oYB1urq1VfpPcFy1uwJQvyerUHrvy7Vpzq+6XXcLhvuGD9VbtJ3HvXJKqv39JmE1soUay3bukzjDW84WYP14NAWwIQvBgVIOAAAl63IdNKkdNtyiIRvHrssZhboJlg9TpUvbOhkd6nzl+gQyYC5Vi9kU1vnFyXXmEcamwFWgOsFuqBhHmwZRrKtvTUHUrkYw2v1qcCXgeB1gQgeDEiQMDmBKQNWVpGCs0on+FJGzKtFEmbMj6Igg+kcFqJRPByH0OdsiYZRHq0cLAZVq2jhYPdJ+NRH8OrzpX6WF4pHuV1aluyYEsftNbQar0u21P3N9Cxweo+BXJyCDTjq6fuYHmG4HXauxzxWk0AgtfqDKB9ENAgsGO7j3Y0+GhUwSiaWT4TvIIQcPIGtkgFbyxmMY0YUBxX3YavWp2QZkQ70dZ53\/R\/0rCRYwKeLBdt3bG6HyetxYok6vE6AQher48A9N\/WBJQ2ZNioFjpVTrYpi1Tw6p3lNXuQ82zmkL+eTScNGW5207rb41nZycWX0bTSJ6lHSpru+8y+MNgsPmZ4zc4E2nM6AQhep2cQ8buagNyoxjO7PMOLEprApMJJxMsbqqpqKC8v3zG4ohG88nH6tTeU2kJgcjyzZt5ON946k+SmKzsmwgmz0Bzj88\/OCniqGwSvHUcVYrIzAQheO2cHsXmaAGzIIkt\/ert06t07i2prN0ZWgQV3RSN4LQgXTdqAAASvDZKAEBxFAILXUelCsF4hwEsZ6reuo5bmJoINWXhZlzZlxcVTqLi4JLybLbpaCt7hZ11MRw\/KsygKNOskAtNuG0dx8QmUkTnASWEjVhCwjAAEr2Xo0TAIBCcAG7LoRoe0KeNZXp7ttXuRgtfucSI+exGA4LVXPhCNvQlA8No7P4jOgwSUG9VgQxbZAJAb2JxkU8ai1wll06Y6mjChkJKTk6mgoMAJIbsqxrKyMtGfjMz+4t+4+ERX9Q+dAQGjCEDwGkUW9YJAhATqt66nnY3bYEMWIT95m5NtyqLsuuG3s+CdO7eCioqKqG\/fvoa3hwb+IFBZWUmLFi2irokp1DM1G2hAAAR0EoDg1QkKl4GAGQRgQxY7yr46H\/HShtzcfKquroldxahJEEhIaCdmeadPnw4iJhO45ZZbqKGhQczyYobXZPhozrEEIHgdmzoE7kYCsCGLbVadalMWWwrG1MYzvDzTO3z4cBoxYoQxjaDWgARWrlxJFRUV2LSG8QECYRCA4A0DFi4FASMJwIbMGLpOtCkzhkTsax06dAgtX75UzPLybC+KeQR4Le\/atWsxy2secrTkcAIQvA5PIMJ3BwHYkBmXRz6Igmd6nWRTZhyN2NYs3SVycnKwgS22aDVrY7HLordjp86UdfBAzetxAQh4nQAEr9dHAPpvCwLShoxPU+NT1VBiS0BuYHOKTVlse29sbXKWFxvYjOUcqHY5y5uUnElJ3TPNDwAtgoCDCEDwOihZCNWdBJQb1fiQicwsfHHFOtNOtCmLNQOj6mObsgED+gi3Bha9KOYR4I1rvIGNC8\/y8mwvCgiAQGACELwYGSBgMQHYkJmTANiUGcdZ2pSxLy8vb0AxjwBsysxjjZacTQCC19n5Q\/QOJwAbMvMSCJsyY1nzLC\/P9s6ZM8fYhlB7GwKwKcOgAAFtAhC82oxwBQgYRgA2ZIahDVhxWUkZlU0to9mzy4lPYUOJHQHYlMWOZbg1waYsXGK43osEIHi9mHX02RYE5Ea1nPwcWlCzwBYxeSEIPoyCZ3ubmvZ6obum9hE2ZabibtUYbMqsY4+WnUEAgtcZeUKULiPASxk2+2opLSOFZpTPoMH5g13WQ\/t2R9qU8Qwvz\/SixI4AbMpixzLcmmBTFi4xXO81AhC8Xss4+msLArAhszYNsCkzjj9syoxjq1Uzn77GyxtgU6ZFCq97kQAErxezjj5bSgA2ZJbiF41Lm7Lc3Hyqrq6xPiAXRQCbMmuTOW7cOBEAbMqszQNatx8BCF775QQRuZyAtCErmlJERSXwLbUq3bApM458aWkJlZZOFaevwabMOM6BaoZNmbm80ZpzCEDwOidXiNQFBFqaG2mLb404XGLVxlUu6JFzuyBtynr3ziI+gQ0ltgRgUxZbnuHUBpuycGjhWq8QgOD1SqbRT8sJ8FKG+q3rqKW5ifhENWxUszwlBJsy43Igbcp4hpdnelHMIyA3sMXFJ1BG5gDzGkZLIGBjAhC8Nk4OQnMXAdiQ2TOfsCkzLi\/YwGYcW62apU1ZSmo2JSSmaF2O10HA9QQgeF2fYnTQDgRgQ2aHLASOATZlxuVG2pT17duXioqwXt040m1rbmhoIF7awCW7H2wPzWSPtuxJAILXnnlBVC4jsGO7j3Y0+GhUwSiaWT7TZb1zfnewgc24HE6YUEi8vIEFLwtfFPMISJuyrokp1DM127yG0RII2JAABK8Nk4KQ3EVAaUOGjWr2zC1syozNS0JCO0pOTqbp06cb2xBqb0MANmUYFCCwjwAEL0YCCBhMYIuvVmxU45ldnuFFsSeBSYWTiJc3VFXVUF5evj2DdGhU0qZs+PDhNGLECIf2wplh80EUPNOLDWzOzB+ijh0BCN7YsURNINCGAGzInDUo0tulE2zKjMmZtCnjWV6e7UUxj4DcwJaR2Z\/i4hPNaxgtgYCNCEDw2igZCMVdBMy0IWu38ydKGllA+y1dQXsOPogalr1Ce9J7+oF2KX2Iut5S6n+NX0jOO5s6bPgmIPRf8wfTjoUVtLdrF3clRaM3cgNbcfEUKi4u8VTfje6s3MAGmzKjSbetX9qUdezUWZzAhgICXiQAwevFrKPPphAw04ZMKXi5cy2XnEc\/Pv1gxIKXb\/z9wETa8fpztHvQUabwsksj0qaMD6Pg2V6U2BGATVnsWIZbE2zKwiWG691GAILXbRlFf2xBQLlRbUb5DMMPmVALXobwwyvl9PNZpwseoWZ4ldfxtZ0++JiSTh9N7X9oJC\/O9MoNbGPGFNDs2eW2GE9uCQI2ZdZlEjZl1rFHy\/YgAMFrjzwgCpcRqN+6nnY2bjPNhiyQ4FWK1XAEL6di\/1dfpwPPLvTsLC9syox7Q8KmzDi2WjVXVlbSokWLCDZlWqTwuhsJQPC6Mavok6UErLAha7WGt09vavdjo5ih3Tm9mH4qvjqsGV6G1+Hbev8aX1mHpVBNbtxX5yNe2pCbm0\/V1TUmt+7+5mBTZl2O+TAKnu3FBjbrcoCWrSEAwWsNd7TqYgJW2JApBS+v3\/3tT4eKTWpyHW7nJcuCblpTL2ng1Cjr86LgZQawKTPuTcoHUfBML2zKjGMcrGbYlJnPHC3agwAErz3ygChcQsAqGzK14N15963+GVqlAJYODoxbujRA8AYffGxTxqWpaa9LRqh9uiE3sMGmzPycwKbMfOZo0XoCELzW5wARuISAmTZkamRqwcsODXIdLl+7+6j+1OnjNQFtyQIJXq8vaZB8YVNm3JsTNmXGsdWqGTZlWoTwuhsJQPC6MavokyUEpA0Zn6bGp6qZWQIJXm6\/26XXUNwz8\/2h6J3hlU4NfKMXrcmUuZMb2GBTFvsRDZuy2DPVW6Oc5U1KzqSk7pl6b8N1IOBYAhC8jk0dArcTAeVGtfk18ykzy9wvkGCCV2kxxrz0CF7l7K4XbcnU4wo2Zca90zZtqiM+ga1v375UVFRkXEOouQ0BpU0ZH0bBh1KggICbCUDwujm76JtpBKQNWdGUIioqMf+LO5jgZQDSkiyY4A0GyasHTwTiAZsy495KpaUlVFo6lQoKCohPYUMxjwBsysxjjZasJwDBa30OEIHDCVhhQ6ZGFkrwBjp2mO8PdbSw+qQ2h6co6vBhUxY1wpAV8Cwvz\/bOmTPH2IZQexsCsCnDoPAKAQher2Qa\/TSMgBU2ZIZ1BhUHJVBWUkZlU8vE6Wt8ChtK7AjApix2LMOtCTZl4RLD9U4lAMHr1MwhblsQkBvVcvJzaEHNAlvEhCCMI8CHUfBsL2zKYs8YNmWxZ6q3RtiU6SWF65xMAILXydlD7JYS4KUMm321lJaRQjPKZ9Dg\/MGWxoPGjScgbcp4hpdnelFiR0DalGEDW+yY6q1J2pTx9dn98DmmlxuucxYBCF5n5QvR2ojAju0+2tHgIytsyGyEwXOhYAObcSmHTZlxbLVqrqioIF7eAJsyLVJ43akEIHidmjnEbSkBq23ILO28xxuXNmW5uflUXV3jcRqx7T5symLLM9zaxo0bJ26BTVm45HC9EwhA8DohS4jRdgTkRjWrbMhsB8RjAWGW17iEw6bMOLZaNcsNbF0TU6hnarbW5XgdBBxFAILXUelCsHYg0NLcSFt8a8ThEqs2rrJDSIjBAgLp7dKpd+8s4hPYUGJLADZlseUZTm3YwBYOLVzrJAIQvE7KFmK1nAAvZajfuo5ampuIT1TDRjXLU2JZALApMw69tCnjgyj4QAoU8wjIDWxx8QmUkTnAvIbREggYTACC12DAqN5dBGBD5q58Rtsb2JRFSzD4\/djAZhxbrZrlLG9KajYlJKZoXY7XQcARBCB4HZEmBGkHArAhs0MW7BUDbMqMywdsyoxjq1VzQ0MD8QlsXGBTpkULrzuFAASvUzKFOC0nABsyy1NgywCwgc24tEyYUEi8vKGoqIjYnxfFPALSpgwb2MxjjpaMJQDBayxf1O4SAkobMmxUc0lSY9QN2JTFCGSQahIS2lFycjJNnz7d2IZQexsC0qYsI7M\/xcUnghAIOJoABK+j04fgzSIgbchmls8UB02ggICSwKTCScTLG6qqaigvLx9wYkhA2pQNHz6cRowYEcOaUZUWAWlThg1sWqTwuhMIQPA6IUuI0VICsCGzFL9jGodNmXGpkjZlPMvLs70o5hGATZl5rNGSsQQgeI3li9odTgA2ZA5PoInhyw1sxcVTqLi4xMSW3d+Us3AYLAAAFAxJREFU3MAGmzLzcy1tyjp26ixOYEMBAacSgOB1auYQtykEpA0ZL2Pg5QwoIBCKgNzAxodR8KEUKLEjAJuy2LEMtybYlIVLDNfbkQAErx2zgphsQUC5UY0PmeCT1VBAIBQBuYFtzJgCmj27HLBiSGDTpjripQ3s1sCuDSjmEYBNmXms0ZJxBCB4jWOLmh1OoH7retrZuE1sUsPsrsOTaWL4sCkzDjZsyoxjq1VzZWUlLVq0iGBTpkUKr9uVAASvXTODuCwlABsyS\/E7unFfnY\/4BLbc3Hyqrq5xdF\/sGDxsyqzLCh9GwbO9sCmzLgdoOXICELyRs8OdLiYAGzIXJ9eErkmbMl7WwMsbUGJHgA+i4Jle2JTFjqnemmBTppcUrrMjAQheO2YFMVlKQG5U4zW7OGTC0lQ4unGe5eXZ3qamvY7uhx2DlxvYYFNmfnZgU2Y+c7QYGwIQvLHhiFpcQoCXMmz21RL\/yxvVBucPdknP0A2zCcCmzDjisCkzjq1WzbAp0yKE1+1KAILXrplBXJYQgA2ZJdhd2yhsyoxLLWzKjGOrVXNFRQXx8oak5ExK6g73Gi1eeN0eBCB47ZEHRGEDArAhs0ESXBYCbMqMS6gdbcp61NXR0AceoM7Nzf6ON3XvTgtvuIGau3UzDoYFNY8bN060yodR8KEUKCBgdwIQvHbPEOIzjYC0ISuaUkRFJfD5NA28yxuCTZlxCS4tLaHS0qlUUFBAfAqblWVIeTkd+t57QUN4\/+yz6eMzz7QyxJi2DZuymOJEZSYQgOA1ATKasD8B2JDZP0dOjRA2ZcZmjg+j4NneOXPmGNtQiNqzPvmETnvkEXGFUtjG\/\/gjjbzvPkrYvp1+iY+n6muvpe+z3HMCH2zKLBtyaDgCAhC8EUDDLe4jIG3IsFHNfbm1Q4\/KSsqobGqZOH0NNmWxzYi0KeMZXp7pNbt0+vlnOn3WLEpfu5bWHX881RQWtgqBlzmc+vjjtOSKK1wldrmTsCkze7ShvWgIQPBGQw\/3uoKA3KiWk59DC2oWuKJP6IT9CHjZpoxnYL\/5ps6wpLAvL7dhhU2Zct3uG1deSXVHHmlYP+1YsbQpS0nNpoTEFDuGiJhAQBCA4MVA8DQBaUOWlpFCM8pnwIbM06PB2M5LmzKe4eWZXq8VPiHN6NK3b18qKjJ3\/b0UvNw3ty1Z0JMvaVPG12b3g42jHma4xhoCELzWcEerNiGwY7uPdjT4aFTBKJpZPtMmUSEMtxLw8gY2ufSARengwcYJI7M3r3ld8PJ7FTZlbv3Ecle\/IHjdlU\/0JgwCsCELAxYujQkBaVOWm5tP1dU1ManTSZW48YQ0ry9pkOMPNmVOeid6M1YIXm\/mHb0mIrlRjWd2eYYXBQTMIDCpcBLx8oaqqhrKy8s3o0nbtOHGE9L0bFpjb953Cgpcvb5XbmDrmphCPVOzbTPmEAgISAIQvBgLniTQ0txIW3xrKDMrk1ZtXOVJBui0dQTS26VT795ZVFu70bogLGrZjSekedWWTD2E5Aa2jMz+FBefaNEIQ7MgEJgABC9GhucI8FKG+q3rqKW5iWBD5rn026LD0qasuHgKFReX2CIms4Kw4wlpsei71w6eCMRMbmCLi0+gjMwBscCKOkAgZgQgeGOGEhU5hQBsyJySKXfHKW3KeJaXZ3u9VOx0QlosuQc6WtiNB06EYgabsliOKNQVSwIQvLGkibpsTwA2ZLZPkWcClBvYvGpTZocT0jwz2EzsaENDA\/EJbFxgU2YieDSlSQCCVxMRLnATgfqt62ln4zbYkLkpqQ7uC2zKCsmqE9IcPGxsH7q0KcMGNtunylMBQvB6Kt3e7qzShgwb1bw9FuzSe9iUDaHly5eKwyLYnxfFPQR4lpdne7GBzT05dXpPIHidnkHEr5sAbMh0o8KFJhKATdkQIXbNPiHNxBR7silpU4YNbJ5Mvy07DcFry7QgqFgTgA1ZrImivlgSgE0ZZnljOZ7sUhdsyuySCcTBBCB4MQ5cTwA2ZK5PseM7yAdR8EyvF23KOHkJCe0oOTmZpk+f7vhcogN\/EJA2ZR07daasgwcCDQhYSgCC11L8aNwMAtKGjE9T41PVUEDAjgTkBjbYlOXYMT2IKUICcpY3KTmTkrpnRlgLbgOB6AlA8EbPEDXYmIByoxofMsEnq6GAgB0JwKasD\/GhFHPmzLFjehBThASUNmU8y8uzvSggYAUBCF4rqKNN0wjAhsw01GgoBgRgUwabshgMI9tVUVlZSYsWLSLYlNkuNZ4KCILXU+n2VmdhQ+atfLuht746H\/EJbLm5+VRdXeOGLoXVh6FDYVMWFjAHXQybMgcly6WhQvC6NLHoFhFsyDAKnEigrKSMyqaW0ezZ5cSnsHmpLFu2lIYNg02ZG3MOmzI3ZtVZfYLgdVa+EK1OAnKjWk5+Di2oWaDzLlwGAvYgwLO8PNvb1LTXHgGZGMWECYU0d24FDqMwkblZTcGmzCzSaCcQAQhejAvXEeClDJt9tcT\/8ka1wfmDXddHdMjdBGBTBpsyN45w2JS5MavO6RMEr3NyhUh1EpCzu3w5z\/CigIATCaxculKEzet5vVbYrYH\/N3z4cBoxYoTXuu\/q\/lZUVBAvb4BNmavTbMvOQfDaMi0IKlICcqNapPfjPhAAAXsR4MMo+FAKFPcQGDdunOgMbMrck1Mn9ASC1wlZQoy6CUgbsilFw6mkCDNDusHhQhCwGYGlK9bSkPPKKCcnhwoKvLV5z2apiHk4sCmLOVJUqIMABK8OSLjEGQRamhtpi28NZWUm08ZVOKLUGVlDlCAQnMCQc8to6cq12MDmwkECmzIXJtXmXYLgtXmCEJ5+AtKGrGZ+EeUP7qv\/RlwJAiBgSwJ1vgbqc9wt1LdvXyF6UdxDQG5gi4tPoIzMAe7pGHpiWwIQvLZNDQILh4DcqJaf05dqFuCLMRx2uBYE7EygcFIFVcxbKZY18PIGFPcQkDZlKanZlJCY4p6OoSe2JADBa8u0IKhwCEgbsl6pXah8RgFmd8OBh2tBwAEEeJaXZ3vnzJnjgGgRol4CcpaXr8\/uB\/tIvdxwXWQEIHgj44a7bERgx3Yf7WjwUcGoHCqfic0tNkoNQgGBmBDgGV6e6YVNWUxw2qoS2JTZKh2uDgaC19XpdX\/npA0ZNqq5P9foobcJyA1ssClz3ziATZn7cmrHHkHw2jEriEk3AblRjWd2eYYXBQRAwJ0EpE0ZNrC5L798EAXP9GIDm\/tya6ceQfDaKRuIJSwCsCELCxcuBgHHE4BNmeNTGLQDcgNbRmZ\/iotPdG9H0TPLCEDwWoYeDUdDgJcy1G9dRy3NTQQbsmhI4l4QcA4B2JQ5J1fhRio3sHXs1FmcwIYCArEmAMEba6KozxQCsCEzBbPxjVxTTjT\/vdbtsIdyxUSiLvsb3z5acByBkrJKmlq2CDZljsucdsCwKdNmhCsiJwDBGzk73GkRAeVGNdiQWZSEaJut\/5Ho7PuIvtkevKbyK4lOPzLalnC\/CwnApsyFSSWihoYG4hPYuMCmzJ05trJXELxW0kfbERGo37qedjZugw1ZRPRscNNPPxMVzCJasZYoMZ7ouWuJjsraF5hSCKtfs0HoCMEeBKRNGR9EwQdSoLiHQGVlJS1atIi6JqZQz9Rs93QMPbGcAASv5SlAAOEQgA1ZOLRseu3rnxAVPtJW7MpwlaL3vOOJHiy0aUcQlpUEsIHNSvrGts2zvDzbiw1sxnL2Wu0QvF7LuMP7CxsyhyeQw5frdkOt1X3oNaLSV4iwntcFCTemC7ApM4arHWqFTZkdsuC+GCB43ZdT1\/YINmQuSa0UvKFmb+Us8EHdiV65gahnN5d0Ht2IJQE+fY2XNxQVFRH786K4hwBsytyTS7v0BILXLplAHCEJwIbMRQMEgtdFybS+K+3Sx1FycjLxCWwo7iEAmzL35NIuPYHgtUsmEEdIAtKGjE9T41PVUBxMAEsaHJw8+4UubcqGDx9OI0aMsF+AiChiAnKWNyk5k5K6Z0ZcD24EASYAwYtxYHsCyo1qfMhEVmay7WNGgCEIYNMahkeMCUibMp7l5dleFHcQUNqU8WEUfCgFCghESgCCN1JyuM80Av\/f3v2DyFHFcQB\/jQHDedFDzkONIMQUIihYRZsQrWKw8U9rUqVQULxCgmj8Qwg2\/oFY52zVNKKpNFYqFkICmiZCNBclijlRzwRiI2\/hhbnJbnZnd3Z2981nuySzM+\/3ea\/4Mnn7e9qQNUbdzIOKbcniE4v9drUla2YOMntK+gGbNmWZTWwIQZuy\/OZ0UhUJvJOS99yBBLQhG4hp9i5y8MTszdmUj1ibsimfoBGGp03ZCHi+elVA4LUYplpAG7Kpnp7RB5fajxXvpBXZ6K4tvIM2ZflOujZl+c5tk5UJvE1qe1YlgfRDtZ07tocvjy1X+q6LCRBon4A2ZfnOuTZl+c5tU5UJvE1Je04lgbiV4fzq9+HOpblw9J29YWd86+dDgACBPgLalOW5RLQpy3Nem6xK4G1S27MGFlj7YzWsXVwN2pANTOZCAgRC6BxEEd\/0alOW33JYWVkJcXuDNmX5zW0TFQm8TSh7RiUBbcgqcbmYAIGSQPoBmzZl+S2N\/fv3d4rSpiy\/uR13RQLvuIXdv7JAakN2cHlPeG1ZI\/nKgL5AoOUC2pTluwDSD9hu2rIYblvalm+hKqtdQOCtndQNRxG4fOmv8MvqD53DJc5+66jQUSx9l0CbBbQpy3f2tSnLd27HWZnAO05d964kELcy\/HbhTLh86e8QT1TzQ7VKfC4mQKAg8NPqxRBPYNu+fXtYXtblJafFkX7AduPm+XDH1vtyKk0tYxQQeMeI69bVBNLe3fgtxwdXs3M1AQLXCsTQGz+OG85vdcRjh+NncWlbmN+ymF+BKqpdQOCtndQNhxWIe3fjlgYfAgQIECAwiMD8\/GJYuHXrIJe6puUCAm\/LF4DyCRAgQIAAAQK5Cwi8uc+w+ggQIECAAAECLRcQeFu+AJRPgAABAgQIEMhdQODNfYbVR4AAAQIECBBouYDA2\/IFoHwCBAgQIECAQO4CAm\/uM6w+AgQIECBAgEDLBQTeli8A5RMgQIAAAQIEchcQeHOfYfURIECAAAECBFouIPC2fAEonwCB3gIP3H9vOPDSs2FubnPnoq+\/+S4cOnxkwxfSNfEvD7\/1fjh56nQtpPueeSo8+cTuDfe6cuW\/cHTlw\/DJp59XesbLB54LD+14sPOdj48dD0c\/+KhrDbHOCxd+D6+\/+V44t\/prpWe4mAABAtMsIPBO8+wYGwECExO4a+vt4eArz4elpY3HlpYDYwqmZ348G1548Y2Rx1sO2d1uWPVZAu\/I0+IGBAjMuIDAO+MTaPgECIxH4PE9j4Z9e58O8a1qfHP72O5dnbekxbCZQvHCwi1DvXktj7xXyO5WYbe3zb0kBN7xrBF3JUBgdgQE3tmZKyMlQKBBgfTmNv0X\/yO7Hu5sMSj+l3\/db3eLwbS8faEchtfXLw28hULgbXDheBQBAlMpIPBO5bQYFAECkxboF3jj+OKWh3G83e21VzeF3n\/W\/620fULgnfRq8nwCBCYtIPBOegY8nwCBqRTot6Wh7re76XmbNt2wYdtEHTgCbx2K7kGAwCwLCLyzPHvGToDA2AT6\/Wjt3bdfDfdsu7tr14NhBlUMvFX25w7yrGLg7Xe9Lg39hPw7AQKzKCDwzuKsGTMBAo0I9GpLlsLp2tqftbXwKrYhE3gbmV4PIUCgRQICb4smW6kECNQjUH67W3yDWuXHZMXRCLz1zI27ECBAoJuAwGtdECBAoIJA+e1u6t5QvMUw2wKKWxqG+X4K4XEc5dA9yh7eYhAfNsxX4HUpAQIExiIg8I6F1U0JEMhVoPx2N\/05bkP47PiJzsls8YdnVU9EK+4Z7telIdoWT0Mrht3kXgzNwwbebqe9DRPGc10L6iJAYHYEBN7ZmSsjJUBgwgLlt7txOOk0tngC2xcnvtrw5\/IRvv2Gf70+vPG7xWCbQnE8AjiG7PiJB2TETzl0DxN4e9VWVxu2fhb+nQABAnUKCLx1aroXAQJZC6TgmH5UVnwrW0fgHeaktRTCfz53vtObN91jbm7u6sEUwwTehYWbO8F5fX29th\/mZb04FEeAwFQLCLxTPT0GR4DAtAikjg3pTerJU6c7Q6trS0Oqs9wZolv919tW0K0\/8DCBN44jHq0cO1HE8Dw3t7lzzHLVrRrTMn\/GQYBAuwUE3nbPv+oJEBhQoPx2N31tXPtcu923X+Asnw4XtzvEzyiBN+5HLn76jWFATpcRIECgUQGBt1FuDyNAYBYFer3dTbXU0ZZsVJdeYXfY+3arufg2+9DhI8Pe2vcIECDQuIDA2zi5BxIgQKBegbrDbhzd9fYC130wRr0a7kaAAIFrBQReq4IAAQIzLNBrz28dWw+G2VYxw5SGToBAxgICb8aTqzQCBPIX6BZKY9V1BN54n36t0vIXViEBAjkICLw5zKIaCBAgQIAAAQIEegoIvBYHAQIECBAgQIBA1gICb9bTqzgCBAgQIECAAAGB1xogQIAAAQIECBDIWkDgzXp6FUeAAAECBAgQICDwWgMECBAgQIAAAQJZCwi8WU+v4ggQIECAAAECBARea4AAAQIECBAgQCBrAYE36+lVHAECBAgQIECAgMBrDRAgQIAAAQIECGQtIPBmPb2KI0CAAAECBAgQEHitAQIECBAgQIAAgawFBN6sp1dxBAgQIECAAAECAq81QIAAAQIECBAgkLWAwJv19CqOAAECBAgQIEBA4LUGCBAgQIAAAQIEshYQeLOeXsURIECAAAECBAgIvNYAAQIECBAgQIBA1gL\/A35Sv8WY34SnAAAAAElFTkSuQmCC","height":337,"width":560}}
%---
%[output:74fde7c4]
%   data: {"dataType":"text","outputData":{"text":"Diagnosis: S - Stray Gassing\n","truncated":false}}
%---
