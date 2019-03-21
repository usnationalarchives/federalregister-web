class EffectiveDatesPresenter

  DAY_DELAY_INTERVALS = [15, 21, 30, 35, 45, 60, 90]
  def initialize(start_date:, end_date:)
    @start_date = start_date
    @end_date   = end_date
  end

  def publication_dates
    effective_dates_and_time_periods.map do |publication_date, time_periods|
      PublicationDate.new(publication_date, time_periods)
    end
  end

  def govinfo_table_html_url
    "https://www.govinfo.gov/content/pkg/FR-#{first_monthly_publication_date}/html/FR-#{first_monthly_publication_date}-ReaderAids.htm"
  end

  def govinfo_table_pdf_url
    "https://www.govinfo.gov/content/pkg/FR-#{first_monthly_publication_date}/pdf/FR-#{first_monthly_publication_date}-ReaderAids.pdf"
  end


  private

  attr_reader :start_date, :end_date

  def first_monthly_publication_date
    FederalRegister::Facet::Document::Daily.search(
      conditions: {
        publication_date: {
          gte: start_date.beginning_of_month.to_s(:iso),
          lte: (start_date.beginning_of_month + 2.weeks).to_s(:iso)
        }
      }
    ).
      detect{|x| x.count > 0}.
      slug
  end

  def issue_should_be_available?(date)
    ! (date.wday == 0 || date.wday == 6) &&
    ! Holiday.is_a_holiday?(date)
  end

  def effective_dates_and_time_periods
    EffectiveDate.find_by_start_date_and_end_date(start_date, end_date)
  end

  class PublicationDate

    def initialize(publication_date, time_periods)
      @publication_date = publication_date
      @time_periods = time_periods
    end

    def to_s
      Date.parse(publication_date).to_s(:month_day)
    end

    def day_delay_intervals
      EffectiveDatesPresenter::DAY_DELAY_INTERVALS.map do |interval|
        data = time_periods.fetch(interval.to_s)
        DayDelayInterval.new(
          Date.parse(data.fetch('date')),
          data.fetch('delay_reasons'),
          interval
        )
      end
    end


    private

    attr_reader :publication_date, :time_periods

    class DayDelayInterval

      attr_reader :date

      def initialize(date, delay_reasons, interval)
        @date          = date
        @delay_reasons = delay_reasons
        @interval      = interval
      end

      def to_s
        date.to_s(:month_day)
      end

      def tooltip_text
        "#{interval} Days After Publication#{delay_text}"
      end

      def delay?
        delay_reasons.present?
      end

      private

      attr_reader :delay_reasons, :interval

      def delay_text
        if delay_reasons.present?
          " (Delay due to #{delay_reasons.to_sentence})"
        end
      end

    end


  end

end
