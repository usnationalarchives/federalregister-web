require 'yaml'
require 'mysql2'
require 'redis'
require 'active_support/core_ext/date/calculations'

class FederalRegisterStats
  attr_reader :beginning_of_month,
    :beginning_of_year,
    :date,
    :end_of_month,
    :mysql,
    :redis

  def initialize(date, env='production')
    @date = Date.parse(date)
    @beginning_of_year = @date.beginning_of_year
    @beginning_of_month = @date.beginning_of_month
    @end_of_month = @date.end_of_month

    credentials = YAML.load_file('../config/database.yml')[env]

    @mysql = Mysql2::Client.new(
      :host => credentials['host'],
      :username => credentials['username'],
      :password => credentials['password'],
      :database => credentials['database']
    )

    @redis = Redis.new
  end

  def generate
    puts "Total # of MyFR Accounts: #{users}"
    puts "YTD # of MyFR Accounts: #{users(beginning_of_year, end_of_month)}"
    puts "New MyFR Accounts in #{beginning_of_month.strftime('%B')}: #{users(beginning_of_month, end_of_month)}"

    puts "Total # of Subscriptions:  #{subscriptions}"
    puts "YTD # of Subscriptions:  #{subscriptions(beginning_of_year, end_of_month)}"
    puts "New Subscriptions in #{beginning_of_month.strftime('%B')}: #{subscriptions(beginning_of_month, end_of_month)}"

    puts "Total # of Comments in #{beginning_of_month.strftime('%B')} via Regulations.gov API integration:  #{comments_submitted}"
    puts "Total # of Comment Forms opened in #{beginning_of_month.strftime('%B')} on FederalRegister.gov:  #{comment_forms_opened}"
  end

  private

  def users(start_date = nil, end_date = nil)
    query = "SELECT COUNT(*) as count FROM users"

    if start_date
      query = "#{query} WHERE created_at >= '#{start_date.to_s(:db)}' && created_at <= '#{end_date.to_s(:db)}'"
    end

    mysql.query(query).first["count"]
  end

  def subscriptions(start_date = nil, end_date = nil)
    query = "SELECT COUNT(*) as count FROM subscriptions"
    where_clause = "WHERE confirmed_at IS NOT NULL"

    if start_date
      where_clause = "#{where_clause} AND created_at >= '#{start_date.to_s(:db)}' AND created_at <= '#{end_date.to_s(:db)}'"
    end

    query = [query, where_clause].join(' ')

    mysql.query(query).first["count"]
  end

  def comments_submitted
    redis.keys("myFR:comment_post_success:#{redisize_date(beginning_of_month)}").map{|k| Hash[redis.zrangebyscore(k, 0, 1000, :with_scores => true)].values}.flatten.sum.to_i
  end

  def comment_forms_opened
    redis.keys("myFR:comment_opened:#{redisize_date(beginning_of_month)}").map{|k| Hash[redis.zrangebyscore(k, 0, 1000, :with_scores => true)].values}.flatten.sum.to_i
  end

  def redisize_date(date)
    date.strftime('%Y-%m*')
  end
end
