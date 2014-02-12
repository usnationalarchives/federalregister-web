module Capybara::RSpecMatchers
  RSpec::Matchers.define :have_meta do |name, expected|
    match do |actual|
      has_css?("meta[name='#{name}'][content='#{expected}']", visible: false)
    end

    failure_message_for_should do |actual|
      actual = first("meta[name='#{name}']")
      if actual
        "expected that meta #{name} would have content='#{expected}' but was '#{actual[:content]}'"
      else
        "expected that meta #{name} would exist with content='#{expected}'"
      end
    end
  end

  RSpec::Matchers.define :have_title do |expected|
    match do |actual|
      has_css?("title", text: expected, visible: false)
    end

    failure_message_for_should do |actual|
      actual = first("title")
      if actual
        "expected that title would have been '#{expected}' but was '#{actual.text}'"
      else
        "expected that title would exist with '#{expected}'"
      end
    end
  end
end
