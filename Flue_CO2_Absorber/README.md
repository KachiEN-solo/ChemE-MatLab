# Python (3.11) Flue CO2 Absorbtion Simulation

This project simulates a packed column within a Flue filled with an amine rich fluid (MEA). which reacts with CO2 to capture the gas within the liquid. The simulation calculates and visualizes concentration and absorbing ability profiles over time for the Flue gas and the amine-rich absorbing fluid (amine scrubbing).

## Features

- Simulates CO₂ capture in a packed absorber column
- Includes carbamate formation and chemical equilibrium
- Accounts for gas-liquid mass transfer
- Supports flow rate and amine concentration sweeps
- Generates plots of removal efficiency and concentration profiles

## Files

- `Flue_CO2_Absorber_main.py`: Main simulation script  
- `/output/`: Folder for saving plots (optional)

## Example Output

**CO₂ Removal Efficiency vs Time**  
![CO2 Absorption Efficiency Output](./Flue_CO2_Absorber/Output/Flue_CO2_Absorber_Output_Test1.jpg)

## How to Run

1. Open `Flue_CO2_Absorber_main.py` in a Python-friendly environment.
2. Download necessary libraries (specified in code header)  
3. Run the script. Plots will display and save automatically (if `/output/` exists).

## Requirements

-   Python 3.11

## License

MIT License.
