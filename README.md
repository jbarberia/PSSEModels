# PSSEModels

Este repositorio sirve como una **plantilla (template)** profesional para desarrollar modelos de optimización de sistemas de potencia utilizando datos de PSS/E en Julia. Está diseñado como una extensión de [PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl).

## Introducción
PSSEModels.jl facilita la integración de archivos binarios `.sav` en flujos de trabajo de optimización, proporcionando herramientas para manejar componentes específicos de PSS/E (cargas ajustables, shunts controlados, áreas, zonas) que no están presentes en el núcleo de PowerModels.

## Características Principales
- **Preparación de Datos Simplificada**: Usa `prepare_psse_data` para automatizar la carga, limpieza de buses de impedancia cero y configuración de valores iniciales.
- **Arquitectura Modular**: Construye problemas complejos utilizando bloques predefinidos como `variable_standard_psse!` y `constraint_standard_psse_bus!`.
- **Documentación Integrada**: Sistema de documentación basado en `Documenter.jl` con manual de usuario y referencia de API.
- **Ejemplos Avanzados**: Incluye casos reales como la optimización de perfiles de tensión mediante parques eólicos.

## Estructura del Proyecto
- `src/core/`: Definiciones de variables, restricciones y utilidades de datos.
- `src/form/`: Implementaciones matemáticas para diferentes formulaciones (ACP, APO, etc.).
- `src/prob/`: Lógica de construcción de problemas modularizada.
- `examples/`: Scripts listos para usar (`run_opf.jl`, `voltage_opt.jl`).
- `docs/`: Fuente de la documentación técnica.

## Uso Rápido
```julia
using PSSEModels
using PowerModels
using Ipopt

# 1. Preparar datos (Carga .sav, colapsa buses ZI, setea arranques)
data = prepare_psse_data("mi_red.sav")

# 2. Configurar optimizador con parámetros recomendados
optimizer = optimizer_with_attributes(Ipopt.Optimizer, "nlp_scaling_method"=>"none")

# 3. Ejecutar optimización (AC Polar)
result = run_prob(data, ACPPowerModel, optimizer)

println("Estado: ", result["termination_status"])
```

## Compatibilidad
**Importante:** Debido a que PSS/E es tradicionalmente un programa de 32 bits, algunos archivos pueden presentar desafíos de precisión numérica. Se recomienda encarecidamente la siguiente configuración para **Ipopt**:

```julia
using JuMP

optimizer = JuMP.optimizer_with_attributes(
    Ipopt.Optimizer,    
    "nlp_scaling_method"=>"none"
)
```

## Documentación
La documentación completa, se puede generar en un sitio local:
1. Abre Julia en la carpeta `docs/`.
2. Ejecuta `include("make.jl")`.
3. Abre `docs/build/index.html` en tu navegador.
