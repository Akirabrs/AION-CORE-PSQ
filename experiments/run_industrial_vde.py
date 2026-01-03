import numpy as np
import matplotlib.pyplot as plt
import os

# AION-CORE: INDUSTRIAL SIMULATION (50+ VARS + NOISE)

class TokamakIndustrialPlant:
    def __init__(self):
        self.time = 0.0
        self.R = 1.85
        self.Z = 0.00
        self.Ip = 15.0e6
        self.I_PF = np.zeros(10)
        self.dZ_dt = 0.0
        self.gamma_growth = 2800.0
        self.sensor_noise_std = {'Z': 0.002, 'Ip': 100e3}
        self.sensor_drift = 0.0

    def dynamics(self, dt, control_actions):
        self.I_PF += (control_actions - self.I_PF * 0.1) * (dt / 0.015)
        F_control = (self.I_PF[2] - self.I_PF[7]) * 500.0
        F_instability = (self.gamma_growth ** 2) * self.Z * self.Ip * 1e-7
        accel_Z = (F_instability - F_control) / (self.Ip * 1e-7)
        self.dZ_dt += accel_Z * dt
        self.Z += self.dZ_dt * dt
        self.time += dt
        self.sensor_drift += np.random.randn() * 1e-5

    def get_sensors(self):
        obs = {}
        obs['Z'] = self.Z + np.random.normal(0, self.sensor_noise_std['Z']) + self.sensor_drift
        obs['dZ'] = self.dZ_dt + np.random.normal(0, 0.1)
        return obs

class AION_CORE_PACC:
    def compute_action(self, sensors):
        z_meas = sensors['Z']
        dz_meas = sensors['dZ']
        # Kalman Prediction Layer
        z_pred = z_meas + dz_meas * 1e-4 
        kp = 8000.0
        kd = 400.0
        # Guardian Logic
        if abs(dz_meas) > 5.0:
            kd *= 3.0
            kp *= 1.5
        u_demand = -kp * z_pred - kd * dz_meas
        action_vector = np.zeros(10)
        action_vector[2] = u_demand
        action_vector[7] = -u_demand
        return np.clip(action_vector, -2000, 2000)

if __name__ == "__main__":
    tokamak = TokamakIndustrialPlant()
    controller = AION_CORE_PACC()
    dt = 1e-5
    steps = 3000
    log_z_real = []
    
    tokamak.Z = 0.02
    tokamak.dZ_dt = 10.0
    
    for k in range(steps):
        sensors = tokamak.get_sensors()
        voltages = controller.compute_action(sensors)
        tokamak.dynamics(dt, voltages)
        log_z_real.append(tokamak.Z)
        
    print("Simulation Check: Final Z =", log_z_real[-1])
