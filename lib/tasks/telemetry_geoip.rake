namespace :telemetry do
  
  task geoip: :environment do
    FileUtils.mkdir_p "etc/geoip"
    
    remote_url = "http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz"
    local_file = "#{Dir.mktmpdir}/GeoLiteCity.dat.gz"
    output = GeocodeService::GEOLITE_DB_PATH
    
    download_file(remote_url, local_file) && gunzip(local_file, output)
  end

  def download_file(remote_path, local_path)
    uri = URI(remote_path)
    downloaded = false

    puts("Downloading file #{remote_path} into #{local_path}")

    req = Net::HTTP::Get.new(uri.request_uri)
    req['If-Modified-Since'] = File.stat(local_path).mtime.rfc2822 if File.exists?(local_path)

    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req) do |response|
        if response.is_a?(Net::HTTPSuccess)
          open(local_path, 'wb') do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
          downloaded = true
          puts(" File download complete")
        elsif response.is_a?(Net::HTTPNotModified)
          puts(" File was not modified")
        else
          puts(" Error downloading file from #{remote_path}: #{response.status}")
        end
      end
    end

    return local_path if downloaded
  end

  def gunzip(input_file, output_file)
    puts("Decompressing file #{input_file} into #{output_file}")
    Zlib::GzipReader.open(input_file) do |gz|
      open(output_file, 'wb') do |io|
        io.write gz.read
      end
    end
  end

end
