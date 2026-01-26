import sys
import os
import math
import matplotlib.pyplot as plt
from matplotlib.path import Path
from matplotlib.widgets import Button

if sys.stdout is None:
    sys.stdout = open(os.devnull, "w")
if sys.stderr is None:
    sys.stderr = open(os.devnull, "w")

def main():
    print("===== DGA Calculator =====")

    # Taking Inputs
    def get_input(prompt):
        while True:
            try:
                val = float(input(prompt))
                return max(0, val)
            except ValueError:
                 print("Invalid input. Please enter a number.")
    
    try:
       h2 = get_input('H2 - Hydrogen (ppm): ')
       ch4 = get_input('CH4 - Methane (ppm): ')
       c2h6 = get_input('C2H6 - Ethane (ppm): ')
       c2h4 = get_input('C2H4 - Ethylene (ppm): ')
       c2h2 = get_input('C2H2 - Acetylene (ppm): ')
       co = get_input('CO - Carbon Monoxide (ppm): ')
       co2 = get_input('CO2 - Carbon Dioxide (ppm): ')
    except KeyboardInterrupt:
         print("\nAborted.")
         sys.exit()

    # ----------------------- Total Dissolved Combustible Gas --------------------------------
    
    tdcg = h2 + ch4 + c2h6 + c2h4 + c2h2 + co
    
    print('\n--- Preliminary Assessment ---')
    print(f'Total Dissolved Combustible Gas (TDCG): {tdcg:.2f} ppm')

    if tdcg < 720:
      print('Status: Condition 1 (Healthy/Normal). Ratios may be unreliable.')
    elif 720 <= tdcg <= 1920:
      print('Status: Condition 2 (Caution). Monitor closely for gas increase.')
    elif 1920 < tdcg <= 4630:
      print('Status: Condition 3 (High Risk)')
    else:
      print('Status: Condition 4 (Excessive Decomposition - Immediate Action)')


    #----------------------------------------- Rogers Ratio Method ------------------------------------

    print('\n---> Rogers Ratio Method <---')

    def get_rr(num, den):
        if den > 0:
            return num / den
        elif num == 0:
            return 0.0
        else:
            return 999.0

    r1 = get_rr(c2h2, c2h4)
    r2 = get_rr(ch4, h2)
    r5 = get_rr(c2h4, c2h6)

    print('\nCalculated Ratios:')
    print(f'R1 (C2H2/C2H4): {r1:.2f}')
    print(f'R2 (CH4/H2):    {r2:.2f}')
    print(f'R5 (C2H4/C2H6): {r5:.2f}')

    rr_result = 'Diagnostic ratios do not match a standard fault pattern (Undetermined)'

    if tdcg < 50:
        print("Gas levels too low for reliable Ratio Analysis.")
        rr_result = "Healthy / Low Gas"
    else:
      if r1 < 0.1 and 0.1 <= r2 <= 1.0 and r5 < 1.0:
          rr_result = 'Normal working condition'
      elif r1 < 0.1 and r2 < 0.1 and r5 < 1.0:
          rr_result = 'Possible Partial Discharge (Rogers method is limited)'
      elif 0.1 <= r1 <= 3.0 and 0.1 <= r2 <= 1.0 and r5 > 3.0:
          rr_result = 'High-energy Discharge (Arcing)'
      elif r1 < 0.1 and 0.1 <= r2 <= 1.0 and 1.0 <= r5 <= 3.0:
          rr_result = 'Low Temperature Thermal Fault (<300C)'
      elif r1 < 0.1 and r2 > 1.0 and 1.0 <= r5 <= 3.0:
          rr_result = 'Medium Temperature Thermal Fault (300-700C)'
      elif r1 < 0.1 and r2 > 1.0 and r5 > 3.0:
          rr_result = 'High Temperature Thermal Fault (>700C)'

    print(f'\nDiagnosis: {rr_result}')


    #------------------------------------------ Key Gas Method ----------------------------------------

    print('\n---> Key Gas Method <---')

    if tdcg > 0:
       p_h2   = (h2 / tdcg) * 100
       p_ch4  = (ch4 / tdcg) * 100
       p_c2h6 = (c2h6 / tdcg) * 100
       p_c2h4 = (c2h4 / tdcg) * 100
       p_c2h2 = (c2h2 / tdcg) * 100
       p_co   = (co / tdcg) * 100
    else:
       p_h2 = p_ch4 = p_c2h6 = p_c2h4 = p_c2h2 = p_co = 0

    kg_result = 'Normal / Inconclusive'

    if p_c2h2 >= 5 and c2h2 > 0:
       kg_result = 'High-Energy Discharge (Arcing) [Key Gas: Acetylene]'
    elif p_c2h4 > 20 and c2h4 > c2h6:
       kg_result = 'Thermal Fault in Oil (>700 C) [Key Gas: Ethylene]'
    elif p_co > 80:
       kg_result = 'Overheating of Insulation Paper [Key Gas: Carbon Monoxide]'
    elif p_c2h6 > p_ch4 and p_c2h6 > p_c2h4:
       kg_result = 'Low-temp Thermal / Oil Decomposition [Key Gas: Ethane]'
    elif p_ch4 > p_h2 and p_ch4 > p_c2h4:
       kg_result = 'Low-temp Thermal (<300 C) [Key Gas: Methane]'
    elif p_h2 > p_ch4 and p_h2 > p_c2h4:
       kg_result = 'Partial Discharge (Corona) [Key Gas: Hydrogen]'

    print(f'Diagnosis: \n{kg_result}\n')


    #------------------------------------------ CO2/CO Ratio ----------------------------------------

    print('\n---> CO2/CO Ratio Analysis <---')

    if co > 0:
       ratio_co2_co = co2 / co
       print(f'CO2/CO Ratio: {ratio_co2_co:.2f}')

       if ratio_co2_co < 3:
           print('Diagnosis: Severe paper degradation (Carbonization).')
       elif ratio_co2_co > 10:
           print('Diagnosis: Normal paper aging, Mild overheating.')
       else:
           print('Diagnosis: Healthy insulation, Standard operation.')
    else:
       print('CO2/CO Ratio: N/A (CO level is 0)')

    # --- Next button ---
    def add_next_button(fig):
        # Position: Left, Bottom, Width, Height
        ax_btn = plt.axes([0.81, 0.01, 0.18, 0.05])
        btn = Button(ax_btn, 'Continue >>', color='#cad3f5', hovercolor='#a5adce')
        fig._btn_ref = btn 
        btn.on_clicked(lambda event: plt.close(fig))

    #------------------------------------------ Duval Triangle 1 ----------------------------------------

    print('\n---> Duval Triangle 1 <---')

    top   = [0.5, 0.866]
    right = [1.0, 0.0]
    left  = [0.0, 0.0]

    a = [0.49, 0.849]; b = [0.51, 0.849]; c = [0.48, 0.831]; d = [0.58, 0.658]; e = [0.6, 0.693]
    f = [0.73, 0.398]; g = [0.75, 0.433]; h = [0.675, 0.303]; I = [0.85, 0];    J = [0.71, 0]
    k = [0.555, 0.268]; l = [0.635, 0.407]; m = [0.55, 0.554]; n = [0.435, 0.753]; o = [0.23, 0]

    poly_PD = [top, b, a]
    poly_T1 = [a, b, e, d, c]
    poly_T2 = [d, e, g, f]
    poly_T3 = [f, g, right, I, h]
    poly_D1 = [n, m, o, left]
    poly_D2 = [m, l, k, J, o]
    poly_DT = [c, d, f, h, I, J, k, l, m, n]

    gas_sum_dt1 = ch4 + c2h4 + c2h2
    dt1_fault = 'Undetermined / Boundary'
    X_pt, Y_pt = 0, 0
    p_ch4, p_c2h4, p_c2h2 = 0, 0, 0

    if gas_sum_dt1 < 1:
       dt1_fault = 'Insufficient Gas for DGA'
    else:
       f_ch4  = ch4 / gas_sum_dt1
       f_c2h4 = c2h4 / gas_sum_dt1
       f_c2h2 = c2h2 / gas_sum_dt1
       p_ch4  = f_ch4 * 100
       p_c2h4 = f_c2h4 * 100
       p_c2h2 = f_c2h2 * 100
       X_pt = ((f_c2h4 / 0.866) + (f_ch4 / 1.732)) * 0.866
       Y_pt = f_ch4 * 0.866
       point = [X_pt, Y_pt]

       if Path(poly_PD).contains_point(point): dt1_fault = 'PD: Partial Discharge'
       elif Path(poly_T1).contains_point(point): dt1_fault = 'T1: Low Temp Thermal (<300C)'
       elif Path(poly_T2).contains_point(point): dt1_fault = 'T2: Med Temp Thermal (300-700C)'
       elif Path(poly_T3).contains_point(point): dt1_fault = 'T3: High Temp Thermal (>700C)'
       elif Path(poly_D1).contains_point(point): dt1_fault = 'D1: Low Energy Discharge'
       elif Path(poly_D2).contains_point(point): dt1_fault = 'D2: High Energy Discharge'
       elif Path(poly_DT).contains_point(point): dt1_fault = 'DT: Mix of Thermal/Electrical'

    print(f'Diagnosis: {dt1_fault}')

    # --- Plotting DT1 ---
    if gas_sum_dt1 >= 1:
       fig, ax = plt.subplots(figsize=(8, 7), facecolor='#24273a')
       ax.set_aspect('equal')
       ax.axis('off')
       ax.set_title(f'Duval Triangle 1 Diagnosis: {dt1_fault}', color='white', fontsize=14)

       def plot_zone(vertices, color, label):
           poly = plt.Polygon(vertices, closed=True, facecolor=color, edgecolor='#24273a')
           ax.add_patch(poly)
           mean_x = sum(v[0] for v in vertices) / len(vertices)
           mean_y = sum(v[1] for v in vertices) / len(vertices)
           if label == 'DT': mean_x, mean_y = 0.65, 0.20
           if label == 'D2': mean_x, mean_y = 0.50, 0.20
           ax.text(mean_x, mean_y, label, ha='center', va='center', fontweight='bold', color='red')

       plot_zone(poly_PD, '#dbeafe', 'PD')
       plot_zone(poly_T1, '#ffadad', 'T1')
       plot_zone(poly_T2, '#ffd6a5', 'T2')
       plot_zone(poly_T3, '#3f3f3f', 'T3')
       plot_zone(poly_D1, '#00cfe0', 'D1')
       plot_zone(poly_D2, '#2652a7', 'D2')
       plot_zone(poly_DT, '#d453a3', 'DT')

       triangle_boundary = [left, top, right, left]
       x_b, y_b = zip(*triangle_boundary)
       ax.plot(x_b, y_b, 'k-', linewidth=1.5)
       ax.plot(X_pt, Y_pt, 'go', markeredgecolor='b', markersize=8)

       label_text = f"Fault\n({p_ch4:.1f}, {p_c2h4:.1f}, {p_c2h2:.1f})"
       ax.text(X_pt + 0.02, Y_pt, label_text, color='black', fontsize=9,
               bbox=dict(facecolor='#cad3f5', edgecolor='red', boxstyle='round,pad=0.3'))

       ax.text(0.215, 0.45, '% $CH_4$', rotation=60, ha='center', fontweight='bold', color='white')
       ax.text(0.77, 0.48, '% $C_2H_4$', rotation=-60, ha='left', fontweight='bold', color='white')
       ax.text(0.5, -0.05, '% $C_2H_2$', ha='center', fontweight='bold', color='white')
       
       add_next_button(fig)
       plt.show() # stops until user closes or clicks continue

    # ----------------------------------------------------------------- Duval Triangle 4 -----------------------------------------------------

    def plot_dt4(h2, ch4, c2h6):
       print('\n---> Duval Triangle 4 (Low/Med Thermal Faults) <---')

       def triangular_dt4(h, m, e):
           return ((m + 0.5 * h), (h * 0.866025))

       raw_pd = [(98, 2, 0), (97, 2, 1), (84, 15, 1), (85, 15, 0)]
       poly_pd = [triangular_dt4(*pt) for pt in raw_pd]
       raw_nd = [(54, 0, 46), (9, 45, 46), (9, 0, 91)]
       poly_nd = [triangular_dt4(*pt) for pt in raw_nd]
       raw_o = [(9, 0, 91), (9, 61, 30), (0, 70, 30), (0, 0, 100)]
       poly_o = [triangular_dt4(*pt) for pt in raw_o]
       raw_c = [(0, 100, 0), (0, 70, 30), (15, 55, 30), (15, 61, 24), (40, 36, 24), (64, 36, 0)]
       poly_c = [triangular_dt4(*pt) for pt in raw_c]
       raw_s = [
           (98, 2, 0), (97, 2, 1), (84, 15, 1), (85, 15, 0), 
           (64, 36, 0), (40, 36, 24), (15, 61, 24), (15, 55, 30), 
           (9, 61, 30), (9, 45, 46), (54, 0, 46), (100, 0, 0) 
       ]
       poly_s = [triangular_dt4(*pt) for pt in raw_s]

       gas_sum_dt4 = h2 + ch4 + c2h6
       dt4_fault = 'Undetermined / Boundary'
       p_h2, p_ch4, p_c2h6 = 0, 0, 0
       X4, Y4 = 0, 0

       if gas_sum_dt4 > 0:
           p_h2 = (h2 / gas_sum_dt4) * 100
           p_ch4 = (ch4 / gas_sum_dt4) * 100
           p_c2h6 = (c2h6 / gas_sum_dt4) * 100
           X4, Y4 = triangular_dt4(p_h2, p_ch4, p_c2h6)
           point = [X4, Y4]
           if Path(poly_pd).contains_point(point): dt4_fault = 'PD - Partial Discharge'
           elif Path(poly_s).contains_point(point): dt4_fault = 'S - Stray Gassing'
           elif Path(poly_c).contains_point(point): dt4_fault = 'C - Carbonisation'
           elif Path(poly_o).contains_point(point): dt4_fault = 'O - Overheating'
           elif Path(poly_nd).contains_point(point): dt4_fault = 'ND - Undefined'

       print(f'Diagnosis: {dt4_fault}')

       fig, ax = plt.subplots(figsize=(8, 7), facecolor='#24273a')
       ax.set_aspect('equal')
       ax.axis('off')
       ax.set_title(f'Duval Triangle 4 Diagnosis: {dt4_fault}', color='white', fontsize=14)

       def add_patch(coords, color, label, lbl_coords):
           poly = plt.Polygon(coords, closed=True, facecolor=color, edgecolor='black', linewidth=1)
           ax.add_patch(poly)
           lx, ly = triangular_dt4(*lbl_coords)
           ax.text(lx, ly, label, color='red', ha='center', fontweight='bold')

       add_patch(poly_s,  (0.95, 0.95, 1.0), 'S',  (50, 20, 30))
       add_patch(poly_pd, (0.8, 0.9, 1.0),   'PD', (92, 9, 3))
       add_patch(poly_nd, (0.9, 1.0, 0.9),   'ND', (25, 10, 65))
       add_patch(poly_o,  (1.0, 0.9, 0.6),   'O',  (4, 30, 66))
       add_patch(poly_c,  (0.6, 0.6, 0.6),   'C',  (15, 70, 15))

       top = triangular_dt4(100, 0, 0)
       right = triangular_dt4(0, 100, 0)
       left = triangular_dt4(0, 0, 100)
       border_x = [top[0], right[0], left[0], top[0]]
       border_y = [top[1], right[1], left[1], top[1]]
       ax.plot(border_x, border_y, 'k-', linewidth=1.2)

       if gas_sum_dt4 > 0:
           ax.plot(X4, Y4, 'go', markeredgecolor='black', markersize=6)
           label_text = f"Fault\n({p_h2:.1f}, {p_ch4:.1f}, {p_c2h6:.1f})"
           ax.text(X4 + 2, Y4, label_text, color='black', fontsize=9,
                   bbox=dict(facecolor='#cad3f5', edgecolor='black', boxstyle='round,pad=0.3'))

       ax.text(23, 48, '% $H_2$', rotation=60, ha='center', fontweight='bold', color='white')
       ax.text(75, 50, '% $CH_4$', rotation=-60, ha='left', fontweight='bold', color='white')
       ax.text(50, -5, '% $C_2H_6$', ha='center', fontweight='bold', color='white')

       add_next_button(fig)
       plt.show()

    if dt1_fault in ['PD: Partial Discharge',
                     'T1: Low Temp Thermal (<300C)',
                      'T2: Med Temp Thermal (300-700C)']:
       plot_dt4(h2, ch4, c2h6)

    # --------------------------------------------- Duval Triangle 5 Function --------------------------------------------------

    def plot_dt5(ch4, c2h4, c2h6):
       print('\n---> Duval Triangle 5 (Med/High Temp Faults) <---')

       def get_dt5_coords(c2h4, ch4):
           return (c2h4 + 0.5 * ch4, ch4 * 0.866025)

       def to_cartesian(pts_list):
           cartesian_pts = []
           for (p_c2h4, p_c2h6) in pts_list:
               p_ch4 = 100 - p_c2h4 - p_c2h6
               cartesian_pts.append(get_dt5_coords(p_c2h4, p_ch4))
           return cartesian_pts

       raw_pd = [(0, 2), (1, 2), (1, 14), (0, 14)]
       raw_s = [(0, 14), (10, 14), (10, 54), (0, 54)]
       raw_o_top = [(0, 0), (10, 0), (10, 14), (1, 14), (1, 2), (0, 2)]
       raw_o_bot = [(0, 54), (10, 54), (10, 90), (0, 100)]
       raw_t2 = [(10, 12), (35, 12), (35, 0), (10, 0)]
       raw_c = [(10, 30), (70, 30), (70, 14), (50, 14), (50, 12), (10, 12)]
       raw_nd = [(10, 90), (35, 65), (35, 30), (10, 30)]
       raw_t3 = [(35, 65), (100, 0), (35, 0), (35, 12), (50, 12), (50, 14), (70, 14), (70, 30), (35, 30)]

       poly_pd = to_cartesian(raw_pd)
       poly_s  = to_cartesian(raw_s)
       poly_o_top = to_cartesian(raw_o_top)
       poly_o_bot = to_cartesian(raw_o_bot)
       poly_t2 = to_cartesian(raw_t2)
       poly_c  = to_cartesian(raw_c)
       poly_nd = to_cartesian(raw_nd)
       poly_t3 = to_cartesian(raw_t3)

       total_gas = ch4 + c2h4 + c2h6
       diag = 'Undetermined / Boundary'
       p_ch4, p_c2h4, p_c2h6 = 0, 0, 0
       ux, uy = 0, 0

       if total_gas > 0:
           p_ch4  = (ch4 / total_gas) * 100
           p_c2h4 = (c2h4 / total_gas) * 100
           p_c2h6 = (c2h6 / total_gas) * 100
           ux, uy = get_dt5_coords(p_c2h4, p_ch4)
           point = [ux, uy]
           if Path(poly_pd).contains_point(point): diag = 'PD - Partial Discharge'
           elif Path(poly_s).contains_point(point): diag = 'S - Stray Gassing'
           elif Path(poly_o_top).contains_point(point) or Path(poly_o_bot).contains_point(point):
               diag = 'O - Overheating'
           elif Path(poly_t2).contains_point(point): diag = 'T2 - Thermal Fault (300-700 C)'
           elif Path(poly_c).contains_point(point): diag = 'C - Carbonization'
           elif Path(poly_nd).contains_point(point): diag = 'ND - Not Determined'
           elif Path(poly_t3).contains_point(point): diag = 'T3 - Thermal Fault (>700 C)'

       print(f'Detected Zone: {diag}')

       fig, ax = plt.subplots(figsize=(8, 7), facecolor='#24273a')
       ax.set_aspect('equal')
       ax.axis('off')
       ax.set_title(f'Duval Triangle 5 Diagnosis: {diag}', color='white', fontsize=14)

       def add_patch(coords, color):
           poly = plt.Polygon(coords, closed=True, facecolor=color, edgecolor='black', linewidth=0.8)
           ax.add_patch(poly)

       add_patch(poly_t3, '#73a6ff')
       add_patch(poly_c,  '#ffae1a')
       add_patch(poly_nd, '#cacdf5')
       add_patch(poly_t2, '#337dff')
       add_patch(poly_s,  '#ff97a9')
       add_patch(poly_pd, '#ffff1a')
       add_patch(poly_o_top, '#ff1a1a')
       add_patch(poly_o_bot, '#ff1a1a')

       boundary = [(0,0), (100,0), (50, 86.6025), (0,0)]
       bx, by = zip(*boundary)
       ax.plot(bx, by, 'k-', linewidth=1.5)

       h = 100 * math.sqrt(3) / 2
       def add_lbl(x, y, txt, color='red'):
           ax.text(x, y, txt, color=color, ha='center', fontweight='bold', fontsize=10)

       add_lbl(46, h-8, 'PD')
       add_lbl(50, h-10, 'O', 'black')
       add_lbl(33, 50,  'S')
       add_lbl(15, 20,  'O', 'black')
       add_lbl(35, 20,  'ND')
       add_lbl(55, 40,  'C')
       add_lbl(52, 11,  'T3')
       add_lbl(83, 15,  'T3')
       add_lbl(57, 60,  'T2')

       ax.text(17, h-50, '% $CH_4$', rotation=60, ha='left', fontweight='bold', color='white', fontsize=11)
       ax.text(50, -4, '% $C_2H_6$', ha='center', fontweight='bold', color='white', fontsize=11)
       ax.text(78, 45, '% $C_2H_4$', rotation=-60, ha='center', fontweight='bold', color='white', fontsize=11)

       if total_gas > 0:
           ax.plot(ux, uy, 'ko', markerfacecolor='red', markersize=8)
           label_text = f"Input\n({p_ch4:.1f}, {p_c2h4:.1f}, {p_c2h6:.1f})"
           ax.text(ux + 2, uy, label_text, color='black', fontsize=9,
                   bbox=dict(facecolor='white', edgecolor='black', boxstyle='round,pad=0.2'))

       add_next_button(fig)
       plt.show()

    if dt1_fault in ['T2: Med Temp Thermal (300-700C)', 'T3: High Temp Thermal (>700C)']:
       plot_dt5(ch4, c2h4, c2h6)

    input("\nAnalysis Complete. Press Enter to exit...")

if __name__ == "__main__":
    main()