defmodule TH do
  @moduledoc ~S"""
  Basic tracing helper
  """

  @tracing_options [{:_, [], [{:return_trace}, {:exception_trace}]}]

  @doc """
  Turn on flat tracing on all functions of given module.

  It configures tracing modules to trace all functions of given module
  in flat way (without indenting recursion calls).

  ## Examples

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
  """
  import :erlang, only: [group_leader: 0]

  @spec trace_flat(module()) :: {:ok, pid()} | {:error, term()}
  def trace_flat(mod) when is_atom(mod) do
    result = flat_tracer()
    {:ok, _} = setup_tracing(mod)
    result
  end


  @doc """
  Turn on flat tracing on given module and given function.

  It configures tracing modules to trace given function of given module
  in flat way (without indenting recursion calls).

  ## Examples

      iex(1)> TH.trace_flat Float, :floor
      {:ok, #PID<0.139.0>}
      iex(2)> Float.floor 1.1
      #PID<0.125.0> call: Float.floor(1.1) level: 0
      #PID<0.125.0> call: Float.floor(1.1, 0) level: 1
      #PID<0.125.0> rtrn: 1.0 level: 1
      #PID<0.125.0> rtrn: 1.0 level: 0
      1.0
  """
  @spec trace_flat(module(), atom()) :: {:ok, pid()} | {:error, term()}
  def trace_flat(mod, fun) when is_atom(mod) and is_atom(fun) do
    result = flat_tracer()
    {:ok, _} = setup_tracing(mod, fun)
    result
  end

  @doc """
  Turn on nested tracing on all functions of given module.

  It configures tracing modules to trace all functions of given module
  in flat way (with indenting recursion calls).

  ## Examples

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
  """
  @spec trace_nested(module()) :: {:ok, pid()} | {:error, term()}
  def trace_nested(mod) when is_atom(mod) do
    result = nested_tracer()
    {:ok, _} = setup_tracing(mod)
    result
  end

  @doc """
  Turn on nested tracing on given function of given module.

  It configures tracing modules to trace given functions of given module
  in flat way (with indenting recursion calls).

  ## Examples

      iex(1)> TH.trace_nested Float, :floor
      {:ok, #PID<0.139.0>}
      iex(2)> Float.floor 1.1
      #PID<0.138.0> Float.floor(1.1)
      #PID<0.138.0> | Float.floor(1.1, 0)
      #PID<0.138.0> | 1.0
      #PID<0.138.0> 1.0
      1.0
  """
  @spec trace_nested(module(), atom()) :: {:ok, pid()} | {:error, term()}
  def trace_nested(mod, fun) when is_atom(mod) and is_atom(fun) do
    result = nested_tracer()
    {:ok, _} = setup_tracing(mod, fun)
    result
  end

  @doc """
  Turn off tracing on all functions of given module.

  ## Examples

      iex(1)> TH.untrace Float
      {:ok, #PID<0.139.0>}
      iex(2)> Float.floor 1.1
      1.0
  """
  @spec untrace(module()) :: {:ok, [tuple()]}
  def untrace(mod) when is_atom(mod) do
    {:ok, _} = :dbg.ctpl(mod)
  end

  @doc """
  Turn off tracing on given function of given module.

  ## Examples

      iex(1)> TH.untrace Float, :floor
      {:ok, [{:matched, :nonode@nohost, 19}]}
      iex(2)> Float.floor 1.1
      1.0
  """
  @spec untrace(module(), atom()) :: {:ok, [tuple()]}
  def untrace(mod, fun) do
    {:ok, _} = :dbg.ctpl(mod, fun)
  end

  defp nested_tracer do
    :dbg.tracer(:process, {&nested_trace/2, 0})
  end

  defp flat_tracer do
    :dbg.tracer(:process, {&flat_trace/2, 0})
  end

  defp nested_trace({:trace, pid, :call, {mod, fun, args}}, level) do
    module =
      mod
      |> Atom.to_string
      |> elixir_module
    function = Atom.to_string(fun)
    args     = format_args(args)
    spaces   = fill_spaces(level)
    IO.puts "#{inspect(pid)} #{spaces}#{module}.#{function}(#{args})"
    level + 1
  end

  defp nested_trace(
    {:trace, pid, :return_from, {_,_,_}, return_value}, level) do
    level  = level - 1
    spaces = fill_spaces(level)
    IO.puts "#{inspect(pid)} #{spaces}#{inspect(return_value)}"
    level
  end

  defp nested_trace(trace, level) do
    IO.puts "trace_msg: #{inspect(trace)}"
    level
  end

  defp flat_trace({:trace, pid, :call, {mod, fun, args}}, level) do
    module =
      mod
      |> Atom.to_string
      |> elixir_module
    function = Atom.to_string(fun)
    args     = format_args(args)
    IO.puts "#{inspect(pid)} call: #{module}.#{function}(#{args}) level: #{level}"
    level + 1
  end

  defp flat_trace({:trace, pid, :return_from, {_,_,_}, return_value}, level) do
    level  = level - 1
    IO.puts "#{inspect(pid)} rtrn: #{inspect(return_value)} level: #{level}"
    level
  end

  defp flat_trace(trace, level) do
    IO.puts "trace_msg: #{inspect(trace)}"
    level
  end

  defp setup_tracing(module,function) do
    {:ok, _} = :dbg.p(:all, :call)
    {:ok, _} = :dbg.tpl(module, function, @tracing_options)
  end

  defp setup_tracing(module) do
    {:ok, _} = :dbg.p(:all, :call)
    {:ok, _} = :dbg.tpl(module, @tracing_options)
  end

  defp elixir_module("Elixir." <> module), do: module
  defp elixir_module(module), do: ":#{module}"

  defp format_args(args) do
    args
    |> inspect()
    |> String.replace(~r/^\[/, "")
    |> String.replace(~r/\]$/, "")
  end

  defp fill_spaces(level) do
    String.duplicate "| ", level
  end
end
