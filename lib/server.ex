# Author: Ciaran Finn

# References:
# https://thepugautomatic.com/2016/01/pattern-matching-complex-strings/
# http://elixir-lang.org/getting-started/mix-otp/task-and-gen-tcp.html
# http://elixir-lang.org/docs/stable/elixir/Task.html

defmodule Server do

  use Application
  import Supervisor.Spec

  @port Application.get_env(:server, :port)


  def start(_type, _args) do
    IO.puts "✓ Server Started"
    children = [
      worker(Task, [Server, :begin_listening, [@port]]),
      supervisor(Task.Supervisor, [[name: Server.TaskSupervisor]])
    ]
    options = [strategy: :one_for_one, name: Server.Supervisor]
    Supervisor.start_link(children, options)
  end

  # --------------------- OPEN PORT --------------------------

  def begin_listening(port) do
    IO.puts "Server listening on: #{port}"
    open_port(port)
  end

  # open a port for incomming connections
  def open_port(port) do
    case :gen_tcp.listen(port,[:binary, packet: :line, active: false, reuseaddr: true]) do
      {:ok, socket} ->
        receive_connection(socket)
      _ ->
        IO.puts "Error opening socket"
        System.halt
    end
  end

  # ----------------- LISTEN FOR CONNECTIONS -----------------

  defp receive_connection(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        handle_client(socket,client)
       _ ->
        IO.puts "Server socket is closed"
        System.halt
    end
  end

  # spawn new worker for every client connection
  defp handle_client(socket, client_socket) do
    case Task.Supervisor.start_child(Server.TaskSupervisor, fn -> process_resquest(socket,client_socket) end) do
      {:ok, pid} ->
            :gen_tcp.controlling_process(client_socket, pid)
            socket |> receive_connection
       _ ->
        IO.puts "Error spawning new worker"
        System.halt
    end
  end

# ------------ CREATE RESPONSE FOR REQUEST TYPE ------------


  defp process_resquest(server_socket,client_socket) do
    case :gen_tcp.recv(client_socket, 0) do
      { _ , data} ->
          IO.puts "Request : #{data}"
          action(server_socket,client_socket,data)
      _ ->
          IO.puts "Error reading from socket"
    end
  end

  defp action( _ ,socket, "HELO" <> " " <> text) do
    payload = "HELO #{text}IP:#{ip_address}\nPort:#{@port}\nStudentID:13320900\n"
    :gen_tcp.send(socket,payload)
    :gen_tcp.close(socket)
  end

  defp action( server_socket , _ , "KILL_SERVICE" <> _) do
    :gen_tcp.close(server_socket)
  end

  defp action( _ ,socket, _ ) do
    :gen_tcp.close(socket)
  end

# --------------------- GET LOCAL IP -----------------------

  defp ip_address do
    12345
  end


end
