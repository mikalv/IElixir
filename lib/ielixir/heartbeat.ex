defmodule IElixir.Heartbeat do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    sock = IElixir.Utils.make_socket(opts, "hb", :rep)
    { :ok, id } = :erlzmq.getsockopt(sock, :identity)
    { :ok, { sock, id } }
  end

  def terminate(_reason, { sock, _ }) do
    :erlzmq.close(sock)
  end

  def handle_info({ :zmq, _, data, [] }, state = { sock, _id }) do
    Logger.info("Heartbeat ping received")
    :erlzmq.send(sock, data)
    { :noreply, state }
  end
  def handle_info(msg, state) do
    Logger.warn("Got unexpected message on hb process: #{inspect msg}")
    { :noreply, state}
  end
end
