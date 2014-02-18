Date::DATE_FORMATS[:date] = "%m/%d/%Y"

# Apr. 22nd, 2011
Date::DATE_FORMATS[:shorter_ordinal] = lambda { |time| time.strftime("%b #{time.day.ordinalize}, %Y") }

# "Friday, April 22nd, 2011"
Date::DATE_FORMATS[:formal] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}, %Y") }

Time::DATE_FORMATS[:date] = "%m/%d/%Y"
Time::DATE_FORMATS[:datetime] = "%m/%d/%Y at %I:%M %P"

# "Friday, April 22nd, 2011 at 1:30 PM"
Time::DATE_FORMATS[:formal_with_time] = lambda { |time| time.strftime("%A, %B #{time.day.ordinalize}, %Y at %I:%M %p") }
