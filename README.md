# TracingHelper

**Basic tracing helper**

## Installation

The the package can be installed as:

  1. Add tracing_helper to your list of dependencies in `mix.exs`:

        def deps do
          [{:tracing_helper, "~> 0.0.1"}]
        end

  2. Ensure tracing_helper is started before your application:

## Usage

  flat version:

        iex(1)> TH.trace_flat Float
        {:ok, [{:matched, :nonode@nohost, 19}, {:saved, 1}]}
        iex(2)> Float.floor 1.1
        #PID<0.125.0> call: Float.__info__(:macros) level: 0
        #PID<0.125.0> rtrn: [] level: 0
        #PID<0.125.0> call: Float.floor(1.1) level: 0
        #PID<0.125.0> call: Float.floor(1.1, 0) level: 1
        #PID<0.125.0> call: Float.power_of_10(0) level: 2
        #PID<0.125.0> rtrn: 1 level: 2
        #PID<0.125.0> rtrn: 1.0 level: 1
        #PID<0.125.0> rtrn: 1.0 level: 0
        1.0

  nested version:

        iex(1)> TH.trace_nested Float
        {:ok, #PID<0.139.0>}
        iex(2)> Float.floor 1.1
        #PID<0.138.0> Float.__info__(:macros)
        #PID<0.138.0> []
        #PID<0.138.0> Float.floor(1.1)
        #PID<0.138.0> | Float.floor(1.1, 0)
        #PID<0.138.0> | | Float.power_of_10(0)
        #PID<0.138.0> | | 1
        #PID<0.138.0> | 1.0
        #PID<0.138.0> 1.0
        1.0



