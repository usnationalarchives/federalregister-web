Date::DATE_FORMATS[:default] = "%m/%d/%Y"
# "Friday, April 22nd, 2011"
Date::DATE_FORMATS[:formal] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}, %Y") }

Time::DATE_FORMATS[:date] = "%m/%d/%Y"
Time::DATE_FORMATS[:default] = "%m/%d/%Y at %I:%M %p"
Time::DATE_FORMATS[:datetime_with_zone] = "%m/%d/%Y at %I:%M %p %Z"

# "Friday, April 22nd, 2011 at 1:30 PM"
Time::DATE_FORMATS[:formal_with_time] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}, %Y at %I:%M %p") }
