Date::DATE_FORMATS[:default] = "%m/%d/%Y"
Date::DATE_FORMATS[:date] = "%m/%d/%Y"
Date::DATE_FORMATS[:day_date] = "%A %d"
Date::DATE_FORMATS[:month_year] = "%B %Y"
Date::DATE_FORMATS[:year_month_day] = "%Y-%m-%d"

# Apr. 22nd, 2011
Date::DATE_FORMATS[:shorter_ordinal] = lambda { |time| time.strftime("%b #{time.day.ordinalize}, %Y") }


# "Friday, April 22nd, 2011"
Date::DATE_FORMATS[:formal] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}, %Y") }
Date::DATE_FORMATS[:formal_no_year] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}") }

Time::DATE_FORMATS[:default] = "%m/%d/%Y at %I:%M %P"
Time::DATE_FORMATS[:date] = "%m/%d/%Y"
Time::DATE_FORMATS[:datetime] = "%m/%d/%Y at %I:%M %P"
Time::DATE_FORMATS[:datetime_with_zone] = "%m/%d/%Y at %I:%M %p %Z"

# "Friday, April 22nd, 2011 at 1:30 PM"
Time::DATE_FORMATS[:formal_with_time] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}, %Y at %I:%M %p") }
Time::DATE_FORMATS[:time_then_date] = lambda { |time| time.strftime("%I:%M %p, on %A, %B #{time.day.ordinalize}, %Y") }
