module OpenImmo
  class FtpImporter

    require 'net/ftp'
    require 'rubygems'
    require 'zip'

    def self.create_importer
      importer = FtpImporter.new
      return false unless importer.new_file_available?
      importer.set_files_to_download
      importer
    end

    def initialize
      @client = Net::FTP.new
      @client.connect("ws.udag.de",21)
      @client.login(ENV['FTP_USER'],ENV['FTP_PASSWORD'])
      @client.chdir(ENV['FTP_EXPORT_DIR'])
      @client.passive = true
      @filenames = []
    end

    def read_xml_files
      init_import unless Rails.env.test?
      xml_files = (Dir.glob "#{ENV['LOCAL_ESTATE_EXPORT_DIR']}**/*.xml") || (Dir.glob "#{ENV['LOCAL_ESTATE_EXPORT_DIR']}*.xml")
      FTP_IMPORTER_LOGGER.info "Found #{xml_files.count} XML Files"
      xml_files.any? ? xml_files.map { |file| File.read(file) } : []
    end

    def new_file_available?
      FTP_IMPORTER_LOGGER.info "Found #{@client.nlst("*.zip").count} new estate exports."
      @client.nlst("*.zip").any?
    end

    def set_files_to_download
      @filenames = @client.nlst("*.zip")
    end

    def clean_up_local_tmp_dir
      FileUtils.rm_rf(Dir.glob("#{ENV['LOCAL_ESTATE_EXPORT_DIR']}*")) if Rails.env.production?
    end

    protected

    def init_import
      download_estate_exports
      extract_estate_exports
      clean_up_ftp_dir
    end

    def download_estate_exports
      Dir.mkdir(ENV['LOCAL_ESTATE_EXPORT_DIR']) unless File.exists?(ENV['LOCAL_ESTATE_EXPORT_DIR'])
      @filenames.each do |filename|
        @client.getbinaryfile(filename, ENV['LOCAL_ESTATE_EXPORT_DIR'] + filename ) unless File.exists?(ENV['LOCAL_ESTATE_EXPORT_DIR'] + filename)
        FTP_IMPORTER_LOGGER.info "Downloaded #{filename}."
      end
    end

    def clean_up_ftp_dir
      return @client.close unless ENV['ENVIRONMENT'] == 'production'
      @client.nlst("*.zip").each do |file|
        @client.delete(file)
      end
      @client.close
    end

    def extract_estate_exports
        @filenames.each do |filename|
          begin
            Zip::File.open(ENV['LOCAL_ESTATE_EXPORT_DIR'] + filename) do |zip_file|
              zip_file.each do |entry|
                entry.extract(ENV['LOCAL_ESTATE_EXPORT_DIR'] + entry.name) unless File.exists?(ENV['LOCAL_ESTATE_EXPORT_DIR'] + entry.name)
              end
              FTP_IMPORTER_LOGGER.info "Extracted #{filename}."
            end
          rescue
            FTP_IMPORTER_LOGGER.info "Could not extract #{filename}."
            next
          end
        end
    end

  end
end
