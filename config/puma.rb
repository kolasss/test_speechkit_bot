# frozen_string_literal: true

on_worker_boot do
  Mongoid::Clients.clients.each do |_name, client|
    client.close
    client.reconnect
  end
end

before_fork do
  Mongoid.disconnect_clients
end
