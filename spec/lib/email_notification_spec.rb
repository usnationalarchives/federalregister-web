require 'spec_helper'

describe EmailNotification do
  it "has valid email highlight definitions" do
    EmailNotification::NOTIFICATIONS.each do |definition|
      expect( EmailNotification.valid_definition?(definition) ).to eq(true), "expected valid defintion for #{definition.inspect}, instead got invalid definition"
    end
  end

  describe ".notifications" do
    it "returns an array of active notifications" do
      notifications = EmailNotification.notifications

      expect( notifications ).to be_kind_of(Array)
      expect( notifications.size ).to eq(2)
    end
  end

  describe ".find" do
    let(:awesome_notification) { FactoryGirl.build(:email_notification, :name => "awesome_notification") }

    before(:each) do
      allow(EmailNotification).to receive(:notifications).and_return( [awesome_notification] )
    end

    it "returns the requested notification when it exists" do
      expect( EmailNotification.find(awesome_notification.name) ).to be(awesome_notification)
    end

    it "returns nil when the requested notification does not exist" do
      expect( EmailNotification.find('not_so_awesome_notification') ).to be(nil)
    end

    context "disabled notification" do
      before(:each) do
        awesome_notification.enabled = false
      end

      it "returns nil for a disabled notification unless proper option is passed" do
        expect( EmailNotification.find(awesome_notification.name) ).to be(nil)
      end

      it "returns the notification for a disabled notification when proper option is passed" do
        expect( EmailNotification.find(awesome_notification.name, :disabled => true) ).to be(awesome_notification)
      end
    end
  end
end
