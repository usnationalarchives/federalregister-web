require File.dirname(__FILE__) + '/../spec_helper'

# Create FakeController to test UserDataPersistor in Isolation
class FakeController < ApplicationController
  include UserDataPersistor
  skip_before_filter :authenticate_user!

  def test
    clipping = Clipping.new
    clipping.save!(validate: false)
  end
end

describe FakeController do

  def add_arbitrary_route(route, controller_action)
    test_routes = Proc.new do
      get route => controller_action
    end
    Rails.application.routes.eval_block(test_routes)
  end

end
