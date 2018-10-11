Date::DATE_FORMATS[:default] = "%m/%d/%Y"
Date::DATE_FORMATS[:date] = "%m/%d/%Y"
Date::DATE_FORMATS[:day_date] = "%A %d"
Date::DATE_FORMATS[:month_day_year] = "%B %-d, %Y"
Date::DATE_FORMATS[:month_year] = "%B %Y"
Date::DATE_FORMATS[:ymd] = "%Y/%m/%d"
Date::DATE_FORMATS[:ymd_dash] = "%Y-%m-%d"
Date::DATE_FORMATS[:year_month] = "%Y/%m"


# Apr. 22nd, 2011
Date::DATE_FORMATS[:shorter_ordinal] = lambda { |time| time.strftime("%b #{time.day.ordinalize}, %Y") }
# Apr. 22, 2011
Date::DATE_FORMATS[:short_month_day_year] = "%b %-d, %Y"

# "Friday, April 22nd, 2011"
Date::DATE_FORMATS[:formal] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}, %Y") }
Date::DATE_FORMATS[:formal_no_year] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}") }

# "Friday, April 22, 2011"
Date::DATE_FORMATS[:formal_wo_ordinal] = "%A, %B %-d, %Y"
Date::DATE_FORMATS[:formal_wo_ordinal_no_year] = "%A, %B %d"



Time::DATE_FORMATS[:default] = "%m/%d/%Y at %l:%M %P"
Time::DATE_FORMATS[:date] = "%m/%d/%Y"
Time::DATE_FORMATS[:datetime] = "%m/%d/%Y at %l:%M %P"
Time::DATE_FORMATS[:datetime_with_zone] = "%m/%d/%Y at %l:%M %p %z"

# "Friday, April 22nd, 2011 at 1:30 PM"
Time::DATE_FORMATS[:formal_with_time] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}, %Y at %l:%M %p") }
Time::DATE_FORMATS[:time_then_date] = "%l:%M %p on %A, %B %-d, %Y"
