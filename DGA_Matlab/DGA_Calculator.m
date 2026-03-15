clc; clear;

%________Mode Selection___________
disp('===== DGA Calculator =====')
disp('Select input mode:')
disp('  1 - Manual Entry')
disp('  2 - CSV Batch Mode')
mode_sel = input('Enter choice (1 or 2): ');

if mode_sel == 2
    % --- CSV Batch Mode ---
    [fname, fpath] = uigetfile('*.csv', 'Select DGA Sample CSV File');
    if isequal(fname, 0)
        disp('No file selected. Exiting.'); return;
    end
    csv_full = fullfile(fpath, fname);

    % To read any column names & order
    results = load_csv_flexible(csv_full);
    if isempty(results)
        return;
    end
    fprintf('\nLoaded %d sample(s) from: %s\n', numel(results), csv_full);
    show_batch_table(results);

else
    % --- Manual Entry Mode ---
    h2   = max(0, input('H2 - Hydrogen (ppm): '));
    ch4  = max(0, input('CH4 - Methane (ppm): '));
    c2h6 = max(0, input('C2H6 - Ethane (ppm): '));
    c2h4 = max(0, input('C2H4 - Ethylene (ppm): '));
    c2h2 = max(0, input('C2H2 - Acetylene (ppm): '));
    co   = max(0, input('CO - Carbon Monoxide (ppm): '));
    co2  = max(0, input('CO2 - Carbon Dioxide (ppm): '));

    r = compute_dga(h2, ch4, c2h6, c2h4, c2h2, co, co2, 'Manual');
    print_dga_report(r);
    analyze_sample(r);
end


function results = load_csv_flexible(csv_full) % Reads any csv file regardless of column names or column order
    results = [];

    try
        tbl = readtable(csv_full, 'TextType', 'string', 'VariableNamingRule', 'preserve');
    catch ME
        fprintf('[CSV] Could not read file: %s\n', ME.message);
        return;
    end

    if height(tbl) == 0 % number of rows in the table
        fprintf('[CSV] File is empty.\n'); return;
    end

    % Normalise header names - lowercase, strip spaces / underscores / hyphens
    raw  = tbl.Properties.VariableNames;
    norm = lower(regexprep(raw, '[\s_\-]', ''));

    % Alias lists for each gas
    aliases = { ...
        {'h2','hydrogen','h2ppm'},                                  ...  1=H2
        {'ch4','methane','ch4ppm'},                                 ...  2=CH4
        {'c2h6','ethane','c2h6ppm'},                                ...  3=C2H6
        {'c2h4','ethylene','c2h4ppm'},                              ...  4=C2H4
        {'c2h2','acetylene','c2h2ppm'},                             ...  5=C2H2
        {'co','carbonmonoxide','coppm'},                            ...  6=CO
        {'co2','carbondioxide','co2ppm','coo2'},                    ...  7=CO2
    };
    gas_labels = {'H2','CH4','C2H6','C2H4','C2H2','CO','CO2'};

    id_aliases = {'sampleid','samplename','sample','id','name', ...
                  'transformer','transformerid','transformerno', ...
                  'serialno','no','sampleno','transid'};

    % Find column index for each gas
    col_idx = zeros(1,7); %1×7 array of zeros to store the column number in the table for each gas
    for g = 1:7
        for j = 1:numel(aliases{g})
            hit = find(strcmp(norm, aliases{g}{j}), 1);
            if ~isempty(hit), col_idx(g) = hit; break; end
        end
    end

    % Find Sample ID column
    id_col = 0;
    for j = 1:numel(id_aliases)
        hit = find(strcmp(norm, id_aliases{j}), 1);
        if ~isempty(hit), id_col = hit; break; end
    end

    % Reporting what was found / missing
    missing = gas_labels(col_idx == 0);
    if ~isempty(missing)
        fprintf('[CSV] Columns not found (defaulting to 0 ppm): %s\n', strjoin(missing,', '));
    end
    if id_col == 0
        fprintf('[CSV] No Sample ID column found — using Row_1, Row_2 ...\n');
    end

    % Row-by-Row Data Extraction
    n = height(tbl); % number of data rows
    results = repmat(make_empty_result(), 1, n);  % array of n identical empty result structs

    for k = 1:n
        vals = zeros(1,7); % temporary array
        for g = 1:7
            if col_idx(g) > 0
                v = tbl{k, col_idx(g)};
                if iscell(v), v = v{1}; end
                if ischar(v) || isstring(v), v = str2double(char(v)); end
                if isnan(v) || isempty(v), v = 0; end
                vals(g) = max(0, v);
            end
        end

        if id_col > 0
            sid = strtrim(char(tbl{k, id_col}));
            if isempty(sid) || strcmpi(sid,'nan'), sid = sprintf('Row_%d',k); end
        else
            sid = sprintf('Row_%d', k);
        end

        results(k) = compute_dga(vals(1),vals(2),vals(3),vals(4),vals(5),vals(6),vals(7), sid);
    end
end


function r = make_empty_result() % blank struct with every field initialized, template for pre-allocation
    r.sample_id   = '';
    r.h2=0; r.ch4=0; r.c2h6=0; r.c2h4=0; r.c2h2=0; r.co=0; r.co2=0;
    r.tdcg        = 0;
    r.tdcg_cond   = '';
    r.rr_result   = '';
    r.kg_result   = '';
    r.co_result   = '';
    r.r1=0; r.r2=0; r.r5=0;
    r.dt1_fault   = '';
    r.dt4_fault   = '';
    r.dt5_fault   = '';
    r.reliability = '';
    r.agree_count = 0;
    r.agree_total = 0;
    r.dominant    = '';
    r.method_names = {};
    r.method_cats  = {};
end

