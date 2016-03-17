require "webrick"

server = WEBrick::HTTPServer.new(Port: 1234)
server.mount_proc "/success" do |req, res|
  if req.request_method == "POST"
    res.body = <<-JSON
{
  "download_id": 123,
  "bundle_id": "com.thoughtbot.Keelhaul",
  "application_version": "1.0.0",
  "receipt_creation_date_ms": "1445437368000",
  "request_date_ms": "1449330864600",
  "original_purchase_date_ms": "1425375064000",
}
  JSON
  else
    res.status = 404
  end
end

server.mount_proc "/error" do |req, res|
  code = req.path_info[1..-1] || 21000
  res.status = 400
  res.body = <<-JSON
{
  "status": #{code}
}
  JSON
end

server.mount_proc "/unauthorized" do |req, res|
  res.status = 401
end

server.mount_proc "/malformed-json" do |req, res|
  res.status = 200
  res.body = "Malformed JSON"
end

server.mount_proc "/insufficient-json" do |req, res|
  res.body = <<-JSON
{
  "download_id": 123,
  "application_version": "1.0.0",
  "receipt_creation_date_ms": "1445437368000",
  "request_date_ms": "1449330864600",
  "original_purchase_date_ms": "1425375064000",
}
  JSON
end

server.mount_proc "/missing-response-data" do |req, res|
end

server.mount_proc "/500" do |req, res|
  res.status = 500
end

server.mount_proc "/unknown-error" do |req, res|
  res.status = 400
  res.body = <<-JSON
{
  "status": 9
}
  JSON
end

["INT", "TERM"].each do |signal|
  trap(signal) { server.shutdown }
end

server.start
