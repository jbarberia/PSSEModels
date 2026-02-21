# User and Developer Manual

This manual provides a guide on how to use, customize, and extend **PSSEModels.jl**.

## 1. Data Preparation

Before building an optimization model, you must load and prepare your PSS/E data. The recommended entry point is `prepare_psse_data(filename)`:

```julia
using PSSEModels
data = prepare_psse_data("your_network.sav")
```

This function performs the following steps:
1.  **Initializes PSS/E** and loads the case.
2.  **Converts to PowerModels format** using `PSSE2PowerModels.jl`.
3.  **Merges Zero-Impedance (ZI) buses**: Collapses nodes connected by low-impedance lines for numerical stability.
4.  **Corrects PV Bus Types**: Ensures bus types in the data model reflect the presence of active generators.
5.  **Sets Start Values**: Initializes `va_start`, `vm_start`, `pg_start`, etc., from the initial power flow solution in the `.sav` file.

## 2. Using Modular Building Blocks

**PSSEModels.jl** provides standardized functions to build optimization problems bit by bit. This is the preferred way to extend the template.

### Basic Workflow
A typical problem builder function looks like this:

```julia
function build_custom_opf(pm::AbstractPowerModel)
    # 1. Variables
    variable_standard_psse!(pm)
    
    # 2. Constraints (Modular)
    constraint_standard_psse_branch!(pm)
    constraint_standard_psse_voltage!(pm)
    
    # Custom constraints can go here!
    for i in ids(pm, :bus)
        # Add your own constraints using JuMP.@constraint(pm.model, ...)
    end
    
    constraint_standard_psse_bus!(pm)
    constraint_standard_psse_dcline!(pm)
    
    # 3. Objective
    objective_min_fuel_cost(pm)
end
```

## 3. Extending the Library

### Adding New Variables
Variables are defined in `src/core/variable.jl`. To add a new variable:
1.  Define a function (e.g., `variable_my_new_var(pm::AbstractPowerModel)`).
2.  Use `var(pm, :my_new_var) = JuMP.@variable(...)`.
3.  Update `variable_standard_psse!` if the variable should be included by default.

### Adding New Constraints
Constraints involve two parts: the **Template** and the **Implementation**.

1.  **Template (`src/core/constraint_template.jl`)**:
    ```julia
    function constraint_my_rule(pm::AbstractPowerModel, i::Int; nw::Int=nw_id_default)
        item = ref(pm, nw, :my_component, i)
        # Extract necessary data and call the dispatch function
        constraint_my_rule(pm, nw, i, item["param1"], item["param2"])
    end
    ```

2.  **Implementation (`src/core/constraint.jl` and `src/form/`)**:
    -   Provide a fallback or a specific implementation for each formulation (ACP, APO, etc.).
    -   Use multiple dispatch to handle different mathematical representations of the grid.

## 4. Best Practices

-   **Stay Within the `pm` Object**: Always use `pm.model` for constraints and `var(pm, ...)` for variables.
-   **Use `ref(pm, ...)`**: Access network data through the `ref` dictionary to ensure compatibility with multi-network features.
-   **Follow PowerModels naming**: If a similar constraint exists in PowerModels, use its naming convention.
-   **Documentation**: Add docstrings to all exported functions so they appear in the auto-generated documentation.