function r = compute_dga(h2, ch4, c2h6, c2h4, c2h2, co, co2, sample_id) % for calculations

    r = make_empty_result();
    r.sample_id = sample_id;
    r.h2=h2; r.ch4=ch4; r.c2h6=c2h6; r.c2h4=c2h4;
    r.c2h2=c2h2; r.co=co; r.co2=co2;

    %--- TDCG (as per IEEE C57.104 standard )---
    r.tdcg = h2 + ch4 + c2h6 + c2h4 + c2h2 + co;
    if     r.tdcg < 720,  r.tdcg_cond = 'Condition 1 (Healthy/Normal)';
    elseif r.tdcg <= 1920, r.tdcg_cond = 'Condition 2 (Caution)';
    elseif r.tdcg <= 4630, r.tdcg_cond = 'Condition 3 (High Risk)';
    else,                  r.tdcg_cond = 'Condition 4 (Immediate Action)';
    end

    %--- Rogers Ratio ---
    if c2h4 > 0, r1=c2h2/c2h4; elseif c2h2==0, r1=0; else, r1=999; end
    if h2   > 0, r2=ch4/h2;    elseif ch4==0,  r2=0; else, r2=999; end
    if c2h6 > 0, r5=c2h4/c2h6; elseif c2h4==0, r5=0; else, r5=999; end
    r.r1=r1; r.r2=r2; r.r5=r5;

    if     isnan(r1)||isnan(r2)||isnan(r5)
        r.rr_result = 'Warning: Invalid input.';
    elseif (r1<0.1)&&(r2>=0.1&&r2<=1.0)&&(r5<1.0)
        r.rr_result = 'Normal working condition';
    elseif (r1<0.1)&&(r2<0.1)&&(r5<1.0)
        r.rr_result = 'Possible Partial Discharge (Rogers method is limited)';
    elseif (r1>=0.1&&r1<=3.0)&&(r2>=0.1&&r2<=1.0)&&(r5>3.0)
        r.rr_result = 'High-energy Discharge (Arcing)';
    elseif (r1<0.1)&&(r2>=0.1&&r2<=1.0)&&(r5>=1.0&&r5<=3.0)
        r.rr_result = 'Low Temperature Thermal Fault (<300C)';
    elseif (r1<0.1)&&(r2>1.0)&&(r5>=1.0&&r5<=3.0)
        r.rr_result = 'Medium Temperature Thermal Fault (300-700C)';
    elseif (r1<0.1)&&(r2>1.0)&&(r5>3.0)
        r.rr_result = 'High Temperature Thermal Fault (>700C)';
    else
        r.rr_result = 'Diagnostic ratios do not match a standard fault pattern (Undetermined)';
    end

    %--- Key Gas ---
    if r.tdcg > 0
        p_h2   = (h2   /r.tdcg)*100;  p_ch4  = (ch4  /r.tdcg)*100;
        p_c2h6 = (c2h6 /r.tdcg)*100;  p_c2h4 = (c2h4 /r.tdcg)*100;
        p_c2h2 = (c2h2 /r.tdcg)*100;  p_co   = (co   /r.tdcg)*100;
    else
        p_h2=0; p_ch4=0; p_c2h6=0; p_c2h4=0; p_c2h2=0; p_co=0;
    end
    r.kg_result = 'Normal / Inconclusive';
    if     (p_c2h2>=5)&&(c2h2>0)
        r.kg_result = 'High-Energy Discharge (Arcing) [Key Gas: Acetylene]';
    elseif (p_c2h4>20)&&(c2h4>c2h6)
        r.kg_result = 'Thermal Fault in Oil (>700 C) [Key Gas: Ethylene]';
    elseif (p_co>80)
        r.kg_result = 'Overheating of Insulation Paper [Key Gas: Carbon Monoxide]';
    elseif (p_c2h6>p_ch4)&&(p_c2h6>p_c2h4)
        r.kg_result = 'Low-temp Thermal / Oil Decomposition [Key Gas: Ethane]';
    elseif (p_ch4>p_h2)&&(p_ch4>p_c2h4)
        r.kg_result = 'Low-temp Thermal (<300 C) [Key Gas: Methane]';
    elseif (p_h2>p_ch4)&&(p_h2>p_c2h4)
        r.kg_result = 'Partial Discharge (Corona) [Key Gas: Hydrogen]';
    end

    %--- CO2/CO Ratio ---
    if co > 0
        ratio = co2/co;
        if     ratio < 3,  r.co_result = 'Severe paper degradation (Carbonization)';
        elseif ratio > 10, r.co_result = 'Normal paper aging, Mild overheating';
        else,              r.co_result = 'Healthy insulation, Standard operation';
        end
    else
        r.co_result = 'N/A (CO = 0)';
    end

    %--- Duval Triangle 1 geometry ---
    top=[0.5,0.866]; right=[1,0]; left=[0,0];
    a=[0.49,0.849]; b=[0.51,0.849]; c_pt=[0.48,0.831]; d=[0.58,0.658]; e=[0.6,0.693];
    f=[0.73,0.398]; g=[0.75,0.433]; h_pt=[0.675,0.303]; I_pt=[0.85,0]; J_pt=[0.71,0];
    k_pt=[0.555,0.268]; l=[0.635,0.407]; m=[0.55,0.554]; n=[0.435,0.753]; o=[0.23,0];

    PD_x=[top(1),b(1),a(1)];                         PD_y=[top(2),b(2),a(2)];
    T1_x=[a(1),b(1),e(1),d(1),c_pt(1)];              T1_y=[a(2),b(2),e(2),d(2),c_pt(2)];
    T2_x=[d(1),e(1),g(1),f(1)];                      T2_y=[d(2),e(2),g(2),f(2)];
    T3_x=[f(1),g(1),right(1),I_pt(1),h_pt(1)];       T3_y=[f(2),g(2),right(2),I_pt(2),h_pt(2)];
    D1_x=[n(1),m(1),o(1),left(1)];                   D1_y=[n(2),m(2),o(2),left(2)];
    D2_x=[m(1),l(1),k_pt(1),J_pt(1),o(1)];           D2_y=[m(2),l(2),k_pt(2),J_pt(2),o(2)];
    DT_x=[c_pt(1),d(1),f(1),h_pt(1),I_pt(1),J_pt(1),k_pt(1),l(1),m(1),n(1)];
    DT_y=[c_pt(2),d(2),f(2),h_pt(2),I_pt(2),J_pt(2),k_pt(2),l(2),m(2),n(2)];

    gas_sum_dt1 = ch4+c2h4+c2h2;
    if gas_sum_dt1 < 1
        r.dt1_fault = 'Insufficient Gas for DGA';
    else
        f_ch4  = ch4  / gas_sum_dt1;
        f_c2h4 = c2h4 / gas_sum_dt1;
        Xp = ((f_c2h4/0.866)+(f_ch4/1.732))*0.866;
        Yp = f_ch4*0.866;
        if     inpolygon(Xp,Yp,PD_x,PD_y), r.dt1_fault='PD: Partial Discharge';
        elseif inpolygon(Xp,Yp,T1_x,T1_y), r.dt1_fault='T1: Low Temperature Thermal Fault (<300C)';
        elseif inpolygon(Xp,Yp,T2_x,T2_y), r.dt1_fault='T2: Medium Temperature Thermal Fault (300-700C)';
        elseif inpolygon(Xp,Yp,T3_x,T3_y), r.dt1_fault='T3: High Temperature Thermal Fault (>700C)';
        elseif inpolygon(Xp,Yp,D1_x,D1_y), r.dt1_fault='D1: Low Energy Discharge';
        elseif inpolygon(Xp,Yp,D2_x,D2_y), r.dt1_fault='D2: High Energy Discharge';
        elseif inpolygon(Xp,Yp,DT_x,DT_y), r.dt1_fault='DT: Mix of Thermal/Electrical';
        else,                                r.dt1_fault='Undetermined / Boundary';
        end
    end

    %--- DT4 / DT5 geometry  ---
    r.dt4_fault = calc_dt4_fault(h2, ch4, c2h6, r.dt1_fault);
    r.dt5_fault = calc_dt5_fault(ch4, c2h4, c2h6, r.dt1_fault);

    %--- Reliability ---
    [r.reliability, r.agree_count, r.agree_total, r.dominant, ...
     r.method_names, r.method_cats] = ...
        calc_reliability(r.rr_result, r.kg_result, r.dt1_fault, r.dt4_fault, r.dt5_fault);
