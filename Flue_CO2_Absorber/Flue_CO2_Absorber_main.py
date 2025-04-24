# Flue_CO2_Absorber.py
# Author: Kachi Ezuma-Ngwu
# Description: Simulate CO₂ capture via amine scrubbing in a packed absorption column

import numpy
from scipy.integrate import solve_ivp
import matplotlib.pyplot as plt
import seaborn as sns


# PARAMETERS -----

# System parameters
column_height = 35.0      # in meters
n_steps = 50
z_span = (0, column_height)
z_eval = numpy.linspace(*z_span, n_steps)

# Operating conditions
P_total = 1.0             # in atm
T = 373.15                # in Kelvin
CO2_frac_inlet = 0.38     # mole fraction of CO2 in flue gas
C_CO2_gas_inlet = CO2_frac_inlet * P_total * 101325 / (8.314 * T)  # mol/m^3

# Liquid phase
amine_conc = 1800         # mol/m^3 (e.g., 18% MEA)
liq_flow_rate = 1.721     # m^3/s
gas_flow_rate = 21.443   # m^3/s

# Externals
k_G = 0.003                # m/s, how fast CO2 crosses from gas into the interface.
a = 188                   # m^2/m^3
E = 1.77                  # Enhancement factor


# ODE Environment ------

def co2_absorption_odes(z, y):
    C_CO2_gas = y[0]  # mol/m^3
    alpha = y[1]      # mol CO2 / mol amine

    # Henry's law for equilibrium CO2 (simplified)
    H_CO2 = 2940  # mol/(m^3*atm), Henry Constant for CO2 in MEA (experimentally determined)
    P_CO2_star = alpha / H_CO2  # placeholder
    N_CO2 = E * k_G * a * (C_CO2_gas - P_CO2_star / (8.314 * T))  # mol/(m³·s)

    # Differential equations
    dCdz = -N_CO2 / gas_flow_rate
    dalphadz = N_CO2 / (liq_flow_rate * amine_conc)

    return [dCdz, dalphadz]


# INITIAL CONDITIONS & SOLVER -------

y0 = [C_CO2_gas_inlet, 0.0]

sol = solve_ivp(co2_absorption_odes, z_span, y0, t_eval=z_eval, method='RK45')


# PLOTTING ------

sns.set(style='whitegrid')

plt.figure(figsize=(10, 5))
plt.plot(z_eval, sol.y[0], label='CO2 Gas Concentration', linewidth=3)
plt.plot(z_eval, sol.y[1], label='Liquid Loading (α)', linewidth=3)

plt.xlabel('Column Height (m)')
plt.ylabel('Concentration (mol/m^3) & Loading')
plt.title('CO2 Absorption in Packed Flue')
plt.legend()
plt.tight_layout()
plt.show()