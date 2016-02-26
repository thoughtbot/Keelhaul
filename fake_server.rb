require "webrick"

server = WEBrick::HTTPServer.new(Port: 1234)
server.mount_proc "/" do |req, res|
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

["INT", "TERM"].each do |signal|
  trap(signal) { server.shutdown }
end

server.start