end


function show_batch_table(results) % Main GUI batch window

    n = numel(results);

    col_names = {'#','Sample ID','H2','CH4','C2H6','C2H4','C2H2','CO','CO2', ...
                 'TDCG','TDCG Status','DT1 Fault','Reliability','Agreement'};
    tdata = cell(n, numel(col_names));
    for k = 1:n
        rk = results(k);
        tdata(k,:) = { k, rk.sample_id, rk.h2, rk.ch4, rk.c2h6, rk.c2h4, rk.c2h2, ...
                       rk.co, rk.co2, rk.tdcg, rk.tdcg_cond, rk.dt1_fault, ...
                       rk.reliability, sprintf('%d / %d', rk.agree_count, rk.agree_total) };
    end

    win_w = 1300; win_h = 580;
    scr = get(0,'ScreenSize');
    fig = uifigure('Name', 'DGA Batch Results', ...
        'Position', [max(10,(scr(3)-win_w)/2)  max(10,(scr(4)-win_h)/2)  win_w  win_h], ...
        'Color', [0.13 0.14 0.22], 'Resize', 'on');

    % ---- Row 1: Title  (y = win_h-44 = 536) ----
    uilabel(fig, 'Text', 'DGA  Batch Analysis Results', ...
        'Position', [18 536 620 30], ...
        'FontSize', 17, 'FontWeight', 'bold', ...
        'FontColor', [0.78 0.84 1.0], 'BackgroundColor', 'none');

    % ---- Row 2: subtitle + inline colour legend  (y = 508) ----
    uilabel(fig, 'Text', sprintf('%d samples loaded  —  select a row, then click Analyze', n), ...
        'Position', [18 508 430 22], ...
        'FontSize', 10, 'FontColor', [0.60 0.67 0.85], 'BackgroundColor', 'none');

    % Legend on the right side of the same row
    lx = 460;
    chip_y = 507;  chip_h = 22;
    uilabel(fig,'Text','■','Position',[lx      chip_y  16 chip_h],'FontSize',13,'FontColor',[0.40 0.82 0.50],'BackgroundColor','none');
    uilabel(fig,'Text','High',    'Position',[lx+17   chip_y  38 chip_h],'FontSize',10,'FontColor',[0.82 0.88 1.0],'BackgroundColor','none');
    uilabel(fig,'Text','■','Position',[lx+60   chip_y  16 chip_h],'FontSize',13,'FontColor',[1.00 0.82 0.25],'BackgroundColor','none');
    uilabel(fig,'Text','Moderate','Position',[lx+77   chip_y  62 chip_h],'FontSize',10,'FontColor',[0.82 0.88 1.0],'BackgroundColor','none');
    uilabel(fig,'Text','■','Position',[lx+144  chip_y  16 chip_h],'FontSize',13,'FontColor',[1.00 0.38 0.38],'BackgroundColor','none');
    uilabel(fig,'Text','Low',     'Position',[lx+161  chip_y  34 chip_h],'FontSize',10,'FontColor',[0.82 0.88 1.0],'BackgroundColor','none');

    % ---- Table: sits between y=70 (status bar area) and y=498; 498 - 70 = 428px height ---
    tbl_y = 70; tbl_h = 428;
    col_widths = {36, 90, 52, 52, 52, 52, 52, 52, 52, 68, 168, 228, 88, 76};

    uit = uitable(fig, ...
        'Data', tdata, 'ColumnName', col_names, 'ColumnWidth', col_widths, ...
        'Position', [10 tbl_y win_w-20 tbl_h], ...
        'FontSize', 11, 'RowName', {}, 'Multiselect', 'off');

    % Row colour coding
    for k = 1:n
        rel = results(k).reliability;
        if     strcmp(rel,'High'),     bg = [0.16 0.28 0.18];
        elseif strcmp(rel,'Moderate'), bg = [0.28 0.24 0.10];
        else,                          bg = [0.30 0.13 0.13];
        end
        addStyle(uit, uistyle('BackgroundColor',bg,'FontColor',[0.92 0.94 1.0]), 'row', k);
    end
    addStyle(uit, uistyle('FontWeight','bold','FontColor','white'), 'column', 1);
    addStyle(uit, uistyle('FontWeight','bold','FontColor','white'), 'column', 2);

    % ---- Status bar  (y=10, h=48) ----
    sel_lbl = uilabel(fig, ...
        'Text', 'No row selected  —  click a row to preview', ...
        'Position', [10 10 win_w-190 48], ...
        'FontSize', 10, 'FontColor', [0.68 0.73 0.90], ...
        'BackgroundColor', [0.16 0.17 0.27], 'HorizontalAlignment', 'left');

    uibutton(fig, 'Text', 'Analyze  ▶', ...
        'Position', [win_w-172 18 158 34], ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.25 0.48 0.88], 'FontColor', 'white', ...
        'ButtonPushedFcn', @(~,~) on_analyze_click(fig, results));

    setappdata(fig, 'selected_idx', 0);
    setappdata(fig, 'sel_lbl', sel_lbl);
    uit.SelectionChangedFcn = @(src,evt) on_row_select(src, evt, results);
