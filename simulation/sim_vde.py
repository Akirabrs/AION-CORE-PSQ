import numpy as np
import matplotlib.pyplot as plt

# Simulation of VDE Suppression for AION-CORE
# Physics Parameters
m_p = 1.67e-27 * 1e20 
gamma_instability = 2500.0
damping = 100.0
dt = 1e-6
sim_time = 0.02
steps = int(sim_time / dt)

# Controller Logic (AION-CORE Kernel)
def aion_core_controller(z_pos, z_vel):
    Kp = 5e4
    Kd = 2e3
    # Control Law
    force_demand = (Kp * (0.0 - z_pos)) + (Kd * (0.0 - z_vel))
    # Guardian Mode Saturation
    return np.clip(force_demand, -10000.0, 10000.0)

# Main Loop
t = np.linspace(0, sim_time, steps)
z = np.zeros(steps)
v = np.zeros(steps)
u = np.zeros(steps)

z[0] = 0.05 # Initial Offset

print("Starting VDE Simulation...")
for k in range(steps - 1):
    u[k] = aion_core_controller(z[k], v[k])
    accel = (gamma_instability * z[k]) - (damping * v[k]) + u[k]
    v[k+1] = v[k] + accel * dt
    z[k+1] = z[k] + v[k+1] * dt
u[-1] = u[-2]

print("Simulation Complete. Data ready for plotting.")
