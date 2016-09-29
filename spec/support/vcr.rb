require 'vcr'

VCR.configure do |config|
  config.configure_rspec_metadata!
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock

  config.register_request_matcher :soapaction_header do |request_1, request_2|
    request_1.headers['Soapaction'] == request_2.headers['Soapaction']
  end

  config.default_cassette_options = {
    allow_playback_repeats: true,
    match_requests_on: [:method, :uri, :soapaction_header]
  }

  config.ignore_localhost = true


  # Can be used for debugging VCR
  # config.debug_logger = $stdout
end