end


function on_row_select(src, evt, results) % To Update status bar on row click.
    row = evt.Selection(1);
    rk  = results(row);
    fig = ancestor(src, 'figure');
    setappdata(fig, 'selected_idx', row);
    lbl = getappdata(fig, 'sel_lbl');
    lbl.Text = sprintf( ...
        '  Row %d  |  %s  |  TDCG: %.0f ppm  |  DT1: %s  |  %s  |  Agreement: %d / %d', ...
        row, rk.sample_id, rk.tdcg, rk.dt1_fault, ...
        rk.reliability, rk.agree_count, rk.agree_total);
end

function on_analyze_click(fig, results) % Analyze button
    idx = getappdata(fig, 'selected_idx');
    if idx == 0
        uialert(fig, 'Click on a row in the table first.', 'No Row Selected'); return;
    end
    print_dga_report(results(idx));
    analyze_sample(results(idx));
end


function print_dga_report(r) % Text report on Command Window.
    fprintf('\n========================================\n');
    fprintf('  DGA Report  -  Sample: %s\n', r.sample_id);
    fprintf('========================================\n');
    fprintf('\n--- Preliminary Assessment ---\n');
    fprintf('TDCG: %.2f ppm  |  %s\n', r.tdcg, r.tdcg_cond);
    fprintf('\n---> Rogers Ratio Method <---\n');
    fprintf('R1=%.2f  R2=%.2f  R5=%.2f\n', r.r1, r.r2, r.r5);
    fprintf('Diagnosis: %s\n', r.rr_result);
    fprintf('\n---> Key Gas Method <---\n');
    fprintf('Diagnosis: %s\n', r.kg_result);
    fprintf('\n---> CO2/CO Ratio <---\n');
    if r.co > 0, fprintf('Ratio: %.2f  |  ', r.co2/r.co); end
    fprintf('%s\n', r.co_result);
    fprintf('\n---> Duval Triangle 1 <---\n');
    fprintf('Diagnosis: %s\n', r.dt1_fault);
    if ~isempty(r.dt4_fault), fprintf('\n---> Duval Triangle 4 <---\nDiagnosis: %s\n', r.dt4_fault); end
    if ~isempty(r.dt5_fault), fprintf('\n---> Duval Triangle 5 <---\nDiagnosis: %s\n', r.dt5_fault); end
    fprintf('\n---> Reliability <---\n');
    fprintf('Result: %s  |  %s  |  %d / %d agree\n', r.dominant, r.reliability, r.agree_count, r.agree_total);
    for i = 1:numel(r.method_names)
        fprintf('  %-22s -> %s\n', r.method_names{i}, r.method_cats{i});
    end
end


function analyze_sample(r) % Per-sample detail window

    % Triangle figures (hidden)
    fig_handles = gobjects(0);
    fig_labels  = {};
    fig_handles(end+1) = plot_dt1(r);  fig_labels{end+1} = 'Duval Triangle 1';
    if ~isempty(r.dt4_fault)
        fig_handles(end+1) = plot_dt4(r); fig_labels{end+1} = 'Duval Triangle 4';
    end
    if ~isempty(r.dt5_fault)
        fig_handles(end+1) = plot_dt5(r); fig_labels{end+1} = 'Duval Triangle 5';
    end

    % --- Dynamic height calculation ---
    % Fixed top zone: title(36) + gap(6) + badge_row(28) + gap(4) + divider(4) = 78px
    % Info rows: each is ROW_H px
    % Divider + method header + method rows + gap + button + bottom margin
    ROW_H = 26; MET_H = 20;
    FIXED_TOP    = 78;
    FIXED_BOTTOM = 4 + 22 + 4 + numel(r.method_names)*MET_H + 14 + 36 + 16;

    n_info = 6 + (~isempty(r.dt4_fault)) + (~isempty(r.dt5_fault));
    win_h  = FIXED_TOP + n_info*ROW_H + FIXED_BOTTOM;
    win_h  = max(win_h, 440);   % minimum height 
    win_w  = 520;

    scr  = get(0,'ScreenSize');
    dwin = uifigure('Name', ['Analysis: ' r.sample_id], ...
        'Position', [max(10,(scr(3)-win_w)/2+60)  max(10,(scr(4)-win_h)/2)  win_w  win_h], ...
        'Color', [0.13 0.14 0.22], 'Resize', 'off', ...
        'CloseRequestFcn', @(src,~) close_fig_group(src, fig_handles));

    % --- Layout to place elements top-down using cursor variable cy ---
    cy = win_h - 10;   % cursor starts near top

    % Title
    cy = cy - 34;
    uilabel(dwin, 'Text', ['Sample: ' r.sample_id], ...
        'Position', [16 cy win_w-32 30], 'FontSize', 16, 'FontWeight', 'bold', ...
        'FontColor', [0.78 0.84 1.0], 'BackgroundColor', 'none');

    % Reliability + agreement
    cy = cy - 34;
    if     strcmp(r.reliability,'High'),     bg = [0.18 0.52 0.22];
    elseif strcmp(r.reliability,'Moderate'), bg = [0.55 0.44 0.06];
    else,                                    bg = [0.60 0.14 0.14];
    end
    uilabel(dwin, 'Text', r.reliability, ...
        'Position', [16 cy 110 26], 'FontSize', 12, 'FontWeight', 'bold', ...
        'FontColor', 'white', 'BackgroundColor', bg, 'HorizontalAlignment', 'center');
    uilabel(dwin, 'Text', sprintf('Agreement: %d / %d methods agree', r.agree_count, r.agree_total), ...
        'Position', [134 cy win_w-150 26], 'FontSize', 11, ...
        'FontColor', [0.80 0.85 1.0], 'BackgroundColor', 'none');

    % divider
    cy = cy - 8;
    uipanel(dwin, 'Position', [16 cy win_w-32 2], ...
        'BackgroundColor', [0.32 0.38 0.58], 'BorderType', 'none');
    cy = cy - 4;

    % Info rows
    rows = {
        'TDCG',         sprintf('%.0f ppm  —  %s', r.tdcg, r.tdcg_cond);
        'DT1 Fault',    r.dt1_fault;
        'Rogers Ratio', r.rr_result;
        'Key Gas',      r.kg_result;
        'CO2/CO',       r.co_result;
        'Dominant Dx',  r.dominant;
    };
    if ~isempty(r.dt4_fault), rows(end+1,:) = {'DT4 Fault', r.dt4_fault}; end
    if ~isempty(r.dt5_fault), rows(end+1,:) = {'DT5 Fault', r.dt5_fault}; end

    LBL_W = 108; VAL_X = 128; VAL_W = win_w - VAL_X - 16;

    for i = 1:size(rows,1)
        cy = cy - ROW_H;
        uilabel(dwin, 'Text', rows{i,1}, ...
            'Position', [16 cy LBL_W ROW_H-2], 'FontSize', 10, 'FontWeight', 'bold', ...
            'FontColor', [0.55 0.68 1.0], 'BackgroundColor', 'none');
        uilabel(dwin, 'Text', rows{i,2}, ...
            'Position', [VAL_X cy VAL_W ROW_H-2], 'FontSize', 10, ...
            'FontColor', [0.88 0.91 1.0], 'BackgroundColor', 'none');
    end

    % --- Method breakdown ---
    cy = cy - 10;
    uipanel(dwin, 'Position', [16 cy win_w-32 2], ...
        'BackgroundColor', [0.28 0.34 0.54], 'BorderType', 'none');
    cy = cy - 22;
    uilabel(dwin, 'Text', 'Method Breakdown', ...
        'Position', [16 cy 200 18], 'FontSize', 10, 'FontWeight', 'bold', ...
        'FontColor', [0.62 0.73 1.0], 'BackgroundColor', 'none');

    for i = 1:numel(r.method_names)
        cy = cy - MET_H;
        uilabel(dwin, 'Text', sprintf('%-22s  %s', r.method_names{i}, r.method_cats{i}), ...
            'Position', [24 cy win_w-40 MET_H-2], 'FontSize', 9, 'FontName', 'Courier New', ...
            'FontColor', [0.80 0.86 1.0], 'BackgroundColor', 'none');
    end

    % --- Show Triangles button at  bottom ----
    uibutton(dwin, 'Text', 'Show Triangle Diagrams  >', ...
        'Position', [16 14 220 34], 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.25 0.48 0.88], 'FontColor', 'white', ...
        'ButtonPushedFcn', @(~,~) embed_nav(fig_handles, fig_labels));
