defmodule Hyperliquid.Streamer.StreamTest do
  use ExUnit.Case, async: false

  alias Hyperliquid.Streamer.Stream

  describe "handle_disconnect/2" do
    test "reconnects after the remote endpoint expires an established connection" do
      state = %{subscription: %{type: "allMids"}}

      assert {:reconnect, ^state} =
               Stream.handle_disconnect(
                 %{reason: {:remote, 1000, "Expired"}, attempt_number: 1},
                 state
               )
    end
  end

  describe "reconnect_delay_ms/1" do
    test "backs off exponentially and caps retries at thirty seconds" do
      assert Enum.map(1..8, &Stream.reconnect_delay_ms/1) ==
               [0, 1_000, 2_000, 4_000, 8_000, 16_000, 30_000, 30_000]
    end
  end

  describe "start_link/1" do
    test "stays alive while retrying an initially unavailable endpoint" do
      original_url = Application.get_env(:hyperliquid, :ws_url)
      Application.put_env(:hyperliquid, :ws_url, "ws://127.0.0.1:1")

      on_exit(fn ->
        if original_url do
          Application.put_env(:hyperliquid, :ws_url, original_url)
        else
          Application.delete_env(:hyperliquid, :ws_url)
        end
      end)

      assert {:ok, pid} = Stream.start_link([])
      Process.unlink(pid)
      on_exit(fn -> if Process.alive?(pid), do: Process.exit(pid, :kill) end)

      Process.sleep(100)

      assert Process.alive?(pid)
    end
  end

  describe "handle_connect/2" do
    test "replaces the heartbeat timer and resets response freshness after reconnecting" do
      state = %{subs: [], heartbeat_timer: nil, last_response: 0}

      assert {:ok, first_connection} = Stream.handle_connect(nil, state)
      assert {:interval, first_timer_ref} = first_connection.heartbeat_timer
      assert is_reference(first_timer_ref)

      assert {:ok, reconnected} = Stream.handle_connect(nil, first_connection)
      assert {:interval, second_timer_ref} = reconnected.heartbeat_timer
      assert is_reference(second_timer_ref)
      refute reconnected.heartbeat_timer == first_connection.heartbeat_timer
      assert reconnected.last_response >= System.system_time(:second) - 1

      :timer.cancel(reconnected.heartbeat_timer)
    end
  end
end
