% chem_reactor_sim.m
% Modeling of a first order, A->B, exothermic reaction, using 
% CSTR (Dynamic) and PFR (Steady-state)

clc; clear; close all;

%%
% ------------------- Variables --------------------------

% Universal

R = 8.314;                       % Gas Constant


% Reactor Design

V = 100;                   % Tank Volume (L)

F = 10;                    % Volumetric Flow Rate (L/min)

C_A0 = 1.0;                % Inlet Concentration of A (mol/L)

T_in = 350;                % Inlet Temparature (K)

T_cool = 300;              % Collant Temparature (K)


% Reactor Kinetics 

k0 = 1e3;                  % Pre-exxponential factor (min^-1)

Ea = 50000;                % Activation energy of reaction (J/mol)

deltaH = -50000;           % Heat of Reaction (J/mol) (Exothermic)


% Physical Properties

dens = 1000;               % Density (g/L)

Cp = 4.18;                 % Heat Capacity (J/(g*K))


% Heat transfer

U = 500;                   % Heat Transfer Coefficient (J/(min*m^2*K))

A = 5.0;                   % Heat exchange area (m^2)

% Put all paramters in a struct for later reference by ODE solvers
params = struct( ...
    'F', F, 'V', V, 'C_A0', C_A0, 'T_in', T_in, 'T_cool', T_cool, ...
    'k0', k0, 'Ea', Ea, 'deltaH', deltaH, 'R', R, ...
    'rho', dens, 'Cp', Cp, 'U', U, 'A', A ...
);

%% ------------------ CSTR Simulation: Varying Coolant Temperature ------------------

% Define the Initial Conditions of the Sim

Y0_cstr = [1.0; 350];

% Define coolant temperatures to simulate
T_cool_vals = [90, 110, 190, 260, 300];   % in Kelvin
colors = lines(length(T_cool_vals));       % Distinct color per curve

% Create new figure for overlay plot
figure('Name','CSTR Temperature Response at Different Coolant Temperatures');
hold on;
grid on;

for i = 1:length(T_cool_vals)
    % Update T_cool in parameter struct
    params.T_cool = T_cool_vals(i);

    % Solve ODEs
    [t_cstr, Y_cstr] = ode45(@(t,Y) cstr_odes(t,Y,params), [0 10], Y0_cstr);

    % Extract temperature profile
    T_cstr = Y_cstr(:,2);

    % Plot result
    plot(t_cstr, T_cstr, 'LineWidth', 2, 'Color', colors(i,:), ...
        'DisplayName', ['T_{cool} = ' num2str(T_cool_vals(i)) 'K']);
end

xlabel('Time (min)');
ylabel('Reactor Temperature T (K)');
title('CSTR Temperature Response for Different Coolant Temperatures');
legend('Location', 'best');
set(gca, 'FontSize', 12, 'XMinorTick', 'on', 'YMinorTick', 'on');

%%
%-------------------- CSTR ODE Solver-------------------

function dYdt = cstr_odes(t,Y,p)
    C_A = Y(1);       % Concentration of A (mol/L)
    T = Y(2);         % Temperature (K)

    % Determine Arrhenius rate constant

    k = p.k0 * exp(-p.Ea/(p.R*T));
    r = k *C_A;

    % Material Balance

    dCAdt = (p.F/p.V)*(p.C_A0 - C_A) - r;

    % Energy Balance

       dTdt = (p.F*p.rho*p.Cp/p.V)*(p.T_in - T) ...
         + (-p.deltaH*r)/(p.rho*p.Cp) ...
         + (p.U*p.A/p.V)*(p.T_cool - T);

    dYdt = [dCAdt; dTdt];
end

%% -------------------- PFR Simulation --------------------
% Define initial values at V = 0 [C_A, T]
Y0_pfr = [C_A0; T_in];
V_span = [0 V];  % From V = 0 to V = 100 L

% Solve spatial ODEs using ode45
[V_pfr, Y_pfr] = ode45(@(V, Y) pfr_odes(V, Y, params), V_span, Y0_pfr);

% Extract results
C_A_pfr = Y_pfr(:,1);
T_pfr = Y_pfr(:,2);

% Plot PFR results
figure('Name','PFR Simulation','NumberTitle','off');
subplot(2,1,1);
plot(V_pfr, C_A_pfr, 'b-', 'LineWidth', 2);
ylabel('C_A (mol/L)');
title('PFR: Concentration vs Reactor Volume');

subplot(2,1,2);
plot(V_pfr, T_pfr, 'r-', 'LineWidth', 2);
ylabel('T (K)');
xlabel('Reactor Volume (L)');
title('PFR: Temperature vs Reactor Volume');


%% -------------------- PFR ODE Function --------------------
function dYdV = pfr_odes(V, Y, p)
    C_A = Y(1);         % Concentration of A (mol/L)
    T = Y(2);           % Temperature (K)

    % Arrhenius rate constant
    k = p.k0 * exp(-p.Ea / (p.R * T));
    r = k * C_A;

    % Mass balance
    dCAdV = -r / p.F;

    % Energy balance
    dTdV = (-(p.deltaH)*r + p.U*p.A*(p.T_cool - T)) / (p.F * p.Cp);

    dYdV = [dCAdV; dTdV];
end