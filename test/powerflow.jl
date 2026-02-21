const test_files = [
    joinpath(@__DIR__, "ver2526pid.sav"),
    joinpath(@__DIR__, "V28p_Trs_2633_sin_py.sav")
]

for filename in test_files
    @testset failfast=true "dc_powerflow: $(basename(filename))" begin
        data = prepare_psse_data(filename)

        results_pm = solve_dc_pf(data, optimizer)    
        sol_pm = results_pm["solution"]
        @test results_pm["termination_status"] in (LOCALLY_SOLVED, OPTIMAL)
        @test results_pm["primal_status"] == FEASIBLE_POINT
        
        results_ps = run_prob(data, DCPPowerModel, optimizer)
        sol_ps = results_ps["solution"]
        @test results_ps["termination_status"] in (LOCALLY_SOLVED, OPTIMAL)
        @test results_ps["primal_status"] == FEASIBLE_POINT
        
        for (i, bus) in data["bus"]
            !(i in sol_pm["bus"] |> keys) && continue
            !(i in sol_ps["bus"] |> keys) && continue
            @test isapprox(sol_pm["bus"][i]["va"], sol_ps["bus"][i]["va"]; atol=5e-4) 
        end

        for (i, gen) in data["gen"]
            !(i in sol_pm["gen"] |> keys) && continue
            !(i in sol_ps["gen"] |> keys) && continue
            @test isapprox(sol_pm["gen"][i]["pg"], sol_ps["gen"][i]["pg"]; atol=1e-4)
        end
    end


    @testset failfast=true "ac_powerflow: $(basename(filename))" begin
        data = prepare_psse_data(filename)

        results_pm = solve_ac_pf(data, optimizer)    
        results_pm["solution"]["branch"] = calc_branch_flow_ac(data)["branch"]
        sol_pm = results_pm["solution"]
        @test results_pm["termination_status"] in (LOCALLY_SOLVED, OPTIMAL)
        @test results_pm["primal_status"] == FEASIBLE_POINT
        
        results_ps = run_prob(data, ACPPowerModel, optimizer)
        sol_ps = results_ps["solution"]
        @test results_ps["termination_status"] in (LOCALLY_SOLVED, OPTIMAL)
        @test results_ps["primal_status"] == FEASIBLE_POINT
        
        for (i, bus) in data["bus"]
            !(i in sol_pm["bus"] |> keys) && continue
            !(i in sol_ps["bus"] |> keys) && continue
            @test isapprox(sol_pm["bus"][i]["vm"], sol_ps["bus"][i]["vm"]; atol=1e-4)
            @test isapprox(sol_pm["bus"][i]["va"], sol_ps["bus"][i]["va"]; atol=1e-4) 
        end

        for (i, gen) in data["gen"]
            !(i in sol_pm["gen"] |> keys) && continue
            !(i in sol_ps["gen"] |> keys) && continue
            @test isapprox(sol_pm["gen"][i]["pg"], sol_ps["gen"][i]["pg"]; atol=1e-4)
            @test isapprox(sol_pm["gen"][i]["qg"], sol_ps["gen"][i]["qg"]; atol=1e-4) 
        end
        
        for (i, branch) in data["branch"]
            !(i in sol_pm["branch"] |> keys) && continue
            !(i in sol_ps["branch"] |> keys) && continue
            @test isapprox(sol_pm["branch"][i]["pt"], sol_ps["branch"][i]["pt"]; atol=5e-2)
            @test isapprox(sol_pm["branch"][i]["qt"], sol_ps["branch"][i]["qt"]; atol=5e-3) 
            @test isapprox(sol_pm["branch"][i]["pf"], sol_ps["branch"][i]["pf"]; atol=5e-2)
            @test isapprox(sol_pm["branch"][i]["qf"], sol_ps["branch"][i]["qf"]; atol=5e-3) 
        end
    end
end
