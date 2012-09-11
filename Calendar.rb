module Calendar
	class Base 
		##
		# @param array conf Contains the instance variables to be initialized
		# 
		
		def initialize(conf)
			@lang = "English"
			@month_type = "short"
			@day_type = "long"
    
			@template = ""
      
			@show_next_prev = false
			@next_prev_url = ""
			@current_month
			@month_name
			@next_month
			@next_prev = false
			@current_day
			@current_year
			@start_day = "sunday"
			
			conf.each do |key, val|
				self.instance_variable_set("@#{key}", val)
			end
		end
		
		##
		# To generate a calendar
		# @param string month the starting month
		# @param string year the starting year
		# @param string data events to be displayed on the calendar
		
		def display(month = "", year = "", data = [])
			
			if month = "" || month.is_a?
				month = Time.now.month
			end
			
			if year == "" || year.is_a?
				year = Time.now.year
			end
			
			if month.size == 1
				month = "0#{month}"
			end
			
			if year.size == 1
				year = "200#{year}"
			elsif year.size == 2
				year = "20#{year}"
			end
			
			ajusted_days = ajust_date(month, year)
			month = ajusted_days[:month]
			year  = ajusted_days[:year]
			# Total days in a month
			number_of_days = total_days(month, year)
			
			# Set the starting day of the week
			
			start_days = {:sunday => 0, :monday => 1, :tuesday => 2, :wednesday => 3, :thursday => 4, :friday => 5, :saturday => 6}
			
			start_day = start_days[@start_day].nil? ? 0 : start_days[@start_day]
			
			# Set the starting day number
			date = Time.mktime(Time.now.year, Time.now.month, 1, 12, 0, 0) # Time.local(Time.now.year, Time.now.month, 12)
			day = start_day + 1 - date.wday
			
			while day > 1
				day -= 7
			end
			
			current_year = Time.now.year
			cur_month = Time.now.month
			current_day   = Time.now.day
			
			current_month = (current_year == year && cur_month == month) ? true : false
			
			@temp = @template == "" ? default_template : @template  # Generating the template data array
			
			# Build the table
			out = "#{@temp['table-open']}"
			
			out += "#{@temp['heading-row-start']}\n"
			
			# previous month link
			
			if @next_prev
				@next_prev_url = @next_prev_url.gsub("/(.+?)\\*$/", "\\1/")
		
				aj_date = ajust_date(month - 1, year)
				out += @temp['heading-previous-cell'].gsub("{previous-url}", "#{@next_prev_url}#{aj_date[:year]}-#{aj_date[:month]}\n")
				
			end
			
			# Heading containing the month/year
			col_span = @show_next_prev ? 5 : 7
			
			@temp["heading-title-cell"] = @temp["heading-title-cell"].gsub("{colspan}", col_span.to_s)
			@temp["heading-title-cell"] = @temp["heading-title-cell"].gsub("{heading}", "#{month_name(month).to_s}&nbsp;#{year.to_s}")
			
			out += "#{@temp["heading-title-cell"]}\n"
			
			# next month link
			
			if @show_next_prev
				@next_prev_url = @next_prev_url.gsub("/(.+?)\\*$/", "\\1/")
				
				aj_date = ajust_date(month + 1, year)
				out += @temp['heading-next-cell'].gsub("{next-url}", "#{@next_prev_url}#{aj_date[:year]}-#{aj_date[:month]}\n")
			end
			
			out += "\n#{@temp['heading-row-end']}\n"
			
			# Write the cells containging the days of the week
			
			out += "\n#{@temp['week-row-start']}\n"
			
			days_names = name_of_the_days()
			
			7.times do | i |
				out += @temp['week-day-cell'].gsub("{week-day}", days_names[(start_day + i) % 7])
			end
			
			out += "\n#{@temp['week-row-end']}\n"
			
			# Build the main body of the calendar
			
			while day <= number_of_days 
				
				out += "\n#{@temp['cal-row-start']}\n"
				
				7.times do | i |
					out += current_month && day == current_day ? @temp['cal-cell-start-today'] : @temp['cal-cell-start']
					
					if day > 0 && day <= number_of_days
						if data[day]
							# cell with content
							temp = current_month && day == current_day ? @temp['cal-cell-content-today'] : @temp['cal-cell-content']
							
							# if there is more than on event per day
							if data[day].is_a?(Array)
								more_events = ""
								
								data[day].each do | key |
									more_events += "<p class=\"more\">&bull;&nbsp;#{key}</p>"
								end
								out += temp.gsub("{day}", day.to_s).gsub("{content}", more_events)
							else
								out += temp.gsub("{day}", day.to_s).gsub("{content}", data[day].to_s)
							end
						else
							# cell with no content
							temp = current_month && day == current_day ? @temp['cal-cell-no-content-today'] : @temp['cal-cell-no-content'] 
							out += temp.gsub("{day}", day.to_s)
						end
					else
						out += @temp['cal-cell-blank'] # blank cells
					end
					out += current_month && day == current_day ? "#{@temp['cal-cell-end-today']}" : "#{@temp['cal-cell-end']}"
					day = day + 1
				end
				out += "\n#{@temp['cal-row-end']}\n"
			end
			out += "\n#{@temp['table-close']}"
		end
		
		def name_of_the_days(day_type = "")
			
			if day_type != ''
				@day_type = day_type
			end
			
			if @day_type == "long"
				day_names = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']
			elsif @day_type == "short"
				day_names = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
			else
				day_names = ['su', 'mo', 'tu', 'we', 'th', 'fr', 'sa']
			end
			
			days = []
			
			day_names.each do | day_name |
				days << day_name.capitalize!
			end
			days
		end
		
		##
		# Total days in a month
		# @param int month Month in integer
		# @param int year Year given in integer
		# @return integer
		
		def total_days(month, year)
			days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
			
			if month < 1 || month > 12
				return 0
			end
			
			if month == 2
				if year % 4 == 0
					return 29
				end
			end
			days[month - 1]
		end
		
		##
		# Set default Template
		# This is used in the event that user has not created their own template
		# @return array
		
		def default_template
			{
				'table-open' => '<table border="0" cellpadding="4" cellspacing="0" class="calendar">',
				'heading-row-start' => '<tr>',
				'heading-previous-cell' => '<th><a href="{previous-url}">&lt;&lt;</a></th>',
				'heading-title-cell' => '<th colspan="{colspan}">{heading}</th>',
				'heading-next-cell'  => '<th><a href="{next-url}">&gt;&gt;</a></th>',
				'heading-row-end'	 => '</tr>',
				'week-row-start'	 => '<tr>',
				'week-day-cell'		 => '<td>{week-day}</td>',
				'week-row-end'		 => '</tr>',
				'cal-row-start'		 => '<tr>',
				'cal-cell-start-today' => '<td>',
				'cal-cell-start'	=> '<td>',
				'cal-cell-content'	 => '<a href="{content}"><strong>&bull;{day}</strong></a>',
				'cal-cell-content-today' => '<a href="{content}">{day}</a>',
				'cal-cell-no-content' => '{day}',
				'cal-cell-no-content-today' => '<strong>{day}</strong>',
				'cal-cell-blank' => '&nbsp;',
				'cal-cell-end' => '</td>',
				'cal-cell-end-today' => '</td>',
				'cal-row-end' => '</tr>',
				'table-close' => '</table>' 
			}
		end
		
		##
		# Get Month name
		# Generrates a textual month based on the numeric month provided
		# @param int month
		# @return string
		
		def month_name(month)
			if @month_type == "short"
				month_names = { 01 => "jan", 02 => "feb", 03 => "mar", 04 => "apr", 05 => "may", 06 => "jun", 07 => "jul", 8 => "aug",
					9 => "sep",
					10 => "oct",
					11 => "nov",
					12 => "dec"
				}
			else 
				month_names = { 01 => "january", 02 => "february", 03 => "march", 04 => "april", 05 => "may", 06 => "june", 07 => "july",
					8 => "august",
					9 => "september",
					10 => "october",
					11 => "november",
					12 => "december"
				}
			end
			month = month_names[month].capitalize!
		end
		
		##
		# Ajust Date
		# Makes sure that we have a valid month/year
		# For example, if you submit 13 as the month, the year will increment and the month will become january
		
		def ajust_date(month, year)
			date = {}
			date[:month] = month 
			date[:year]  = year
			
			while date[:month] > 12
				date[:month] -= 12
				date[:year] + 1
			end
			
			while date[:month] <= 0
				date[:month] += 12
				date[:year] - 1
			end
			
			if date[:month].size == 1
				date[:month] = "0#{date[:month]}"
			end
			date 
		end
    
	end
end