end


function embed_nav(fig_handles, fig_labels) % Attaches Prev/Next controls directly to
%  each triangle
    n = numel(fig_handles);
    if n == 0, return; end

    FIG_W = 700; FIG_H = 560; NAV_H = 46;
    scr = get(0,'ScreenSize');

    for i = 1:n
        fig = fig_handles(i);

        fx = max(40, (scr(3)-FIG_W)/2 + (i-1)*30);
        fy = max(40, (scr(4)-FIG_H)/2 - (i-1)*24);
        set(fig, 'Position', [fx fy FIG_W FIG_H]);

        % Compressing axes upward to leave room for nav bar at the bottom
        ax_list = findobj(fig, 'Type', 'axes');
        for ai = 1:numel(ax_list)
            % left bottom width height
            op = get(ax_list(ai), 'OuterPosition');
            nav_frac = NAV_H / FIG_H;
            % height
            new_bot = op(2) + nav_frac;
            new_h   = op(4) - nav_frac;
            if new_h > 0.1
                set(ax_list(ai), 'OuterPosition', [op(1) new_bot op(3) new_h]);
            end
        end

        % Store shared navigation state in each figure
        setappdata(fig, 'nav_handles', fig_handles);
        setappdata(fig, 'nav_labels',  fig_labels);
        setappdata(fig, 'nav_idx',     i);

        % clean up
        set(fig, 'CloseRequestFcn', @(src,~) close_fig_group(src, fig_handles));

        % Dark background strip for the nav bar area
        annotation(fig, 'rectangle', [0, 0, 1, NAV_H/FIG_H], ...
            'FaceColor', [0.10 0.11 0.18], 'EdgeColor', 'none');

        % Prev button
        uicontrol(fig, 'Style', 'pushbutton', 'String', '< Prev', ...
            'Units', 'pixels', 'Position', [8 8 80 30], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'Callback', @(~,~) nav_step_embedded(fig, -1));

        % Centre label showing position
        uicontrol(fig, 'Style', 'text', ...
            'String', sprintf('%d / %d  —  %s', i, n, fig_labels{i}), ...
            'Units', 'pixels', 'Position', [96 10 FIG_W-200 26], ...
            'BackgroundColor', [0.10 0.11 0.18], 'ForegroundColor', [0.85 0.90 1.0], ...
            'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

        % Next button
        uicontrol(fig, 'Style', 'pushbutton', 'String', 'Next >', ...
            'Units', 'pixels', 'Position', [FIG_W-88 8 80 30], ...
            'FontSize', 10, 'FontWeight', 'bold', ...
            'Callback', @(~,~) nav_step_embedded(fig, +1));
    end

    % Show only the first triangle
    for i = 2:n, set(fig_handles(i), 'Visible', 'off'); end
    set(fig_handles(1), 'Visible', 'on');
    figure(fig_handles(1));
end


function nav_step_embedded(this_fig, direction) % Prev / Next callback
    handles = getappdata(this_fig, 'nav_handles');
    n       = numel(handles);
    current = getappdata(this_fig, 'nav_idx');

    set(this_fig, 'Visible', 'off');
    next = mod(current - 1 + direction, n) + 1;
    set(handles(next), 'Visible', 'on');
    figure(handles(next));   % bring to front
end


function close_fig_group(this_fig, all_handles) %  Deletes a figure and all sibling
    for k = 1:numel(all_handles)
        try
            if ishandle(all_handles(k)) && isvalid(all_handles(k))
                delete(all_handles(k));
            end
        catch
        end
    end
    % Deletes the detail window 
    try
        if ishandle(this_fig) && isvalid(this_fig)
            delete(this_fig);
        end
    catch
    end
end


function [reliability, agree_count, agree_total, dominant, m_names, m_cats] = ...
         calc_reliability(rr_result, kg_result, dt1_fault, dt4_fault, dt5_fault) % Agreement check across methods

    m_names = {'Rogers Ratio', 'Key Gas', 'Duval Triangle 1'};
    m_cats  = {categorize_fault(rr_result), categorize_fault(kg_result), categorize_fault(dt1_fault)};
    if ~isempty(dt4_fault), m_names{end+1}='Duval Triangle 4'; m_cats{end+1}=categorize_fault(dt4_fault); end
    if ~isempty(dt5_fault), m_names{end+1}='Duval Triangle 5'; m_cats{end+1}=categorize_fault(dt5_fault); end

    agree_total = numel(m_cats);
    uq = unique(m_cats);
    max_cnt = 0; dominant = '';
    for i = 1:numel(uq)
        c = sum(strcmp(m_cats, uq{i}));
        if c > max_cnt, max_cnt=c; dominant=uq{i}; end
    end
    agree_count = max_cnt;
    ra = agree_count / agree_total;
    if     ra >= 0.8, reliability = 'High';
    elseif ra >= 0.5, reliability = 'Moderate';
    else,             reliability = 'Low';
    end
end


function cat = categorize_fault(result) % Maps raw strings to fault groups
    r = lower(result);
    if     contains(r,'partial discharge')||contains(r,'corona')
        cat = 'Partial Discharge';
    elseif contains(r,'thermal')&&(contains(r,'>700')||contains(r,'t3')||contains(r,'high temp'))
        cat = 'Thermal Fault (High >700C)';
    elseif contains(r,'thermal')&&(contains(r,'300-700')||contains(r,'t2')||contains(r,'medium'))
        cat = 'Thermal Fault (Medium 300-700C)';
    elseif contains(r,'thermal')&&(contains(r,'<300')||contains(r,'t1')||contains(r,'low temp'))
        cat = 'Thermal Fault (Low <300C)';
    elseif contains(r,'thermal')||contains(r,'overheating')||contains(r,'carboniz')
        cat = 'Thermal Fault';
    elseif contains(r,'arcing')||contains(r,'high-energy discharge')||contains(r,'high energy')
        cat = 'Electrical Discharge';
    elseif contains(r,'normal')||contains(r,'healthy')||contains(r,'aging')
        cat = 'Normal / Aging';
    elseif contains(r,'paper')||contains(r,'insulation')||contains(r,'cellulose')
        cat = 'Insulation / Paper Fault';
    else
        cat = 'Undetermined';
    end
end


function dt4_fault = calc_dt4_fault(h2, ch4, c2h6, dt1_fault) %  DT4 geometry
    dt4_fault = '';
    if ~(strcmp(dt1_fault,'PD: Partial Discharge') || ...
         strcmp(dt1_fault,'T1: Low Temperature Thermal Fault (<300C)') || ...
         strcmp(dt1_fault,'T2: Medium Temperature Thermal Fault (300-700C)')), return; 
    end

    tri = @(h,m,~) [(m+0.5*h), (h*sqrt(3)/2)];
    gs  = h2+ch4+c2h6;
    if gs < 1, dt4_fault = 'Insufficient Gas'; return; end
    ph=(h2/gs)*100; pm=(ch4/gs)*100; pe=(c2h6/gs)*100;
    pt=tri(ph,pm,pe); X=pt(1); Y=pt(2);

    p_pd=[tri(98,2,0);tri(97,2,1);tri(84,15,1);tri(85,15,0)];
    p_nd=[tri(54,0,46);tri(9,45,46);tri(9,0,91)];
    p_o =[tri(9,0,91);tri(9,61,30);tri(0,70,30);tri(0,0,100)];
    p_c =[tri(0,100,0);tri(0,70,30);tri(15,55,30);tri(15,61,24);tri(40,36,24);tri(64,36,0)];
    p_s =[tri(98,2,0);tri(97,2,1);tri(84,15,1);tri(85,15,0); ...
          tri(64,36,0);tri(40,36,24);tri(15,61,24);tri(15,55,30); ...
          tri(9,61,30);tri(9,45,46);tri(54,0,46);tri(100,0,0)];

    if     inpolygon(X,Y,p_pd(:,1),p_pd(:,2)), dt4_fault='PD - Partial Discharge';
    elseif inpolygon(X,Y,p_s(:,1), p_s(:,2)),  dt4_fault='S - Stray Gassing';
    elseif inpolygon(X,Y,p_c(:,1), p_c(:,2)),  dt4_fault='C - Carbonisation';
    elseif inpolygon(X,Y,p_o(:,1), p_o(:,2)),  dt4_fault='O - Overheating';
    elseif inpolygon(X,Y,p_nd(:,1),p_nd(:,2)), dt4_fault='ND - Undefined';
    else,                                        dt4_fault='Undetermined / Boundary';
    end
end


function dt5_fault = calc_dt5_fault(ch4, c2h4, c2h6, dt1_fault) % DT5 geometry
    dt5_fault = '';
    if ~(strcmp(dt1_fault,'T3: High Temperature Thermal Fault (>700C)') || ...
         strcmp(dt1_fault,'T2: Medium Temperature Thermal Fault (300-700C)')), return; end

    total = ch4+c2h4+c2h6;
    if total < 1, dt5_fault = 'Insufficient Gas'; return; end
    pm=(ch4/total)*100; pe=(c2h4/total)*100;
    gx=@(e,m) e+0.5*m; gy=@(m) m*(sqrt(3)/2);
    xy=@(p) [gx(p(:,1),100-p(:,1)-p(:,2)), gy(100-p(:,1)-p(:,2))];

    aPD=[0,2;1,2;1,14;0,14]; aS=[0,14;10,14;10,54;0,54];
    aOT=[0,0;10,0;10,14;1,14;1,2;0,2]; aOB=[0,54;10,54;10,90;0,100];
    aT2=[10,12;35,12;35,0;10,0]; aC=[10,30;70,30;70,14;50,14;50,12;10,12];
    aND=[10,90;35,65;35,30;10,30];
    aT3=[35,65;100,0;35,0;35,12;50,12;50,14;70,14;70,30;35,30];
    ux=gx(pe,pm); uy=gy(pm);
    xPD=xy(aPD); xS=xy(aS); xOT=xy(aOT); xOB=xy(aOB);
    xT2=xy(aT2); xC=xy(aC); xND=xy(aND); xT3=xy(aT3);

    if     inpolygon(ux,uy,xPD(:,1),xPD(:,2)), dt5_fault='PD - Partial Discharge';
    elseif inpolygon(ux,uy,xS(:,1), xS(:,2)),  dt5_fault='S - Stray Gassing';
    elseif inpolygon(ux,uy,xOT(:,1),xOT(:,2))||inpolygon(ux,uy,xOB(:,1),xOB(:,2)), dt5_fault='O - Overheating';
    elseif inpolygon(ux,uy,xT2(:,1),xT2(:,2)), dt5_fault='T2 - Thermal Fault (300-700 C)';
    elseif inpolygon(ux,uy,xC(:,1), xC(:,2)),  dt5_fault='C - Carbonization';
    elseif inpolygon(ux,uy,xND(:,1),xND(:,2)), dt5_fault='ND - Not Determined';
    elseif inpolygon(ux,uy,xT3(:,1),xT3(:,2)), dt5_fault='T3 - Thermal Fault (>700 C)';
    else,                                        dt5_fault='Undetermined / Boundary';
    end
end


function fig = plot_dt1(r) % Duval Triangle 1 figure
    ch4=r.ch4; c2h4=r.c2h4; c2h2=r.c2h2;
    top=[0.5,0.866]; right=[1,0]; left=[0,0];
    a=[0.49,0.849]; b=[0.51,0.849]; c_pt=[0.48,0.831]; d=[0.58,0.658]; e=[0.6,0.693];
    f=[0.73,0.398]; g=[0.75,0.433]; h_pt=[0.675,0.303]; I_pt=[0.85,0]; J_pt=[0.71,0];
    k_pt=[0.555,0.268]; l=[0.635,0.407]; m=[0.55,0.554]; n=[0.435,0.753]; o=[0.23,0];

    PD_x=[top(1),b(1),a(1)];                         PD_y=[top(2),b(2),a(2)];
    T1_x=[a(1),b(1),e(1),d(1),c_pt(1)];              T1_y=[a(2),b(2),e(2),d(2),c_pt(2)];
    T2_x=[d(1),e(1),g(1),f(1)];                      T2_y=[d(2),e(2),g(2),f(2)];
    T3_x=[f(1),g(1),right(1),I_pt(1),h_pt(1)];       T3_y=[f(2),g(2),right(2),I_pt(2),h_pt(2)];
    D1_x=[n(1),m(1),o(1),left(1)];                   D1_y=[n(2),m(2),o(2),left(2)];
    D2_x=[m(1),l(1),k_pt(1),J_pt(1),o(1)];           D2_y=[m(2),l(2),k_pt(2),J_pt(2),o(2)];
    DT_x=[c_pt(1),d(1),f(1),h_pt(1),I_pt(1),J_pt(1),k_pt(1),l(1),m(1),n(1)];
    DT_y=[c_pt(2),d(2),f(2),h_pt(2),I_pt(2),J_pt(2),k_pt(2),l(2),m(2),n(2)];

    fig = figure('Name',['Duval Triangle 1 - ' r.sample_id],'Color','#24273a', ...
                 'NumberTitle','off','Visible','off');
    hold on; axis equal; axis off;

    fill(PD_x,PD_y,[0.85 0.95 1.00],'EdgeColor','#24273a');
    fill(T1_x,T1_y,[1.00 0.68 0.69],'EdgeColor','#24273a');
    fill(T2_x,T2_y,[1.00 0.80 0.00],'EdgeColor','#24273a');
    fill(T3_x,T3_y,[0.25 0.25 0.25],'EdgeColor','#24273a');
    fill(D1_x,D1_y,[0.00 0.81 0.88],'EdgeColor','#24273a');
    fill(D2_x,D2_y,[0.15 0.32 0.65],'EdgeColor','#24273a');
    fill(DT_x,DT_y,[0.83 0.33 0.64],'EdgeColor','#24273a');

    text(mean(PD_x),mean(PD_y),'PD','HorizontalAlignment','center','FontWeight','bold','color','r');
    text(mean(T1_x),mean(T1_y),'T1','HorizontalAlignment','center','FontWeight','bold','color','r');
    text(mean(T2_x),mean(T2_y),'T2','HorizontalAlignment','center','FontWeight','bold','color','r');
    text(mean(T3_x),mean(T3_y),'T3','HorizontalAlignment','center','FontWeight','bold','color','r');
    text(mean(D1_x),mean(D1_y),'D1','HorizontalAlignment','center','FontWeight','bold','color','r');
    text(0.65,0.20,'DT','HorizontalAlignment','center','FontWeight','bold','color','r');
    text(0.5, 0.2, 'D2','HorizontalAlignment','center','FontWeight','bold','color','r');
    plot([0 1 0.5 0],[0 0 0.866 0],'k-','LineWidth',1.2);

    gas_sum = ch4+c2h4+c2h2;
    if gas_sum >= 1
        pct_ch4  = (ch4  /gas_sum)*100;
        pct_c2h4 = (c2h4 /gas_sum)*100;
        pct_c2h2 = (c2h2 /gas_sum)*100;
        f_ch4  = ch4  /gas_sum;  f_c2h4 = c2h4 /gas_sum;
        Xp = ((f_c2h4/0.866)+(f_ch4/1.732))*0.866;
        Yp = f_ch4*0.866;
        plot(Xp,Yp,'go','MarkerFaceColor','b','MarkerSize',4,'LineWidth',1.5);
        text(Xp+0.03,Yp,sprintf('  Fault\n  (%.1f, %.1f, %.1f)',pct_ch4,pct_c2h4,pct_c2h2), ...
            'BackgroundColor','#cad3f5','color','k','EdgeColor','r','LineWidth',1,'Margin',1);
    end
    text(0.215,0.45,'% CH_4','Rotation',60,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');
    text(0.77, 0.48,'% C_2H_4','Rotation',-60,'HorizontalAlignment','left','FontSize',12,'FontWeight','bold');
    text(0.5, -0.05,'% C_2H_2','HorizontalAlignment','center','FontSize',12,'FontWeight','bold');
    title(['Duval Triangle 1 Diagnosis: ' r.dt1_fault],'FontSize',14);
    hold off;
end


function fig = plot_dt4(r) % Duval Triangle 4 figure
    h2=r.h2; ch4=r.ch4; c2h6=r.c2h6;
    fprintf('The fault zones are shown on Duval trangle 4\n')

    fig = figure('Color','#24273a','Name',['Duval Triangle 4 - ' r.sample_id], ...
                 'NumberTitle','off','Visible','off');
    hold on; axis equal; axis off;

    tri = @(h,m,~) [(m+0.5*h), (h*sqrt(3)/2)];
    Top=tri(100,0,0); Left=tri(0,0,100); Right=tri(0,100,0);
    plot([Top(1) Left(1) Right(1) Top(1)],[Top(2) Left(2) Right(2) Top(2)],'k','LineWidth',1.2);

    p_pd=[tri(98,2,0);tri(97,2,1);tri(84,15,1);tri(85,15,0)];
    p_nd=[tri(54,0,46);tri(9,45,46);tri(9,0,91)];
    p_o =[tri(9,0,91);tri(9,61,30);tri(0,70,30);tri(0,0,100)];
    p_c =[tri(0,100,0);tri(0,70,30);tri(15,55,30);tri(15,61,24);tri(40,36,24);tri(64,36,0)];
    p_s =[tri(98,2,0);tri(97,2,1);tri(84,15,1);tri(85,15,0); ...
          tri(64,36,0);tri(40,36,24);tri(15,61,24);tri(15,55,30); ...
          tri(9,61,30);tri(9,45,46);tri(54,0,46);tri(100,0,0)];

    function fill_poly(pts,color)
        patch(pts(:,1),pts(:,2),color,'EdgeColor','k','LineWidth',1);
    end
    fill_poly(p_s,[0.95,0.95,1.0]); fill_poly(p_pd,[0.8,0.9,1.0]);
    fill_poly(p_nd,[0.9,1.0,0.9]);  fill_poly(p_o,[1.0,0.9,0.6]);
    fill_poly(p_c,[0.6,0.6,0.6]);

    function text_loc(h,m,~,str)
        loc=[(m+0.5*h),(h*sqrt(3)/2)];
        text(loc(1),loc(2),str,'Color','r','HorizontalAlignment','center','FontWeight','bold');
    end
    text_loc(92,9,3,'PD'); text_loc(50,20,30,'S');
    text_loc(25,10,65,'ND'); text_loc(4,30,66,'O'); text_loc(15,70,15,'C');

    text(23,48,'% H_2','Rotation',60,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');
    text(75,50,'% CH_4','Rotation',-60,'HorizontalAlignment','left','FontSize',12,'FontWeight','bold');
    text(50,-5,'% C_2H_6','HorizontalAlignment','center','FontSize',12,'FontWeight','bold');

    gs=h2+ch4+c2h6;
    ph=(h2/gs)*100; pm=(ch4/gs)*100; pe=(c2h6/gs)*100;
    inp=tri(ph,pm,pe);
    plot(inp(1),inp(2),'go','MarkerSize',4,'MarkerFaceColor','b','LineWidth',1.5);
    text(inp(1)+2,inp(2),sprintf('  Fault\n  (%.1f, %.1f, %.1f)',ph,pm,pe), ...
        'BackgroundColor','#cad3f5','color','k','EdgeColor','k','LineWidth',1,'Margin',1);
    title(['Duval Triangle 4 Diagnosis: ' r.dt4_fault],'FontSize',14);
    fprintf('Diagnosis: %s\n', r.dt4_fault);
end


function fig = plot_dt5(r) % Duval Triangle 5 figure
    ch4=r.ch4; c2h4=r.c2h4; c2h6=r.c2h6;
    fprintf('The fault zones are shown on Duval trangle 5\n')

    total=ch4+c2h4+c2h6;
    pm=(ch4/total)*100; pe=(c2h4/total)*100; pv=(c2h6/total)*100;
    h_tri=100*sqrt(3)/2;
    gx=@(e,m) e+0.5*m; gy=@(m) m*(sqrt(3)/2);
    xy=@(p) [gx(p(:,1),100-p(:,1)-p(:,2)), gy(100-p(:,1)-p(:,2))];

    aPD=[0,2;1,2;1,14;0,14]; aS=[0,14;10,14;10,54;0,54];
    aOT=[0,0;10,0;10,14;1,14;1,2;0,2]; aOB=[0,54;10,54;10,90;0,100];
    aT2=[10,12;35,12;35,0;10,0]; aC=[10,30;70,30;70,14;50,14;50,12;10,12];
    aND=[10,90;35,65;35,30;10,30];
    aT3=[35,65;100,0;35,0;35,12;50,12;50,14;70,14;70,30;35,30];

    fig = figure('Color','#24273a','Name',['Duval Triangle 5 - ' r.sample_id],'Visible','off');
    hold on; axis equal; axis off;

    dz=@(p,col) patch('Vertices',xy(p),'Faces',1:size(p,1),'FaceColor',col,'EdgeColor','k','LineWidth',0.8);
    dz(aT3,[0.451 0.651 1.0]); dz(aC,[1.0 0.682 0.102]);
    dz(aND,[0.792 0.827 0.961]); dz(aT2,[0.2 0.49 1.0]);
    dz(aS,[1.0 0.592 0.663]); dz(aPD,[1.0 1.0 0.102]);
    dz(aOT,[1.0 0.102 0.102]); dz(aOB,[1.0 0.102 0.102]);

    plot([0 100 50 0],[0 0 h_tri 0],'k-','LineWidth',1.5);
    text(46,h_tri-8,'PD','Color','r','Horiz','center','FontWeight','bold');
    text(50,h_tri-10,'O','Color','k','Horiz','center','FontWeight','bold');
    text(33,50,'S','Color','r','Horiz','center','FontWeight','bold');
    text(15,20,'O','Color','k','Horiz','center','FontWeight','bold');
    text(35,20,'ND','Color','r','Horiz','center','FontWeight','bold');
    text(55,40,'C','Color','r','Horiz','center','FontWeight','bold');
    text(52,11,'T3','Color','r','Horiz','center','FontWeight','bold');
    text(83,15,'T3','Color','r','Horiz','center','FontWeight','bold');
    text(57,60,'T2','Color','r','Horiz','center','FontWeight','bold');
    text(17,h_tri-50,'% CH_4','Rotation',60,'HorizontalAlignment','left','FontSize',12,'FontWeight','bold');
    text(50,-4,'% C_2H_6','HorizontalAlignment','center','FontSize',12,'FontWeight','bold');
    text(78,45,'% C_2H_4','Rotation',-60,'HorizontalAlignment','center','FontSize',12,'FontWeight','bold');

    ux=gx(pe,pm); uy=gy(pm);
    plot(ux,uy,'ko','MarkerFaceColor','r','MarkerSize',8,'LineWidth',1.5);
    text(ux+2,uy,sprintf('  Input\n  (%.1f, %.1f, %.1f)',pm,pe,pv), ...
        'BackgroundColor','w','EdgeColor','k','FontSize',8);

    fprintf('\nDetected Zone: %s\n', r.dt5_fault);
    title(['Duval Triangle 5: ' r.dt5_fault]);
end
