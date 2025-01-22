Tenkit.configure do |c|
  c.team_id = ENV["APPLE_DEVELOPER_TEAM_ID"]
  c.service_id = ENV["APPLE_DEVELOPER_SERVICE_ID"]
  c.key_id = ENV["APPLE_DEVELOPER_KEY_ID"]
  c.key = ENV["APPLE_DEVELOPER_PRIVATE_KEY"]
end
