defmodule StriveWeb.LiveMonitor do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{views: %{}}}
  end

  def handle_cast({:monitor, pid, view_module, metadata}, state) do
    Process.monitor(pid)
    {:noreply, %{state | views: Map.put(state.views, pid, {view_module, metadata})}}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    {{view_module, metadata}, others} = Map.pop(state.views, pid)
    view_module.unmount(metadata)
    {:noreply, %{state | views: others}}
  end

  def monitor(pid, view_module, metadata) do
    GenServer.cast(__MODULE__, {:monitor, pid, view_module, metadata})
  end
end
