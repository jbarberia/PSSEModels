# PSSEModels Template

This repository serves as a template for building power system optimization models in Julia, specifically tailored for PSS/E data.

## Project Structure

- `src/core/`: Core definitions.
    - `data.jl`: High-level data preparation (`prepare_psse_data`).
    - `variable.jl`: Custom PSSE variables (load power, shunt susceptance).
    - `constraint.jl` & `constraint_template.jl`: Custom PSSE constraints.
- `src/form/`: Formulation-specific implementations (e.g., ACP, APO).
- `src/prob/`: Problem definitions and modular building logic.
- `examples/`: Practical scripts demonstrating OPF and custom optimizations.
- `test/`: Parameterized test suite across multiple `.sav` files.

## How to use this template

### 1. Data Preparation
Use `prepare_psse_data` to handle all boilerplate (parsing, merging ZI buses, correcting PV types, and setting initial start values from power flow):
```julia
using PSSEModels
data = prepare_psse_data("your_network.sav")
```

### 2. Define New Variables/Constraints
- **Variables**: Add them in `src/core/variable.jl`.
- **Constraints**: 
    - Add a template in `src/core/constraint_template.jl`.
    - Implement logic in `src/core/constraint.jl`.
    - Provide formulation implementations in `src/form/`.

### 3. Build a New Problem
Instead of writing a giant function, use the modular building blocks in `src/prob/prob.jl`:
```julia
function build_custom_prob(pm::AbstractPowerModel)
    variable_standard_psse!(pm) # Adds all standard PSSE variables
    
    constraint_standard_psse_branch!(pm)
    constraint_standard_psse_voltage!(pm)
    
    # Custom logic here
    for i in ids(pm, :bus)
        # ... your custom constraints ...
    end
    
    constraint_standard_psse_bus!(pm)
    constraint_standard_psse_dcline!(pm)
end
```

## Key Features

- **Modular Architecture**: Build problems using standardized components (`variable_standard_psse!`, etc.).
- **PSS/E Integration**: Native support for PSS/E specific features via `PSSE2PowerModels.jl`.
- **Ready-to-use Examples**: See `examples/voltage_opt.jl` for a complex custom optimization case.

## Contributing

- Follow the modular pattern for all new constraints.
- Use `prepare_psse_data` in all tests and examples.
- Ensure all exported functions have comprehensive docstrings.
