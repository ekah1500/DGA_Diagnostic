clc; clear;

%________Taking Inputs___________
disp("===== DGA Calculator =====")
h2 = max(0, input('H2 - Hydrogen (ppm): '));
ch4 = max(0, input('CH4 - Methane (ppm): '));
c2h6 = max(0, input('C2H6 - Ethane (ppm): '));
c2h4 = max(0, input('C2H4 - Ethylene (ppm): '));
c2h2 = max(0, input('C2H2 - Acetylene (ppm): '));
co = max(0, input('CO - Carbon Monoxide (ppm): '));
co2 = max(0, input('CO2 - Carbon Dioxide (ppm): '));

%----------------------- Calculating Total Dissolved Combustible Gas --------------------------------
tdcg = h2 + ch4 + c2h6 + c2h4 + c2h2 + co;

fprintf('\n--- Preliminary Assessment ---\n');
fprintf('Total Dissolved Combustible Gas (TDCG): %.2f ppm\n', tdcg);

if tdcg < 720
    fprintf('Status: Condition 1 (Healthy/Normal). Ratios may be unreliable.\n');
elseif tdcg >= 720 && tdcg <= 1920
    fprintf('Status: Condition 2 (Caution). Monitor closely for gas increase.\n');
elseif tdcg > 1920 && tdcg <= 4630
    fprintf('Status: Condition 3 (High Risk)\n');
else
    fprintf('Status: Condition 4 (Excessive Decomposition - Immediate Action)\n');
end
 
%----------------------------------------- Rogers Ratio Method ------------------------------------

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

fprintf('\n---> Rogers Ratio Method Method <---\n')

%____________Display Ratio Calculations_____________
fprintf('\nCalculated Ratios:\n');
fprintf('R1 (C2H2/C2H4): %.2f\n', r1);
fprintf('R2 (CH4/H2): %.2f\n', r2);
fprintf('R5 (C2H4/C2H6): %.2f\n', r5);

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
    rr_result = 'High Tempertaure Thermal Fault (>700C)';
    
else
    rr_result = 'Diagnostic ratios do not match a standard fault pattern (Undetermined)';
end

fprintf('\nDiagnosis:\n%s\n', rr_result);

%------------------------------------------ Key Gas Method ----------------------------------------

fprintf('\n---> Key Gas Method <---\n')

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

fprintf('Diagnosis: \n%s\n', kg_result);

%------------------------------------------ CO2/CO Ratio ----------------------------------------

fprintf('\n---> CO2/CO Ratio Analysis <---\n');

if co > 0
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
    fprintf('CO2/CO Ratio: N/A Invalid Input.\n');
end

%---------------------------------- Duval triangle 1----------------------------------------

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

if gas_sum_dt1 < 1 % Threshold of 1 ppm 
    dt1_fault = 'Insufficient Gas for DGA'; %#ok<NASGU>
    X_pt = NaN; Y_pt = NaN; %#ok<NASGU>
else
    p_ch4 = (ch4/gas_sum_dt1) * 100; p_c2h4 = (c2h4/gas_sum_dt1) * 100; p_c2h2 = (c2h2/gas_sum_dt1) * 100; %Percentages
end

% Calculating Sample Point (X, Y)
% Using fractions (0-1), not percentages (0-100) for the coordinate formula
if gas_sum_dt1 > 0
    f_ch4 = ch4 / gas_sum_dt1;
    f_c2h4 = c2h4 / gas_sum_dt1;
else
    f_ch4 = 0; f_c2h4 = 0;
end

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

fprintf('\n---> Duval triangle <---\n');
fprintf('Diagnosis: %s\n', dt1_fault);

% Plotting Graph
figure('Name', 'Duval Triangle 1', 'Color', '#24273a');
hold on;
axis equal;
axis off; % Hide standard axes

% Zone Patches (Colored)
fill(PD_x, PD_y, [0.8500 0.9500 1.0000], 'EdgeColor', '#24273a');   
fill(T1_x, T1_y, [1.0000 0.6824 0.6863], 'EdgeColor', '#24273a');      
fill(T2_x, T2_y, [1.0000 0.8000 0.0000], 'EdgeColor', '#24273a');    
fill(T3_x, T3_y, [0.2471 0.2471 0.2471], 'EdgeColor', '#24273a');    
fill(D1_x, D1_y, [0.0000 0.8118 0.8784], 'EdgeColor', '#24273a');     
fill(D2_x, D2_y, [0.1490 0.3216 0.6549], 'EdgeColor', '#24273a');    
fill(DT_x, DT_y, [0.8314 0.3255 0.6392], 'EdgeColor', '#24273a');    

% Adding Zone Labels
text(mean(PD_x), mean(PD_y), 'PD', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r');
text(mean(T1_x), mean(T1_y), 'T1', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r');
text(mean(T2_x), mean(T2_y), 'T2', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r');
text(mean(T3_x), mean(T3_y), 'T3', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r');
text(mean(D1_x), mean(D1_y), 'D1', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r');
text(0.65, 0.20, 'DT', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); % Manual placement for DT
text(0.5, 0.2, 'D2', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'color', 'r'); % Manual placement for D2

% Main Triangle Boundary
plot([0 1 0.5 0], [0 0 0.866 0], 'k-', 'LineWidth', 1.2);

% Plotting Sample Point
plot(X_pt, Y_pt, 'go', 'MarkerFaceColor', 'b', 'MarkerSize', 4, 'LineWidth', 1.5);

% Label to Sample Point
text(X_pt + 0.03, Y_pt, sprintf('  Fault\n  (%.1f, %.1f, %.1f)', p_ch4, p_c2h4, p_c2h2), ...
    'BackgroundColor', '#cad3f5', 'color', 'k', 'EdgeColor', 'r', 'LineWidth', 1, 'Margin', 1);

% Corner Labels
text(0.215, 0.45, '% CH_4', 'Rotation', 60, 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
text(0.77, 0.48, '% C_2H_4', 'Rotation', -60, 'HorizontalAlignment', 'left', 'FontSize', 12, 'FontWeight', 'bold');
text(0.5, -0.05, '% C_2H_2', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');

% Title
title(['Duval Triangle 1 Diagnosis: ' dt1_fault], 'FontSize', 14);
hold off;


%---------------------------------- Duval Triangle 4 ----------------------------------------

if  strcmp(dt1_fault,'PD: Partial Discharge') || ...
    strcmp(dt1_fault, 'T1: Low Temperature Thermal Fault (<300C)') || ...
    strcmp(dt1_fault, 'T2: Medium Temperature Thermal Fault (300-700C)')
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


%---------------------------------- Duval Triangle 5 ----------------------------------------

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

