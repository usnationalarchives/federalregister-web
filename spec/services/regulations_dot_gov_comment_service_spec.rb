require 'spec_helper'

RSpec.describe RegulationsDotGovCommentService do
  let(:comment_service) {
    ip = '192.168.0.1'
    args = {document_number: '2018-00001'}
    RegulationsDotGovCommentService.new(ip, args)
  }

  context "determining API key for comment submission" do
    context "determining API key for submission" do
      it "#api_key returns the primary comment key for IP addresses with less than #{RegulationsDotGovCommentService::HOURLY_SUBMISSION_LIMIT} submissions in the last hour", :isolate_redis do
        expect(comment_service.api_key).to eq('AAABBBCCC')
      end

      context "previous hour does not affect this hour" do
        it "#api_key returns the primary comment key for IP addresses with less than #{RegulationsDotGovCommentService::HOURLY_SUBMISSION_LIMIT} submissions in the last hour", :isolate_redis do
          previous_hour_tracking_key = comment_service.hourly_comment_tracking_key.gsub(
            ":#{Time.current.hour}:",
            ":#{(Time.current - 1.hour).hour}:"
          )
          $redis.incrby previous_hour_tracking_key, RegulationsDotGovCommentService::HOURLY_SUBMISSION_LIMIT

          expect(comment_service.api_key).to eq('AAABBBCCC')
        end
      end

      it "#api_key returns the secondary comment key for IP addresses with meet or exceed #{RegulationsDotGovCommentService::HOURLY_SUBMISSION_LIMIT} submissions in the last hour", :isolate_redis do
        $redis.incrby comment_service.hourly_comment_tracking_key, RegulationsDotGovCommentService::HOURLY_SUBMISSION_LIMIT
        expect(comment_service.api_key).to eq('XXXYYYZZZ')
      end
    end
  end

  context "recording comment submission counts" do
    it "#increment_comment_tracking_keys increments the hourly tracking key by 1", :isolate_redis do
      expect{
        comment_service.increment_comment_tracking_keys
      }.to change{
        comment_service.hourly_requests_for_ip
      }.from(0).to(1)
    end

    it "#increment_comment_tracking_keys increments the bulk tracking key by 10 when the hourly limit is reached", :isolate_redis do
      $redis.incrby comment_service.hourly_comment_tracking_key, RegulationsDotGovCommentService::HOURLY_SUBMISSION_LIMIT - 1

      expect{
        comment_service.increment_comment_tracking_keys
      }.to change{
        comment_service.hourly_requests_for_ip
      }.from(9).to(10)

      expect(
        comment_service.daily_bulk_requests_for_ip
      ).to eq(10)
    end

    it "#increment_comment_tracking_keys increments the bulk tracking key by 1 when over the hourly limit", :isolate_redis do
      $redis.incrby comment_service.hourly_comment_tracking_key, RegulationsDotGovCommentService::HOURLY_SUBMISSION_LIMIT
      $redis.incrby comment_service.bulk_totals_comment_tracking_key, RegulationsDotGovCommentService::HOURLY_SUBMISSION_LIMIT

      comment_service.increment_comment_tracking_keys

      expect(
        comment_service.daily_bulk_requests_for_ip
      ).to eq(11)
    end

    it "#increment_comment_tracking_keys works as expected across hour boundaries", :isolate_redis do
      # set up IP to have gone over the submission limit in the past and be on the verge of exceeding it again
      comments_in_previous_hour = RegulationsDotGovCommentService::HOURLY_SUBMISSION_LIMIT + 10
      Timecop.freeze(Time.current-1.hour) do
        $redis.incrby(
          comment_service.hourly_comment_tracking_key,
          comments_in_previous_hour
        )
        $redis.incrby(
          comment_service.bulk_totals_comment_tracking_key,
          comments_in_previous_hour
        )
      end
      # comments so far this hour
      $redis.incrby(
        comment_service.hourly_comment_tracking_key,
        RegulationsDotGovCommentService::HOURLY_SUBMISSION_LIMIT - 1
      )

      # resets hourly
      expect{
        comment_service.increment_comment_tracking_keys
      }.to change{
        comment_service.hourly_requests_for_ip
      }.from(9).to(10)

      # cumulative for the day
      expect(
        comment_service.daily_bulk_requests_for_ip
      ).to eq(
        RegulationsDotGovCommentService::HOURLY_SUBMISSION_LIMIT + comments_in_previous_hour
      )
    end
  end

  context "over rate limit errors" do
    before(:each) do
      allow(RegulationsDotGov::Client).to receive(:api_key).and_return('XXXX')
      client = RegulationsDotGov::Client.new
      allow(comment_service).to receive(:comment_form).and_return(
        double('comment_form',
          document_id: '1234', fields: [], attachments: [], client: client
        )
      )
      allow_any_instance_of(Comment).to receive(:document).and_return(
        double('document', comment_url: 'https://example.com')
      )
    end

    it "notifies us if the submission is not bulk" do
      allow(comment_service).to receive(:bulk_submission?).and_return(false)
      allow(comment_service).to receive(:submit_comment).and_raise(RegulationsDotGov::Client::OverRateLimit.new('', 429))

      expect(Honeybadger).to receive(:notify)
      comment_service.send_to_regulations_dot_gov
    end

    it "does not notify us if the submission is bulk" do
      allow(comment_service).to receive(:bulk_submission?).and_return(true)
      allow(comment_service).to receive(:submit_comment).and_raise(RegulationsDotGov::Client::OverRateLimit.new('', 429))

      expect(Honeybadger).not_to receive(:notify)
      comment_service.send_to_regulations_dot_gov
    end
  end
end
