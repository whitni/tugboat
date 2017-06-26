require 'spec_helper'

describe Tugboat::CLI do
  include_context 'spec'

  let(:snapshot_name) { 'foo-snapshot' }

  describe 'snapshots a droplet' do
    it 'with a fuzzy name' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:post, 'https://api.digitalocean.com/v2/droplets/3164444/actions').
        with(body: '{"type":"snapshot","name":"foo-snapshot"}',
             headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('snapshot_response'), headers: {})

      snapshot_fuzzy_stdout = <<-eos
Droplet fuzzy name provided. Finding droplet ID...done\e[0m, 3164444 (example3.com)
Warning: Droplet must be in a powered off state for snapshot to be successful
Queuing snapshot 'foo-snapshot' for 3164444 (example3.com)...Snapshot successful!
      eos

      expect { (cli.snapshot(snapshot_name, 'example3.com')) }.to output(snapshot_fuzzy_stdout).to_stdout
    end

    it 'with an id' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets/3164444?per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(headers: { 'Content-Type' => 'application/json' }, status: 200, body: fixture('show_droplet_inactive'))

      stub_request(:post, 'https://api.digitalocean.com/v2/droplets/3164494/actions').
        with(body: '{"type":"snapshot","name":"foo-snapshot"}',
             headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('snapshot_response'), headers: {})

      cli.options = cli.options.merge(id: '3164444')

      snapshot_id_stdout = <<-eos
Droplet id provided. Finding Droplet...done\e[0m, 3164494 (example.com)
Warning: Droplet must be in a powered off state for snapshot to be successful
Queuing snapshot 'foo-snapshot' for 3164494 (example.com)...Snapshot successful!
      eos

      expect { (cli.snapshot(snapshot_name)) }.to output(snapshot_id_stdout).to_stdout
    end

    it 'with a name' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:post, 'https://api.digitalocean.com/v2/droplets/3164444/actions').
        with(body: '{"type":"snapshot","name":"foo-snapshot"}',
             headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('snapshot_response'), headers: {})

      cli.options = cli.options.merge(name: 'example3.com')

      snapshot_name_stdout = <<-eos
Droplet name provided. Finding droplet ID...done\e[0m, 3164444 (example3.com)
Warning: Droplet must be in a powered off state for snapshot to be successful
Queuing snapshot 'foo-snapshot' for 3164444 (example3.com)...Snapshot successful!
      eos

      expect { (cli.snapshot(snapshot_name)) }.to output(snapshot_name_stdout).to_stdout
    end

    it 'does not snapshot a droplet that is active' do
      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=1').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      stub_request(:get, 'https://api.digitalocean.com/v2/droplets?page=1&per_page=200').
        with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization' => 'Bearer foo', 'Content-Type' => 'application/json', 'User-Agent' => 'Faraday v0.9.2' }).
        to_return(status: 200, body: fixture('show_droplets'), headers: {})

      cli.options = cli.options.merge(name: 'example.com')

      snapshot_active_error_stdout = <<-eos
Droplet name provided. Finding droplet ID...done\e[0m, 6918990 (example.com)
Droplet must be off for this operation to be successful.
      eos

      expect{ cli.snapshot(snapshot_name) }.to raise_error(SystemExit).and output(snapshot_active_error_stdout).to_stdout
    end
  end
end
