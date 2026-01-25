# PSSEModels



## Compatibilidad
Debido a que PSSE es un programa de 32 bits es posible que ciertos solvers fallen en la resolución de los programas.

Se recomienda la siguiente configuración para Ipopt.

```julia
using JuMP

optimizer = JuMP.optimizer_with_attributes(
    Ipopt.Optimizer,    
    "nlp_scaling_method"=>"none"
)
```
