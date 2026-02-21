# PSSEModels.jl Documentation

Welcome to **PSSEModels.jl**, a specialized framework for power system optimization using PSS/E data in Julia. This package extends [PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl) to provide seamless integration with `.sav` files and custom PSS/E-specific modeling components.

## Core Philosophy

PSSEModels.jl is built on three main pillars:
1.  **Direct PSS/E Integration**: Leveraging [PSSE2PowerModels.jl](https://github.com/jbarberia/PSSE2PowerModels) for high-fidelity parsing of binary `.sav` files.
2.  **Extended Modeling**: Support for components often required in PSS/E workflows but not standard in PowerModels (e.g., adjustable load power, shunt susceptance control, area/zone/owner metadata).
3.  **Modular Problem Building**: A component-based approach to defining optimization problems, allowing developers to mix and match standard and custom constraints.

## Relationship with PowerModels.jl

This package is a "PowerModels Extension". It uses the same mathematical abstractions and data structures:
-   **Data Model**: Uses the standard PowerModels "InfrastructureModels" dictionary format, enriched with PSS/E metadata.
-   **Formulations**: Plugs into the `AbstractPowerModel` hierarchy (ACP, ACR, DCP, etc.).
-   **Solvers**: Compatible with any JuMP-supported solver (Ipopt, Gurobi, HiGHS).

## Getting Started

Check the [User Manual](manual.md) for a guide on how to run simulations and extend the model with your own optimization logic.
