A Ruby Calendar that can be used with Sinatra Rails or any Ruby framework 
===============

A Simple Ruby Calendar That can be used to display events

## Basic use

calendar = Calendar::Base.new()
## To display the calendar in a web browser
calendar.display

## To parse year, month, data 

data = {20 => ["Make that pull request and fix some bugs", "Push the change back on Github"], 14 => "Eat breakfast"}

calendar = Calendar::Base.new(Time.now.year, Time.now.month, data)

## Display it to a web browser 
calendar.display

If you want to change the default templates and to display the previous month link or next month link

template = {
  			'table-open' => '<table class="calendar">',
				'heading-row-start' => '<tr>',
				'heading-previous-cell' => '<th><a href="{previous-url}">&lt;&lt;</a></th>',
				'heading-title-cell' => '<th colspan="{colspan}">{heading}</th>',
				'heading-next-cell'  => '<th><a href="{next-url}">&gt;&gt;</a></th>',
				'heading-row-end'	 => '</tr>',
				'week-row-start'	 => '<tr>',
				'week-day-cell'		 => '<th class="day-header">{week-day}</th>',
				'week-row-end'		 => '</tr>',
				'cal-row-start'		 => '<tr>',
				'cal-cell-start-today' => '<td>',
				'cal-cell-start'	=> '<td>',
				'cal-cell-content'	 => '<span class="day-listing">{day}</span>{content}',
				'cal-cell-content-today' => '<div class="today"><span class="day-listing">{day}</span>{content}</div>',
				'cal-cell-no-content' => '<span class="day-listing">{day}</span>',
				'cal-cell-no-content-today' => '<div class="today"><span class="day-listing">{day}</span></div>',
				'cal-cell-blank' => '&nbsp;',
				'cal-cell-end' => '</td>',
				'cal-cell-end-today' => '</td>',
				'cal-row-end' => '</tr>',
				'table-close' => '</table>' 
			}
      
conf = {"start_day" => :sunday, "next_prev" => true, "show_next_prev" => true, "next_prev_url" => "/your_url/", "template" => template}

calendar = Calendar::Base.new(conf)
calendar.display('', '', data)