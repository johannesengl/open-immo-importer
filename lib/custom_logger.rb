class CustomLogger

	@logger

	def initialize(logger_name_or_token)
		if Rails.env.development? || Rails.env.test?
			path = "#{Rails.root}/log/"+ logger_name_or_token + ".log"
			@logger = Logger.new(path)
			@logger.level = Logger::INFO
		else
			@logger = Le.new(logger_name_or_token, ssl: true)
		end
	end

	def info(text)
		@logger.info(text)
	end

	def warn(text)
		@logger.warn(text)
	end
end
