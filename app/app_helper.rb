module AppHelper
	module_function

	def parse_date_string(date_string, format_string = "yyyy-MM-dd HH:mm:ss z")
		date_formatter = NSDateFormatter.alloc.init
		date_formatter.dateFormat = format_string
		date = date_formatter.dateFromString date_string
		date
	end

	def current_user
		App::Persistence[:current_user]
	end

	def current_user=(user)
		App::Persistence[:current_user] = user
	end
end